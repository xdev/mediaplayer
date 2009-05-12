package us.xdev.mediaplayer.views
{
	import com.a12.util.Utils;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import gs.TweenLite;

	public class Description extends AbstractView
	{
		
		[Embed(source='library.swf', symbol='explore_icons')]
    	private var explore_icons:Class;
		
		public function Description(ref:Object,model:*,controller:*,title:String=null,description:String=null)
		{
			super(ref,model,controller);
			
			ref.alpha = 0.0;
			TweenLite.to(ref,0.5,{alpha:1.0});
			
			//create back
			//Utils.drawRect(Utils.createmc(ref,'back',{alpha:0.8}),ref.stage.stageWidth,ref.stage.stageHeight,0x000000,1.0);
			Utils.drawRoundRect(Utils.createmc(ref,'back',{x:0.5,y:0.5,alpha:0.8}),640,360,0x000000,1.0,10,[1.0,0xFFFFFF,1.0]);
			
			
			var tf:TextFormat = new TextFormat();
			tf.font = 'AG Schoolbook MediumA';
			tf.size = 24;
			tf.color = 0xFFFFFF;
			
			var tf2:TextFormat = new TextFormat();
			tf2.font = 'AG Schoolbook RegularA';
			tf2.size = 12;
			tf2.color = 0xFFFFFF;
			
			//title
			if(title){
				var t:TextField = Utils.makeTextfield(Utils.createmc(ref,'t1',{x:20,y:20}),title,tf,{width:600});
			}
			
			//text
			if(description){
				Utils.makeTextfield(Utils.createmc(ref,'t2',{x:20,y:20 + t.textHeight + 6}),description,tf2,{width:500});
			}
			
			ref.stage.addEventListener(Event.RESIZE, onResize,false,0,true);
			
			ref.mouseEnabled = true;
			ref.buttonMode = true;
			ref.addEventListener(MouseEvent.CLICK,handleMouse,false,0,true);
			
		}
		
		private function handleMouse(e:MouseEvent):void
		{
			controller.closeScreen();
		}
		
		public function setSize(w:int,h:int):void
		{
			
		}
		
		private function onResize(e:Event = null):void
		{
			var mc:MovieClip = Utils.$(ref,'back');
			//mc.graphics.clear();
			//Utils.drawRect(mc,ref.stage.stageWidth,ref.stage.stageHeight,0x000000,1.0);
		}
				
	}
	
}