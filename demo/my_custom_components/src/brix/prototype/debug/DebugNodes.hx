package brix.prototype.debug;

import brix.component.ui.DisplayObject;
import brix.core.Application;

import js.Lib;
import js.Dom;

/**
 * ...
 * @author Thomas Fétiveau
 */
class DebugNodes  extends DisplayObject
{
	override public function init():Void 
	{
		trace("DebugNodes component initialized");
		
		var debugButton = Lib.document.createElement("img");
		debugButton.setAttribute("src", "assets/debug.png");
		debugButton.onclick = callback(debugNodes);
		this.rootElement.appendChild(debugButton);
	}
	
	public function debugNodes(e : Event)
	{
		debugNode(getBrixApplication().htmlRootElement);
	}
	
	public function debugNode(node : HtmlDom)
	{
		for (cCount in 0...node.childNodes.length)
		{
			var elt : HtmlDom = cast(node.childNodes[cCount]);
			if (elt.className != null)
			{
				var tagName = untyped elt.nodeName;
				trace("tag " + tagName +
				" with class=" + elt.className +
				" has associated components : "+getBrixApplication().getAssociatedComponents(elt,Type.resolveClass("brix.component.ui.DisplayObject")));
			}
			if (node.childNodes[cCount].hasChildNodes())
				debugNode( elt );
		}
	}
}