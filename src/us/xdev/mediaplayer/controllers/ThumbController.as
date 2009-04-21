package us.xdev.mediaplayer.controllers
{

	public class ThumbController
	{

		private var model:*;

		public function ThumbController(model:*)
		{
			this.model = model;
		}
		
		public function viewSlide(id:int):void
		{
			model.setSlide(id);
		}
		
	}
	
}