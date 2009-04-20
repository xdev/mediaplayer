package us.xdev.mediaplayer.views
{
	
	import com.a12.util.CustomEvent;
	import com.a12.util.LoadMovie;
	import com.a12.util.Utils;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import gs.TweenLite;
	
	import us.xdev.mediaplayer.models.*;

	public class Transport extends AbstractView
	{

		public var _height:Number;
		public var _width:Number;

		protected var _originalSize:Object;
		public var _controls:MovieClip;
		
		protected var _timer:Timer;
		protected var _timeMode:Boolean;
		protected var _soundLevel:Number;
		protected var _soundLevelA:Array;
		protected var _scrubberWidth:Number;
		
		private var icons:Object;
		private var options:Object = {};

		public function Transport(ref:Object,model:*,controller:*=null)
		{
			
			super(ref,model,controller);
			
			//icons = options.icons;
			
			_width = 640;
			_height = 360;
			
			_originalSize = {};
			_originalSize._width = _width;
			_originalSize._height = _height;
			
			
			_timeMode = true;
			_soundLevelA = [0.0,0.3,0.6,1.0];
			_soundLevel = 3;
			_scrubberWidth = 8;
			
			if(model as AudioModel){
				renderUI();
			}			
					
		}
		
		public function setScale(value:Number):void
		{
			//find _height and _width based upon scale
			var tW:int,tH:int;
			
			if(value<100){
				tW = ((value/100) * _originalSize._width);
				tH = ((value/100) * _originalSize._height);				
			}else{
				tW = _originalSize._width;
				tH = _originalSize._height;
			}		
			
			_height = tH;
			_width = tW;
			layoutUI();
			//updateSize({_width:tW,_height:tH});
		}
		
		public function setWidth(value:Number):void
		{
			_width = value;
			layoutUI();
		}

		public function getDimensions(mode:Boolean):Object
		{
			if(mode == false){
				return {_height:_height,_width:_width};
			}else{
				return {_height:_originalSize._height,_width:_originalSize._width};
			}
		}
	
		public override function update(event:CustomEvent=null):void
		{
			//dish out to all children
			super.update(event);
			/*
			var mc:MovieClip;
			if(infoObj.stream != undefined){
			
			
			}
			if(infoObj.action == 'onTransportChange'){
				
			}
			
			if(infoObj.action == 'updateSize'){
				
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
			
			if(infoObj.action == 'updateView'){
				updateView(infoObj);
			}
			if(infoObj.action == 'mediaComplete'){
				trace('local stop, needs to not stop if playback has never begun');
				controller.stop();			
			}
			
			dispatchEvent(new CustomEvent(infoObj.action,true,false,infoObj));
			*/
		}
		
		protected function updateSize(infoObj:Object):void
		{
			_width = infoObj._width;
			_height = infoObj._height;			
			renderUI();
		}	
		
		private function toggleTime():void
		{
			_timeMode = !_timeMode;
		}
		
		private function toggleAudio():void
		{
			if(_soundLevel < _soundLevelA.length){
				_soundLevel++;
			}
			if(_soundLevel == _soundLevelA.length){
				_soundLevel = 0;
			}
			
			//set the audio icon position
			MovieClip(Utils.$(_controls,'audio')).gotoAndStop('audio'+_soundLevel);
			//controller setVolume
			controller.setVolume(_soundLevelA[_soundLevel]);
		}
		
		protected function updateView(infoObj:Object):void
		{
			//check the mode for display
			var txt:String = '';
			
			switch(_timeMode)
			{
				case true:
					if(infoObj.time_remaining){
						txt = '-' + Utils.padZero(infoObj.time_remaining.minutes) + ':' + Utils.padZero(Math.ceil(infoObj.time_remaining.seconds));
					}
				break;
				
				case false:
					if(infoObj.time_current){
						txt = Utils.padZero(infoObj.time_current.minutes) + ':' + Utils.padZero(infoObj.time_current.seconds);
					}
				break;
				/*
				case 'progress':
					txt = Utils.padZero(infoObj.time_current.minutes) + ':' + Utils.padZero(infoObj.time_current.seconds) + '/';
					txt += Utils.padZero(infoObj.time_duration.minutes) + ':' + Utils.padZero(infoObj.time_duration.seconds);
				break;
				*/
			}
			
			if(_controls){
				if(Utils.$(_controls,'label')){
					TextField(Utils.$(_controls,'label.displayText')).text = txt;
				}
					
				var factor:Number = (_width-95) / 100;
			
				var mc:MovieClip;
				
				//if dragging false
				if(infoObj.time_percent != undefined){
					mc = MovieClip(Utils.$(_controls,'timeline.scrubber'));
					if(mc.dragging == false){
						mc.x = infoObj.time_percent * ((_width-95)-_scrubberWidth) / 100;
					}
				}
				
				if(Utils.$(_controls,'video_play')){
					mc = MovieClip(Utils.$(_controls,'video_play'));
					if(infoObj.playing){
						mc.gotoAndStop('video_pause');
						mc = MovieClip(Utils.$(ref,'video_overlay_play'));
						if(mc != null){
							mc.alpha = 0.0;
							mc.removeEventListener(MouseEvent.CLICK,mouseHandler);
							mc.buttonMode = false;
							mc.mouseEnabled = false;
						}
					}else{
				
						//fade in the video bizzzle
						//Move.changeProps(MovieClip(Utils.$(ref,'video_overlay_play')),{alpha:0.75},500,'Cubic','easeOut');
				
						mc.gotoAndStop('video_play');
						mc = MovieClip(Utils.$(ref,'video_overlay_play'));
						if(mc != null){
							mc.alpha = 0.75;
							mc.addEventListener(MouseEvent.CLICK,mouseHandler);
							mc.buttonMode = true;
							mc.mouseEnabled = true;
							mc.mouseChildren = false;
						}
				
					}
				}
			
				if(infoObj.loaded_percent >= 0){
					mc = MovieClip(Utils.$(_controls,'timeline.strip_load'));
					mc.scaleX = infoObj.loaded_percent / 100;
				}
			
				if(infoObj.time_percent >= 0){
					mc = MovieClip(Utils.$(_controls,'timeline.strip_progress'));
					mc.scaleX = infoObj.time_percent / 100;
				}
			
			}
		
			
			mc = MovieClip(Utils.$(ref,'still'));
			if(mc){
			
				if(infoObj.playing){
					TweenLite.to(MovieClip(mc),0.2,{alpha:0.0});
				}
			
				if(!infoObj.playing && infoObj.time_percent === 0){
					TweenLite.to(MovieClip(mc),0.5,{alpha:1.0});
				}
			
			}
			
		}
		
		private function trackScrubber(e:Event):void
		{
			controller.findSeek(Utils.$(_controls,'timeline.scrubber').x / (_width-95));
		}
		
		// Consider moving this into the Controller
		protected function mouseHandler(e:MouseEvent):void
		{
			var mc:MovieClip = MovieClip(e.currentTarget);
			
			if(e.type == MouseEvent.ROLL_OVER){
				
			}
			if(e.type == MouseEvent.ROLL_OUT){
				
			}
			if(e.type == MouseEvent.CLICK){
				if(mc.name == 'video_play'){
					controller.toggle();
				}
				if(mc.name == 'video_start'){
					controller.stop();
				}
				if(mc.name == 'label'){
					toggleTime();
				}
				if(mc.name == 'strip_back'){
					var playing:Boolean = controller.getPlaying();					
					controller.findSeek(mc.mouseX / (_width-95));
					if(!playing){
						controller.pause();
					}
				}
				if(mc.name == 'audio'){
					toggleAudio();
				}
				if(mc.name == 'cover'){
					controller.toggle();
				}
				if(mc.name == 'video_overlay_play'){
					controller.play();
				}
			}
			if(e.type == MouseEvent.MOUSE_DOWN){
				var rect:Rectangle = new Rectangle();
				rect.top = -4;
				rect.bottom = -4;
				rect.left = 0;
				rect.right = (_width-95)-_scrubberWidth;
				mc.startDrag(false,rect);
				mc.dragging = true;
				
				mc.playing = controller.getPlaying();
				controller.pause();
				
				//set up special stage tracker
				ref.stage.addEventListener(MouseEvent.MOUSE_UP,mouseHandler);
				
				//_timer.start();
				mc.addEventListener(Event.ENTER_FRAME, trackScrubber);
			}
			if(e.type == MouseEvent.MOUSE_UP){
				
				mc = MovieClip(Utils.$(_controls,'timeline.scrubber'));
				
				mc.dragging = false;
				mc.stopDrag();
				controller.findSeek(mc.x / (_width-95));
				
				if(mc.playing == true){			
					controller.play();
				}else{
					controller.pause();
				}
				
				mc.playing = null;
				
				ref.stage.removeEventListener(MouseEvent.MOUSE_UP,mouseHandler);
				
				//_timer.stop();
				mc.removeEventListener(Event.ENTER_FRAME, trackScrubber);
			}
			/*
			if(e.type == MouseEvent.MOUSE_MOVE){
				if(mc.dragging == true){
					controller.findSeek(mc.x / (_width-95));		
				}
			}
			*/
		}
		
		private function layoutUI():void
		{
			if(_controls != null){
				var mc:MovieClip;
				mc = MovieClip(Utils.$(_controls,"back"));
				mc.graphics.clear();
				Utils.drawRect(mc,_width,20,0x404040,1.0);
			
				var t:MovieClip = MovieClip(Utils.$(_controls,"timeline"));
				mc = MovieClip(Utils.$(t,"strip_back"));
				mc.graphics.clear();
				Utils.drawRect(mc,_width-95,8,0xCCCCCC,1.0);
			
				mc = MovieClip(Utils.$(t,"strip_hit"));
				mc.graphics.clear();
				Utils.drawRect(mc,_width-95,12,0xFF0000,0.0);
			
				mc = MovieClip(Utils.$(t,"strip_load"));
				mc.graphics.clear();
				Utils.drawRect(mc,_width-95,8,0xFFFFFF,1.0);
			
				mc = MovieClip(Utils.$(t,"strip_progress"));
				mc.graphics.clear();
				Utils.drawRect(mc,_width-95,8,0x808080,1.0);
			
				//move the label
				mc = MovieClip(Utils.$(_controls,"label"));
				mc.x = _width - 50;
			
				//move the audio
				mc = MovieClip(Utils.$(_controls,"audio"));
				mc.x = _width - 10;
			}
		}
	
		protected function renderUI():void
		{
			//make video screen clickable yo
			var v:MovieClip = MovieClip(Utils.$(ref,'myvideo'));
			//ref.stage.addEventListener(MouseEvent.CLICK,mouseHandler);			
			_controls = Utils.createmc(ref,"controls",{y:_height-20});
		
			var b:MovieClip = Utils.createmc(_controls,"back",{alpha:0.75,mouseEnabled:true});
			Utils.drawRect(b,_width,20,0x404040,1.0);
			b.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			var i:MovieClip,mc:MovieClip;
			
			//VCR stop (back to beginning)
			i = new icons();
			i.gotoAndStop('video_start');
			mc = MovieClip(_controls.addChild(i));
			mc.name = 'video_start';
			mc.buttonMode = true;
			mc.x = 10;
			mc.y = 10;
			mc.addEventListener(MouseEvent.ROLL_OVER,mouseHandler);
			mc.addEventListener(MouseEvent.ROLL_OUT,mouseHandler);
			mc.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			//play/pause
			i = new icons();
			i.gotoAndStop('video_play');
			mc = MovieClip(_controls.addChild(i));
			mc.name = 'video_play';
			mc.buttonMode = true;
			mc.x = 30;
			mc.y = 10;
			mc.addEventListener(MouseEvent.ROLL_OVER,mouseHandler);
			mc.addEventListener(MouseEvent.ROLL_OUT,mouseHandler);
			mc.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			//timeline
			var t:MovieClip = Utils.createmc(_controls,"timeline",{x:40,y:10});
			mc = Utils.createmc(t,"strip_back",{y:-4,_scope:this,mouseEnabled:true});
			mc.buttonMode = true;
			Utils.drawRect(mc,_width-95,8,0xCCCCCC,1.0);
		
			var h:MovieClip = Utils.createmc(t,"strip_hit",{y:-6});
			Utils.drawRect(h,_width-95,12,0xFF0000,0.0);
			
			mc.hitArea = h;
			mc.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			h = Utils.createmc(t,"strip_load",{y:-4,scaleX:0.0});
			Utils.drawRect(h,_width-95,8,0xFFFFFF,1.0);
			
			h = Utils.createmc(t,"strip_progress",{y:-4,scaleX:0.0});
			Utils.drawRect(h,_width-95,8,0x808080,1.0);		
			
			//scrubber
			i = Utils.createmc(t,"scrubber",{y:-4,dragging:false,mouseEnabled:true});
			Utils.drawRect(i,_scrubberWidth,_scrubberWidth,0x000000,1.0);
			i.buttonMode = true;
			i.addEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			
			//_timer = new Timer(20);
			//_timer.addEventListener(TimerEvent.TIMER, trackScrubber);			
			//i.addEventListener(MouseEvent.MOUSE_MOVE,mouseHandler);
			
			//progress label
			var tf:TextFormat = new TextFormat();
			tf.font = "Akzidenz Grotesk";
			tf.size = 10;
			tf.color = 0xFFFFFF;
			
			if(options.tf != undefined){
				tf = options.tf;
			}
		
			var l:MovieClip = Utils.createmc(_controls,"label",{x:_width-50,y:2.5,mouseEnabled:true});
			Utils.makeTextfield(l,"00:00",tf,{_width:35});//autoSize:TextFieldAutoSize.RIGHT
			l.addEventListener(MouseEvent.CLICK,mouseHandler);
			l.buttonMode = true;
			
			//audio controls
			i = new icons();
			i.gotoAndStop('audio3');
			mc = MovieClip(_controls.addChild(i));
			mc.name = 'audio';
			mc.buttonMode = true;
			mc.x = _width-10;
			mc.y = 10;
			mc.addEventListener(MouseEvent.ROLL_OVER,mouseHandler);
			mc.addEventListener(MouseEvent.ROLL_OUT,mouseHandler);
			mc.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			//create still frame
			if(options.still != undefined){
				
				mc = Utils.createmc(ref,'still',{alpha:0.0});
				var movie:LoadMovie = new LoadMovie(mc,options.still);
				movie.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,revealStill);
				
				controller.stop();
				
				//sort depth
				ref.setChildIndex(mc,ref.numChildren-3);
			}
		
		}
		
		private function revealStill(e:Event=null):void
		{
			TweenLite.to(MovieClip(Utils.$(ref,'still')),0.5,{alpha:1.0});
			//psudeo event
			dispatchEvent(new CustomEvent('updateSize',true,false,{mc:ref}));
		}
		
		public function onKill():void
		{
			
		}	

	}

}