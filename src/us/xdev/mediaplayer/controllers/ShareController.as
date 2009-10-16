package us.xdev.mediaplayer.controllers
{
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.events.EventDispatcher;
	
	public class ShareController extends EventDispatcher
	{

		protected var model:*;

		public function ShareController(model:*)
		{
			this.model = model;
		}
		
		public function share(socialid:String,custom:String=''):String
		{
			var url:String = '';
			switch(socialid){
				case 'twitter':
					url = 'http://twitter.com/home?status='+model.page_url;
				break;
				case 'facebook':
					url = 'http://www.facebook.com/share.php?u='+model.page_url;
				break;
				case 'delicious':
					url = 'http://delicious.com/save?url='+model.page_url+'&amp;title='+model.page_title;
				break;
				case 'digg':
					url = 'http://digg.com/submit?url='+model.page_url+'&amp;title='+model.page_title;
				break;
				case 'myspace':
					url = 'http://www.myspace.com/Modules/PostTo/Pages/?u='+model.page_url+'&t='+model.page_title+'&c=%20';
				break;
				case 'windowslive':
					url = 'https://favorites.live.com/quickadd.aspx?marklet=1&mkt=en-us&url='+model.page_url+'&title='+model.page_title+'&top=1';
				break;
				case 'stumbleupon':
					url = 'http://www.stumbleupon.com/submit?url='+model.page_url+'&amp;title='+model.page_title;
				break;
				case 'reddit':
					url = 'http://reddit.com/submit?url='+model.page_url;
				break;				
			}
			
			//url encode stuff
			
			//load it
			navigateToURL(new URLRequest(url),'_blank');
			
			return url;
		}
		
	}
}