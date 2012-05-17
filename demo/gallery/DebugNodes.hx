package ;

import slplayer.ui.DisplayObject;
import slplayer.core.SLPlayer;

import js.Lib;
import js.Dom;

/**
 * ...
 * @author Thomas Fétiveau
 */

class DebugNodes  extends DisplayObject
{
	static override var className = "debugnode";
	
	override public function init(e:Event):Void 
	{
		trace("DebugNodes component initialized");
		
		var debugButton = Lib.document.createElement("img");
		debugButton.setAttribute("src", "assets/debug.png");
		debugButton.onclick = callback(debugNodes);
		this.rootElement.appendChild(debugButton);
	}
	
	public function debugNodes(e : Event)
	{
		trace("debugNodes");
		debugNode(Lib.document.body);
	}
	
	public function debugNode(node : HtmlDom)
	{
		trace("debugNode("+node+")");
		for (cCount in 0...node.childNodes.length)
		{
			if (cast(node.childNodes[cCount]).className != null)
			{
				trace("CLASSNAME FOUND");
				var tagName = untyped node.childNodes[cCount].nodeName;
				trace("tag " + tagName +
				" with class=" + cast(node.childNodes[cCount]).className +
				" has associated components : "+SLPlayer.getAssociatedComponents(cast(node.childNodes[cCount])));
			}
			if (node.childNodes[cCount].hasChildNodes())
				debugNode(cast(node.childNodes[cCount]));
		}
	}
}