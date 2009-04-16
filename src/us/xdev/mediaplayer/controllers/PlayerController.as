package us.xdev.mediaplayer.controllers
{
	
	public class PlayerController
	{

		private function sendExternal(e:String,args:Array=null):void
		{
			//if we are supposed to send
			var _args = [];
			_args.push(e);
			if(args){
				for(var i=0;i<args.length;i++){
					_args.push(args[i]);
				}
			}
			var method = ExternalInterface.call;			
			method.apply(ExternalInterface,_args);
		}

		private function toggleFullScreen():void
		{
			switch(true){
	
				case stage.displayState == "fullScreen":
					stage.displayState = "normal";
				break;
		
				case stage.displayState == "normal":
					stage.displayState = "fullScreen";
				break;
		
			}	
			
		}
		
		private function toggleSlideShow():void
		{
			showUI();
			flagPlaying = !flagPlaying;
			if(flagPlaying){
				//
				if(flagThumbs){
					toggleThumbs();
				}
				advanceSlide(1);
			}else{
				clearInterval(progressInterval);
			}
			clearTimeout(slideInterval);			
			updateSlideShowState();
		}
		
		private function advanceSlide(dir:int):void
		{
			clearTimeout(slideInterval);
			switch(true)
			{
				case slideIndex + dir > slideMax - 1:
					slideIndex = 0;
				break;

				case slideIndex + dir < 0:
					slideIndex = slideMax - 1;
				break;

				default:
					slideIndex += dir;
				break;
			}
				
			viewSlide();
				
		}
		
		private function keyListener(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.LEFT:
					if(slideMax>1){
						advanceSlide(-1);
					}
				break;
		
				case Keyboard.RIGHT:
					if(slideMax>1){
						advanceSlide(1);
					}
				break;
		
				case 38:
					if(slideMax>1){
						advanceSlide(-1);
					}
				break;
		
				case 40:
					if(slideMax>1){
						advanceSlide(1);
					}
				break;
		
				case Keyboard.SPACE:
					if(MP){
						MP.toggle();
					}
				break;
				/*
				case 70:
					toggleFullScreen();
				break;
		
				case 83:
					toggleSlideShow();				
				break;
		
				case 84:			
					toggleThumbs();
				break;
				*/
			}
		}
		
		private function handleThumb(e:CustomEvent):void
		{
			viewSlideByIndex(e.props.id);
			toggleThumbs(false);
		}
	
		
	}

}
