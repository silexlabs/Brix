package slplayer.ui;

import slplayer.core.SLPlayer;

import js.Lib;
import js.Dom;

import haxe.Template;

/**
 * TODO rename DisplayObject in something more explicit ?
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
	static var rootElementNameFilter : List<String> = Lambda.list([]);
	
	
	/**
	 * The Template object used to render the template syntax.
	 */
	var tpl : Template;
	
	/**
	 * The dom node associated with the instance of this component
	 */
	public var rootElement(default, null) : HtmlDom;

	private function new(rootElement : HtmlDom) 
	{
		this.rootElement = rootElement;
		
		SLPlayer.addAssociatedComponent(rootElement, this);
	}
	
	// --- CUSTOMIZABLE API ---

	public dynamic function init(e:Event) : Void { }
}