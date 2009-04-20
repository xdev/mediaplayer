package us.xdev.mediaplayer.models
{
	import com.a12.util.CustomEvent;
	import com.a12.util.Utils;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class AudioModel extends EventDispatcher implements IMediaModel
	{
	
		private var _file:String;
		
		private var _metaData:Object;
		
		private var _sound:Sound;
		private var _channel:SoundChannel;
		private	var	_volume:Number;
		private var _timer:Timer;
				
		private var _playing:Boolean;		
		private var _position:Number;
		private var _options:Object;
		
		public var b:EventDispatcher = new EventDispatcher();
	
		public function AudioModel(_file:String,_options:Object=null)
		{
			this._file = _file;
			this._options = _options;
			_metaData = {};
			_playing = false;
			_volume = 1.0;	
		}
		
		// --------------------------------------------------------------------
		// Interface Methods
		// --------------------------------------------------------------------
		
		public function load():void
		{
			playMedia();
		}
		
		public function stopStream():void
		{
			_channel.stop();
			_position = 0;
			_channel = _sound.play(_position);	
			_playing = false;	
			_channel.stop();
			updateView();
			dispatchPlaybackStatus(false);
		}
		
		public function playStream():void
		{
			_channel.stop();
			_channel = _sound.play(_position);
			_setVolume();
			_playing = true;
			updateView();
			dispatchPlaybackStatus(true);
		}
		
		public function pauseStream():void
		{
			switch(true){
				case _playing == true:
					_position = _channel.position;
					_channel.stop();
					_playing = false;
					dispatchPlaybackStatus(false);
				break;
			
				case _playing == false:
					_channel.stop();
					_channel = _sound.play(_position);
					_playing = true;
					_setVolume();
					dispatchPlaybackStatus(true);
				break;
			}
			updateView();
		}
		
		public function toggleStream():void
		{
			pauseStream();
		}
			
		public function seekStream(time:Number):void
		{
			_channel.stop();
			_channel = _sound.play(time);
			_position = time;
			_setVolume();
			_playing = true;
		}
	
		public function seekStreamPercent(percent:Number):void
		{
			seekStream(percent * _sound.length);
		}
		
		public function toggleAudio():void
		{
			
		}
		
		public function setVolume(value:Number):void
		{
			_volume = value;
			_setVolume();
		}
		
		public function setBuffer(value:Number):void
		{
			
		}
	
		public function getPlaying():Boolean
		{
			return _playing;
		}
		
		public function kill():void
		{
			_channel.stop();
			_channel = null;
			_sound = null;
			_playing = false;
			_timer.stop();
			_timer = null;
		}
		
		private function update(obj:Object):void
		{
			dispatchEvent(new CustomEvent('onUpdate',true,true,obj));
		}
		
		// --------------------------------------------------------------------
		// Class Methods
		// --------------------------------------------------------------------
		private function _setVolume():void
		{
			var transform:SoundTransform = new SoundTransform();
			transform.volume = _volume;
			_channel.soundTransform = transform;
		}
		
		private function streamStatus(obj:Object):void
		{
			trace(obj.code);
		}
			
		private function playMedia():void
		{
			_metaData = {};		
		
			var tObj:Object = {};		
		
			_sound = new Sound();
			var req:URLRequest = new URLRequest(_file);
			//true
			
			_sound.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_sound.addEventListener(Event.COMPLETE, onComplete);
			_sound.addEventListener(Event.ID3, id3Handler);
			
			/*
			new SoundLoaderContext(_bufferTime,true)
			*/
			
			_sound.load(req);
			
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, updateView);
			_timer.start();
			
			_channel = _sound.play();
			_playing = true;
			
			update(tObj);
			
			if(_options.paused == true){
				stopStream();
			}
		}
	
		private function onComplete(e:Event):void
		{
			update({action:'mediaComplete'});
		}
	
		private function onLoad(e:Event):void
		{
			update({action:'onLoad'});
		}
		
		private function progressHandler(e:Event):void
		{
			
		}
		
		private function id3Handler(e:Event):void
		{
			
		}
		
		private function dispatchPlaybackStatus(mode:Boolean):void
		{
			/*
			var tObj = {};
			tObj.action = 'onTransportChange';
			tObj.mode = mode;
			tObj.file = _file;
			setChanged();
			update(tObj);
			*/
			b.dispatchEvent(new CustomEvent('onTransportChange',true,false,{mode:mode,file:_file}));
		}
	
		private function updateView(e:TimerEvent=null):void
		{
			var tObj:Object = {};
		
			tObj.action = "updateView";
			tObj.time_current = Utils.convertSeconds(Math.floor(_channel.position/1000));
			tObj.time_duration = Utils.convertSeconds(Math.floor(_sound.length/1000));
			tObj.time_remaining = Utils.convertSeconds(Math.floor(_sound.length/1000) - Math.floor(_channel.position/1000));
			tObj.time_percent = Math.floor(((_channel.position/1000) / Math.floor(_sound.length/1000)) * 100);
			tObj.loaded_percent = Math.floor((_sound.bytesLoaded / _sound.bytesTotal) * 100);
			tObj.playing = _playing;
				
			update(tObj);			
		
		}
	
	}

}