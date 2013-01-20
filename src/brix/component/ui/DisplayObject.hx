/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.ui;

import brix.core.Application;
import brix.core.EventMap;

import brix.component.IBrixComponent;
using brix.component.IBrixComponent.BrixComponent;

#if macro
import cocktail.Lib;
import cocktail.Dom;
#else
import js.Lib;
import js.Dom;
#end

import haxe.Template;

/**
 * The contract a DisplayObject must fulfill.
 */
interface IDisplayObject implements IBrixComponent
{
	/**
	 * having a associated HTML DOM element.
	 */
	public var rootElement(default, null) : HtmlDom;
}

/**
 * A displayObject is a UI component associated with an HTML DOM element. You declare an instance of a DisplayObject by putting
 * class="[YourDisplayObjectClassName]" in the attributes of the HTML DOM element you want to associate to.
 * 
 * In case you want to allow your component only on specific HTML tags, set the @tagNameFilter() meta tag before your component 
 * Class declaration with an array value containing the tag names, for instance:
 * 
 * @tagNameFilter("ul", "ol") class MyComponent extends DisplayObject { }
 * 
 * If you want to ensure that users of your component sets required "data-<MyCustonParam>" attributes on its HTML element, you can 
 * set the @requires() meta tag before your component Class declaration, like below : 
 * 
 * @requires(<MyCustonParam>, <MyCustonParam2>, ...) class MyComponent extends DisplayObject { }
 * 
 * @author Thomas Fétiveau
 */
class DisplayObject implements IDisplayObject
{
	/**
	 * The id of the containing Brix Application instance.
	 * FIXME to deprecate
	 */
	public var brixInstanceId : String;
	/**
	 * The dom node associated with the instance of this component. By default, all events used for communication with other 
	 * components are dispatched to and listened from this DOM element.
	 */
	public var rootElement(default, null) : HtmlDom;
	/**
	 * The EventMap object managing the component's listeners subscriptions
	 */
	private var eventMap:EventMap;

	/**
	 * Returns the associated running Application instance.
	 * FIXME to deprecate
	 * 
	 * @return	an Application object.
	 */
	public function getBrixApplication() : Application
	{
		return BrixComponent.getBrixApplication(this);
	}

	/**
	 * Common constructor for all DisplayObjects. If there is anything specific to a given component class initialization, override the init() method.
	 * 
	 * @param	rootElement
	 */
	private function new(rootElement : HtmlDom, brixId:String) 
	{
		this.rootElement = rootElement;
		
		this.eventMap = new EventMap();

		// FIXME about to be removed
		initBrixComponent(brixId);

		#if disableFastInit // FIXME what if added at runtime ?
			//check the @tagNameFilter constraints
			checkFilterOnElt(Type.getClass(this) , rootElement);
			//check the @requires constraints
			BrixComponent.checkRequiredParameters(Type.getClass(this) , rootElement);
		#end

		getBrixApplication().addAssociatedComponent(rootElement, this); // FIXME about to be removed
	}

	/**
	 * Removes the component from the application.
	 */
	public function remove():Void
	{
		clean();

		getBrixApplication().removeAssociatedComponent(rootElement,this); // FIXME about to be removed
	}

	/**
	 * Registers an event listener.
	 */
	public function mapListener(dispatcher:Dynamic, type:String, listener:js.Event->Void, ?useCapture:Bool=false):Void
	{
		this.eventMap.mapListener(dispatcher, type, listener, useCapture);
	}

	/**
	 * Unregisters an event listener.
	 */
	public function unmapListener(dispatcher:Dynamic, type:String, listener:js.Event->Void, ?useCapture:Bool=false):Void
	{
		this.eventMap.unmapListener(dispatcher, type, listener, useCapture);
	}

	/**
	 * Unregister all event listeners registered through mapListener().
	 */
	public function unmapListeners():Void
	{
		this.eventMap.unmapListeners();
	}

	/**
	 * Dispatches a CustomEvent on the specified node, holding Dynamic data.
	 * @param	eventType the event type
	 * @param	?data, the data to attach to the event object (event.detail)
	 * @param	?dispatcher the dispatching node.
	 */
	public function dispatch(eventType:String, ?data:Dynamic=null, ?dispatcher:HtmlDom=null):Void
	{
		if (dispatcher == null)
			dispatcher = rootElement;
		var event : CustomEvent = cast js.Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(eventType, false, false, data);
		dispatcher.dispatchEvent(event);
	}

	/**
	 * Tells if a given class is a DisplayObject.
	 * TODO cannot simply use Std.is here ?
	 * 
	 * @param	cmpClass	the Class to check.
	 * @return	Bool		true if DisplayObject is in the Class inheritance tree.
	 */
	static public function isDisplayObject(cmpClass : Class<Dynamic>):Bool
	{
		if (cmpClass == Type.resolveClass("brix.component.ui.DisplayObject"))
			return true;

		if (Type.getSuperClass(cmpClass) != null)
			return isDisplayObject(Type.getSuperClass(cmpClass));

		return false;
	}

	/**
	 * Checks if a given element is allowed to be the component's rootElement against the tag filters.
	 * 
	 * @param	cmpClass: the component class to check
	 * @param	elt: the DOM element to check. By default the rootElement.
	 */
	static public function checkFilterOnElt( cmpClass:Class<Dynamic> , elt:HtmlDom ) : Void
	{
		if (elt.nodeType != Lib.document.body.nodeType)
			throw "cannot instantiate "+Type.getClassName(cmpClass)+" on a non element node.";

		var tagFilter = (haxe.rtti.Meta.getType(cmpClass) != null) ? haxe.rtti.Meta.getType(cmpClass).tagNameFilter : null ;

		if ( tagFilter == null)
			return;

		if ( Lambda.exists( tagFilter , function(s:Dynamic) { return elt.nodeName.toLowerCase() == Std.string(s).toLowerCase(); } ) )
			return;
		
		throw "cannot instantiate "+Type.getClassName(cmpClass)+" on this type of HTML element: "+elt.nodeName.toLowerCase();
	}

	// --- CUSTOMIZABLE API ---

	/**
	 * For specific initialization logic specific to your component class, override this method.
	 */
	public function init() : Void { }

	/**
	 * Override this method if you need some special logic on your component when removing it.
	 */
	public function clean() : Void 
	{
		// release the event listeners
		unmapListeners();
	}
}