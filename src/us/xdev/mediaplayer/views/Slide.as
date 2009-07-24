package us.xdev.mediaplayer.views
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.media.Video;

	//should clean up
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;

	import com.a12.util.Utils;
	import com.a12.util.CustomEvent;
	import com.a12.util.LoadMovie;

	import gs.TweenLite;

	import us.xdev.mediaplayer.models.IMediaModel;
	import us.xdev.mediaplayer.models.AudioModel;
	import us.xdev.mediaplayer.models.VideoModel;
	import us.xdev.mediaplayer.controllers.TransportController;

	public class Slide extends AbstractView
	{
		private var preloadInterval:Number;

		private var _width:int;
		private var _height:int;

		protected var mediaModel:IMediaModel;
		protected var transportView:*;
		protected var transportController:TransportController;
		private var mediaView:*;

		protected var transportViewClass:*;
		protected var transportControllerClass:*;
		
		private var data:Object;

		//this is the screen to display assets
		public function Slide(ref:Object,model:*,controller:*=null)
		{
			super(ref,model,controller);
			transportViewClass = us.xdev.mediaplayer.views.Transport;
			transportControllerClass = us.xdev.mediaplayer.controllers.TransportController;
		}

		public function onKill():void
		{
			clearInterval(preloadInterval);
			killMedia();
		}

		override public function update(event:CustomEvent=null):void
		{
			//trace('slide.update = ' + event.props.action);
			if(event.props.action == 'showUI'){
				if(transportView){
					TweenLite.to(transportView.getRef(),0.3,{alpha:1.0});
				}
			}

			if(event.props.action == 'hideUI'){
				if(transportView){
					TweenLite.to(transportView.getRef(),0.5,{alpha:0.0});
				}
			}

			if(event.props.action == 'pause'){
				if(transportController){
					transportController.pause();
				}
			}

			if(event.props.action == 'play'){
				if(transportController){
					transportController.play();
				}
			}

			if(event.props.action == 'render'){
				//attach stuff yea
			}
			
		}

		private function killMedia():void
		{
			if(mediaModel){
				mediaModel.kill();
				mediaModel = null;
				//transportView.onKill();
				transportView = null;
				transportController = null;
			}
		}

		private function handleMediaUpdate(event:CustomEvent):void
		{
			//trace('handleMediaUpdate = ' + event.props.action);
			//MP._view.addEventListener('updateSize', onResize, false, 0, true);
			
			var v:Video;
			if(event.props.action == 'playVideo'){
				v = event.props.video;
				v.name = 'asset';
				ref.addChildAt(v,0);
				transportController.setVolume(0.75);
			}
			if(event.props.action == 'updateSize'){

				if(Utils.$(ref,'asset')){
					v = event.props.video;
					v.width = event.props.width;
					v.height = event.props.height;
					//v.alpha = 1.0;
					//Utils.$(ref,'asset').width = event.props.width;
					//Utils.$(ref,'asset').height = event.props.height;
					//if we're a video drop in cover?clip???

					/*
					if(event.props.action == 'updateSize'){

						//
						if(model as VideoModel){
							//create cover to register clicks!

							//optionally
								mc = Utils.createmc(ref,'cover',{buttonMode:true,mouseEnabled:true});
								Utils.drawRect(mc,infoObj._width,infoObj._height,0xFF0000,0.0);
								mc.addEventListener(MouseEvent.CLICK,mouseHandler);

							var i:MovieClip = new icons();
							i.gotoAndStop('video_overlay_play');
							mc = MovieClip(ref.addChild(i));
							mc.alpha = 0.0;
							mc.name = 'video_overlay_play';
							mc.buttonMode = true;
							mc.x = infoObj._width/2;
							mc.y = infoObj._height/2;
							//mc.addEventListener(MouseEvent.ROLL_OVER,mouseHandler);
							//mc.addEventListener(MouseEvent.ROLL_OUT,mouseHandler);

						}

						_originalSize = {};
						_originalSize._width = infoObj._width;
						_originalSize._height = infoObj._height;
						updateSize(infoObj);
					}
					*/

					reveal();
				}

			}
			if(event.props.action == 'onTransportChange'){
				if(event.props.mode){
					hideStill();
				}
			}
		}

		public function render(data:Object):void
		{
			this.data = data;

			killMedia();

			//build preload clip
			var preloadClip:MovieClip = Utils.createmc(ref,'preload',{alpha:0.0});
			ref.setChildIndex(preloadClip,0);

			if(data.mode == 'media'){
				
				var options:Object = data;
				if(options.still){
					options.paused = true;
				}
				var ext:String = data.file.substr(data.file.lastIndexOf('.')+1,data.file.length).toLowerCase();

				if(ext == 'mp4' || ext == 'mov' || ext == 'm4v' || ext == 'flv'){
					mediaModel = new VideoModel(data.file,options);
				}
				if(ext == 'mp3'){
					mediaModel = new AudioModel(data.file,options);
				}

				transportController = new transportControllerClass(mediaModel);
				transportView = new transportViewClass(Utils.createmc(ref,'transport'),mediaModel,transportController);
				mediaModel.addEventListener('onUpdate',transportView.update);
				mediaModel.addEventListener('onUpdate',handleMediaUpdate);

				mediaModel.load();

				//stop slideshow
				//controller.setPlaying(false);
				
				//create still frame
				if(options.still != undefined){
					addStill();					
				}

			}



			if(data.mode == 'image'){

				var tf:TextFormat = new TextFormat();
				tf.font = 'Arial';
				tf.size = 10;
				tf.color = 0xFFFFFF;
				tf.align = 'center';

				Utils.makeTextfield(preloadClip,'',tf,{width:100});
				preloadClip.x = ref.stage.stageWidth/2 - preloadClip.width/2;
				preloadClip.y = ref.stage.stageHeight/2 - 8;

				//do the drop shadow son

				preloadClip.filters = [
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

				var movie:LoadMovie = new LoadMovie(Utils.createmc(ref,'asset'),data.file);
				movie.addEventListener(Event.COMPLETE,reveal);
				movie.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,handlePreload,false,0,true);

				clearTimeout(preloadInterval);
				preloadInterval = setTimeout(renderPreload,500);

			}


			//kick back the listener
		}
		
		protected function addStill():void
		{
			var mc:MovieClip = Utils.createmc(ref,'still',{alpha:0.0});
			//add img holder
			
			//add icons, etc
			var movie:LoadMovie = new LoadMovie(mc,data.still);
			movie.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,revealStill);
			//transportController.stop();
			
			//sort depth
			//ref.setChildIndex(mc,ref.numChildren-3);
		}
		
		//be ready to call this if user scrubs past the start, or better yet
		//don't show the scrub yet
		protected function hideStill():void
		{
			var mc:MovieClip = Utils.$(ref,'still');
			TweenLite.to(mc,0.3,{alpha:0.0});
			//disable the mouse, yo
			mc.mouseEnabled = false;
			mc.buttonMode = false;
		}
		
		protected function revealStill(e:Event):void
		{
			var mc:MovieClip = Utils.$(ref,'still');
			TweenLite.to(mc,0.5,{alpha:1.0});
			
			//add mouse events
			mc.mouseEnabled = true;
			mc.buttonMode = true;
			mc.addEventListener(MouseEvent.CLICK,handleMouse,false,0,true);
		}
		
		protected function handleMouse(e:MouseEvent):void
		{
			var mc:* = e.currentTarget;
			if(mc.name == 'still'){
				hideStill();
				transportController.play();
			}
		}

		private function reveal(e:Event=null):void
		{
			TweenLite.to(ref,1.0,{alpha:1.0});

			dispatchEvent(new CustomEvent('onReveal',false,false,{data:data}));

			_width = Utils.$(ref,'asset').width;
			_height = Utils.$(ref,'asset').height;

			scale();
		}

		private function renderPreload():void
		{
			clearTimeout(preloadInterval);
			//fade clip in
			var mc:MovieClip = Utils.$(ref,'preload');
			TweenLite.to(mc,0.5,{alpha:1.0});
		}

		private function handlePreload(e:ProgressEvent):void
		{
			var p:int = Math.ceil(100*(e.bytesLoaded / e.bytesTotal));
			var mc:* = Utils.$(ref,'preload.displayText');
			mc.text = p + '%';
			if(p == 100){
				TweenLite.to(mc,0.5,{alpha:0.0});
			}

			//update to clip
		}

		/*
		add play icon from paused state...
		draw huge hit area for play/pause video, etc
		*/

		private function getVideoDimensions(mode:Boolean=true):Object
		{
			if(mode == false){
				return {height:Utils.$(ref,'asset').height,width:Utils.$(ref,'asset').width};
			}else{
				return {height:_height,width:_width};
			}
		}
		
		protected function getScale(objWidth:Number,objHeight:Number,max:Number):Number
		{
			return Utils.getScale(objWidth,objHeight,ref.stage.stageWidth - (model.getConfig().marginX*2),ref.stage.stageHeight - (model.getConfig().marginY*2),'scale',max).x;
		}
		
		public function scale():void
		{

			var mc:MovieClip;
			var slide:* = Utils.$(ref,'asset');

			var stageW:int = ref.stage.stageWidth;
			var stageH:int = ref.stage.stageHeight;

			if(slide){
				var imgX:int = _width;
				var imgY:int = _height;
				var m:int = 100;

				//m = undefined;

				if(mediaModel != null)
				{
					//if(ref.stage.displayState == "fullScreen"){
						var tA:Object = getVideoDimensions(true);
						imgX = tA.width;
						imgY = tA.height;
					//}


					if(model.getConfig().scalevideo){
						m = undefined;
					}
				}else{
					if(ref.stage.displayState == "fullScreen"){
						imgX = stageW;
						imgY = stageH;
						m = undefined;
					}
				}



				/*
				if(model.getConfig().scaleimage){
					m = undefined;
				}
				*/
				//m = undefined;

				var scale:Number = getScale(imgX,imgY,m);
				scale = scale/100;



				//if we're a image
				if(mediaModel == null){
					slide.scaleX = scale;
					slide.scaleY = scale;
					slide.x = stageW/2 - slide.width/2;
					slide.y = (stageH)/2 - slide.height/2;
				}

				//if we're a video
				if(mediaModel != null){

					//MP.setScale(scale*100);
					//tA = getVideoDimensions();

					//lock it down to 100?
					if(ref.stage.displayState != "fullScreen"){
						//if(scale > 1){
						//	scale = 1;
						//}
					}

					slide.width = Math.ceil(_width*scale);
					slide.height = Math.ceil(_height*scale);
					slide.x = stageW/2 - slide.width/2;
					slide.y = (stageH)/2 - slide.height/2;

					//update view
					
					mc = transportView.getRef();
					mc.y = stageH-mc.height;
					mc.x = stageW/2-320;//0;
					//depending on view
					if(ref.stage.displayState == "fullScreen"){
						mc.y = stageH-(mc.height*3);
					}else{

					}

					transportView.setWidth(640);//stageW);
					
				}

			}
			
			var still:MovieClip = Utils.$(ref,'still');
			
			if(still){
				//scale her up, same style as other, this is where we can override again, scale the image, not the artwork, etc
				still.width = Math.ceil(_width*scale);
				still.height = Math.ceil(_height*scale);
				still.x = stageW/2 - still.width/2;
				still.y = (stageH)/2 - still.height/2;
			}
			
		}

		private function scaleStage():void
		{
			//Optionally use hardware acceleration
			if(mediaModel){
				var mc:* = Utils.$(ref,'asset');
				var screenRectangle:Rectangle = new Rectangle();
				screenRectangle.x = 0;
				screenRectangle.y = 0;
				screenRectangle.width=mc.width;
				screenRectangle.height=mc.height;
				ref.stage.fullScreenSourceRect = screenRectangle;
			}else{
				ref.stage.fullScreenSourceRect = null;
			}
		}

	}

}