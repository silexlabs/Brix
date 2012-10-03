package brix.prototype.debug;

import org.brix.component.ui.DisplayObject;
import org.brix.core.Application;

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
		debugNode(getBrix().htmlRootElement);
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
				" has associated components : "+getBrix().getAssociatedComponents(elt,Type.resolveClass("org.brix.component.ui.DisplayObject")));
			}
			if (node.childNodes[cCount].hasChildNodes())
				debugNode( elt );
		}
	}
}