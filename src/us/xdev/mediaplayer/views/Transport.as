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
		[Embed(source='library.swf', symbol='mediaplayback_icons')]
		private var icons:Class;
		
		[Embed(source='library.swf', symbol='AkzidenzGrotesk')]
		private var font1:Class;
				
		protected var _timer:Timer;
		protected var _timeMode:Boolean;
		protected var _soundLevel:Number;
		protected var _soundLevelA:Array;
		protected var _scrubberWidth:Number;
				
		private var options:Object = {};
		
		private var _width:int = 640;
		private var _height:int = 20;
		
		public function Transport(ref:Object,model:*,controller:*,options:Object=null)
		{
			
			super(ref,model,controller);
			
			this.options = options;
						
			_timeMode = true;
			_soundLevelA = [0.0,0.3,0.6,1.0];
			_soundLevel = 3;
			_scrubberWidth = 8;
			
			/*
			if(model as AudioModel){
				renderUI();
			}
			*/
			renderUI();			
					
		}
		
		public function setWidth(value:Number):void
		{
			_width = value;
			layoutUI();
		}
	
		public override function update(event:CustomEvent=null):void
		{
			//dish out to all children
			super.update(event);			
			var mc:MovieClip;
			
			if(event.props.action == 'showUI'){
				
			}
			
			if(event.props.action == 'hideUI'){
				
			}
			
			if(event.props.stream != undefined){
			
			
			}
			if(event.props.action == 'onTransportChange'){
				
			}
						
			if(event.props.action == 'updateView'){
				updateView(event.props);
			}
			if(event.props.action == 'mediaComplete'){
				trace('local stop, needs to not stop if playback has never begun');
				controller.stop();			
			}
			
			//dispatchEvent(new CustomEvent(infoObj.action,true,false,infoObj));
			
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
			MovieClip(Utils.$(ref,'audio')).gotoAndStop('audio'+_soundLevel);
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
			
			if(ref){
				if(Utils.$(ref,'label')){
					TextField(Utils.$(ref,'label.displayText')).text = txt;
				}
					
				var factor:Number = (_width-95) / 100;
			
				var mc:MovieClip;
				
				//if dragging false
				if(infoObj.time_percent != undefined){
					mc = MovieClip(Utils.$(ref,'timeline.scrubber'));
					if(mc.dragging == false){
						mc.x = infoObj.time_percent * ((_width-95)-_scrubberWidth) / 100;
					}
				}
				
				if(Utils.$(ref,'video_play')){
					mc = MovieClip(Utils.$(ref,'video_play'));
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
					mc = MovieClip(Utils.$(ref,'timeline.strip_load'));
					mc.scaleX = infoObj.loaded_percent / 100;
				}
			
				if(infoObj.time_percent >= 0){
					mc = MovieClip(Utils.$(ref,'timeline.strip_progress'));
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
			controller.findSeek(Utils.$(ref,'timeline.scrubber').x / (_width-95));
		}
		
		// Consider moving this into the Controller
		protected function mouseHandler(e:MouseEvent):void
		{
			var mc:* = e.currentTarget;
			
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
					var playing:Boolean = model.getPlaying();					
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
				
				mc.playing = model.getPlaying();
				controller.pause();
				
				//set up special stage tracker
				ref.stage.addEventListener(MouseEvent.MOUSE_UP,mouseHandler);
				
				//_timer.start();
				mc.addEventListener(Event.ENTER_FRAME, trackScrubber);
			}
			if(e.type == MouseEvent.MOUSE_UP){
				
				mc = MovieClip(Utils.$(ref,'timeline.scrubber'));
				
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
			if(ref != null){
				var mc:MovieClip;
				mc = MovieClip(Utils.$(ref,"back"));
				mc.graphics.clear();
				Utils.drawRect(mc,_width,20,0x404040,1.0);
			
				var t:MovieClip = MovieClip(Utils.$(ref,"timeline"));
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
				mc = MovieClip(Utils.$(ref,"label"));
				mc.x = _width - 50;
			
				//move the audio
				mc = MovieClip(Utils.$(ref,"audio"));
				mc.x = _width - 10;
			}
		}
	
		protected function renderUI():void
		{
					
			var b:MovieClip = Utils.createmc(ref,"back",{alpha:0.75,mouseEnabled:true});
			Utils.drawRect(b,_width,20,0x404040,1.0);
			b.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			var i:MovieClip,mc:MovieClip;
			
			//VCR stop (back to beginning)
			i = new icons();
			i.gotoAndStop('video_start');
			mc = MovieClip(ref.addChild(i));
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
			mc = MovieClip(ref.addChild(i));
			mc.name = 'video_play';
			mc.buttonMode = true;
			mc.x = 30;
			mc.y = 10;
			mc.addEventListener(MouseEvent.ROLL_OVER,mouseHandler);
			mc.addEventListener(MouseEvent.ROLL_OUT,mouseHandler);
			mc.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			//timeline
			var t:MovieClip = Utils.createmc(ref,"timeline",{x:40,y:10});
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
			
			//if(options.tf != undefined){
			//	tf = options.tf;
			//}
		
			var l:MovieClip = Utils.createmc(ref,"label",{x:_width-50,y:2.5,mouseEnabled:true});
			Utils.makeTextfield(l,"00:00",tf,{width:35});//autoSize:TextFieldAutoSize.RIGHT
			l.addEventListener(MouseEvent.CLICK,mouseHandler);
			l.buttonMode = true;
			
			//audio controls
			i = new icons();
			i.gotoAndStop('audio3');
			mc = MovieClip(ref.addChild(i));
			mc.name = 'audio';
			mc.buttonMode = true;
			mc.x = _width-10;
			mc.y = 10;
			mc.addEventListener(MouseEvent.ROLL_OVER,mouseHandler);
			mc.addEventListener(MouseEvent.ROLL_OUT,mouseHandler);
			mc.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			
		
		}
		
		public function onKill():void
		{
			
		}	

	}

}