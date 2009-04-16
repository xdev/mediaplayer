package us.xdev.mediaplayer.models
{

	import com.a12.util.XMLLoader;
	
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;

	public class PlayerModel extends EventDispatcher
	{

		public var slideIndex:int;
		public var slideMax:int;
		public var slideA:Array;		
		
		public var configObj:Object;
		private var params:Object;

		public function PlayerModel(p:Object)
		{

			params = p;
			setConfig();


			var xml:String;

			if(Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone"){
				xml = 'demo_slideshow.xml';
			}

			//params.still = 'demo_video.jpg';
			//params.src = 'demo_video.flv';

			if(params['src']){

				var still:String = '';
				if(params['still']){
					still = '<still>'+params['still']+'</still>';
				}
				parseXML('<xml><slides><slide><file>'+params['src']+'</file>' + still + '</slide></slides></xml>');

			}else{

				if(params['xml']){
					xml = params['xml'];
				}
				new XMLLoader(xml,parseXML,this);
			}
		}
		
		public function getConfig():Object
		{
			return configObj;	
		}
		
		public function setSlide(ind:int):void
		{
			slideIndex = ind;
			//update	
		}
		
		public function advanceSlide(dir:int):void
		{
			switch(true)
			{
				case slideIndex + dir > slideMax - 1:
					slideIndex = 0;
				break;

				case slideIndex + dir < 0:
					slideIndex = slideMax - 1;
				break;

				default:
					slideIndex += dir;
				break;
			}
			
			//update for a viewSlide	
		}

		private function init():void
		{
			//flagThumbs = false;

			if(slideMax > 1){

				//flagPlaying = true;
				slideIndex = -1;


				//only do this if we need them yo
				//Utils.createmc(stage,'thumbs');

			}else{
				//flagPlaying = false;
				configObj.slideshow = false;
				configObj.thumbgrid = false;
				slideIndex = -1;

			}

			//broadcast out a ready signal for view
		}

		private function setConfig():void
		{
			configObj =
			{
				thumbgrid:true,
				fullscreen:true,
				duration:5000,
				slideshow:true,
				scalevideo:true,
				scaleimage:false,
				marginX:0,
				marginY:0,
				thumbWidth:140,
				thumbHeight:140,
				padding:10,
				animate:false,
				shownumbers:false
			}


			//check the parameters.

			var v:*;
			v = params['duration'];
			if(v){
				configObj.duration = Number(v);
			}
			v = params['thumbWidth'];
			if(v){
				configObj.thumbWidth = Number(v);
			}
			v = params['thumbHeight'];
			if(v){
				configObj.thumbHeight = Number(v);
			}
			v = params['padding'];
			if(v){
				configObj.padding = Number(v);
			}
			v = params['marginX'];
			if(v){
				configObj.marginX = Number(v);
			}
			v = params['marginY'];
			if(v){
				configObj.marginY = Number(v);
			}
			v = params['thumbgrid'];
			if(v){
				if(v == 'true'){
					configObj.thumbgrid = true;
				}else{
					configObj.thumbgrid = false;
				}
			}
			v = params['fullscreen'];
			if(v){
				if(v == 'true'){
					configObj.fullscreen = true;
				}else{
					configObj.fullscreen = false;
				}
			}
			v = params['slideshow'];
			if(v){
				if(v == 'true'){
					configObj.slideshow = true;
				}else{
					configObj.slideshow = false;
				}
			}
			v = params['scalevideo'];
			if(v){
				if(v == 'true'){
					configObj.scalevideo = true;
				}else{
					configObj.scalevideo = false;
				}
			}
			v = params['scaleimage'];
			if(v){
				if(v == 'true'){
					configObj.scaleimage = true;
				}else{
					configObj.scaleimage = false;
				}
			}
		}

		private function parseXML(xml:String):void
		{
			var tXML:XML = new XML(xml);
			//parse config information

			var snip:XMLList = tXML.slides;
			var i:int=0;
			slideA = [];
			for each(var node:XML in snip..slide){

				var file:String = node.file.toString();
				var ext:String = file.substring(file.lastIndexOf('.')+1,file.length).toLowerCase();

				var tObj:Object = {};
				tObj.file = file;
				tObj.id = i;

				if(node.thumb != undefined){
					tObj.thumb = node.thumb.toString();
				}

				if(ext == 'flv' || ext == 'mov' || ext == 'mp4' || ext == 'mp3' || ext == 'm4v'){
					tObj.mode = 'media';
					if(node.still != undefined){
						tObj.still = node.still.toString();
					}
				}

				if(ext == 'jpg' || ext == 'jpeg' || ext == 'gif' || ext == 'png' || ext == 'swf'){
					tObj.mode = 'image';
				}

				if(tObj.mode){
					slideA.push(tObj);
				}

				i++;
			}
			slideMax = i;

			init();

		}

	}

}