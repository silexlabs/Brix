/*
 * This file is part of SLPlayer http://www.silexlabs.org/groups/labs/slplayer/
 * 
 * This project is © 2011-2012 Silex Labs and is released under the GPL License:
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms 
 * of the GNU General Public License (GPL) as published by the Free Software Foundation; 
 * either version 2 of the License, or (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU General Public License for more details.
 * 
 * To read the license please visit http://www.gnu.org/copyleft/gpl.html
 */
package org.slplayer.component.data;

import js.Dom;
import js.Lib;

import org.slplayer.component.data.IDataConsumer;

/**
 * The DataObject structure common with DataConsumers.
 */
typedef DataObject = 
{
	src : String,
	srcTitle : Null<String>,
	data : Array<Dynamic>
}

/**
 * A data provider component should implement this interface to be compliant with data consumer components.
 * 
 * note : this is a draft and may be abandonned / revised again in a near future.
 * 
 * @author Thomas Fétiveau
 */
interface IDataProvider
{
	/**
	 * Common callback to all data provider to retreive data.
	 */
	public function getData():Void;
	/**
	 * Callback invoked when a new data consumer is showing up.
	 */
	public function onNewDataConsumer( dataConsumer : IDataConsumer ):Void;
}

/**
 * Mixin methods for DataProvider components.
 * FIXME: Not compatible with android native browser because of custom events
 */
class DataProvider 
{
	static public var ON_DATA_PROVIDER_EVENT_TYPE = "newDataProvider";
	
	static public function startProviding(provider : IDataProvider, target : Dynamic)
	{
		target.addEventListener(DataConsumer.ON_DATA_CONSUMER_EVENT_TYPE, function(e:CustomEvent) { provider.onNewDataConsumer( e.detail ); }, false);
	}
	
	static public function dispatchData(target : HtmlDom, data : DataObject)
	{
		var onDataEvent : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		
		onDataEvent.initCustomEvent(DataConsumer.ON_DATA_EVENT_TYPE, false, false, data);
		
		target.dispatchEvent(onDataEvent);
	}
}