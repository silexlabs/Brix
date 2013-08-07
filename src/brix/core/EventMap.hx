/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.core;

import js.html.Event;
import js.html.CustomEvent;
import js.html.HtmlElement;
import js.Browser;

import brix.util.haxe.ObjectHash;
import brix.util.DomTools;
import haxe.ds.StringMap;

/**
 * event dispach direction
 */
enum EventDirection 
{
	/**
	 * dispatch to the parents
	 */
	up;
	/**
	 * dispatch to the children
	 */
	down;
	/**
	 * dispatch up and down
	 */
	both;
	/**
	 * dispatch on the node only
	 */
	none;
}
/**
 * The EventMap object offers an alternative way to register an event listener. Using EventMap, 
 * you do not have to worry about keeping your listener references to unregister them later.
 * 
 * @author Thomas Fétiveau and lexoyo
 */
class EventMap 
{
	private var notCapturingListeners:ObjectHash<Dynamic,StringMap<List<Event->Void>>>;

	private var capturingListeners:ObjectHash<Dynamic,StringMap<List<Event->Void>>>;

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
	public function mapListener( dispatcher:Dynamic, type:String, listener:Event->Void, ?useCapture:Bool=false ):Void
	{
		var coll = getListeners(useCapture);

		if (!coll.exists(dispatcher))
		{
			coll.set(dispatcher, new StringMap());
		}
		if (!coll.get(dispatcher).exists(type))
		{
			coll.get(dispatcher).set(type, new List());
		}
		if (!Lambda.exists(coll.get(dispatcher).get(type), function(l:Event->Void) { return Reflect.compareMethods(listener, l); }))
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
	public function unmapListener( dispatcher:Dynamic, type:String, listener:Event->Void, ?useCapture:Bool=false ):Void
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
	/**
	 * Dispatches a CustomEvent on the specified node, holding Dynamic data.
	 * @param	eventType the event type
	 * @param	?data, the data to attach to the event object (event.detail)
	 * @param	?dispatcher the dispatching node.
	 * @param	?direction 	up or down the DOM.
	 */
	public function dispatch(eventType:String, data:Dynamic, dispatcher:HtmlElement, cancelable:Bool, direction:EventDirection):Void
	{//trace("dispatch "+eventType+" on "+dispatcher);
		if (direction != down)
		{
			// use native dispatcher
			dispatchCustomEvent(eventType, data, dispatcher, cancelable, direction == up || direction == both);
		}
		else
		{
			// for down only dispatch on the node itself 
			dispatchCustomEvent(eventType, data, dispatcher, cancelable, false);
		}
		if (direction == down || direction == both)
		{
			dispatchDownRecursive(eventType, data, dispatcher, cancelable);
		}
	}

	private function dispatchDownRecursive(eventType:String, data:Dynamic, dispatcher:HtmlElement, cancelable:Bool)
	{//trace("dispatchDownRecursive "+eventType+" on "+dispatcher);
		for (i in 0...dispatcher.childNodes.length)
		{
			var node : HtmlElement = cast dispatcher.childNodes[i];
			if (node.nodeType == NodeTypes.ELEMENT_NODE)
			{
				dispatchCustomEvent(eventType, data, node, cancelable, false);
				dispatchDownRecursive(eventType, data, node, cancelable);
			}
		}
	}

	private function dispatchCustomEvent(eventType:String, data:Dynamic, dispatcher:HtmlElement, cancelable:Bool, canBubble:Bool)
	{//trace("dispatchCustomEvent "+eventType+" on "+dispatcher.className);
		var event : CustomEvent = cast Browser.document.createEvent("CustomEvent");
		event.initCustomEvent(eventType, canBubble, cancelable, data);
		dispatcher.dispatchEvent(event);
	}

	private function getListeners(useCapture:Bool):ObjectHash<Dynamic,StringMap<List<Event->Void>>>
	{
		if (useCapture)
			return capturingListeners;
		return notCapturingListeners;
	}

	private function crossBrowserAddEventListener(dispatcher:Dynamic, type:String, listener:Event->Void, useCapture:Bool)
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

	private function crossBrowserRemoveEventListener(dispatcher:Dynamic, type:String, listener:Event->Void, useCapture:Bool)
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
