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
		//FIXME we should possibly not call directly getData here but another function onNewDataConsumer
		untyped target.addEventListener(Common.ON_DATA_CONSUMER_EVENT_TYPE, function(e:Event) { provider.getData(); }, false);
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
	public function getData():Void;
}