/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.core;

import brix.util.haxe.ObjectHash;

import js.Lib;
import js.Dom;

/**
 * The EventMap object offers an alternative way to register an event listener. Using EventMap, 
 * you do not have to worry about keeping your listener references to unregister them later.
 * 
 * @author Thomas Fétiveau
 */
class EventMap 
{
	private var notCapturingListeners:ObjectHash<Dynamic,Hash<List<js.Event->Void>>>;

	private var capturingListeners:ObjectHash<Dynamic,Hash<List<js.Event->Void>>>;

	public function new() 
	{
		notCapturingListeners = new ObjectHash();
		capturingListeners = new ObjectHash();
	}

	/**
	 * 
	 * @param	dispatcher
	 * @param	type
	 * @param	listener
	 * @param	?useCapture
	 */
	public function mapListener( dispatcher:Dynamic, type:String, listener:js.Event->Void, ?useCapture:Bool=false ):Void
	{
		var coll = getListeners(useCapture);

		if (!coll.exists(dispatcher))
		{
			coll.set(dispatcher, new Hash());
		}
		if (!coll.get(dispatcher).exists(type))
		{
			coll.get(dispatcher).set(type, new List());
		}
		if (!Lambda.exists(coll.get(dispatcher).get(type), function(l:js.Event->Void) { return Reflect.compareMethods(listener, l); }))
		{
			coll.get(dispatcher).get(type).add(listener);

			crossBrowserAddEventListener(dispatcher, type, listener, useCapture);
		}
	}

	/**
	 * 
	 * @param	dispatcher
	 * @param	type
	 * @param	listener
	 * @param	?useCapture
	 */
	public function unmapListener( dispatcher:Dynamic, type:String, listener:js.Event->Void, ?useCapture:Bool=false ):Void
	{
		var coll = getListeners(useCapture);

		if (coll.exists(dispatcher) && coll.get(dispatcher).exists(type))
		{
			for (l in coll.get(dispatcher).get(type))
			{
				if (Reflect.compareMethods(listener, l))
				{
					crossBrowserRemoveEventListener(dispatcher, type, l, useCapture);

					coll.get(dispatcher).get(type).remove(l);
					return;
				}
			}
		}
	}

	/**
	 * Unregister all event listeners registered through mapListener().
	 */
	public function unmapListeners():Void
	{
		var useCapture = true;
		for (c in [capturingListeners, notCapturingListeners])
		{
			for (d in {iterator:c.keys})
			{
				for (t in {iterator:c.get(d).keys})
				{
					for (l in c.get(d).get(t))
					{
						crossBrowserRemoveEventListener(d, t, l, useCapture);

						c.get(d).get(t).remove(l);
					}
					c.get(d).remove(t);
				}
				c.remove(d);
			}
			useCapture = false;
		}
	}

	private function getListeners(useCapture:Bool):ObjectHash<Dynamic,Hash<List<js.Event->Void>>>
	{
		if (useCapture)
			return capturingListeners;
		return notCapturingListeners;
	}

	private function crossBrowserAddEventListener(dispatcher:Dynamic, type:String, listener:js.Event->Void, useCapture:Bool)
	{
#if js
		untyped
		{
			if ( __js__("dispatcher.addEventListener") )
			{
#end
				dispatcher.addEventListener(type, listener, useCapture);
#if js
			}
			else if ( __js__("dispatcher.attachEvent") ) // IE<9 specific
			{
				dispatcher.attachEvent("on"+type, listener);
			}
		}
#end
	}

	private function crossBrowserRemoveEventListener(dispatcher:Dynamic, type:String, listener:js.Event->Void, useCapture:Bool)
	{
#if js
		untyped
		{
			if ( __js__("dispatcher.removeEventListener") )
			{
#end
				dispatcher.removeEventListener(type, listener, useCapture);
#if js
			}
			else if ( __js__("dispatcher.detachEvent") ) // IE<9 specific
			{
				dispatcher.detachEvent("on"+type, listener);
			}
		}
#end
	}
}
