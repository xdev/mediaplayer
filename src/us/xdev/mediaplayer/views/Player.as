package us.xdev.mediaplayer.views
{
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
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import com.a12.util.LoadMovie;
	import com.a12.util.Utils;
	import com.a12.util.CustomEvent;
	import com.greensock.TweenLite;
	
	import us.xdev.mediaplayer.controllers.ThumbController;
	import us.xdev.mediaplayer.views.*;

	public class Player extends AbstractView
	{
		//Assets
		[Embed(source='/library.swf', symbol='mediaplayer_icons')]
		private var mediaplayer_icons:Class;
		
		[Embed(source='/library.swf', symbol='icon_timer')]
		private var icon_timer:Class;
		
		[Embed(source='/library.swf', symbol='Arial')]
		private var font1:Class;
		
		//Todo: Why public
		public var slideInterval:Number;
		
		protected var uiInterval:Number;
		protected var progressOffset:Number;
		protected var progressInterval:Number;
		protected var timestamp:Number;
		protected var configObj:Object;
		protected var flagThumbs:Boolean;
		protected var slideView:Slide;
		protected var thumbView:ThumbStrip;//ThumbGrid;
		protected var thumbController:ThumbController;
		
		//set these up for customizations
		protected var slideViewClass:*;
		protected var thumbViewClass:*;
		protected var thumbControllerClass:*;
		
		public function Player(ref:Object, model:*, controller:*=null)
		{
			super(ref, model, controller);
			
			//declare classes for slide and thumb views/controllers
			slideViewClass = us.xdev.mediaplayer.views.Slide;
			thumbViewClass = us.xdev.mediaplayer.views.ThumbStrip;
			thumbControllerClass = us.xdev.mediaplayer.controllers.ThumbController;
			
			configObj = model.getConfig();
			
			//build thumbnails????
			
			ref.stage.scaleMode = StageScaleMode.NO_SCALE;
			ref.stage.align = StageAlign.TOP_LEFT;
			ref.stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			ref.stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen, false, 0, true);
		}
		
		protected function buildThumbs():void
		{
			thumbController = new thumbControllerClass(model);
			thumbView = new thumbViewClass(
				Utils.createmc(ref, 'thumbs', { visible:false }),
				model,
				thumbController,
				{ thumbWidth:50, thumbHeight:50, padding:10, marginX:0, marginY:0 }
			);
		}
		
		protected function hideThumbs():void
		{
			flagThumbs = false;
			showThumbs(true);
		}
		
		override public function update(event:CustomEvent=null):void
		{
			//dish out to all children
			super.update(event);
			
			if(event.props.action == 'init'){
				init();
			}
			
			if(event.props.action == 'viewSlide'){
				//this is for incoming actions from ThumbController
				flagThumbs = false;
				viewSlide();
			}
		}
		
		protected function keyListener(event:KeyboardEvent):void
		{
			controller.handleKey(event);
		}
		
		public function init():void
		{
			model.setPlaying(false);
			
			renderUI();
			buildThumbs();
			
			controller.advanceSlide(1);	
			
			//listen to the mouse event to hide or show ui
			ref.stage.addEventListener(Event.MOUSE_LEAVE, mouseListener, false, 0, true);
			ref.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseListener, false, 0, true);
			//track keyboard navigation
			ref.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener, false, 0, true);
			
		}
		
		protected function mouseListener(event:Event):void
		{
			if(event.type == MouseEvent.MOUSE_MOVE){
				showUI();
			}
			if(event.type == Event.MOUSE_LEAVE){
				hideUI();
			}
		}
		
		protected function showUI():void
		{
			//start timer to hideUI
			clearTimeout(uiInterval);
			uiInterval = setTimeout(hideUI, 3000);
			TweenLite.to(MovieClip(ref.getChildByName('ui')), 0.3, { alpha:1.0 });
			
			slideView.update(new CustomEvent('onUpdate', false, false, { action:'showUI' }));
			
			if(ref.stage.displayState == "fullScreen" && model.slideMax > 1){
				if(flagThumbs == false){
					flagThumbs = true;
					showThumbs(true);
				}
			}
		}
		
		protected function hideUI():void
		{
			clearTimeout(uiInterval);
			TweenLite.to(MovieClip(ref.getChildByName('ui')), 0.5, { alpha:0.0 });
			
			slideView.update(new CustomEvent('onUpdate', false, false, { action:'hideUI' }));
			
			flagThumbs = false;
			showThumbs(false);
		}
		
		protected function showThumbs(fade:Boolean=true):void
		{
			if(thumbView == null){
				return;
			}
			var ui:MovieClip = Utils.$(ref,'ui');
			var c:MovieClip = Utils.$(ref,'thumbs');
			var slide:MovieClip = Utils.$(ref,'slide');
			
			if(flagThumbs){
				c.alpha = 0.0;
				c.visible = true;
				TweenLite.to(c,0.3,{alpha:1.0,y:ref.stage.stageHeight - 70});
				
				//kill slideshow
				model.setPlaying(false);
				clearInterval(progressInterval);
				clearTimeout(slideInterval);
				updateSlideShowState();
				
				//tell slide to pause
				if(slideView){
					//slideView.update(new CustomEvent('onUpdate',false,false,{action:'pause'}));
				}
				
			}else{
				if(fade == true){
					//TweenLite.to(MovieClip(slide),0.5,{alpha:1.0});
				}
				
				TweenLite.to(c,0.3,{alpha:0.0,y:ref.stage.stageHeight + 10});
				
				if(model.slideMax > 1){
					ref.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener,false,0,true);
				}
				if(slideView){
					//slideView.update(new CustomEvent('onUpdate',false,false,{action:'play'}));
				}
			}
		}
		
		public function toggleThumbs(fade:Boolean=true):void
		{
			flagThumbs = !flagThumbs;
			showThumbs(fade);
		}
		
		public function toggleSlideShow():void
		{
			showUI();
			model.setPlaying(!model.flagPlaying);
			var mc:MovieClip = Utils.$(ref, 'ui.slideshow');
			if(model.flagPlaying){
				if(flagThumbs){
					toggleThumbs();
				}
				controller.advanceSlide(1);
				Utils.$(mc,'icon').gotoAndStop('icon_slideshow_off');
				Utils.$(mc,'label.displayText').text = 'Stop';
			}else{
				clearInterval(progressInterval);
				Utils.$(mc,'icon').gotoAndStop('icon_slideshow_on');
				Utils.$(mc,'label.displayText').text = 'Slideshow';
			}
			clearTimeout(slideInterval);
			updateSlideShowState();
		}
		
		public function startSlideShow():void
		{
			clearTimeout(slideInterval);
			clearInterval(progressInterval);
			progressOffset = 0;
			progressInterval = setInterval(slideProgressSegment, configObj.duration/100);
			slideProgressSegment();
			slideInterval = setTimeout(controller.advanceSlide, configObj.duration,1);
		}
		
		public function stopSlideShow():void
		{
			model.setPlaying(false);
			clearTimeout(slideInterval);
			clearInterval(progressInterval);
			updateSlideShowState();
		}
		
		public function toggleFullScreen():void
		{
			switch(true){
				
				case ref.stage.displayState == "fullScreen":
					ref.stage.displayState = "normal";
				break;
				
				case ref.stage.displayState == "normal":
					ref.stage.displayState = "fullScreen";
				break;
				
			}
		}
		
		protected function handleIconsMouse(event:Event):void
		{
			//get the type, process the target
			var mc:MovieClip = MovieClip(event.currentTarget);
			if(mc.name == 'nav_prev' || mc.name == 'nav_next'){
				if(event.type == MouseEvent.MOUSE_OVER){
					TweenLite.to(MovieClip(mc), 0.1, { alpha:1.0 });
				}
				if(event.type == MouseEvent.MOUSE_OUT){
					TweenLite.to(MovieClip(mc), 0.3, { alpha:0.4 });
				}
				if(event.type == MouseEvent.CLICK){
					controller.advanceSlide(mc.dir);
				}
			}
			if(event.type == MouseEvent.CLICK){
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
		
		protected function renderUI():void
		{
			var ui:MovieClip = Utils.createmc(ref, 'ui', { alpha:0 });
			var i:*;
			var mc:MovieClip;
			var xPos:int = 0;
			
			if(configObj.fullscreen == true){
				i = new mediaplayer_icons();
				i.gotoAndStop('fullscreen');
				i.name = 'icon';
				mc = Utils.createmc(ui, 'fullscreen');
				mc.addChild(i);
				mc.y = 14;
				mc.buttonMode = true;
				mc.addEventListener(MouseEvent.ROLL_OVER, handleIconsMouse, false, 0, true);
				mc.addEventListener(MouseEvent.ROLL_OUT, handleIconsMouse, false, 0, true);
				mc.addEventListener(MouseEvent.CLICK, handleIconsMouse, false, 0, true);
				mc.xPos = 14;
				xPos = 14;
			}
			
			if(configObj.thumbgrid == true){
				i = new mediaplayer_icons();
				i.gotoAndStop('thumbnail');
				i.name = 'icon';
				mc = Utils.createmc(ui, 'thumbnail');
				mc.addChild(i);
				mc.buttonMode = true;
				mc.y = 14;
				mc.addEventListener(MouseEvent.ROLL_OVER, handleIconsMouse, false, 0, true);
				mc.addEventListener(MouseEvent.ROLL_OUT, handleIconsMouse, false, 0, true);
				mc.addEventListener(MouseEvent.CLICK, handleIconsMouse, false, 0, true);
				if(xPos == 14){
					mc.xPos = 38;
				}else{
					mc.xPos = 14;
				}
			}
			
			xPos = 6;
			
			if(configObj.slideshow == true){
				
				i = new icon_timer();
				i.name = 'icon';
				if(model.flagPlaying){
					i.gotoAndStop('pause');
				}else{
					i.gotoAndStop('play');
				}
				mc = Utils.createmc(ui, 'toggle');
				mc.addChild(i);
				mc.buttonMode = true;
				mc.x = 14;
				mc.y = 14;
				mc.addEventListener(MouseEvent.ROLL_OVER, handleIconsMouse, false, 0, true);
				mc.addEventListener(MouseEvent.ROLL_OUT, handleIconsMouse, false, 0, true);
				mc.addEventListener(MouseEvent.CLICK, handleIconsMouse, false, 0, true);
				xPos = 28;
			}
			
			if(model.slideMax > 1){
				var tf:TextFormat = new TextFormat();
				tf.font = 'Arial';
				tf.size = 11;
				tf.color = 0xFFFFFF;
				
				mc = Utils.createmc(ui, 'label', { alpha:0.0 });
				Utils.makeTextfield(Utils.createmc(mc,'txt'), '', tf, { width:100 });
				mc.x = xPos;
				mc.y = 7;
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
				
				//left, right
				i = new mediaplayer_icons();
				i.gotoAndStop('nav_arrow');
				mc = Utils.createmc(ui, 'nav_prev');
				mc.addChild(i);
				mc.dir = -1;
				mc.x = 25;
				mc.y = 100;
				mc.alpha = 0.4;
				mc.buttonMode = true;
				mc.addEventListener(MouseEvent.MOUSE_OVER, handleIconsMouse, false, 0, true);
				mc.addEventListener(MouseEvent.MOUSE_OUT, handleIconsMouse, false, 0, true);
				mc.addEventListener(MouseEvent.CLICK, handleIconsMouse, false, 0, true);
				
				i = new mediaplayer_icons();
				i.gotoAndStop('nav_arrow');
				mc = Utils.createmc(ui, 'nav_next');
				mc.addChild(i);
				mc.dir = 1;
				mc.rotation = 180;
				mc.x = 585;
				mc.y = 100;
				mc.alpha = 0.4;
				mc.buttonMode = true;
				mc.addEventListener(MouseEvent.MOUSE_OVER, handleIconsMouse, false, 0, true);
				mc.addEventListener(MouseEvent.MOUSE_OUT, handleIconsMouse, false, 0, true);
				mc.addEventListener(MouseEvent.CLICK, handleIconsMouse, false, 0, true);
			}
			
			onResize();
		}
		
		protected function onResize(event:Event = null):void
		{
			var ui:MovieClip = Utils.$(ref, 'ui');
			var mc:MovieClip;
			
			mc = Utils.$(ui, 'fullscreen');
			if(mc){
				mc.x = ref.stage.stageWidth - mc.xPos;
			}
			
			mc = Utils.$(ui, 'thumbnail');
			if(mc){
				mc.x = ref.stage.stageWidth - mc.xPos;
			}
			
			mc = Utils.$(ref, 'preload');
			if(mc){
				mc.x = ref.stage.stageWidth/2 - mc.width/2;
				mc.y = ref.stage.stageHeight/2 - 8;
			}
			
			mc = Utils.$(ref, 'thumbs');
			if(mc){
				if(flagThumbs){
					mc.y = ref.stage.stageHeight - 70;
				}else{
					mc.y = ref.stage.stageHeight + 10;
				}
			}
			
			if(model.slideMax > 1){
				mc = Utils.$(ui, 'nav_prev');
				if(mc){
					mc.y = Math.floor(ref.stage.stageHeight/2);
				}
				
				mc = Utils.$(ui, 'nav_next');
				if(mc){
					mc.y = Math.floor(ref.stage.stageHeight/2);
					mc.x = ref.stage.stageWidth - 25;
				}
			}
			
			if(slideView != null){
				slideView.scale();
			}
		}
		
		protected function onFullScreen(event:FullScreenEvent):void
		{
			var mc:MovieClip = Utils.$(ref,'ui.fullscreen.icon');
			if(ref.stage.displayState == "fullScreen"){
				mc.gotoAndStop('fullscreen_off');
			}else{
				mc.gotoAndStop('fullscreen');
			}
		}
		
		protected function updateSlideShowState():void
		{
			//TODO: figure out if we need this? should be handled in a typical update cycle
			/*
			var ui:MovieClip = Utils.$(ref,'ui');
			var l:MovieClip = Utils.$(ui,'toggle.icon');
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
			*/
		}
		
		protected function handleSlideLoad(event:CustomEvent):void
		{
			if(configObj.slideshow == true){
				timestamp = getTimer();
				
				if(event.props.data.mode == 'media'){
					stopSlideShow();
				}
				
				if(model.flagPlaying){
					startSlideShow();
				}
			}
		}
		
		protected function viewSlide():void
		{
			clearInterval(progressInterval);
			if(slideView != null){
				slideView.onKill();
			}
			slideView = null;
			//remove from updates
			//create new
			var slide:MovieClip = Utils.createmc(ref, 'slide', { alpha:0.0 });
			ref.setChildIndex(slide, 0);
			slideView = new slideViewClass(slide,model,controller);
			slideView.addEventListener('onReveal',handleSlideLoad,false,0,true);
			
			//register for updates
			add(slideView);
			
			slideView.render(model.slideA[model.slideIndex]);
			//controller.sendExternal('viewSlide',[model.slideIndex]);
			
			//should consolidate flow
			updateSlideShowState();
			
			//update the text
			var ui:MovieClip = Utils.$(ref, 'ui');
			
			if(model.slideMax > 1){
				if(Utils.$(ui, 'label')){
					TextField(Utils.$(ui, 'label.txt.displayText')).text = (model.slideIndex+1) + '/' + model.slideMax;
				}
			}
			
			clearTimeout(slideInterval);
		}
		
		protected function slideProgressListener(event:ProgressEvent):void
		{
			//renderProgress(p);
		}

		protected function slideProgressSegment():void
		{
			//renderProgress((timestamp - getTimer())/configObj.duration);
		}
		
		protected function renderProgress(value:Number):void
		{
			//specific for OG spin animation
			var dO:Number = 3.6;
			var r:int = 20;
			
			if(progressOffset < 360){
				progressOffset = Math.abs(value * 360);
			}else{
				progressOffset = 0;
			}
			
			var x1:Number = r*Math.sin(progressOffset*Math.PI/180);
			var x2:Number = r*Math.sin((progressOffset+dO)*Math.PI/180);
			var y1:Number = r*Math.cos((progressOffset)*Math.PI/180);
			var y2:Number = r*Math.cos((progressOffset+dO)*Math.PI/180);
			
			//stage
			var mc:MovieClip = Utils.$(ref, 'ui.toggle.icon.circ');
			
			mc.graphics.moveTo(0,0);
			mc.graphics.beginFill(0x222222,0.75);
			mc.graphics.lineTo(x1,y1);
			mc.graphics.lineTo(x2,y2);
			mc.graphics.endFill();
		}
	}
}