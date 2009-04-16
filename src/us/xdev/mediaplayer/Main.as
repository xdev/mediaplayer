package us.xdev.mediaplayer
{
	import us.xdev.mediaplayer.controllers.PlayerController;
	import us.xdev.mediaplayer.models.PlayerModel;
	import us.xdev.mediaplayer.views.Player;
	
	import flash.display.Sprite;
		
	public class Main extends Sprite
	{
				
		public function Main()
		{
			
			var model:PlayerModel = new	PlayerModel(root.loaderInfo.parameters);
			var controller:PlayerController = new PlayerController(model);
			var view:Player = new Player(model,controller);			
			
		}
				
	
	}
	
}
