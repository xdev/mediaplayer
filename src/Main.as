package
{
	import us.xdev.mediaplayer.controllers.PlayerController;
	import us.xdev.mediaplayer.models.PlayerModel;
	import us.xdev.mediaplayer.views.Player;
	
	import flash.system.Capabilities;	
	import flash.display.Sprite;
	
	[SWF(frameRate="30", backgroundColor="#000000")]
		
	public class Main extends Sprite
	{
		public function Main()
		{
			var params:Object = root.loaderInfo.parameters;
			
			if(Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone"){
				params = {};
				params.xml = 'http://mediaplayer.local/demo_slideshow.xml';
				//params.still = 'http://explore.local/assets/img/sample/video_still.jpg';
				//rtmp://url/vod/
				//params.server = 'rtmp://beta.fms.edgecastcdn.net/000C21/videos/';
				//params.src = 'Adrenaline_Junkie-Explore_700kbit_16x9.mov';
			}
			
			var model:PlayerModel = new	PlayerModel(params);
			var controller:PlayerController = new PlayerController(model);
			var view:Player = new Player(this,model,controller);
			controller.setView(view);
			model.addEventListener('onUpdate',view.update);
			model.init();
		}
	
	}
	
}