package us.xdev.mediaplayer.controllers
{

	public class TransportController
	{

		private var model:*;

		public function TransportController(model:*)
		{
			this.model = model;
		}
		
		public function toggleSound():void
		{
			model.toggleSound();		
		}
		
		public function setVolume(value:Number):void
		{
			model.setVolume(value);		
		}
	
		public function pause():void
		{
			model.pauseStream();
		}
		
		public function toggle():void
		{
			model.toggleStream();
		}
	
		public function play():void
		{
			model.playStream();
		}	
	
		public function stop():void
		{
			model.stopStream();
		}	
	
		public function findSeek(percent:Number):void
		{
			model.seekStreamPercent(percent);
		}
					
		public function switchStream(file:String,pos:*=null):void
		{
			/*
			if(isNaN(pos)){
				pos = model.getStreamTime();
			}*/
			pos = 0;
			model.switchStream(file,pos);
		}

	}

}