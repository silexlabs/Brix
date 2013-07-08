/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.list;

import js.Dom;
import haxe.Http;
import haxe.Timer;

import brix.component.ui.DisplayObject;
import brix.component.navigation.Layer;

/**
 * Connector base
 */
class ConnectorBase extends DisplayObject
{
	////////////////////////////////////
	// constants
	////////////////////////////////////
	/**
	 * event to request data change
	 */
	public static inline var ON_DATA_RECEIVED = "onDataReceived";
	
	/**
	 * event when there was an error while fetching data
	 */
	public static inline var ON_DATA_ERROR = "onDataError";
	
	/**
	 * event when all data from the url has been fetched
	 */
	public static inline var ON_NO_MORE_DATA = "onNoMoreData";
	
	/**
	 * attribute to allow the component to load data automatically, e.g. when the layer is shown
	 * by default it is true, set it to false in the html to prevent auto data loading
	 */
	public static inline var ATTR_AUTO_LOAD = "data-connector-auto-load";
	/**
	 * attribute to set on the root element to specify an url
	 */
	public static inline var ATTR_URL = "data-connector-url";
	/**
	 * path of the object to use as root for the data
	 * @example		a value of "resource.list" 
	 * 				will look for the obect list in the data received: {resource:{list:[{title:a},{title:b}]}}
	 */
	public static inline var ATTR_ROOT = "data-connector-root";
	/**
	 * attribute to set the polling frequency, in ms
	 */
	public static inline var ATTR_POLL_FREQ = "data-connector-poll-frequency";
	public static inline var ATTR_STARTUP_DELAY = "data-connector-startup-delay";
	/**
	 * The rss root node
	 */
	private var dataRootNode:String = "";
	
	////////////////////////////////////
	// properties
	////////////////////////////////////
	private var pollingFreq:Null<Int>;
	private var isPolling:Bool=false;
	private var latestData:String = "";
	private var objectData:Dynamic;

	////////////////////////////////////
	// DisplayObject methods
	////////////////////////////////////
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);

		init();

		// listen to the Layer class event, in order to loadData when the page opens
		if (rootElement.getAttribute(ConnectorBase.ATTR_AUTO_LOAD) != "false")
		{
			mapListener(rootElement, Layer.EVENT_TYPE_SHOW_AGAIN, onLayerShow, false);
			mapListener(rootElement, Layer.EVENT_TYPE_SHOW_STOP, onLayerShow, false);
			mapListener(rootElement, Layer.EVENT_TYPE_HIDE_STOP, onLayerHide, false);

			var pollingFreqStr = rootElement.getAttribute(ATTR_POLL_FREQ);
			if (pollingFreqStr != null)
			{
				pollingFreq = Std.parseInt(pollingFreqStr);
			}
			else
			{
				pollingFreq = 0;
			}
			var startupDelay = rootElement.getAttribute(ATTR_STARTUP_DELAY);
			if (startupDelay != null)
			{
				Timer.delay(callback(loadData, null), Std.parseInt(startupDelay));
			}
			else
			{
				loadData();
			}
		}
	}
	/**
	 * init
	 */ 
	override public function init():Void
	{
		if (rootElement.getAttribute(ConnectorBase.ATTR_ROOT) != null) {
			dataRootNode = rootElement.getAttribute(ConnectorBase.ATTR_ROOT);
		}
	}
	/**
	 * start/stop polling
	 */
	public function startPolling(pollingFreq:Int) 
	{
		isPolling = true;
	}
	/**
	 * start/stop polling
	 */
	public function stopPolling() 
	{
		isPolling = false;
	}
	/**
	 * the layer is being showed
	 */ 
	public function onLayerShow(e:Event)
	{
		// refresh list data
		loadData();
		// stat polling
		if (pollingFreq!=null && pollingFreq>0)
		{
			startPolling(pollingFreq);
		}
		latestData = "";
	}
	/**
	 * the layer is being hidden
	 */ 
	public function onLayerHide(e:Event)
	{
		// stop polling
		if (pollingFreq!=null && pollingFreq>0)
		{
			stopPolling();
		}
	}
	/**
	 * load the data
	 */ 
	public function loadData(?url:Null<String>=null)
	{
		// default value
		if (url == null)
		{
			url = rootElement.getAttribute(ATTR_URL);
			if (url == null || url == "")
			{
				trace("Error: no url provided, aborting http request. I will not load data. Connector "+rootElement.className);
				return;
			}
		}
		//trace("loadData "+url);
		// call the service
		var http = new Http(url);
		http.onError = onError;
		http.onData  = onData;
		http.request(false);
	}
	
	/**
	 * callback for the http request
	 */ 
	public function onData(data:String)
	{
		if (isPolling && pollingFreq!=null && pollingFreq>0)
		{
			Timer.delay(callback(loadData, null), pollingFreq);
		}
		// small optim
		if (hasNoMoreDataToLoad(data))
		{
			onNoMoreData(objectData);
			//trace("no new data");
			return;
		}
		else
		{
			//trace("new data ");
			//trace(rootElement.className);
		}

		latestData = data;
		// parse data to object
		try
		{
			objectData = parseData2Object(data);
			//trace(objectData);
		}
		catch(e:Dynamic)
		{
			trace("Error parsing string data \""+data+"\". Error message: "+e);
		}

		// get data root
		if (objectData!=null)
		{
			//var dataRootNode = rootElement.getAttribute(ConnectorBase.ATTR_ROOT);
			if (dataRootNode!="")
			{
				try
				{
					var path = dataRootNode.split(".");
					for (idx in 0...path.length)
					{
						var objName = path[idx];
						objectData = Reflect.field(objectData, objName);
					}
				}
				catch(e:Dynamic)
				{
					trace("Error while looking for the data root object \""+dataRootNode+"\" in \""+data+"\". Error message: "+e);
				}
			}
			onDataReceived(objectData);
		}
		else
		{
			// todo: dispatch an error event
			trace("Warning: no data received.");
		}
	}
	
	/**
	 * callback for the http request
	 */ 
	public function onError(message:String)
	{
		trace("onError " + message);
		dispatch(ConnectorBase.ON_DATA_ERROR, null, rootElement, false, up);
	}
	/**
	 * dispatch an event with the new data
	 */ 
	public function onDataReceived(objectData:Dynamic)
	{
		// dispatch a custom event
		dispatch(ConnectorBase.ON_DATA_RECEIVED, objectData, rootElement, false, none);
	}
	
	/**
	 * dispatch an event with the data
	 * to signal there is no more to load
	 */
	public function onNoMoreData(objectData:Dynamic)
	{
		dispatch(ConnectorBase.ON_NO_MORE_DATA, objectData, rootElement, false, none);
	}
	
	/**
	 * parse the connector data to object.
	 * to be overrriden in extending classes
	 * 
	 * @param	data
	 * @return
	 */
	public function parseData2Object(data:String):Dynamic
	{
		
	}
	
	/**
	 * check wether new loaded data are the same
	 * as old loaded data.
	 * 
	 * to be overriden to implement behaviour 
	 * specific to a connector
	 */
	public function hasNoMoreDataToLoad(data:String):Bool
	{
		return data == latestData;
	}
}