package us.xdev.mediaplayer.controllers
{

	import flash.events.KeyboardEvent;
	import flash.external.ExternalInterface;
	import flash.ui.Keyboard;
	import flash.utils.clearTimeout;
	
	import com.a12.util.CustomEvent;

	public class PlayerController
	{

		private var model:*;
		private var view:*;

		public function PlayerController(model:*,view:*=null)
		{
			this.model = model;
			this.view = view;
		}
		
		public function setView(view:*):void
		{
			this.view = view;
		}

		private function handleTransport(e:CustomEvent):void
		{
			if(e.props.mode == true){
				sendExternal('playMedia');
			}else{
				sendExternal('stopMedia');
			}
		}

		public function sendExternal(e:String,args:Array=null):void
		{
			return;
			
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

		public function viewSlideByIndex(value:Number):void
		{
			model.setSlide(value);			
		}
		
		public function advanceSlide(dir:int):void
		{
			clearTimeout(view.slideInterval);
			model.advanceSlide(dir);
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
					
					//	MP.toggle();
					
				break;

				case 70:
					view.toggleFullScreen();
				break;

				case 83:
					view.toggleSlideShow();
				break;

				case 84:
					view.toggleThumbs();
				break;
				
			}
		
		}

	}

}
