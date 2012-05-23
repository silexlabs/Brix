package slplayer.data;

import js.Dom;
import js.Lib;

import slplayer.ui.DisplayObject;

import slplayer.data.Common;

/**
 * To be a standard data consumer, a component must implement IDataConsumer. Also, It should use DataConsumer (using slplayer.data.DataConsumer).
 * @author Thomas Fétiveau
 */
class DataConsumer 
{
	static public function startConsuming(consumer : IDataConsumer, from : Dynamic)
	{
		untyped from.addEventListener(Common.ON_DATA_EVENT_TYPE, function(e:Event) {
																						#if flash9
																							var evt:cocktail.core.event.CustomEvent = cast(e);
																						#else
																							var evt = e;
																						#end
																						consumer.onData(e.detail); 
																					} , false);
		
		var onNewConsumerEvent = untyped Lib.document.createEvent("CustomEvent");
		
		untyped onNewConsumerEvent.initCustomEvent(Common.ON_DATA_CONSUMER_EVENT_TYPE, false, false, consumer);
		
		untyped from.dispatchEvent(onNewConsumerEvent);
	}
}

interface IDataConsumer
{
	/**
	 * Common callback to all data consumers to receive data.
	 * @param	e
	 */
	private function onData(dataObj : DataObject):Void;
}