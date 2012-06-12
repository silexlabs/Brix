package slplayer.ui;

import slplayer.core.Application;

import slplayer.core.ISLPlayerComponent;
using slplayer.core.ISLPlayerComponent.SLPlayerComponent;

import slplayer.core.SLPlayerComponentTools;

import js.Lib;
import js.Dom;

import haxe.Template;

/**
 * Structure helping with handling the skinnable elts of a component.
 * FIXME / TODO keep this and generalize a skining sub-cmps handling logic or remove this.
 */
typedef SkinnableUIElt = 
{
	eltAttrId : String,
	elt : HtmlDom
}

/**
 * TODO comment
 */
interface IDisplayObject implements ISLPlayerComponent
{
	public var SLPlayerInstanceId : String;
	
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
	 * The id of the containing SLPlayer instance.
	 */
	public var SLPlayerInstanceId : String;
	/**
	 * The dom node associated with the instance of this component. By default, all events used for communication with other 
	 * components are dispatched to and listened from this DOM element.
	 */
	public var rootElement(default, null) : HtmlDom;
	
	/**
	 * Returns the associated running Application instance.
	 * 
	 * @return	an Application object.
	 */
	public function getSLPlayer() : Application
	{
		return SLPlayerComponent.getSLPlayer(this);
	}
	
	/**
	 * Common constructor for all DisplayObjects. If there is anything specific to a given component class initialization, override the init() method.
	 * 
	 * @param	rootElement
	 */
	private function new(rootElement : HtmlDom, SLPId:String) 
	{
		this.rootElement = rootElement;
		
		initSLPlayerComponent(SLPId);
		
		#if disableFastInit
			//check the @tagNameFilter constraints
			checkFilterOnElt(Type.getClass(this) , rootElement);
			//check the @requires constraints
			SLPlayerComponentTools.checkRequiredParameters(Type.getClass(this) , rootElement);
		#end
		
		Application.get(SLPlayerInstanceId).addAssociatedComponent(rootElement, this);
		
		#if slpdebug
			trace("Successfuly created instance of "+Type.getClassName(Type.getClass(this)));
		#end
	}
	
	/**
	 * Tells if a given class is a DisplayObject. 
	 * 
	 * @param	cmpClass	the Class to check.
	 * @return	Bool		true if DisplayObject is in the Class inheritance tree.
	 */
	static public function isDisplayObject(cmpClass : Class<Dynamic>):Bool
	{
		if (cmpClass == Type.resolveClass("slplayer.ui.DisplayObject"))
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
	public dynamic function init() : Void { }
}