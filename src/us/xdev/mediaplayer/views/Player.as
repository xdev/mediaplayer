package us.xdev.mediaplayer.views
{
	//Flash Classes
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.FullScreenEvent;
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.geom.Rectangle;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	
	//A12 Classes
	import com.a12.util.Utils;
	import com.a12.util.LoadMovie;
	import com.a12.util.XMLLoader;
	import com.a12.util.CustomEvent;
	import com.a12.modules.mediaplayback.*;
	
	//3rd party Classes
	import gs.TweenLite;
	import com.carlcalderon.arthropod.Debug;
	
	//Application Classes	
	import us.xdev.mediaplayer.ThumbGrid;

	
	public class Player
	{
		[Embed(source='library.swf', symbol='mediaplayer_icons')] 
		private var mediaplayer_icons:Class;

		[Embed(source='library.swf', symbol='icon_timer')] 
		private var icon_timer:Class;
		
		private var timestamp:Number;
		
		
		
		public function Player(model:IModel)
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			stage.addEventListener(Event.RESIZE, onResize,false,0,true);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen,false,0,true);
			
			//listen to the mouse event to hide or show ui
			stage.addEventListener(Event.MOUSE_LEAVE, mouseListener,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseListener,false,0,true);
			//track keyboard navigation
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener,false,0,true);
			
		}
		
		private function mouseListener(e:Event):void
		{
			if(e.type == MouseEvent.MOUSE_MOVE){
				showUI();
			}
			if(e.type == Event.MOUSE_LEAVE){
				hideUI();
			}
		}
		
		private function showUI():void
		{
			//start timer to hideUI
			clearTimeout(uiInterval);
			uiInterval = setTimeout(hideUI,3000);
			TweenLite.to(MovieClip(stage.getChildByName('ui')),0.3,{alpha:1.0});
			
			if(MP != null){
				var mc = Utils.$(MP._view.ref,'controls');
				TweenLite.to(MovieClip(mc),0.3,{alpha:1.0});
			}
		}
		
		private function hideUI():void
		{
			clearTimeout(uiInterval);
			TweenLite.to(MovieClip(stage.getChildByName('ui')),0.5,{alpha:0.0});
			
			if(MP != null){
				var mc = Utils.$(MP._view.ref,'controls');
				TweenLite.to(MovieClip(mc),0.5,{alpha:0.0});
			}
		}
		
		
		private function toggleThumbs(fade:Boolean=true):void
		{
			flagThumbs = !flagThumbs;

			//Debug.log('toggleThumbs - ' + flagThumbs.toString());

			var ui = Utils.$(stage,'ui');
			var mc = Utils.$(ui,'thumbnail');

			var c = Utils.$(stage,'thumbs');
			var slide = Utils.$(stage,'slide');	

			if(flagThumbs){
				//tell it to activate

				//Debug.log('in true section');

				TweenLite.to(MovieClip(slide),0.05,{alpha:0.0});
				//slide.alpha = 0.0;

				stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyListener,false);


				//swap depth with ui
				stage.setChildIndex(c,stage.numChildren - 2);
				if(thumbClass == null){
					c.alpha = 0.0;					
					thumbClass = new ThumbGrid(c,this,slideA,configObj);
					thumbClass.addEventListener('onThumbClick',handleThumb,false,0,true);
					thumbClass.setIndex(slideIndex);


				}else{
					thumbClass.setIndex(slideIndex);
					c.alpha = 0.0;
					c.visible = true;					
				}

				TweenLite.to(c,0.5,{alpha:1.0});


				//deactivate majority of ui controls
				/*
				c = Utils.$(ui,'toggle');
				c.mouseEnabled = false;
				c.alpha = 0.0;
				*/

				c = Utils.$(ui,'nav_prev');
				c.mouseEnabled = false;
				c.alpha = 0.0;

				c = Utils.$(ui,'nav_next');
				c.mouseEnabled = false;
				c.alpha = 0.0;

				//toggle icon
				mc.gotoAndStop('thumbnail_off');


				//kill slideshow
				flagPlaying = false;
				clearInterval(progressInterval);
				clearTimeout(slideInterval);			
				updateSlideShowState();


				//pause video
				if(MP){
					MP.stop();
				}

			}else{

				//Debug.log('in false section');
				//thumbClass.onKill();
				//thumbClass = null;
				if(fade == true){
					TweenLite.to(MovieClip(slide),0.5,{alpha:1.0});
				}

				if(thumbClass){
					c.visible = false;
				}

				if(slideMax > 1){
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener,false,0,true);
				}

				//toggle icon
				mc.gotoAndStop('thumbnail');



				//reactivate stuffs

				//c = Utils.$(ui,'toggle');
				//c.mouseEnabled = true;
				//c.alpha = 1.0;

				//Debug.log('BREAK!');

				c = Utils.$(ui,'nav_prev');

				c.mouseEnabled = true;
				c.alpha = 1.0;

				//Debug.log(c.toString());

				c = Utils.$(ui,'nav_next');
				c.mouseEnabled = true;
				c.alpha = 1.0;
			}
		}

		private function initVideo(e:Event):void
		{
			var mc = Utils.$(MP._view.ref,'controls');
			mc.alpha = 0.0;
			onResize();
		}
		
		
		private function handleIconsMouse(e:Event):void
		{
			//get the type, process the target
			var mc = e.currentTarget;
			if(mc.name == 'nav_prev' || mc.name == 'nav_next'){
				if(e.type == MouseEvent.MOUSE_OVER){
					TweenLite.to(MovieClip(mc),0.2,{scaleX:1.2,scaleY:1.2});
				}
				if(e.type == MouseEvent.MOUSE_OUT){
					TweenLite.to(MovieClip(mc),0.5,{scaleX:1.0,scaleY:1.0});
				}
				if(e.type == MouseEvent.CLICK){
					advanceSlide(mc.dir);
				}
				
			}
			if(e.type == MouseEvent.CLICK){
				if(mc.name == 'thumbnail'){
					toggleThumbs();
				}
				if(mc.name == 'toggle'){
					toggleSlideShow();
				}
				if(mc.name == 'fullscreen'){
					toggleFullScreen();
				}
			}
		}
		
		private function buildUI():void
		{
			var ui = Utils.createmc(stage,'ui',{alpha:0});
			//this.stage.setChildIndex(ui,1);
			//top bar			
			//full screen, thumbnail, timer/toggle, status
			
			
			//handle mouse over generic
			//handle mouse out generic
			
			var i,mc,xPos;
			
			if(configObj.fullscreen == true){
			
				i = new mediaplayer_icons();
				i.gotoAndStop('fullscreen');
				mc = ui.addChild(i);
				mc.name = 'fullscreen';
				mc.buttonMode = true;
				mc.y = 14;
				mc.addEventListener(MouseEvent.ROLL_OVER,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.ROLL_OUT,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.CLICK,handleIconsMouse,false,0,true);
				mc.xPos = 14;
				xPos = 14;
			
			}
			
			if(configObj.thumbgrid == true){
				i = new mediaplayer_icons();
				i.gotoAndStop('thumbnail');
				mc = ui.addChild(i);
				mc.name = 'thumbnail';
				mc.buttonMode = true;
				mc.y = 14;
				mc.addEventListener(MouseEvent.ROLL_OVER,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.ROLL_OUT,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.CLICK,handleIconsMouse,false,0,true);
				if(xPos == 14){
					mc.xPos = 38;
				}else{
					mc.xPos = 14;
				}
			}
			
			xPos = 6;
			
			if(configObj.slideshow == true){
				i = new icon_timer();
				if(flagPlaying){			
					i.gotoAndStop('pause');
				}else{
					i.gotoAndStop('play');
				}
				mc = ui.addChild(i);
				mc.name = 'toggle';
				mc.buttonMode = true;	
				mc.x = 14;
				mc.y = 14;
				mc.addEventListener(MouseEvent.ROLL_OVER,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.ROLL_OUT,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.CLICK,handleIconsMouse,false,0,true);
				xPos = 28;
			}		
				
			
			
			if(slideMax > 1){
			
				var tf = new TextFormat();
				tf.font = 'Akzidenz Grotesk';
				tf.size = 10;
				tf.color = 0xFFFFFF;
			
				mc = Utils.createmc(ui,'label');
				
				//make back
				//Utils.drawRect(Utils.createmc(mc,'back',{alpha:0.75,y:-3}),60,20,0x404040,1.0);
								
				//make txt,
				Utils.makeTextfield(Utils.createmc(mc,'txt'),'',tf,{width:100});
				mc.x = xPos;
				mc.y = 7;
				
				//do the drop shadow son
				
				mc.filters = [
				new DropShadowFilter
				(
					1,
	                45,
	                0x000000,
	                1.0,
	                1,
	                1,
	                0.8,
	                BitmapFilterQuality.HIGH,
	                false,
	                false)
				];
				
				
				//nav 
				//left, right
				i = new mediaplayer_icons();
				i.gotoAndStop('nav_arrow');
				mc = ui.addChild(i);
				mc.dir = -1;
				mc.name = 'nav_prev';
				mc.x = 15;
				mc.y = 100;
				mc.alpha = 0.75;
				mc.buttonMode = true;
				mc.addEventListener(MouseEvent.MOUSE_OVER,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.MOUSE_OUT,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.CLICK,handleIconsMouse,false,0,true);
			
				i = new mediaplayer_icons();
				i.gotoAndStop('nav_arrow');
				mc = ui.addChild(i);
				mc.dir = 1;
				mc.name = 'nav_next';
				mc.rotation = 180;
				mc.x = 575;
				mc.y = 100;
				mc.alpha = 0.75;
				mc.buttonMode = true;
				mc.addEventListener(MouseEvent.MOUSE_OVER,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.MOUSE_OUT,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.CLICK,handleIconsMouse,false,0,true);
				
				
				
			}
			
			onResize();
			
		}
		
		private function onResize(e:Event = null):void
		{
			var ui = Utils.$(stage,'ui');
			var mc;
			
			mc = Utils.$(ui,'fullscreen');
			if(mc){
				mc.x = stage.stageWidth - mc.xPos;
			}
			
			mc = Utils.$(ui,'thumbnail');
			if(mc){
				mc.x = stage.stageWidth - mc.xPos;
			}
			
			mc = Utils.$(stage,'preload');
			if(mc){
				mc.x = stage.stageWidth/2 - mc.width/2;
				mc.y = stage.stageHeight/2 - 8;
			}
			
			if(slideMax > 1){
				mc = Utils.$(ui,'nav_prev');
				mc.y = Math.floor(stage.stageHeight/2);
			
				mc = Utils.$(ui,'nav_next');
				mc.y = Math.floor(stage.stageHeight/2);
				mc.x = stage.stageWidth - 15;
			}
			
			scaleSlide();
			
		}
		
		private function onFullScreen(e:FullScreenEvent):void
		{
			var mc = Utils.$(stage,'ui.fullscreen');
			if(stage.displayState == "fullScreen"){
				mc.gotoAndStop('fullscreen_off');
			}else{
				mc.gotoAndStop('fullscreen');
			}
		}
		
		private function updateSlideShowState():void
		{
			var ui = Utils.$(stage,'ui');
			var l = Utils.$(ui,'toggle');
			if(l){
				var mc = Utils.$(l,'circ')
						
				if(flagPlaying){
					l.gotoAndStop('pause');
					TweenLite.to(mc,0.5,{alpha:1.0});
				}else{
					l.gotoAndStop('play');
					TweenLite.to(mc,0.5,{alpha:0.0});
				}
			}
		}
		
		
		private function viewSlide():void
		{
			var s = Utils.$(stage,'slide');
			if(s){
				stage.removeChild(s);
			}
			var slide = Utils.createmc(stage,'slide',{alpha:0});
			stage.setChildIndex(slide,0);
			var holder = Utils.createmc(slide,'holder');

			clearTimeout(preloadInterval);
			clearInterval(progressInterval);

			//ExternalInterface.call('viewSlide',slideIndex);
			sendExternal('viewSlide',[slideIndex]);

			if(MP){
				MP._view.removeEventListener('updateSize', onResize, false);
				MP.kill();
				MP = null;
			}

			if(slideA[slideIndex].mode == 'media'){
				var obj = {hasView:true,still:slideA[slideIndex].still};
				if(obj.still){
					//obj.paused = true;
				}

				//Consider overlay centered video controls while in fullscreen				
				MP = new com.a12.modules.mediaplayback.MediaPlayback(holder,slideA[slideIndex].file,obj);
				MP._view.addEventListener('updateSize', onResize, false, 0, true);
				//MP._view.addEventListener('onStill', onResize, false, 0, true);
				//_model.b
				MP._model.b.addEventListener('onTransportChange',handleTransport,false,0,true);

				flagPlaying = false;
				updateSlideShowState();
				revealSlide();
			}

			//build preload clip
			var mc = Utils.$(stage,'preload');
			if(mc){
				stage.removeChild(mc);
			}
			mc = Utils.createmc(stage,'preload',{alpha:0.0});
			stage.setChildIndex(mc,0);

			if(slideA[slideIndex].mode == 'image'){

				var tf = new TextFormat();
				tf.font = 'Akzidenz Grotesk';
				tf.size = 10;
				tf.color = 0xFFFFFF;
				tf.align = 'center';

				Utils.makeTextfield(mc,'',tf,{width:100});
				mc.x = stage.stageWidth/2 - mc.width/2;
				mc.y = stage.stageHeight/2 - 8;

				//do the drop shadow son

				mc.filters = [
				new DropShadowFilter
				(
					1,
	                45,
	                0x000000,
	                1.0,
	                1,
	                1,
	                0.8,
	                BitmapFilterQuality.HIGH,
	                false,
	                false)
				];

				var movie = new LoadMovie(holder,slideA[slideIndex].file);
				movie.addEventListener(Event.COMPLETE,revealSlide);	
				movie.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,handlePreload,false,0,true);

				clearTimeout(preloadInterval);
				preloadInterval = setTimeout(renderPreload,500);




			}

			//update the text
			var ui = Utils.$(stage,'ui');

			if(slideMax > 1){
				TextField(Utils.$(ui,'label.txt.displayText')).text = (slideIndex+1) + '/' + slideMax;				

				//var b = Utils.$(ui,'label.back');
				//b.width = tf.textWidth + 5;
			}
			//kick back the listener



		}

		private function renderPreload():void
		{
			clearTimeout(preloadInterval);
			//fade clip in
			var mc = Utils.$(stage,'preload');
			TweenLite.to(mc,0.5,{alpha:1.0});
		}

		private function handlePreload(e:ProgressEvent):void
		{
			var p = Math.ceil(100*(e.bytesLoaded / e.bytesTotal));
			var mc = Utils.$(stage,'preload.displayText');			
			mc.text = p + '%';
			if(p == 100){
				TweenLite.to(mc,0.5,{alpha:0.0});
			}

			//update to clip
		}

		//display preloading of next image?
		private function slideProgressListener(e:ProgressEvent):void
		{
			//renderProgress(p);
		}
		
		private function slideProgressSegment():void
		{
			renderProgress((timestamp - getTimer())/configObj.duration);
		}
		
		private function renderProgress(p:Number):void
		{
			var dO = 3.6;
			var r = 20;
									
			if(progressOffset < 360){
				progressOffset = Math.abs(p * 360);
			}else{
				progressOffset = 0;
			}
			
			var x1 = r*Math.sin(progressOffset*Math.PI/180);
			var x2 = r*Math.sin((progressOffset+dO)*Math.PI/180);
			var y1 = r*Math.cos((progressOffset)*Math.PI/180);
			var y2 = r*Math.cos((progressOffset+dO)*Math.PI/180);
			
			//stage
			var mc = Utils.$(stage,'ui.toggle.circ');			

			mc.graphics.moveTo(0,0);
			mc.graphics.beginFill(0x222222,0.75);//404040
			mc.graphics.lineTo(x1,y1);
			mc.graphics.lineTo(x2,y2);
			mc.graphics.endFill();
			
		}
		
		private function revealSlide(e:Event=null):void
		{
			var slide = Utils.$(stage,'slide');
			TweenLite.to(MovieClip(slide),1.0,{alpha:1.0});
			
			clearTimeout(preloadInterval);
			
			if(flagPlaying){
				
				
				
				if(configObj.slideshow == true){
										
					timestamp = getTimer();

					clearTimeout(slideInterval);
					slideInterval = setTimeout(advanceSlide,configObj.duration,1);

					//
					var mc = Utils.$(stage,'ui.toggle.circ');
					mc.graphics.clear();
					mc.scaleY = -1.0;
					
					
					progressOffset = 0;
					
					if(flagPlaying){
						progressInterval = setInterval(slideProgressSegment,configObj.duration/100);
						slideProgressSegment();
					}
					
				}
			}
			
			slide._width = slide.width;
			slide._height = slide.height;
			
			//set the height and width properties yea?
			
			scaleSlide();
		}	
		
		private function scaleSlide():void
		{
			var mc;
			var slide = Utils.$(stage,'slide');
			if(slide){			
				var imgX = slide._width;
				var imgY = slide._height;
				var m = 100;
				
				if(MP != null)
				{
					var tA = MP.getDimensions();
					imgX = tA.width;
					imgY = tA.height;
					
					if(configObj.scalevideo){
						m = undefined;
					}
				}else{
					if(configObj.scaleimage){
						m = undefined;
					}
				}
			
				var scale = Utils.getScale(imgX,imgY,stage.stageWidth-(configObj.marginX*2),stage.stageHeight-(configObj.marginY*2),'scale',m).x;
												
				scale = scale/100;
				//if we're a image
				if(MP == null){	
					slide.scaleX = scale;
					slide.scaleY = scale;
					slide.x = stage.stageWidth/2 - slide.width/2;
					slide.y = (stage.stageHeight)/2 - slide.height/2;
				}
				
				//if we're a video
				if(MP != null){
					
					MP.setScale(scale*100);
					tA = MP.getDimensions();
					
					slide.x = 0;
					slide.y = 0;
					
					mc = Utils.$(MP._view.ref,'myvideo');
					if(mc != null){
						mc.width = Math.ceil(tA.width*scale);
						mc.height = Math.ceil(tA.height*scale);
						mc.x = stage.stageWidth/2 - mc.width/2;
						mc.y = (stage.stageHeight)/2 - mc.height/2;
					}
					
					mc = Utils.$(MP._view.ref,'still');
					if(mc != null){
						mc.width = Math.ceil(tA.width*scale);
						mc.height = Math.ceil(tA.height*scale);
						mc.x = stage.stageWidth/2 - mc.width/2;
						mc.y = (stage.stageHeight)/2 - mc.height/2;
					}
					
					
					//do overlay icon
					mc = Utils.$(MP._view.ref,'video_overlay_play');
					if(mc != null){
						mc.x = stage.stageWidth/2;
						mc.y = stage.stageHeight/2;
					}
					
					mc = Utils.$(MP._view.ref,'cover');
					if(mc != null){
						mc.width = Math.ceil(tA.width*scale);
						mc.height = Math.ceil(tA.height*scale);
						mc.x = stage.stageWidth/2 - mc.width/2;
						mc.y = (stage.stageHeight)/2 - mc.height/2;						
					}
					MP.setWidth(stage.stageWidth);
					if(MP._view._controls != null){
						MP._view._controls.y = stage.stageHeight - 20;
					}
					
					
				}
			
			}
		
		}
		
		private function scaleStage():void
		{
			//Optionally use hardware acceleration
			/*
			if(MP){
				var mc = Utils.$(MP._view.ref,'myvideo');
				var screenRectangle:Rectangle = new Rectangle();
				screenRectangle.x = 0;
				screenRectangle.y = 0;
				screenRectangle.width=mc.width;
				screenRectangle.height=mc.height;
				stage.fullScreenSourceRect = screenRectangle;			
			}else{
				stage.fullScreenSourceRect = null;
			}
			*/
		}	
		
		
		
	}
	
	
}