package us.xdev.mediaplayer.controllers
{

	import flash.events.KeyboardEvent;
	import flash.external.ExternalInterface;
	import flash.ui.Keyboard;

	import com.a12.util.CustomEvent;

	public class PlayerController
	{

		private var model:*;

		public function PlayerController(model:*)
		{
			this.model = model;
		}

		private function handleTransport(e:CustomEvent):void
		{
			if(e.props.mode == true){
				sendExternal('playMedia');
			}else{
				sendExternal('stopMedia');
			}
		}

		private function sendExternal(e:String,args:Array=null):void
		{
			var _args:Array = [];
			_args.push(e);
			if(args){
				for(var i:int=0;i<args.length;i++){
					_args.push(args[i]);
				}
			}
			var method:Function = ExternalInterface.call;
			method.apply(ExternalInterface,_args);
		}

		public function toggleFullScreen():void
		{
			//Move to View, since this is purely visual..?
			/*
			switch(true){

				case stage.displayState == "fullScreen":
					stage.displayState = "normal";
				break;

				case stage.displayState == "normal":
					stage.displayState = "fullScreen";
				break;

			}
			*/

		}

		public function viewSlideByIndex(value:Number):void
		{
			model.setSlide(value);			
		}

		public function toggleSlideShow():void
		{
			/*
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
			*/
		}

		public function advanceSlide(dir:int):void
		{
			//clearTimeout(slideInterval);
			model.advanceSlide(dir);			

			//viewSlide();

		}

		public function handleKey(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.LEFT:
					if(model.slideMax>1){
						advanceSlide(-1);
					}
				break;

				case Keyboard.RIGHT:
					if(model.slideMax>1){
						advanceSlide(1);
					}
				break;

				case 38:
					if(model.slideMax>1){
						advanceSlide(-1);
					}
				break;

				case 40:
					if(model.slideMax>1){
						advanceSlide(1);
					}
				break;

				case Keyboard.SPACE:
					//if(MP){
					//	MP.toggle();
					//}
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
			//toggleThumbs(false);
		}

	}

}
