/*

Add thumb grid
Fix timer icon
Offer defaults and overrides for configuration

*/

package
{
	
	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.geom.Rectangle;
	
	import com.a12.util.*;
	import com.a12.modules.mediaplayback.*;
	
	import com.gs.TweenLite;
	
	final public class Main extends Sprite
	{
		
		private var _ref:MovieClip;
		private var Layout:Object;
		
		private var flagFullscreen:Boolean;
		private var flagPlaying:Boolean;
		private var flagThumbs:Boolean;
		
		private var slideIndex:int;
		private var slideMax:int;
		private var slideA:Array;
		
		private var slideInterval:Number;
		private var uiInterval:Number;
		
		private var progressOffset:Number;
		private var progressInterval:Number;
		
		private var configObj:Object;
		private var myTimer:Timer;	
		private var timestamp:Number;	
		
		private var MP:com.a12.modules.mediaplayback.MediaPlayback;
		
		public function Main()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var xml;
			
			if(Capabilities.playerType == "External"){
				xml = 'http:/bbb.dev/php/gallery.php?id=1';
				xml = '../xml/gallery.xml';
			}
			else {
				
			}
			
			
			if(root.loaderInfo.parameters.xml){
				xml = root.loaderInfo.parameters.xml;
			}
			
			new XMLLoader(xml,parseXML,this);
			
			Layout = 
			{
				marginX:0,
				marginY:0,
				menuBarH:0
			}
			
			configObj = 
			{
				thumbgrid:true,
				fullscreen:true,
				duration:5000,
				slideshow:true
			}
			
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		private function parseXML(xml:String):void
		{
			var tXML:XML = new XML(xml);
			//parse config information
			
			
			
			
			var snip:XMLList = tXML.RecordSet.(@Type == "Slides");
			var i:int=0;
			slideA = [];			
			for each(var node:XML in snip..Row){
				slideA.push(
					{
						id		: i,
						file	: node.file
					}
				);
				i++;
			}			
			slideMax = i;
			flagThumbs = false;
			
			if(slideMax > 1){
				
				
				
				flagPlaying = true;
				slideIndex = -1;
				buildUI();
				advanceSlide(1);
						
				//listen to the mouse event to hide or show ui
				stage.addEventListener(Event.MOUSE_LEAVE, mouseListener);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseListener);
				//track keyboard navigation
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener);
			
			}else{
				flagPlaying = false;
				configObj.slideshow = false;
				configObj.thumbgrid = false;
				slideIndex = -1;
				buildUI();
				advanceSlide(1);
			}
			
			
		}
		
		private function testHandler(e:CustomEvent):void
		{
			//trace(e.props.name);
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
			TweenLite.to(MovieClip(this.stage.getChildByName('ui')),0.5,{alpha:1.0});
			
			if(MP != null){
				var mc = Utils.$(MP._view.ref,'controls');
				TweenLite.to(MovieClip(mc),0.5,{alpha:1.0});
			}
		}
		
		private function hideUI():void
		{
			clearTimeout(uiInterval);
			TweenLite.to(MovieClip(this.stage.getChildByName('ui')),0.5,{alpha:0.0});
			
			if(MP != null){
				var mc = Utils.$(MP._view.ref,'controls');
				TweenLite.to(MovieClip(mc),0.5,{alpha:0.0});
			}
		}
		
		private function handleIconsMouse(e:Event):void
		{
			//get the type, process the target
			var mc = DisplayObject(e.target);
			
			if(mc.name == 'nav_prev' || mc.name == 'nav_next'){
				if(e.type == MouseEvent.MOUSE_OVER){
					TweenLite.to(MovieClip(mc),0.2,{scaleX:1.2,scaleY:1.2});
				}
				if(e.type == MouseEvent.MOUSE_OUT){
					TweenLite.to(MovieClip(mc),0.5,{scaleX:1.0,scaleY:1.0});
				}
				if(e.type == MouseEvent.CLICK){
					//TweenLite.to(MovieClip(mc),0.2,{scaleX:1.0,scaleY:1.0});
					advanceSlide(mc.dir);
				}
			}
		}
		
		private function buildUI():void
		{			
			var ui = Utils.createmc(this.stage,'ui',{alpha:0});
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
				mc.addEventListener(MouseEvent.ROLL_OVER,handleIconsMouse);
				mc.addEventListener(MouseEvent.ROLL_OUT,handleIconsMouse);
				mc.addEventListener(MouseEvent.CLICK,toggleFullScreen);
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
				mc.addEventListener(MouseEvent.ROLL_OVER,handleIconsMouse);
				mc.addEventListener(MouseEvent.ROLL_OUT,handleIconsMouse);
				mc.addEventListener(MouseEvent.CLICK,toggleThumbs);
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
				mc.addEventListener(MouseEvent.ROLL_OVER,handleIconsMouse);
				mc.addEventListener(MouseEvent.ROLL_OUT,handleIconsMouse);
				mc.addEventListener(MouseEvent.CLICK,toggleSlideShow);
				xPos = 28;
			}		
				
			
			
			if(slideMax > 1){
			
				var tf = new TextFormat();
				tf.font = 'Akzidenz Grotesk';
				tf.size = 10;
				tf.color = 0xFFFFFF;
			
				mc = Utils.createmc(ui,'label');
				Utils.makeTextfield(mc,'',tf,{width:100});
				mc.x = xPos;
				mc.y = 7;
				
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
				mc.addEventListener(MouseEvent.MOUSE_OVER,handleIconsMouse);
				mc.addEventListener(MouseEvent.MOUSE_OUT,handleIconsMouse);
				mc.addEventListener(MouseEvent.CLICK,handleIconsMouse);
			
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
				mc.addEventListener(MouseEvent.MOUSE_OVER,handleIconsMouse);
				mc.addEventListener(MouseEvent.MOUSE_OUT,handleIconsMouse);
				mc.addEventListener(MouseEvent.CLICK,handleIconsMouse);
			
			}
			
			onResize();
			
		}
		
		private function advanceSlide(dir:int):void
		{
			clearTimeout(slideInterval);
			switch(true)
			{
				case slideIndex + dir > slideMax - 1:
					slideIndex = 0;
				break;

				case slideIndex + dir < 0:
					slideIndex = slideMax - 1;
				break;

				default:
					slideIndex += dir;
				break;
			}
						
			viewSlide();
						
		}
		
		private function onResize(e:Event = null):void
		{
			var ui = Utils.$(this.stage,'ui');
			var mc;
			
			mc = Utils.$(ui,'fullscreen');
			if(mc){
				mc.x = stage.stageWidth - mc.xPos;
			}
			
			mc = Utils.$(ui,'thumbnail');
			if(mc){
				mc.x = stage.stageWidth - mc.xPos;
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
		
		private function onFullScreen():void
		{
			
		}
		
		private function keyListener(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.LEFT:
					advanceSlide(-1);
				break;
				
				case Keyboard.RIGHT:
					advanceSlide(1);
				break;
				
				case 38:
					advanceSlide(-1);
				break;
				
				case 40:
					advanceSlide(1);
				break;				
				
			}
		}
		
		
		private function toggleFullScreen(e:Event = null):void
		{
			flagFullscreen = !flagFullscreen;

			if(flagFullscreen){
				

				//Optionally use hardware acceleration
				/*
				var screenRectangle:Rectangle = new Rectangle();
				screenRectangle.x = 0;
				screenRectangle.y = 0;
				screenRectangle.width=stage.stageWidth;
				screenRectangle.height=stage.stageHeight; 
				stage.fullScreenSourceRect = screenRectangle;			
				*/
				stage.displayState = "fullScreen";
			}else{

				stage.displayState = "normal";
			}
		}
		
		private function toggleThumbs(e:Event = null):void
		{
			flagThumbs = !flagThumbs;
			
			if(flagThumbs){
				//tell it to activate
				
				//kill slideshow
			}else{
				//
			}
		}
		
		private function toggleSlideShow(e:Event = null):void
		{
			flagPlaying = !flagPlaying;
			clearTimeout(slideInterval);
			
			//swap the icon state
			var ui = Utils.$(this.stage,'ui');
			var l = Utils.$(ui,'toggle');
			var mc;
			
			if(flagPlaying){
				advanceSlide(1);
				l.gotoAndStop('pause');
				mc = Utils.$(Utils.$(Utils.$(this.stage,'ui'),'toggle'),'circ');
				TweenLite.to(mc,0.5,{alpha:1.0});
			}else{
				l.gotoAndStop('play');
				clearInterval(progressInterval);
				//myTimer.stop();
				mc = Utils.$(Utils.$(Utils.$(this.stage,'ui'),'toggle'),'circ');
				TweenLite.to(mc,0.5,{alpha:0.0});
				//fade it out
			}
		}
		
		private function initVideo(e:Event)
		{
			var mc = Utils.$(MP._view.ref,'controls');
			mc.alpha = 0.0;
			onResize();
		}
		
		private function viewSlide():void
		{
			var s = Utils.$(this.stage,'slide');
			if(s){
				this.stage.removeChild(s);
			}
			var slide = Utils.createmc(this.stage,'slide',{alpha:0});
			this.stage.setChildIndex(slide,0);
			var holder = Utils.createmc(slide,'holder');
			
			var file:String = slideA[slideIndex].file;
			var ext = file.substring(file.lastIndexOf('.')+1,file.length);
			
			if(MP){
				MP._view.removeEventListener('updateSize', initVideo, false);
				MP.kill();
				MP = null;
			}
									
			if(ext == 'flv' || ext == 'mov' || ext == 'mp4' || ext == 'mp3' || ext == 'm4v'){
				MP = new com.a12.modules.mediaplayback.MediaPlayback(holder,file,{hasView:true});
				MP._view.addEventListener('updateSize', onResize, false, 0, true);
				flagPlaying = false;
				revealSlide();
			}
			
			if(ext == 'jpg' || ext == 'gif' || ext == 'png' || ext == 'swf'){
				var movie = new LoadMovie(holder,file);
				movie.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,revealSlide);				
			}
			
			//update the text
			var ui = Utils.$(this.stage,'ui');
			
			if(slideMax > 1){
				var l = Utils.$(ui,'label');
				var tf = Utils.$(l,'displayText');
				tf.text = (slideIndex+1) + '/' + slideMax;
			}
			//kick back the listener			
			
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
			var mc = Utils.$(Utils.$(Utils.$(this.stage,'ui'),'toggle'),'circ');			

			mc.graphics.moveTo(0,0);
			mc.graphics.beginFill(0x222222,0.75);//404040
			mc.graphics.lineTo(x1,y1);
			mc.graphics.lineTo(x2,y2);
			mc.graphics.endFill();
			
		}
		
		private function revealSlide(e:Event=null):void
		{
			var slide = Utils.$(this.stage,'slide');
			TweenLite.to(MovieClip(slide),1.0,{alpha:1.0});
			if(flagPlaying){
				
				
				
				if(configObj.slideshow == true){
										
					timestamp = getTimer();

					clearTimeout(slideInterval);
					slideInterval = setTimeout(advanceSlide,configObj.duration,1);

					//
					var mc = Utils.$(Utils.$(Utils.$(this.stage,'ui'),'toggle'),'circ');
					mc.graphics.clear();
					mc.scaleY = -1.0;
					
					clearInterval(progressInterval);
					progressInterval = setInterval(slideProgressSegment,configObj.duration/100);
					
					/*
					myTimer = new Timer(slideDuration/100, 100);
					myTimer.addEventListener("timer", slideProgressSegment);
					myTimer.start();
					*/
					
					progressOffset = 0;
					slideProgressSegment();
				}
			}
			
			slide._width = slide.width;
			slide._height = slide.height;
			
			//set the height and width properties yea?
			
			scaleSlide();
		}	
		
		private function scaleSlide():void
		{
			
			var slide = Utils.$(this.stage,'slide');
			if(slide){			
				var imgX = slide._width;
				var imgY = slide._height;
			
				
				if(MP != null)
				{
					var tA = MP.getDimensions();
					imgX = tA.width;
					imgY = tA.height;
				}

				var scale = 100;

				//switch out floor for ceil
				switch(true){

					case imgY > stage.stageHeight - Layout.marginY*2-Layout.menuBarH:
						scale = Math.ceil(100 *(stage.stageHeight - Layout.marginY*2 - Layout.menuBarH)/imgY);
						if((scale/100) * imgX > stage.stageWidth - Layout.marginX*2){
							scale = Math.ceil(100 *(stage.stageWidth - Layout.marginX*2)/imgX);
						}
					break;

					case imgX > stage.stageWidth - Layout.marginX*2:
						scale = Math.ceil(100 *(stage.stageWidth - Layout.marginX*2)/imgX);
						if((scale/100) * imgY > stage.stageWidth - Layout.marginY*2-Layout.menuBarH){
							scale = Math.ceil(100 *(stage.stageHeight - Layout.marginY*2 - Layout.menuBarH)/imgY);
						}
					break;

				}
												
				scale = scale/100;
				//if we're a image
				if(MP == null){	
					slide.scaleX = scale;
					slide.scaleY = scale;
					slide.x = stage.stageWidth/2 - slide.width/2;
					slide.y = (stage.stageHeight-Layout.menuBarH)/2 - slide.height/2;
				}
				
				//if we're a video
				if(MP != null){
					
					MP.setScale(scale*100);
					tA = MP.getDimensions();
					
					slide.x = 0;
					slide.y = 0;
					
					var mc = Utils.$(MP._view.ref,'myvideo');
					if(mc != null){
						mc.width = Math.ceil(tA.width*scale);
						mc.height = Math.ceil(tA.height*scale);
					
						mc.x = stage.stageWidth/2 - mc.width/2;
						mc.y = (stage.stageHeight-Layout.menuBarH)/2 - mc.height/2;
					}
					
					//do overlay icon
					mc = Utils.$(MP._view.ref,'video_overlay_play');
					if(mc != null){
						mc.x = stage.stageWidth/2;
						mc.y = stage.stageHeight/2;
					}
					
					mc = Utils.$(MP._view.ref,'cover');
					if(mc != null){
						mc.x = stage.stageWidth/2 - tA.width/2;
						mc.y = (stage.stageHeight-Layout.menuBarH)/2 - tA.height/2;					
					}
					MP.setWidth(stage.stageWidth);
					if(MP._view._controls != null){
						MP._view._controls.y = stage.stageHeight - 20;
					}
					
				}
			
			}
		}	
		
	}
	
}