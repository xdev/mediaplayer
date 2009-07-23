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
				
		[Embed(source='library.swf', symbol='Arial')]
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
						
			_timeMode = false;
			_soundLevelA = [0.0,0.2,0.6,1.0];
			_soundLevel = 3;
			_scrubberWidth = 8;
						
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
		
		protected function toggleTime():void
		{
			_timeMode = !_timeMode;
		}
		
		protected function toggleAudio():void
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
						txt = '-' + '00:' + Utils.padZero(infoObj.time_remaining.minutes) + ':' + Utils.padZero(Math.ceil(infoObj.time_remaining.seconds));
					}
				break;
				
				case false:
					if(infoObj.time_current){
						txt = '00:' + Utils.padZero(infoObj.time_current.minutes) + ':' + Utils.padZero(infoObj.time_current.seconds);
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
					
				var factor:Number = (_width-(50+64)) / 100;
			
				var mc:MovieClip;
				
				//if dragging false
				if(infoObj.time_percent != undefined){
					mc = MovieClip(Utils.$(ref,'timeline.scrubber'));
					if(mc.dragging == false){
						mc.x = infoObj.time_percent * ((_width-(100+64))-(_scrubberWidth/2)) / 100;
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
					mc.graphics.clear();
					mc.percent = infoObj.loaded_percent;
					Utils.drawRoundRect(mc,(infoObj.loaded_percent/100)*(_width-(95+64)),11,0x808080,1.0,10);
					//mc.scaleX = infoObj.loaded_percent / 100;
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
		
		protected function trackScrubber(e:Event):void
		{
			controller.findSeek(Utils.$(ref,'timeline.scrubber').x / (_width-(100+64)-(_scrubberWidth/2)));
		}
		
		// Consider moving this into the Controller
		protected function mouseHandler(e:MouseEvent):void
		{
			var mc:* = e.currentTarget;
			trace(mc.name);
			
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
				if(mc.name == 'strip_hit'){
					
					var playing:Boolean = model.getPlaying();					
					controller.findSeek(mc.mouseX / (_width-(100+64)));
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
				rect.top = 5.5;
				rect.bottom = 5.5;
				rect.left = _scrubberWidth/2 + 1.5;
				rect.right = _width-(100+64)-(_scrubberWidth/2);
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
				controller.findSeek(mc.x / (_width-(100+64)-(_scrubberWidth/2)));
				
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
		
		protected function layoutUI():void
		{
			if(ref != null){
				var mc:MovieClip;
				mc = MovieClip(Utils.$(ref,"back"));
				mc.graphics.clear();
				Utils.drawRoundRect(mc,_width,40,0x000000,1.0,8.0);
			
				var t:MovieClip = MovieClip(Utils.$(ref,"timeline"));
				mc = MovieClip(Utils.$(t,"strip_back"));
				mc.graphics.clear();
				//mc:MovieClip, w:Number, h:Number, rgb:Number, alpha:Number = 1.0, radius:Number = 10, lineStyle:Array = null
				Utils.drawRoundRect(mc,_width-100,10,0xCCCCCC,0.0,10,[1.0,0xFFFFFF,1.0]);
				
				mc = Utils.$(ref,'timeback');
				mc.x = _width-(64+50)+0.5;
			
				mc = MovieClip(Utils.$(t,"strip_hit"));
				mc.graphics.clear();
				Utils.drawRect(mc,_width-(50+64),12,0xFF0000,0.0);
			
				mc = MovieClip(Utils.$(t,"strip_load"));
				mc.graphics.clear();
				if(mc.percent){
					Utils.drawRoundRect(mc,(mc.percent/100)*(_width-(95+64)),11,0x808080,1.0,10);
				}
				//Utils.drawRect(mc,_width-164,8,0xFFFFFF,1.0);
			
				mc = MovieClip(Utils.$(t,"strip_progress"));
				mc.graphics.clear();
				//Utils.drawRect(mc,_width-95,8,0x808080,1.0);
			
				//move the label
				mc = MovieClip(Utils.$(ref,"label"));
				mc.x = _width - 100;
			
				//move the audio
				mc = MovieClip(Utils.$(ref,"audio"));
				mc.x = _width - 25;
			}
		}
	
		protected function renderUI():void
		{
					
			var b:MovieClip = Utils.createmc(ref,"back",{alpha:0.68,mouseEnabled:true});
			Utils.drawRoundRect(b,_width,40,0x000000,1.0,8.0);
			b.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			var i:MovieClip,mc:MovieClip;
			
			//VCR stop (back to beginning)
			
			i = new icons();
			i.gotoAndStop('video_start');
			mc = MovieClip(ref.addChild(i));
			mc.name = 'video_start';
			mc.buttonMode = true;
			mc.x = 15;
			mc.y = 20;
			mc.addEventListener(MouseEvent.ROLL_OVER,mouseHandler);
			mc.addEventListener(MouseEvent.ROLL_OUT,mouseHandler);
			mc.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			
			//play/pause
			i = new icons();
			i.gotoAndStop('video_play');
			mc = MovieClip(ref.addChild(i));
			mc.name = 'video_play';
			mc.buttonMode = true;
			mc.x = 35;
			mc.y = 20;
			mc.addEventListener(MouseEvent.ROLL_OVER,mouseHandler);
			mc.addEventListener(MouseEvent.ROLL_OUT,mouseHandler);
			mc.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			//timeline
			var t:MovieClip = Utils.createmc(ref,"timeline",{x:50,y:14});
			mc = Utils.createmc(t,"strip_back",{x:0.5,y:0.5,mouseEnabled:true});
			mc.buttonMode = true;
			//Utils.drawRect(mc,_width-100,10,0x000000,0.0,[1.0,0xFFFFFF,1.0]);
			
			i = new icons();
			i.gotoAndStop('timeback');
			mc = MovieClip(ref.addChild(i));
			mc.name = 'timeback';
			mc.x = _width - (64+50) + 0.5;
			mc.y = 14.5;
			
			var h:MovieClip = Utils.createmc(t,"strip_hit",{mouseEnabled:true});
			Utils.drawRect(h,_width-(50+64),12,0xFF0000,0.0);
			h.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			h = Utils.createmc(t,"strip_load",{x:0.5,y:0.5});
			t.setChildIndex(h,0);
			//Utils.drawRect(h,_width-95,8,0xFFFFFF,1.0);
			
			//not used in this design
			h = Utils.createmc(t,"strip_progress",{y:0,scaleX:0.0,alpha:0.0});
			Utils.drawRect(h,_width-95,8,0x808080,1.0);		
			
			//scrubber
			i = Utils.createmc(t,"scrubber",{y:5.5,dragging:false,mouseEnabled:true});
			i.buttonMode = true;
			i.addEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
			Utils.drawCircle(Utils.createmc(i,'icon'), 0xFFFFFF, 1.0, _scrubberWidth/2);
			Utils.drawCircle(Utils.createmc(i,'hit',{}), 0xFFFFFF, 0.0, _scrubberWidth);
			
			
			//_timer = new Timer(20);
			//_timer.addEventListener(TimerEvent.TIMER, trackScrubber);			
			//i.addEventListener(MouseEvent.MOUSE_MOVE,mouseHandler);
			
			//progress label
			var tf:TextFormat = new TextFormat();
			tf.font = "Arial";
			tf.size = 8;
			tf.color = 0x000000;
			
			/*
			if(options.tf != undefined){
				tf = options.tf;
			}
			*/
		
			var l:MovieClip = Utils.createmc(ref,"label",{x:_width-100,y:13,mouseEnabled:true});
			Utils.makeTextfield(l,"00:00:00",tf,{width:50});//autoSize:TextFieldAutoSize.RIGHT
			l.addEventListener(MouseEvent.CLICK,mouseHandler);
			l.buttonMode = true;
			
			//audio controls
			i = new icons();
			i.gotoAndStop('audio3');
			mc = MovieClip(ref.addChild(i));
			mc.name = 'audio';
			mc.buttonMode = true;
			mc.x = _width-25;
			mc.scaleX = 1.5;
			mc.scaleY = 1.5;
			mc.y = 20;
			mc.addEventListener(MouseEvent.ROLL_OVER,mouseHandler);
			mc.addEventListener(MouseEvent.ROLL_OUT,mouseHandler);
			mc.addEventListener(MouseEvent.CLICK,mouseHandler);
			
			
		
		}
		
		public function onKill():void
		{
			
		}	

	}

}