/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component;

import brix.core.Application;

#if macro
import cocktail.html.HtmlElement;
#else
import js.html.HtmlElement;
#end

/**
 * The interface each Brix component should implement to be able to standardly retreive their Brix Application instance.
 * 
 * @author Thomas Fétiveau
 */
interface IBrixComponent
{
	/**
	 * the Brix Application instance id.
	 */
	public var brixInstanceId : String;
	
	/**
	 * a method to get transparently the associated Application instance.
	 */
	public function getBrixApplication() : Application;
}

/**
 * The common code to all Brix components.
 */
class BrixComponent 
{
	static public function initBrixComponent(component : IBrixComponent, brixInstanceId : String):Void
	{
		component.brixInstanceId = brixInstanceId;
	}
	
	static public function getBrixApplication(component : IBrixComponent):Application
	{
		return Application.get(component.brixInstanceId);
	}
	
	/**
	 * Checks if there is any missing required attribute on the associated HTML element of this component.
	 * 
	 * @param	the class of the component to check.
	 * @param	the DOM element to check. By default the rootElement.
	 */
	static public function checkRequiredParameters( cmpClass : Class<Dynamic> , elt:HtmlElement ) : Void
	{
		var requires = haxe.rtti.Meta.getType(cmpClass).requires;
		
		if (requires == null)
			return;

		for (r in requires)
		{
			if ( elt.getAttribute( Std.string(r) ) == null || StringTools.trim( elt.getAttribute( Std.string(r) ) ) == "" )
			{
				throw Std.string(r) + " parameter is required for "+Type.getClassName(cmpClass);
			}
		}
	}
}
