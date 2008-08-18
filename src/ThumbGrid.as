package
{
	//Flash Classes
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	//A12 Classes
	import com.a12.util.Utils;
	import com.a12.util.CustomEvent;
	import com.a12.util.LoadMovie;
	import com.a12.modules.mediaplayback.*;
	import com.a12.ui.Scrollbar;
	
	//3rd party Classes
	import com.gs.TweenLite;
	
	public class ThumbGrid
	{
		private var slideA:Array;
		private var _ref:MovieClip;
		private var _parent:Object;
		
		private var thumbWidth:Number;
		private var thumbHeight:Number;
		private var padding:Number;
		
		private var rowC:Number;
		private var rowM:Number;
		
		private var Scrolla:Scrollbar;
		private var lastP:Number;
		private var p:Number;
		
		private var pageIndex:Number;
		
		public function ThumbGrid(_r,_p,_obj)
		{
			_ref = _r;
			_parent = _p;
			slideA = _obj;
			
			thumbWidth = 140;
			thumbHeight = 140;
			padding = 10;
			
			lastP = 0;
			
			_ref.alpha = 0;
			
			_ref.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyListener);
			
			//build back block
			var mc = Utils.createmc(_ref,'block',{alpha:1});
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
			var pageMax = '';
			switch(true){
				case pageIndex < pageMax:
				
				break;
				
			}
		}
		
		private function buildGrid():void
		{
			var cont = Utils.createmc(_ref,'cont');
			
			//grid
			var g = Utils.createmc(cont,'grid');
			//mask
			g.mask = Utils.createmc(cont,'mask');
			
			//scroller
			Scrolla = new Scrollbar(Utils.createmc(cont,'scroller'),
			{
				mode:'vertical',
				clr_bar:0x222222,
				clr_nip:0xFFFFFF,
				barW:20,
				barH:360,
				nipW:20,
				nipH:60,
				offsetH:0,
				shiftAmount:0
			});
			
			Scrolla.addEventListener('onScroll', scrollGrid);
			
			
			for(var i=0;i<slideA.length;i++){
				var clip = Utils.createmc(g,'clip'+i);
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
				
				//if we're a video put the play icon on small style
				if(slideA[i].mode == 'media'){
					var ic = new mediaplayback_icons();
					ic.gotoAndStop('video_overlay_play');
					var mc = clip.addChild(ic);
					mc.name = 'overlay';
					mc.scaleX = 0.5;
					mc.scaleY = 0.5;
					
					mc.x = thumbWidth/2;
					mc.y = thumbHeight/2;
				}
				
				//mask
				var m = Utils.createmc(clip,'mask');
				Utils.drawRect(m,thumbWidth,thumbHeight,0x333333,1.0);
				img.mask = m;
				
				//stroke
				Utils.drawRect(Utils.createmc(clip,'hit',{alpha:0.0}),thumbWidth,thumbHeight,0x333333,0.0,[1.0,0xFFFFFF,1.0]);
				
				clip.mouseEnabled = true;
				clip.buttonMode = true;
				clip.addEventListener(MouseEvent.MOUSE_OVER,handleMouse,false,0,true);
				clip.addEventListener(MouseEvent.MOUSE_OUT,handleMouse,false,0,true);
				clip.addEventListener(MouseEvent.CLICK,handleMouse,false,0,true);
				
				if(_parent.slideIndex == i){
					clip.state = 'hit';
					Utils.$(clip,'hit').alpha = 1.0;
				}
				
			}
			
			//left, right
			i = new mediaplayer_icons();
			i.gotoAndStop('nav_arrow');
			mc = _ref.addChild(i);
			mc.dir = -1;
			mc.name = 'nav_prev';
			mc.rotation = 90;
			mc.x = _ref.stage.stageWidth/2;
			mc.alpha = 0.75;
			mc.buttonMode = true;
			mc.addEventListener(MouseEvent.MOUSE_OVER,handleIconsMouse);
			mc.addEventListener(MouseEvent.MOUSE_OUT,handleIconsMouse);
			mc.addEventListener(MouseEvent.CLICK,handleIconsMouse);
		
			i = new mediaplayer_icons();
			i.gotoAndStop('nav_arrow');
			mc = _ref.addChild(i);
			mc.dir = 1;
			mc.name = 'nav_next';
			mc.rotation = 270;
			mc.x = _ref.stage.stageWidth/2;
			mc.alpha = 0.75;
			mc.buttonMode = true;
			mc.addEventListener(MouseEvent.MOUSE_OVER,handleIconsMouse);
			mc.addEventListener(MouseEvent.MOUSE_OUT,handleIconsMouse);
			mc.addEventListener(MouseEvent.CLICK,handleIconsMouse);
			
			layoutGrid();
		}
		
		private function handleIconsMouse(e:MouseEvent):void
		{
			var mc = e.currentTarget;
			if(e.type == MouseEvent.CLICK){
				
				advancePage(mc.dir);
				
			}
			
			if(e.type == MouseEvent.MOUSE_OVER){
				TweenLite.to(MovieClip(mc),0.2,{scaleX:1.2,scaleY:1.2});
			}
			if(e.type == MouseEvent.MOUSE_OUT){
				TweenLite.to(MovieClip(mc),0.5,{scaleX:1.0,scaleY:1.0});
			}
		}
		
		private function advancePage(dir:Number):void
		{
			
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
			//redraw the base, or something
			var mc = Utils.$(_ref,'block');
			mc.width = _ref.stage.stageWidth;
			mc.height = _ref.stage.stageHeight;
			
			layoutGrid();
		}
		
		private function scrollGrid(e:CustomEvent):void
		{
			var p = e.props.percent;
			Utils.$(Utils.$(_ref,'cont'),'grid').y = -Math.floor(((rowC-(rowM-1)) * (thumbHeight+padding)) * (p/100));
			
			var unitSize = (((thumbHeight+padding) * rowM) - padding) / rowM;
			//trace(unitSize);
			
			
			lastP = p;
		}
		
		private function layoutGrid():void
		{
	
			rowC = 0;
			rowM = 5;
			var colC = 0;
			var colM = 5;
			
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
			var g = Utils.$(cont,'grid');
			
			for(var i=0;i<slideA.length;i++){
				var clip = Utils.$(g,'clip'+i);
				
				//update position
				clip.x = colC*(thumbWidth+padding);
				clip.y = rowC*(thumbHeight+padding);
				
				if(colC<colM){
					colC++;
				}
				if(colC == colM){
					colC = 0;
					rowC++;
				}
			}
			
			//adjust mask			
			var m = Utils.$(cont,'mask');
			m.graphics.clear();
			var mh = ((thumbHeight+padding) * rowM)-padding;
			Utils.drawRect(m,(thumbWidth+padding) * colM,mh,0xFF0000,1.0);			
			
			/*
			//adjust scrollbar
			if((rowM * colM) < _parent.slideMax){
				//enable and update
				Scrolla.ref.visible = true;
				Scrolla.setEnabled(true);
				Scrolla.ref.x = (thumbWidth+padding) * colM;
				Scrolla.setHeight(((thumbHeight+padding) * rowM) - padding);
				Scrolla.setValue(lastP/100);
			}else{
				//disable
				Scrolla.ref.visible = false;
				Scrolla.setEnabled(false);
			}
			*/
			Scrolla.ref.visible = false;
			Scrolla.setEnabled(false);
			
			
			
			
			
			//center container
			cont.x = (_ref.stage.stageWidth/2) - ((((thumbWidth+padding) * colM)-padding)/2);
			cont.y = (_ref.stage.stageHeight/2) - _parent.Layout.marginY - (((thumbWidth+padding) * rowM)/2);
			
			var mc = Utils.$(_ref,'nav_prev');
			mc.x = _ref.stage.stageWidth/2;
			mc.y = cont.y-(padding*2);
			
			mc = Utils.$(_ref,'nav_next');
			mc.x = _ref.stage.stageWidth/2;
			mc.y = cont.y+mh+(padding*2);
			
			
		
		}
		
	}
	
}