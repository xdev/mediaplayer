package us.xdev.mediaplayer.models
{

	import com.a12.util.CustomEvent;
	import com.a12.util.Utils;
	
	import flash.display.MovieClip;
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.media.Video;
	import flash.utils.Timer;

	public class VideoModel extends EventDispatcher implements IMediaModel
	{
	
		private var _file:String;
		private var _stream:NetStream;
		private var _connection:NetConnection;
		private var _video:Video;
		private var _timer:Timer;
		private var _metaData:Object;		
		private var _playing:Boolean;
		private var _options:Object;
		
		public var b:EventDispatcher = new EventDispatcher();
	
		public function VideoModel(_file:String,_options:Object=null)
		{
			this._file = _file;
			this._options = _options;
			_metaData = {};
			_playing = false;
		}
		
		// --------------------------------------------------------------------
		// Interface Methods
		// --------------------------------------------------------------------
		
		public function load():void
		{
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_connection.connect(null);
		}
		
		public function stopStream():void
		{
			pauseStream();
			seekStream(0);
			_playing = false;
			dispatchPlaybackStatus(false);
		}
		
		public function playStream():void
		{
			_stream.resume();
			_playing = true;
			dispatchPlaybackStatus(true);
		}		
	
		public function pauseStream():void
		{
			_stream.pause();
			_playing = false;
			dispatchPlaybackStatus(false);
		}
		
		public function toggleStream():void
		{
			_playing = !_playing;			
			_stream.togglePause();
			//is there an event listener to for this
			if(_playing){
				dispatchPlaybackStatus(true);
			}else{
				dispatchPlaybackStatus(false);
			}
		}	
			
		public function seekStream(time:Number):void
		{
			_stream.seek(time);
			_playing = true;
		}
	
		public function seekStreamPercent(percent:Number):void
		{
			seekStream(percent * _metaData.duration);
		}
		
		public function toggleAudio():void
		{
			
		}
		
		public function setVolume(value:Number):void
		{
			var transform:SoundTransform = new SoundTransform();
			transform.volume = value;
			_stream.soundTransform = transform;
		}
		
		public function setBuffer(value:Number):void
		{
			_stream.bufferTime = value;
		}
			
		public function getPlaying():Boolean
		{
			return _playing;
		}
	
		public function kill():void
		{
			_stream.close();
			_stream = null;
			_connection = null;
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
		
		private function cuePointHandler(obj:Object):void
		{
			//obj.name + obj.time
		}
		
		private function dispatchPlaybackStatus(mode:Boolean):void
		{
			var tObj:Object = {};
			tObj.action = 'onTransportChange';
			tObj.mode = mode;
			tObj.file = _file;
			update(tObj);
		}
		
		private function onMetaData(obj:Object):void
		{
			//should run only once!
			if(obj.width && _metaData.width == undefined){
				var tObj:Object = {};
				tObj.action = 'updateSize';
				tObj.video = _video;
				tObj.width =  obj.width;
				tObj.height = obj.height;								
				update(tObj);
			}
		
			for(var i:Object in obj){
				_metaData[i] = obj[i];			
				if(i == 'duration'){
					_metaData.durationObj = Utils.convertSeconds(Math.floor(obj[i]));
				}
			}
		}
		
		private function netStatusHandler(event:NetStatusEvent):void
		{
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					playMedia();
				break;
				
				case "NetStream.Play.StreamNotFound":
					//trace("Unable to locate video: " + videoURL);
				break;
				
				case "NetStream.Play.Stop":
					onComplete();
				break;
			}
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
            trace("securityErrorHandler: " + event);
        }

        private function asyncErrorHandler(event:AsyncErrorEvent):void
		{
            // ignore AsyncErrorEvent events.
        }

		private function connectStream():void
		{
			
		}
	
		private function playMedia():void
		{
			_stream = new NetStream(_connection);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			//check buffer time son
			if(_options.buffer != undefined){
				setBuffer(_options.buffer);
			}
			
			var clientObj:Object = {};
			clientObj.onMetaData = onMetaData;
			clientObj.onCuePoint = cuePointHandler;
			_stream.client = clientObj;
			_stream.play(_file);
			_video = new Video();
			_video.attachNetStream(_stream);			
			
			_playing = true;	
					
			var tObj:Object = {};
			tObj.action = 'playVideo';
			tObj.stream = _stream;
			tObj.video = _video;		
			tObj.playing = _playing;
			update(tObj);
			
			dispatchPlaybackStatus(true);
			
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, updateView);
			_timer.start();
			
			if(_options.paused == true){
				stopStream();
			}			
			
		}
	
		private function updateView(e:TimerEvent=null):void
		{
			//convert time in seconds to 00:00
			var tObj:Object = {};
		
			tObj.action = "updateView";
			tObj.time_current = Utils.convertSeconds(Math.floor(_stream.time));
			if(_metaData.durationObj != undefined){
				tObj.time_duration = _metaData.durationObj;
				tObj.time_percent = Math.floor((_stream.time / _metaData.duration) * 100);
				tObj.time_remaining = Utils.convertSeconds(_metaData.duration - Math.floor(_stream.time));
				//this is specifically for flv files encoded in 3rd party tools that do not produce the 
				//Netstream.Play.Stop command
				//Need to add another condition that checks the playstate			
			
				if(Math.ceil(_stream.time) == Math.ceil(_metaData.duration)){
					//onComplete();
				}
			}
		
			tObj.loaded_percent = Math.floor((_stream.bytesLoaded / _stream.bytesTotal) * 100);		
			tObj.playing = _playing;
			
			update(tObj);
		}
	
		private function onComplete():void
		{
			update({action:'mediaComplete'});
		}
	
	}

}