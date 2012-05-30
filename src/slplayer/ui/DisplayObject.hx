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
 * This is the class every UI component must extend to be attached to the DOM.
 * @author Thomas Fétiveau
 */
class DisplayObject 
{
	/**
	 * A list of allowed tag names for the body element.
	 * If this parameter isn't defined or if the list is empty, it means there is no filtering (all tag names are allowed).
	 */
	static var rootElementNameFilter : List<String> = Lambda.list([]);
	
	/**
	 * The dom node associated with the instance of this component. By default, all events used for communication with other 
	 * components are dispatched to and listened from this DOM element.
	 */
	public var rootElement(default, null) : HtmlDom;
	
	/**
	 * Common constructor for all DisplayObjects. If there is anything specific to a given component class initialization, override the init() method.
	 * @param	rootElement
	 */
	private function new(rootElement : HtmlDom) 
	{
		this.rootElement = rootElement;
		
		if (!checkFilterOnElt(rootElement))
			throw "ERROR: cannot instantiate "+Type.getClassName(Type.getClass(this))+" on a "+rootElement.nodeName+" element.";
		
		SLPlayer.addAssociatedComponent(rootElement, this);
	}
	
	/**
	 * Checks if a given element is allowed to be the component's rootElement against the tag filters.
	 * @param	elt: the HtmlDom to check.
	 * @return true if allowed, false if not.
	 */
	private function checkFilterOnElt( elt:HtmlDom ) : Bool
	{
		if (elt.nodeType != Lib.document.body.nodeType) //FIXME cleaner way to do this comparison ?
			return false;
		
		var tagFilter = Reflect.field(Type.getClass(this), "rootElementNameFilter");
		
		if ( tagFilter == null || tagFilter.isEmpty() )
			return true;
		
		if ( Lambda.exists( tagFilter , function(s:String) { return elt.nodeName.toLowerCase() == s.toLowerCase(); } ) )
			return true;
		
		return false;
	}
	
	// --- CUSTOMIZABLE API ---
	
	/**
	 * For specific initialization logic specific to your component class, override this method.
	 */
	public dynamic function init() : Void { }
}