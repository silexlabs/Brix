package slplayer.ui.group;

import slplayer.ui.DisplayObject;
import slplayer.core.SLPlayer;

import js.Dom;
import js.Lib;

/**
 * Gives its child elements a common event-based communication point.
 * @author Thomas Fétiveau
 */
class Group extends DisplayObject
{
	override public dynamic function init() : Void
	{
		groupMembers();
	}
	
	private function groupMembers()
	{
		var groupableChilds : List<IGroupable> = discoverGroupableChilds(rootElement);
		
		for (member in groupableChilds)
		{
			member.groupElement = rootElement;
		}
	}
	
	private function discoverGroupableChilds(elt:HtmlDom) : List<IGroupable>
	{
		var groupables : List<IGroupable> = new List();
		
		var directChilds:HtmlCollection<Dynamic> = elt.childNodes;
		
		for (childCnt in 0...directChilds.length)
		{
			var childElt : HtmlDom = cast directChilds[childCnt];
			if (childElt.nodeType != Lib.document.body.nodeType)
				continue;
			
			var cmps = getSLPlayer().getAssociatedComponents(directChilds[childCnt]);
			
			if (cmps != null)
			{
				for (cmp in cmps)
				{
					if (Std.is(cmp,IGroupable))
					{
						groupables.add(cast cmp);
					}
				}
			}
			
			groupables = Lambda.concat(groupables, discoverGroupableChilds(directChilds[childCnt]));
		}
		
		return groupables;
	}
}