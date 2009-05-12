package us.xdev.mediaplayer.views
{
	import com.a12.util.Utils;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import gs.TweenLite;

	public class Share extends AbstractView
	{
		
		[Embed(source='library.swf', symbol='explore_icons')]
    	private var explore_icons:Class;
		
		public function Share(ref:Object,model:*,controller:*)
		{
			super(ref,model,controller);
			
			ref.alpha = 0.0;
			TweenLite.to(ref,0.5,{alpha:1.0});
			
			//create back
			//Utils.drawRect(Utils.createmc(ref,'back',{alpha:0.8}),ref.stage.stageWidth,ref.stage.stageHeight,0x000000,1.0);
			Utils.drawRoundRect(Utils.createmc(ref,'back',{x:0.5,y:0.5,alpha:0.8}),640,360,0x000000,1.0,10,[1.0,0xFFFFFF,1.0]);
			
			//add png
			var i:* = new explore_icons();
			i.gotoAndStop('screen_share');
			i.name = 'screen';
			ref.addChild(i);
			
			ref.stage.addEventListener(Event.RESIZE, onResize,false,0,true);
			ref.mouseEnabled = true;
			ref.buttonMode = true;
			ref.addEventListener(MouseEvent.CLICK,handleMouse,false,0,true);
			
		}
		
		private function handleMouse(e:MouseEvent):void
		{
			controller.closeScreen();
		}
		
		private function onResize(e:Event = null):void
		{
			var mc:MovieClip = Utils.$(ref,'back');
			//mc.graphics.clear();
			//Utils.drawRect(mc,ref.stage.stageWidth,ref.stage.stageHeight,0x000000,1.0);
		}
				
	}
	
}