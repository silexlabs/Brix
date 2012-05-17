package slplayer.ui;

import js.Lib;
import js.Dom;

/**
 * ...
 * @author Thomas Fétiveau
 */
class DisplayObject 
{
	/**
	 * The class name associated with this component
	 */
	public static var className : String = "DisplayObject";
	/**
	 * The dom node associated with the instance of this component
	 */
	public var rootElement(default, null) : HtmlDom;

	private function new(rootElement : HtmlDom) 
	{
		this.rootElement = rootElement;
		
		//Keep a reference within the node object to each DisplayObject instance linked to this node
		var slPlayerCmps : List<DisplayObject> = cast Reflect.field(rootElement, "slPlayerCmps");
		
		if (slPlayerCmps == null)
			slPlayerCmps = new List();

		slPlayerCmps.add(this);
	}
	
	// --- CUSTOMIZABLE API ---

	public dynamic function init(e:Event) : Void { }
}