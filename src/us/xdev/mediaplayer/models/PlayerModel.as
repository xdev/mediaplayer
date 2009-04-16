package us.xdev.mediaplayer.models
{

	public class PlayerModel extends EventDispatcher
	{
		
		private var slideIndex:int;
		private var slideMax:int;
		private var slideA:Array;
		
		private var flagPlaying:Boolean;
		private var flagThumbs:Boolean;
		
		private var slideInterval:Number;
		private var uiInterval:Number;
		
		private var progressOffset:Number;
		private var progressInterval:Number;
		private var preloadInterval:Number;
		
		private var configObj:Object;
		
		public function PlayerModel()
		{
			
			setConfig();		
			
			
			//Debug.clear();
			//Debug.object(configObj);
						
			var xml;
			
			if(Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone"){
				xml = 'demo_slideshow.xml';				
			}
			
			//params.still = 'demo_video.jpg';
			//params.src = 'demo_video.flv';
						
			if(params['src']){
				
				var still = '';
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
		
		private function init():void
		{
			flagThumbs = false;
			
			if(slideMax > 1){
								
				flagPlaying = true;
				slideIndex = -1;
				buildUI();
				advanceSlide(1);
				
				//only do this if we need them yo
				Utils.createmc(stage,'thumbs');
				
			}else{
				flagPlaying = false;
				configObj.slideshow = false;
				configObj.thumbgrid = false;
				slideIndex = -1;
				buildUI();
				advanceSlide(1);
			}
		}
		
		private function handleTransport(e:CustomEvent):void
		{
			//Debug.object(e.props);
			if(e.props.mode == true){
				sendExternal('playMedia');
				//ExternalInterface.call('playMedia');
			}else{
				sendExternal('stopMedia');
				//ExternalInterface.call('stopMedia');
			}
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
			var params:Object = root.loaderInfo.parameters;
			var v;
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
			//var snip:XMLList = tXML.RecordSet.(@Type == "Slides");
			var snip:XMLList = tXML.slides;
			var i:int=0;
			slideA = [];			
			for each(var node:XML in snip..slide){
				
				var file = node.file.toString();				
				var ext = file.substring(file.lastIndexOf('.')+1,file.length).toLowerCase();
								
				var tObj = {};
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
		
		private function viewSlideByIndex(value:Number):void
		{
			slideIndex = value;
			viewSlide();
		}
		
	}
	
}