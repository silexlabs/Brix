package slplayer.prototype.ui;

import js.Lib;
import js.Dom;

import slplayer.ui.DisplayObject;

import slplayer.core.SLPlayer;

using StringTools;

/**
 * This component "extends" the behavior of the <pre> element by reducing the default tab size (a
 * standard css3 property may appear one day: http://dev.w3.org/csswg/css3-text/#tab-size) and optionaly
 * reading its content from another component.
 * @author Thomas Fétiveau
 */
class CodeViewer extends DisplayObject
{
	/**
	 * A list of allowed tag names for the root element.
	 */
	static var rootElementNameFilter : List<String> = Lambda.list(["pre"]);
	
	static var CODE_VIEW_ID_TAG = "code-viewer-id";
	
	override private function new(rootElement : HtmlDom) 
	{
		super(rootElement);
		
		//get container element
		var container = Lib.document.getElementById(rootElement.getAttribute("data-"+CODE_VIEW_ID_TAG));
		
		if ( container == null)
		{
			container = rootElement;
		}
		
		//reduce default tab size
		rootElement.innerHTML = container.innerHTML.htmlEscape().replace( "	" , "&nbsp;&nbsp;").replace("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;","");
	}
}