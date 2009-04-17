package us.xdev.mediaplayer.views
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	
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
		
	import us.xdev.mediaplayer.pattern.AbstractView;
	
	public class Slide extends AbstractView
	{
		private var preloadInterval:Number;
		private var configObj:Object;
		
		private var _width:int;
		private var _height:int;
		
		//this is the screen to display assets
		public function Slide(ref:Object,model:*,controller:*=null)
		{
			super(ref,model,controller);
			configObj = model.getConfig();			
		}
		
		public function onKill():void
		{
			clearInterval(preloadInterval);
		}
		
		override public function update(event:CustomEvent=null):void
		{
			if(event.props.action == 'render'){
				
				//attach stuff yea
				
			}
		}
		
		public function render(data:Object):void
		{
			/*
			if(MP){
				MP._view.removeEventListener('updateSize', onResize, false);
				MP.kill();
				MP = null;
			}
			*/
			var holder:MovieClip = Utils.createmc(ref,'holder');
			
			if(data.mode == 'media'){
				var obj:Object = {hasView:true,still:data.still};
				if(obj.still){
					//obj.paused = true;
				}

				//Consider overlay centered video controls while in fullscreen
				//MP = new com.a12.modules.mediaplayback.MediaPlayback(holder,slideA[slideIndex].file,obj);
				//MP._view.addEventListener('updateSize', onResize, false, 0, true);
				//MP._view.addEventListener('onStill', onResize, false, 0, true);
				//_model.b
				//MP._model.b.addEventListener('onTransportChange',handleTransport,false,0,true);

				model.setPlaying(false);
				
				reveal();
			}

			//build preload clip
		
			var preloadClip:MovieClip = Utils.createmc(ref,'preload',{alpha:0.0});
			ref.setChildIndex(preloadClip,0);

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

				var movie:LoadMovie = new LoadMovie(holder,model.slideA[model.slideIndex].file);
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
			
			_width = Utils.$(ref,'holder').width;
			_height = Utils.$(ref,'holder').height;

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
		
		public function scale():void
		{
			
			var mc:MovieClip;
			var slide:MovieClip = Utils.$(ref,'holder');
			
			var stageW:int = ref.stage.stageWidth;
			var stageH:int = ref.stage.stageHeight;
			
			if(slide){
				var imgX:int = _width;
				var imgY:int = _height;
				var m:int = 100;
				/*
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
				*/
				
				if(configObj.scaleimage){
					m = undefined;
				}

				var scale:Number = Utils.getScale(imgX,imgY,stageW-(configObj.marginX*2),stageH-(configObj.marginY*2),'scale',m).x;
				
				scale = scale/100;
				//if we're a image
				//if(MP == null){
					slide.scaleX = scale;
					slide.scaleY = scale;
					slide.x = stageW/2 - slide.width/2;
					slide.y = (stageH)/2 - slide.height/2;
				//}

				//if we're a video
				/*
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
				*/

			}

			
		}
		
	}
	
}