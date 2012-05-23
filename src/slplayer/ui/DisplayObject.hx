package slplayer.ui;

import slplayer.core.SLPlayer;

import js.Lib;
import js.Dom;

import haxe.Template;

/**
 * 
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
	 * A list of allowed tag names for the root element.
	 * If this parameter isn't defined or if the list is empty, it means there is no filtering (all tag names are allowed).
	 */
	static var bodyElementNameFilter : List<String> = Lambda.list([]);
	
	static public var BODY_TAG = "body";
	
	/**
	 * The dom node associated with the instance of this component.
	 */
	public var rootElement(default, null) : HtmlDom;
	/**
	 * The dom node associated with the UI of this component. By default, it will be the same as the rootElement.
	 * But if a direct child element of the rootElement has the data-body attribute set to the classname of this component, 
	 * it will be used as the root UI element. However, the events will still be dispatched to and listen from the real rootElement.
	 */
	public var bodyElement(default, null) : HtmlDom;

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
	 * @param	rootElement
	 * @return
	 */
	private function determineBodyElement(rootElement : HtmlDom):HtmlDom
	{
		var childElts = rootElement.childNodes;
		for (cnt in 0...childElts.length)
		{
			if (childElts[cnt].nodeType != Lib.document.body.nodeType) //FIXME is there a cleaner way to get the value of the type element ?
				continue;
			
			if (childElts[cnt].getAttribute("data-"+BODY_TAG) != null)
			{
				if (Lambda.exists( childElts[cnt].getAttribute("data-" + BODY_TAG).split(" ") , function (s:String) { return s == Reflect.field(Type.getClass(this), "className"); } ))
					if (checkFilterOnElt(childElts[cnt]))
						return childElts[cnt];
			}
		}
		return rootElement;
	}
	
	/**
	 * Checks if a given element is allowed to be the component's bodyElement against the tag filters.
	 * @param	elt
	 * @param	tagFilter
	 * @return
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

	public dynamic function init() : Void { }
}