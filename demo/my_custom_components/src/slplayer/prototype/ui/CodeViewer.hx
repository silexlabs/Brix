package slplayer.prototype.ui;

import js.Lib;
import js.Dom;

import slplayer.ui.DisplayObject;

using StringTools;

/**
 * This component "extends" the behavior of the <pre> element by reducing the default tab size (a
 * standard css3 property may appear one day: http://dev.w3.org/csswg/css3-text/#tab-size) and optionaly
 * reading its content from another component.
 * @author Thomas Fétiveau
 */
@tagNameFilter("pre")
class CodeViewer extends DisplayObject
{
	/**
	 * The data- optional attribute used to specify with HTML element we're viewing.
	 */
	static inline var CODE_VIEW_ID_TAG = "code-viewer-id";
	
	/**
	 * Overrides constructor to avoid having the slpid attributes in the HTML code at runtime.
	 * @param	rootElement
	 * @param	SLPId
	 */
	override private function new(rootElement : HtmlDom, SLPId:String) 
	{
		super(rootElement, SLPId);
		
		//get container element
		var container = Lib.document.getElementById(rootElement.getAttribute("data-"+CODE_VIEW_ID_TAG).split(' ')[0]);
		
		if ( container == null)
		{
			container = rootElement;
		}
		
		//reduce default tab size
		rootElement.innerHTML = container.innerHTML.htmlEscape().replace( "	" , "&nbsp;&nbsp;").replace("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;","");
	}
}