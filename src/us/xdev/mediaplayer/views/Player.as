package us.xdev.mediaplayer.views
{

	import com.a12.modules.mediaplayback.*;
	import com.a12.util.LoadMovie;
	import com.a12.util.Utils;
	import com.a12.util.CustomEvent;

	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	import gs.TweenLite;

	import us.xdev.mediaplayer.pattern.AbstractView;

	public class Player extends AbstractView
	{
		[Embed(source='library.swf', symbol='mediaplayer_icons')]
		private var mediaplayer_icons:Class;

		[Embed(source='library.swf', symbol='icon_timer')]
		private var icon_timer:Class;

		private var slideInterval:Number;
		private var uiInterval:Number;

		private var progressOffset:Number;
		private var progressInterval:Number;
		

		private var timestamp:Number;

		private var configObj:Object;

		private var flagThumbs:Boolean;
		
		private var slideView:Slide;


		public function Player(ref:Object,model:*,controller:*=null)
		{

			super(ref,model,controller);

			configObj = model.getConfig();

			ref.stage.scaleMode = StageScaleMode.NO_SCALE;
			ref.stage.align = StageAlign.TOP_LEFT;

			ref.stage.addEventListener(Event.RESIZE, onResize,false,0,true);
			ref.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen,false,0,true);



		}

		override public function update(event:CustomEvent=null):void
		{
			//dish out to all children
			super.update(event);
			//handle local stuff

			if(event.props.action == 'init'){
				init();
			}

			if(event.props.action == 'viewSlide'){
				viewSlide();
			}
		}

		private function keyListener(e:KeyboardEvent):void
		{
			controller.handleKey(e);
		}

		public function init():void
		{
			buildUI();

			//listen to the mouse event to hide or show ui
			ref.stage.addEventListener(Event.MOUSE_LEAVE, mouseListener,false,0,true);
			ref.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseListener,false,0,true);
			//track keyboard navigation
			ref.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener,false,0,true);

			controller.advanceSlide(1);
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
			TweenLite.to(MovieClip(ref.getChildByName('ui')),0.3,{alpha:1.0});

			/*
			if(MP != null){
				var mc = Utils.$(MP._view.ref,'controls');
				TweenLite.to(MovieClip(mc),0.3,{alpha:1.0});
			}
			*/
		}

		private function hideUI():void
		{
			clearTimeout(uiInterval);
			TweenLite.to(MovieClip(ref.getChildByName('ui')),0.5,{alpha:0.0});

			/*
			if(MP != null){
				var mc = Utils.$(MP._view.ref,'controls');
				TweenLite.to(MovieClip(mc),0.5,{alpha:0.0});
			}
			*/
		}

		private function toggleThumbs(fade:Boolean=true):void
		{	
			return;
			
			flagThumbs = !flagThumbs;

			//Debug.log('toggleThumbs - ' + flagThumbs.toString());

			var ui:MovieClip = Utils.$(ref,'ui');
			var mc:MovieClip = Utils.$(ui,'thumbnail');

			var c:MovieClip = Utils.$(ref,'thumbs');
			var slide:MovieClip = Utils.$(ref,'slide');

			if(flagThumbs){
				//tell it to activate

				//Debug.log('in true section');

				TweenLite.to(MovieClip(slide),0.05,{alpha:0.0});
				//slide.alpha = 0.0;

				ref.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyListener,false);


				//swap depth with ui
				ref.setChildIndex(c,ref.numChildren - 2);
				/*
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
				*/

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
				model.setPlaying(false);
				clearInterval(progressInterval);
				clearTimeout(slideInterval);
				updateSlideShowState();


				//pause video
				//if(MP){
				//	MP.stop();
				//}

			}else{

				//Debug.log('in false section');
				//thumbClass.onKill();
				//thumbClass = null;
				if(fade == true){
					TweenLite.to(MovieClip(slide),0.5,{alpha:1.0});
				}

				//if(thumbClass){
				//	c.visible = false;
				//}

				if(model.slideMax > 1){
					ref.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener,false,0,true);
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

		private function handleIconsMouse(e:Event):void
		{
			//get the type, process the target
			var mc:MovieClip = MovieClip(e.currentTarget);
			if(mc.name == 'nav_prev' || mc.name == 'nav_next'){
				if(e.type == MouseEvent.MOUSE_OVER){
					TweenLite.to(MovieClip(mc),0.2,{scaleX:1.2,scaleY:1.2});
				}
				if(e.type == MouseEvent.MOUSE_OUT){
					TweenLite.to(MovieClip(mc),0.5,{scaleX:1.0,scaleY:1.0});
				}
				if(e.type == MouseEvent.CLICK){
					controller.advanceSlide(mc.dir);
				}

			}
			if(e.type == MouseEvent.CLICK){
				if(mc.name == 'thumbnail'){
					toggleThumbs();
				}
				if(mc.name == 'toggle'){
					controller.toggleSlideShow();
				}
				if(mc.name == 'fullscreen'){
					controller.toggleFullScreen();
				}
			}
		}

		private function buildUI():void
		{
			var ui:MovieClip = Utils.createmc(ref,'ui',{alpha:0});
			//this.stage.setChildIndex(ui,1);
			//top bar
			//full screen, thumbnail, timer/toggle, status


			//handle mouse over generic
			//handle mouse out generic

			var i:MovieClip,mc:MovieClip,xPos:int;

			if(configObj.fullscreen == true){

				i = new mediaplayer_icons();
				i.gotoAndStop('fullscreen');
				mc = Utils.createmc(ui,'fullscreen');
				mc.addChild(i);
				mc.y = 14;
				mc.buttonMode = true;
				mc.addEventListener(MouseEvent.ROLL_OVER,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.ROLL_OUT,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.CLICK,handleIconsMouse,false,0,true);
				mc.xPos = 14;
				xPos = 14;

			}

			if(configObj.thumbgrid == true){
				i = new mediaplayer_icons();
				i.gotoAndStop('thumbnail');
				mc = Utils.createmc(ui,'thumbnail');
				mc.addChild(i);
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
				if(model.flagPlaying){
					i.gotoAndStop('pause');
				}else{
					i.gotoAndStop('play');
				}
				mc = MovieClip(ui.addChild(i));
				mc.name = 'toggle';
				mc.buttonMode = true;
				mc.x = 14;
				mc.y = 14;
				mc.addEventListener(MouseEvent.ROLL_OVER,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.ROLL_OUT,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.CLICK,handleIconsMouse,false,0,true);
				xPos = 28;
			}



			if(model.slideMax > 1){

				var tf:TextFormat = new TextFormat();
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
				mc = Utils.createmc(ui,'nav_prev');
				mc.addChild(i);
				mc.dir = -1;
				mc.x = 15;
				mc.y = 100;
				mc.alpha = 0.75;
				mc.buttonMode = true;
				mc.addEventListener(MouseEvent.MOUSE_OVER,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.MOUSE_OUT,handleIconsMouse,false,0,true);
				mc.addEventListener(MouseEvent.CLICK,handleIconsMouse,false,0,true);

				i = new mediaplayer_icons();
				i.gotoAndStop('nav_arrow');
				mc = Utils.createmc(ui,'nav_next');
				mc.addChild(i);
				mc.dir = 1;
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
			var ui:MovieClip = Utils.$(ref,'ui');
			var mc:MovieClip;

			mc = Utils.$(ui,'fullscreen');
			if(mc){
				mc.x = ref.stage.stageWidth - mc.xPos;
			}

			mc = Utils.$(ui,'thumbnail');
			if(mc){
				mc.x = ref.stage.stageWidth - mc.xPos;
			}

			mc = Utils.$(ref,'preload');
			if(mc){
				mc.x = ref.stage.stageWidth/2 - mc.width/2;
				mc.y = ref.stage.stageHeight/2 - 8;
			}

			if(model.slideMax > 1){
				mc = Utils.$(ui,'nav_prev');
				mc.y = Math.floor(ref.stage.stageHeight/2);

				mc = Utils.$(ui,'nav_next');
				mc.y = Math.floor(ref.stage.stageHeight/2);
				mc.x = ref.stage.stageWidth - 15;
			}

			if(slideView != null){
				slideView.scale();
			}
		}

		private function onFullScreen(e:FullScreenEvent):void
		{
			var mc:MovieClip = Utils.$(ref,'ui.fullscreen');
			if(ref.stage.displayState == "fullScreen"){
				mc.gotoAndStop('fullscreen_off');
			}else{
				mc.gotoAndStop('fullscreen');
			}
		}

		private function updateSlideShowState():void
		{
			var ui:MovieClip = Utils.$(ref,'ui');
			var l:MovieClip = Utils.$(ui,'toggle');
			if(l){
				var mc:MovieClip = Utils.$(l,'circ')

				if(model.flagPlaying){
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
			//clean up
			clearInterval(progressInterval);
			if(slideView != null){
				slideView.onKill();
			}
			slideView = null;
			//remove from updates
			
			//create new
			var slide:MovieClip = Utils.createmc(ref,'slide',{alpha:0});
			ref.setChildIndex(slide,0);	
			slideView = new Slide(slide,model,controller);
			
			//register for updates
			add(slideView);	
			
			slideView.render(model.slideA[model.slideIndex]);
			//controller.sendExternal('viewSlide',[model.slideIndex]);
						
			//should consolidate flow
			updateSlideShowState();
			
			//update the text
			var ui:MovieClip = Utils.$(ref,'ui');

			if(model.slideMax > 1){
				TextField(Utils.$(ui,'label.txt.displayText')).text = (model.slideIndex+1) + '/' + model.slideMax;
			}


		}

		

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
			var dO:Number = 3.6;
			var r:int = 20;

			if(progressOffset < 360){
				progressOffset = Math.abs(p * 360);
			}else{
				progressOffset = 0;
			}

			var x1:Number = r*Math.sin(progressOffset*Math.PI/180);
			var x2:Number = r*Math.sin((progressOffset+dO)*Math.PI/180);
			var y1:Number = r*Math.cos((progressOffset)*Math.PI/180);
			var y2:Number = r*Math.cos((progressOffset+dO)*Math.PI/180);

			//stage
			var mc:MovieClip = Utils.$(ref,'ui.toggle.circ');

			mc.graphics.moveTo(0,0);
			mc.graphics.beginFill(0x222222,0.75);//404040
			mc.graphics.lineTo(x1,y1);
			mc.graphics.lineTo(x2,y2);
			mc.graphics.endFill();

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