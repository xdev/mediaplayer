package us.xdev.mediaplayer.pattern
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class AbstractView extends Sprite
	{
		
		protected var model:Object;
		protected var controller:Object;
		protected var childA:Array;
		
		public function AbstractView(model:Object,controller:Object=null)
		{
			this.model = model;
			this.controller = controller;
			childA = new Array();
		}
		
		public function add(view:AbstractView):void
		{
			childA.push(view);
		}
		
		public function remove(view:AbstractView):void
		{
			for(var i:int=0;i<childA.length;i++){
				if(childA[i] == view){
					childA.splice(i,1);
				}
			}
		}
		
		public function get(i:int):AbstractView
		{
			return childA[i];
		}
		
		public function update(event:Event=null):void
		{
			
		}
		
	}
	
}