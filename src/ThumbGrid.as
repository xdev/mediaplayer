package
{

	import flash.display.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.events.*;
	import flash.text.*;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.geom.Rectangle;
	
	//import com.a12.util.*;
	import com.a12.util.Utils;
	import com.a12.util.CustomEvent;
	import com.a12.util.LoadMovie;
	
	import com.a12.modules.mediaplayback.*;
	
	import com.gs.TweenLite;
	
	public class ThumbGrid
	{
		private var slideA:Array;
		private var _ref:MovieClip;
		private var _parent:Object;
		
		private var thumbWidth:Number;
		private var thumbHeight:Number;
		private var padding:Number;
		
		public function ThumbGrid(_r,_p,_obj)
		{
			_ref = _r;
			_parent = _p;
			slideA = _obj;
			
			thumbWidth = 140;
			thumbHeight = 140;
			padding = 10;
			
			_ref.alpha = 0;
			
			_ref.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener);
			
			//build back block
			var mc = Utils.createmc(_ref,'block',{alpha:0.9});
			Utils.drawRect(mc,_ref.stage.stageWidth,_ref.stage.stageHeight,0x000000,1.0);
			
			//
			mc.mouseEnabled = true;
			//mc.addEventListener(MouseEvent.CLICK,handleMouse,false);
			
			//center oneself
			
			//on resize do stuff
			
			buildGrid();
			_ref.stage.addEventListener(Event.RESIZE,onResize,false,0,true);
			
			TweenLite.to(_ref,0.5,{alpha:1.0});
			
		}
		
		private function handleMouse(e:MouseEvent):void
		{
			var mc = e.currentTarget;
			if(e.type == MouseEvent.MOUSE_OVER){
				Utils.$(mc,'hit').alpha = 1.0;
			}
			if(e.type == MouseEvent.MOUSE_OUT){
				if(mc.state == 'normal'){
					Utils.$(mc,'hit').alpha = 0.0;
				}
			}
			if(e.type == MouseEvent.CLICK){
				//close and load that index son
				_parent.viewSlideByIndex(mc.id);
				_parent.toggleThumbs();
			}
		}
		
		public function onKill():void
		{
			//remove listener
			_ref.stage.removeEventListener(Event.RESIZE,onResize,false);
			_ref.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyListener);
			Utils.$(_ref,'block').removeEventListener(MouseEvent.CLICK,handleMouse,false);
		}
		
		private function keyListener(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.LEFT:
					advanceSlide(-1);
				break;
				
				case Keyboard.RIGHT:
					advanceSlide(1);
				break;
				
				case 38:
					advanceSlide(-1);
				break;
				
				case 40:
					advanceSlide(1);
				break;
			}
		}
		
		private function advanceSlide(dir:Number):void
		{
			trace('dir' + dir);
		}
		
		private function buildGrid():void
		{
			var cont = Utils.createmc(_ref,'cont');
			for(var i=0;i<slideA.length;i++){
				var clip = Utils.createmc(cont,'clip'+i);
				var file = String(slideA[i].thumb);
				
				//What to do if there is no thumb? Display file name?
				clip.id = i;
				clip.state = 'normal';
				//back
				Utils.drawRect(Utils.createmc(clip,'back'),thumbWidth,thumbHeight,0x222222,1.0);
				//img
				var img = Utils.createmc(clip,'img',{alpha:0.0});
				var movie = new LoadMovie(img,file);
				movie.addEventListener(Event.COMPLETE,revealThumb);
				
				//mask
				var m = Utils.createmc(clip,'mask');
				Utils.drawRect(m,thumbWidth,thumbHeight,0x333333,1.0);
				img.mask = m;
				
				//stroke
				Utils.drawRect(Utils.createmc(clip,'hit',{alpha:0.0}),thumbWidth,thumbHeight,0x333333,0.0,[1.0,0xFFFFFF,1.0]);
				
				clip.mouseEnabled = true;
				clip.addEventListener(MouseEvent.MOUSE_OVER,handleMouse,false,0,true);
				clip.addEventListener(MouseEvent.MOUSE_OUT,handleMouse,false,0,true);
				clip.addEventListener(MouseEvent.CLICK,handleMouse,false,0,true);
				
				if(_parent.slideIndex == i){
					clip.state = 'hit';
					Utils.$(clip,'hit').alpha = 1.0;
				}
				
			}
			
			layoutGrid();
		}
		
		private function setIndex(value:Number):void
		{
			
		}
		
		private function revealThumb(e:CustomEvent):void
		{
			//mc
			var mc = e.props.mc;
			
			//assign initial values
			mc._width = mc.width;
			mc._height = mc.height;
			
			//scale
			var scale = Utils.getScale(mc._width,mc._height,thumbWidth,thumbHeight).x/100;
			mc.scaleX = scale;
			mc.scaleY = scale;
			
			//align
			mc.x = Math.ceil((thumbWidth-mc.width)/2);
			mc.y = Math.ceil((thumbHeight-mc.height)/2);			
			
			//fade			
			TweenLite.to(mc,0.5,{alpha:1.0});
			
		}
		
		private function onResize(e:Event):void
		{
			//
			var mc = Utils.$(_ref,'block');
			mc.width = _ref.stage.stageWidth;
			mc.height = _ref.stage.stageHeight;
			//redraw the base, or something
			
			layoutGrid();
		}
		
		private function layoutGrid():void
		{
			/*
			work in a constrained fashion
			
			work in a flexible fashion with fluidity
			
			*/
			
			
			var rowC = 0;
			var rowM = 5;
			var colC = 0;
			var colM = 5;
			
			//begin 1001 journals code
			
			var tx = _ref.stage.stageWidth - ((thumbWidth+padding)*1);

			colM = Math.floor(tx/(thumbWidth+padding));

			if(colM > 5){
				//colM = 5;
			}

			var ty = _ref.stage.stageHeight - _parent.Layout.marginY - ((thumbWidth+padding)*1);

			rowM = Math.floor(ty/(thumbWidth+padding));

			if(rowM > 5){
				//rowM = 5;
			}

			var gm =(Math.ceil(_parent.slideMax/colM)*colM);

			if(gm%colM != 0){
				gm += colM;
			}

			var thumbScroll = gm/colM;

			if(gm <(colM*rowM)){
				gm =(colM*rowM);
			}
			
			//
			
			var cont = Utils.$(_ref,'cont');
			
			for(var i=0;i<slideA.length;i++){
				var clip = Utils.$(cont,'clip'+i);
				
				clip.x = colC*150;
				clip.y = rowC*150;
				
				if(colC<colM){
					colC++;
				}
				if(colC == colM){
					colC = 0;
					rowC++;
				}
			}
			
			cont.x = (_ref.stage.stageWidth/2) - (((thumbWidth+padding) * colM)/2);
			cont.y = (_ref.stage.stageHeight/2) - _parent.Layout.marginY - (((thumbWidth+padding) * rowM)/2);
		
		}
		
	}
	
}