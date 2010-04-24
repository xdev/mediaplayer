package us.xdev.mediaplayer.models
{
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.utils.Timer;
	
	import com.a12.util.CustomEvent;
	import com.a12.util.Utils;
	
	public class VideoModel extends EventDispatcher implements IMediaModel
	{
		//TODO: remove this, use internal messaging
		public var b:EventDispatcher = new EventDispatcher();
		
		private var _file:String;
		private var _stream:NetStream;
		private var _connection:NetConnection;
		private var _video:Video;
		private var _timer:Timer;
		private var _metaData:Object;
		private var _playing:Boolean;
		private var _options:Object;
		private var _serverVersion:String;
		private var _availableBandwidth:Number;
		private var _performBandwidthTest:Boolean;
		
		public function VideoModel(_file:String, _options:Object=null)
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
			var clientObj:Object = {};
			clientObj.onBWDone = onBWDone;
			clientObj.onBWCheck = onBWCheck;
			_connection.client = clientObj;
			_connection.connect(_options.server);
		}
		
		public function stopStream():void
		{
			seekStream(0);
			pauseStream();
			_playing = false;
			dispatchPlaybackStatus(false, 'stop');
		}
		
		public function playStream():void
		{
			_stream.resume();
			_playing = true;
			dispatchPlaybackStatus(true, 'play');
		}
		
		public function pauseStream():void
		{
			_stream.pause();
			_playing = false;
			dispatchPlaybackStatus(false, 'pause');
		}
		
		public function toggleStream():void
		{
			_playing = !_playing;
			_stream.togglePause();
			//is there an event listener to for this
			if(_playing){
				dispatchPlaybackStatus(true, 'toggle');
			}else{
				dispatchPlaybackStatus(false, 'toggle');
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
			update({action:'onVolumeChange', volume:value});
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
		
		public function switchStream(_file:String, pos:Number=0):void
		{
			_stream.play(formatFile(_file), pos);
		}
		
		private function update(obj:Object):void
		{
			dispatchEvent(new CustomEvent('onUpdate', true, true, obj));
		}
		// --------------------------------------------------------------------
		// Class Methods
		// --------------------------------------------------------------------
		
		private function cuePointHandler(obj:Object):void
		{
			//obj.name + obj.time
		}
		
		//Hack, this is for the external interface, example sound board
		private function dispatchPlaybackStatus(mode:Boolean, action:String):void
		{
			var tObj:Object = {};
			tObj.action = 'onTransportChange';
			tObj._action = action;
			tObj.mode = mode;
			tObj.file = _file;
			update(tObj);
		}
		
		private function onBWDone( ... rest ):void
		{
			_availableBandwidth = rest[0];
			update({ action:'onBandwidth', bandwidth:_availableBandwidth });
		}
		
		private function onBWCheck( ... rest ):Number
		{
			return 0;
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
				
				if(_options.paused == true){
					stopStream();
					update({ action:'onMetaData' });
				}
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
			switch (event.info.code){
				case 'NetConnection.Connect.Success':
					playMedia();
				break;
				
				case 'NetStream.Buffer.Full':
				
				break;
				
				case 'NetStream.Buffer.Empty':
					trace('Buffer Empty');
					if(_playing){
						//update({action:'onQOSFail'});
					}
				break;
				
				case 'Netstream.Play.InsufficientBW':
					trace('insufficientBW');
					if(_playing){
						update({action:'onQOSFail'});
					}
				break;
					
				case 'NetStream.Play.StreamNotFound':
				case 'NetConnection.Connect.Failed':
					
				break;
				
				case 'NetConnection.Connect.Rejected':
					
				break;
				
				case 'NetStream.Seek.Notify':
					
				break;
				
				case 'NetStream.Seek.Failed':
					
				break;
				
				case 'NetStream.Play.Stop':
					//evaluate position
					if(_stream && _metaData && _metaData.duration){
						if(Math.ceil(_stream.time) == Math.ceil(_metaData.duration)){
							onComplete();
						}
					}else{
						if(_stream){
							playStream();
						}
					}
				break;
			}
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void
		{
			
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void
		{
			// ignore AsyncErrorEvent events.
		}
		
		private function streamLengthHandler(len:Number):void
		{
			//onData({type:'streamlength',duration:len});
		}
		
		private function formatFile(file:String):String
		{
			var ext:String = file.substr(file.lastIndexOf('.')+1, file.length).toLowerCase();
			var basename:String = file.substr(0, file.lastIndexOf('.'));
			if(ext == 'mp4' || ext == 'mov' || ext == 'aac' || ext == 'm4a'){
				return 'mp4:'+ file;
			} else if (ext == 'flv' && _options.server != null){
				return basename;
			} else {
				return file;
			}
		}
		
		private function playMedia():void
		{
			_stream = new NetStream(_connection);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			if(_options.buffer != undefined){
				setBuffer(_options.buffer);
			}
			
			var clientObj:Object = {};
			clientObj.onMetaData = onMetaData;
			clientObj.onCuePoint = cuePointHandler;
			_stream.client = clientObj;
			_stream.play(formatFile(_file),0);
			var res:Responder = new Responder(streamLengthHandler);
			_connection.call("getStreamLength", res, _file);
			_connection.call("checkBandwidth", null);
			
			_video = new Video();
			_video.attachNetStream(_stream);
			_playing = true;
			
			var tObj:Object = {};
			tObj.action = 'playVideo';
			tObj.stream = _stream;
			tObj.video = _video;
			tObj.playing = _playing;
			update(tObj);
			
			dispatchPlaybackStatus(true, 'init');
			
			_timer = new Timer(100);
			_timer.addEventListener(TimerEvent.TIMER, updateView);
			_timer.start();
		}
		
		public function getStreamTime():Number
		{
			var r:Number = 0;
			if(_stream){
				if(_stream.time){
					r = _stream.time;
				}
			}
			return r;
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
				
				/*
				this is specifically for flv files encoded in 3rd party tools that do not produce the
				Netstream.Play.Stop command
				Need to add another condition that checks the playstate
				*/
				
				if(Math.ceil(_stream.time) == Math.ceil(_metaData.duration)){
					onComplete();
				}
				
				if(_playing && _stream.currentFPS < 6 && _stream.bufferLength < 0.5){
					trace('updateView, found crappy performance');
					//update({action:'onQOSFail'});
				}
			}
			
			tObj.loaded_percent = Math.floor((_stream.bytesLoaded / _stream.bytesTotal) * 100);
			tObj.playing = _playing;
			
			update(tObj);
			
		}
		
		private function onComplete():void
		{
			update({ action:'onMediaComplete' });
		}
	}
}