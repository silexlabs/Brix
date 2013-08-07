/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.group;

import js.html.HtmlElement;
import brix.component.ui.DisplayObject;


/**
 * Gives its child elements a common event-based communication point.
 * 
 * @author Thomas Fétiveau
 */
@:build(brix.component.group.GroupBuilder.build())
class Group extends DisplayObject
{
	/**
	 * The node attribute name for Groupable components to keep a reference to their group
	 */
	static inline private var GROUP_ID_ATTR:String = "data-group-id";
	/**
	 * The runtime group id sequence
	 */
	static public var GROUP_SEQ:Int = 0;
	
	/**
	 * 
	 * @param	rootElement
	 * @param	BrixId
	 */
	private function new(rootElement : HtmlElement, brixId:String)
	{
		super(rootElement, brixId);

		// manage case the Group instance has been added at runtime
		var explodedClassName = rootElement.className.split(" ");
		if (Lambda.has( explodedClassName, "Group" ))
		{
			GROUP_SEQ++;

			// r for runtime, not to mix with group ids set at macro time
			var newGroupId : String = "Group" + GROUP_SEQ + "r";

			explodedClassName.remove("Group");
			explodedClassName.unshift(newGroupId);
			rootElement.className = explodedClassName.join(" ");

			//discover the IGroupable childs and set the group id on their DOM elt
			for (gc in discoverGroupableChilds(rootElement))
			{
				gc.setAttribute( "data-group-id" , newGroupId );
			}
		}
	}

	/**
	 * Search for groupable components in the childs of the given HTML element.
	 * 
	 * @param the HTML element to search in.
	 * @return a List of elements associated with at list one groupable component.
	 */
	private function discoverGroupableChilds( elt:HtmlElement ) : List<HtmlElement>
	{
		var groupables : List<HtmlElement> = new List();

		for (childCnt in 0...elt.childNodes.length)
		{
			if (elt.childNodes[childCnt].nodeType != 1)
			{
				continue;
			}
			if (cast(elt.childNodes[childCnt]).className != null)
			{
				var classes:Array<String> = cast(elt.childNodes[childCnt]).className.split(" ");
				for (c in classes)
				{
					var rc:Class<Dynamic> = getBrixApplication().resolveUIComponentClass(c, brix.component.group.IGroupable);

					if ( rc == null ) continue;

					groupables.add(cast elt.childNodes[childCnt]);
					break;
				}
				if (Lambda.has(cast(elt.childNodes[childCnt]).className.split(" "), "Group"))
				{
					continue;
				}
			}
			groupables = Lambda.concat(groupables, discoverGroupableChilds(cast(elt.childNodes[childCnt])));
		}
		return groupables;
	}
}