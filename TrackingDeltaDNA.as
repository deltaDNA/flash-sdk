package 
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestHeader;
	import  flash.system.Capabilities;
	import starling.utils.SystemUtil;
	/**	 
	 * @author Will Perone
	 * implementation of http://docs.deltadna.com/rest-api/
	 * standard events you will need to track: clientDevice, engageConverted, engageResponse, gameStarted, newPlayer... they will be in your event-reference
	 *
	 *** Please fill out your DeltaDNA APIKEYs, COLLECT_URL and ENGAGE_URL ***
	 */
	public class TrackingDeltaDNA 
	{
		private var apikey:String;
		private var url:String;
		private var userid:String;
		private var sessionid:String;
		private var platform:String;
		
		private static const APIKEY_DEV:String = "";
		private static const APIKEY_LIVE:String = "";
		private static const COLLECT_URL:String = "";
		private static const ENGAGE_URL:String = "";
		
		private static const PLATFORM_ANDROID:String = "ANDROID";
		private static const PLATFORM_IOS:String = "IOS";
		private static const PLATFORM_WEB:String = "WEB";
		
		private static const DEVICE_HANDHELD:String = "HANDHELD";
		private static const DEVICE_MOBILE_PHONE:String = "MOBILE_PHONE";
		private static const DEVICE_TABLET:String = "TABLET";
		private static const DEVICE_PC:String = "PC";
		
		private static const TABLET_THRESHOLD:Number = 7.0;
		
		public function TrackingDeltaDNA(_islive:Boolean, _userid:int) 
		{
			apikey = _islive ? APIKEY_LIVE : APIKEY_DEV;
			userid = _userid.toString();
			platform = GetOS();
			url = COLLECT_URL + "/" + apikey + "/";
			sessionid = (Math.random() * uint.MAX_VALUE).toString(16) + '-' + (Math.random() * uint.MAX_VALUE).toString(16);
		}
		
		public function track(event:String, param1name:String= null, param1value:*= null, param2name:String= null, param2value:*= null, param3name:String= null, param3value:*= null, param4name:String= null, param4value:*= null):void 
		{
			var date:Date = new Date();
			var data:Object = 
			          {eventName: event,
					   userID: userid, 
					   sessionID: sessionid,
					   //eventTimestamp: date.fullYear + '-' + (date.month+1) + '-' + date.date + ' ' + date.hours + ':' + date.minutes + ':' + date.seconds+':'+date.milliseconds,
					   eventParams: { platform: platform }
					  };
			if (param1name)	data.eventParams[param1name] = param1value;
			if (param2name) data.eventParams[param2name] = param2value;
			if (param3name) data.eventParams[param3name] = param3value;
			if (param4name) data.eventParams[param4name] = param4value;
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			request.requestHeaders.push(hdr);
			request.data = JSON.stringify(data);			
			request.method= "POST";
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			loader.addEventListener(Event.COMPLETE, function (e:Event):void { 
				//trace('success ' + e.target.data); 
			} );
			loader.addEventListener("error", function(e:ErrorEvent):void { 
				trace(e.text); 
			});
			loader.addEventListener("ioError", function(e:IOErrorEvent):void { 
				trace(e.text); 
			});
			loader.load(request);
		}
		
		public static function GetOS():String
		{
			var starlingOS:String = SystemUtil.platform;
			var deltaOS:String = "";
			switch(starlingOS)
			{
				case "IOS":
					deltaOS = PLATFORM_IOS;
				case "AND":
					deltaOS = PLATFORM_ANDROID;
				case "WIN":
				case "MAC":
				case "LINUX":
				default:
					deltaOS = PLATFORM_WEB;
					break;
			}
			return deltaOS;
		}
		
		public static function GetDeviceType():String
		{
			var starlingOS:String = SystemUtil.platform;
			var w:Number = Capabilities.screenResolutionX;
			var h:Number = Capabilities.screenResolutionY;
			var dpi:Number = Capabilities.screenDPI;
			
			var screenInches:Number = Math.round(Math.sqrt(Math.pow(w/dpi,2)+Math.pow(h/dpi,2)) * 100) / 100;
			var deltaDeviceType:String = "";
			
			if (GetOS() != PLATFORM_WEB)
			{
				if (screenInches >= TABLET_THRESHOLD) 
				{
					return DEVICE_TABLET;
				}
				else
				{
					return DEVICE_MOBILE_PHONE;
				}
			}
			else
			{
				return DEVICE_PC;
			}
			
		}
		
		public static function GetDeviceRatio():String
		{
			var w:Number = Capabilities.screenResolutionX;
			var h:Number = Capabilities.screenResolutionY;
			var ratio:String = (w / h).toString();
			return ratio;
		}
		
	}

}