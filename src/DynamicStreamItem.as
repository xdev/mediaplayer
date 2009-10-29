/*************************************************************************
*                       
* ADOBE SYSTEMS INCORPORATED
* Copyright 2008 Adobe Systems Incorporated
* All Rights Reserved.
*
* NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the 
* terms of the Adobe license agreement accompanying it.  If you have received this file from a 
* source other than Adobe, then your use, modification, or distribution of it requires the prior 
* written permission of Adobe.
*
**************************************************************************/

package
{
	public class DynamicStreamItem extends Object
	{
		
		/**
		 * streamArray
		 * Array of streams and bitrates
		 * 
		 */
		private var streamArray:Array;
		
		/**
		 * Start time for the stream
		 * Default is 0
		 */		
		public var start:Number;
		
		/**
		 * len:Number
		 * Default is -1 to coincide with defaults for NetStream.play()
		 */		
		public var len:Number;
		
		/**
		 * reset:Boolean
		 * Default is true to coincide with defaults for NetStream.play()
		 */		
		public var reset:Boolean;
		
		/**
		 * streamCount
		 * This is the number of encodings you have present.
		 */		
		public var streamCount:int;
		
		/**
		 * startRate
		 * The DynamicStream class will begin playing the stream that is equal to or in excess of this value
		 * if the historical max bandwidth exceeds this preferred start rate.
		 */
		public var startRate:Number;
		
		/**
		 * Constructor for DynamicStreamOptions
		 * 
		 * Usage:
		 * var ds:DynamicStream = new DynamicStream(nc);
		 * 
		 * var dsi:DynamicStreamItem = new DynamicStreamItem();
		 * 
		 * dsi.addStream("mp4:Sample Movie_800.f4v", 800);
		 * dsi.addStream("mp4:Sample Movie_1500.f4v", 1500);
		 * dsi.addStream("mp4:Sample Movie_2200.f4v", 2200);
		 * dsi.addStream("mp4:Sample Movie_5600.f4v", 5600);
		 * 
		 * ds.startPlay(dso);
		 * 
		 */
		public function DynamicStreamItem() {
			
			streamArray = new Array();	
			streamCount = NaN;
			start = 0;
			len = -1;
			reset = true;
			startRate = -1;

		}
		
		/**
		 * Adds a stream and bitrate pair to the DynamicStreamItem object 
		 * @param streamName
		 * @param bitRate
		 * 
		 */		
		public function addStream(streamName:String, bitRate:Number):void {
		
			if(!isNaN(bitRate)) {
				streamArray.push({name:streamName, rate:bitRate});
			}
			streamArray.sortOn("rate", Array.NUMERIC);
		
		}
		
		/**
		 * Returns the array of stream/bitrate pairs 
		 * @return 
		 * 
		 */		
		public function get streams():Array {
			return streamArray;
		}
		
	}
}