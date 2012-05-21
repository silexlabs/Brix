package slplayer.data;

import js.Dom;
import js.Lib;

import slplayer.ui.DisplayObject;

import slplayer.data.Common;


/**
 * To be a standard data provider, a component must implement IDataProvider. Also, It should use DataProvider (using slplayer.data.DataProvider).
 * @author Thomas Fétiveau
 */
class DataProvider 
{
	static public function startProviding(provider : IDataProvider, target : Dynamic)
	{
		untyped target.addEventListener(Common.ON_DATA_CONSUMER_EVENT_TYPE, callback(provider.getData), false);
	}
	
	static public function dispatchData(target : Dynamic, data : DataObject)
	{
		var onDataEvent = untyped Lib.document.createEvent("CustomEvent");
		
		untyped onDataEvent.initCustomEvent(Common.ON_DATA_EVENT_TYPE, false, false, data);
		
		untyped target.dispatchEvent(onDataEvent);
	}
}

interface IDataProvider
{
	/**
	 * Common callback to all data provider to retreive data.
	 * @param	e
	 */
	public function getData(e:Event = null):Void;
}