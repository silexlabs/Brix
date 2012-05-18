package slplayer.ui;

import slplayer.core.SLPlayer;

import js.Lib;
import js.Dom;

/**
 * TODO rename DisplayObject in something more explicit ?
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
		
		SLPlayer.addAssociatedComponent(rootElement, this);
	}
	
	// --- CUSTOMIZABLE API ---

	public dynamic function init(e:Event) : Void { }
}