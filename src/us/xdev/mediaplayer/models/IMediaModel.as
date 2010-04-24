package us.xdev.mediaplayer.models
{
	import flash.events.IEventDispatcher;
	
	public interface IMediaModel extends IEventDispatcher
	{
		function load():void;
		
		function stopStream():void;
		
		function playStream():void;
		
		function pauseStream():void;
		
		function toggleStream():void;
		
		function seekStream(time:Number):void;
		
		function seekStreamPercent(percent:Number):void;
		
		function toggleAudio():void;
		
		function setVolume(value:Number):void;
		
		function setBuffer(value:Number):void;
		
		function getPlaying():Boolean;
		
		function kill():void;
		
	}
}