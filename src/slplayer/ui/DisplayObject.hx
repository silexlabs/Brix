package slplayer.ui;

import slplayer.core.SLPlayer;

import js.Lib;
import js.Dom;

import haxe.Template;

/**
 * Structure helping with handling the skinnable elts of a component.
 */
typedef SkinnableUIElt = 
{
	eltAttrId : String,
	elt : HtmlDom
}

/**
 * This is the class every UI component must extends to be attached to the DOM.
 * @author Thomas Fétiveau
 */
class DisplayObject 
{
	/**
	 * The class name associated with this component. It's what appears in the class attribute of the HTML
	 * elements that have an instance of this component attached to them.
	 */
	static var className : String = "displayobject";
	/**
	 * A list of allowed tag names for the body element.
	 * If this parameter isn't defined or if the list is empty, it means there is no filtering (all tag names are allowed).
	 */
	static var bodyElementNameFilter : List<String> = Lambda.list([]);
	/**
	 * The data- attribute to set on a direct child element to use as the body element (the root UI element).
	 */
	static public var BODY_TAG = "body";
	
	/**
	 * The dom node associated with the instance of this component. By default, all events used for communication with other 
	 * components are dispatched to and listened from this DOM element.
	 */
	public var rootElement(default, null) : HtmlDom;
	/**
	 * The dom node associated with the UI of this component. By default, it will be the same as the rootElement.
	 * But if a direct child element of the rootElement has the data-body attribute set to the classname of this component, 
	 * it will be used as the root UI element. However, the events will still be dispatched to and listen from the real rootElement.
	 */
	public var bodyElement(default, null) : HtmlDom;
	
	/**
	 * Common constructor for all DisplayObjects. If there is anything specific to a given component class initialization, override the init() method.
	 * @param	rootElement
	 */
	private function new(rootElement : HtmlDom) 
	{
		this.rootElement = rootElement;
		
		this.bodyElement = determineBodyElement(rootElement);
		
		if (!checkFilterOnElt(bodyElement))
			throw "ERROR: cannot instantiate "+Reflect.field(Type.getClass(this), "className")+" on a "+bodyElement.nodeName+" element.";
		
		SLPlayer.addAssociatedComponent(rootElement, this);
	}
	
	/**
	 * Search in the direct rootElement's childs for an element having the data-body parameter containing this component's classname value.
	 * @param	rootElement, the root HtmlDom associated with the component.
	 * @return  the bodyElement, ie: the root HtmlDom of the UI part of the component (defined by the data-body tag).
	 */
	private function determineBodyElement(rootElement : HtmlDom):HtmlDom
	{
		var childElts = rootElement.childNodes;
		for (cnt in 0...childElts.length)
		{
			if (childElts[cnt].nodeType != Lib.document.body.nodeType) //FIXME is there a cleaner way to get the value of the type element ?
				continue;
			
			if (cast(childElts[cnt], HtmlDom).getAttribute("data-"+BODY_TAG) != null)
			{
				if (Lambda.exists( cast(childElts[cnt], HtmlDom).getAttribute("data-" + BODY_TAG).split(" ") , function (s:String) { return s == Reflect.field(Type.getClass(this), "className"); } ))
					if (checkFilterOnElt( cast(childElts[cnt], HtmlDom) ))
						return cast(childElts[cnt], HtmlDom);
			}
		}
		return rootElement;
	}
	
	/**
	 * Checks if a given element is allowed to be the component's bodyElement against the tag filters.
	 * @param	elt: the HtmlDom to check.
	 * @return true if allowed, false if not.
	 */
	private function checkFilterOnElt( elt:HtmlDom ) : Bool
	{
		if (elt.nodeType != Lib.document.body.nodeType) //FIXME cleaner way to do this comparison ?
			return false;
		
		var tagFilter = Reflect.field(Type.getClass(this), "bodyElementNameFilter");
		
		if ( tagFilter == null || tagFilter.isEmpty() )
			return true;
		
		if ( Lambda.exists( tagFilter , function(s:String) { return elt.nodeName.toLowerCase() == s.toLowerCase(); } ) )
			return true;
		
		return false;
	}
	
	// --- CUSTOMIZABLE API ---
	
	/**
	 * For specific initialization logic specific to your component class, override this method.
	 * @param	args: the optionnal data- arguments a component could take for initialization.
	 */
	public dynamic function init(?args:Hash<String>) : Void { }
}