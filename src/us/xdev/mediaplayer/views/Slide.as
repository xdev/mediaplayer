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
		private var configObj:Object;

		private var _width:int;
		private var _height:int;

		private var mediaModel:IMediaModel;
		private var transportView:*;
		private var transportController:TransportController;
		private var mediaView:*;

		//this is the screen to display assets
		public function Slide(ref:Object,model:*,controller:*=null)
		{
			super(ref,model,controller);
			configObj = model.getConfig();
		}

		public function onKill():void
		{
			clearInterval(preloadInterval);
			killMedia();
		}

		override public function update(event:CustomEvent=null):void
		{
			
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
			var v:Video;
			if(event.props.action == 'playVideo'){
				v = event.props.video;
				v.name = 'asset';
				ref.addChildAt(v,0);
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
		}

		public function render(data:Object):void
		{
			killMedia();

			//build preload clip
			var preloadClip:MovieClip = Utils.createmc(ref,'preload',{alpha:0.0});
			ref.setChildIndex(preloadClip,0);

			if(data.mode == 'media'){
				var obj:Object = {hasView:true,still:data.still};

				//Utils.drawRect(asset,100,10,0xFF0000,0.5);

				if(obj.still){
					obj.paused = true;
				}

				var options:Object = {};
				var ext:String = data.file.substr(data.file.lastIndexOf('.')+1,data.file.length).toLowerCase();

				if(ext == 'mp4' || ext == 'mov' || ext == 'm4v' || ext == 'flv'){
					mediaModel = new VideoModel(data.file,options);
				}
				if(ext == 'mp3'){
					mediaModel = new AudioModel(data.file,options);
				}

				transportController = new TransportController(mediaModel);
				transportView = new Transport(Utils.createmc(ref,'transport'),mediaModel,transportController);
				mediaModel.addEventListener('onUpdate',transportView.update);
				mediaModel.addEventListener('onUpdate',handleMediaUpdate);

				mediaModel.load();

				//Consider overlay centered video controls while in fullscreen

				//MP._view.addEventListener('updateSize', onResize, false, 0, true);
				//MP._view.addEventListener('onStill', onResize, false, 0, true);
				//MP._model.b.addEventListener('onTransportChange',handleTransport,false,0,true);

				//stop slideshow
				//controller.setPlaying(false);
				
				/*
				//create still frame
				if(options.still != undefined){

					mc = Utils.createmc(ref,'still',{alpha:0.0});
					var movie:LoadMovie = new LoadMovie(mc,options.still);
					movie.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,revealStill);

					controller.stop();

					//sort depth
					ref.setChildIndex(mc,ref.numChildren-3);
				}
				*/

			}



			if(data.mode == 'image'){

				var tf:TextFormat = new TextFormat();
				tf.font = 'Akzidenz Grotesk';
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

		private function reveal(e:Event=null):void
		{
			TweenLite.to(ref,1.0,{alpha:1.0});

			//clearTimeout(preloadInterval);

			if(model.flagPlaying){


				/*
				if(configObj.slideshow == true){

					timestamp = getTimer();

					clearTimeout(slideInterval);
					slideInterval = setTimeout(controller.advanceSlide,configObj.duration,1);

					//
					var mc:MovieClip = Utils.$(ref,'ui.toggle.circ');
					mc.graphics.clear();
					mc.scaleY = -1.0;


					progressOffset = 0;

					if(flagPlaying){
						progressInterval = setInterval(slideProgressSegment,configObj.duration/100);
						slideProgressSegment();
					}

				}
				*/
			}

			_width = Utils.$(ref,'asset').width;
			_height = Utils.$(ref,'asset').height;
			
					
			//set the height and width properties yea?

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
				
				
				if(mediaModel != null)
				{
					//var tA:Object = getVideoDimensions();
					//imgX = tA.width;
					//imgY = tA.height;

					if(configObj.scalevideo){
						m = undefined;
					}
				}
								
				if(configObj.scaleimage){
					m = undefined;
				}
				
				//m = undefined;

				var scale:Number = Utils.getScale(imgX,imgY,stageW-(configObj.marginX*2),stageH-(configObj.marginY*2),'scale',m).x;
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
					if(scale > 1){
						scale = 1;
					}

					slide.width = Math.ceil(_width*scale);
					slide.height = Math.ceil(_height*scale);
					slide.x = stageW/2 - slide.width/2;
					slide.y = (stageH)/2 - slide.height/2;
					
					//update view
					mc = transportView.getRef();
					mc.y = stageH-mc.height;
					mc.x = 0;
					transportView.setWidth(stageW);
					
					/*
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
					*/
				}
				

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