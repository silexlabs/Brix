/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.group;

import brix.component.ui.DisplayObject;

import js.Dom;
//import js.Lib;

/**
 * Gives its child elements a common event-based communication point.
 * 
 * @author Thomas Fétiveau
 */
//@:build(brix.component.group.GroupBuilder.build())
class Group extends DisplayObject
{
	/**
	 * 
	 */
	static inline private var GROUP_ID_ATTR:String = "data-group-id";
	/**
	 * 
	 */
	static public var GROUP_SEQ:Int = 0;
	
	/**
	 * 
	 * @param	rootElement
	 * @param	BrixId
	 */
	private function new(rootElement : HtmlDom, brixId:String)
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
	private function discoverGroupableChilds( elt:HtmlDom ) : List<HtmlDom>
	{
		var groupables : List<HtmlDom> = new List();

		if (elt.nodeType != 1 || elt.className==null) return groupables;

		//if (!getBrixApplication().getAssociatedComponents(elt,brix.component.group.IGroupable).isEmpty())
		for (c in elt.className.split(" "))
		{
			var rc:Class<Dynamic> = getBrixApplication().resolveUIComponentClass(c);

			if ( rc == null ) continue;

			var ci = Type.createEmptyInstance(rc);

			if ( ci == null || !Std.is( ci, brix.component.group.IGroupable) ) continue;

			groupables.add(elt);
			break;
		}

		for (childCnt in 0...elt.childNodes.length)
		{
			groupables = Lambda.concat(groupables, discoverGroupableChilds(elt.childNodes[childCnt]));
		}
		return groupables;
	}
}