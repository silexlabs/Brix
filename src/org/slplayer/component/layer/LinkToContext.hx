package org.slplayer.component.layer;

import js.Lib;
import js.Dom;

import org.slplayer.component.layer.LinkBase;
import org.slplayer.util.DomTools;

/**
 * Let you specify a context to display when the user clicks on the component's node
 * All the elements with the context in their class name will be displayed. Initially, you are expected to set ther css style "visibility" to "hidden"
 */
@tagNameFilter("a")
class LinkToContext extends LinkBase{
	/**
	 * constant, name of attribute
	 * Optional, you can use href instead
	 */
	public static inline var CONFIG_TRANSITION_DURATION:String = "data-context";
	/**
	 * Stores the style node with the current context as visible 
	 */
	private static var styleSheet:StyleSheet;
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, SLPId:String) {
		super(rootElement, SLPId);
		// retrieve the name of our link in data-context instead of href
		if (rootElement.getAttribute(CONFIG_TRANSITION_DURATION) != null){
			linkName = rootElement.getAttribute(CONFIG_TRANSITION_DURATION);
		}
		trace("LinkToContext "+linkName);
	}
	/**
	 * user clicked the link
	 * do an action to the pages corresponding to our link
	 */
	override private function onClick(e:Event){
		if (styleSheet != null){
			Lib.document.getElementsByTagName("head")[0].removeChild(cast(styleSheet));	
		}

		var node = Lib.document.createElement('style');
		node.setAttribute('type', 'text/css');

		var cssText = "."+linkName+" {visibility : visible; }";
		node.appendChild(Lib.document.createTextNode(cssText));
		
		Lib.document.getElementsByTagName("head")[0].appendChild(node);

		trace("LinkToContext added "+cssText);

		styleSheet = cast(node);
	}

}
