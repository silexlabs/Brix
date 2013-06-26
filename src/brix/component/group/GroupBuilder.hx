/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.group;


import brix.component.list.JsonConnector;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

import brix.core.Builder;
import brix.util.MacroTools;

import cocktail.html.HtmlElement;


using Lambda;

/**
 * Implements the group "magic" (ie: associating the group component with its groupable childs at compile time).
 * 
 * @author Thomas Fétiveau
 */
class GroupBuilder
{
	/**
	 * Parses the HTML source file to search for declared groups. When a group is found, give it a unique id and share this id
	 * its groupable childs. This id assignment and sharing is done by modifying the HTML DOM. This allows then any groupable
	 * component to retreive its group DOM element transparently thanks to the GroupableBuilder macro.
	 */
	macro static public function build() : Array<haxe.macro.Field>
	{
		var groupFullClassName = Context.getLocalClass().get().pack.join(".") + "." + Context.getLocalClass().get().name;
		
		var groupClassNames = Builder.getUnconflictedClassTags( groupFullClassName );
		
		var shortestClassName = groupClassNames.first();
		
		for ( scn in groupClassNames ) { if (scn.length < shortestClassName.length) shortestClassName = scn; }
		
		//the group id sequence
		var gCnt = 0;
		
		for ( groupClass in groupClassNames )
		{
			for ( groupElt in cocktail.Browser.document.body.getElementsByClassName(groupClass) )
			{
				gCnt++;
				
				//generate a new group id and set it on the group elt
				var classAttr = groupElt.getAttribute("class");
				
				var newGroupId : String = shortestClassName + gCnt;
				
				var newClassAttr : String = newGroupId;
				
				for (ca in classAttr.split(" "))
				{
					if ( ca != groupClass )
					{
						newClassAttr += " " + ca;
					}
				}
				
				groupElt.setAttribute("class" , newClassAttr);
				
				//discover the IGroupable childs and set the group id on their DOM elt
				for (cg in discoverGroupableChilds(groupElt))
				{
					cg.setAttribute( "data-group-id" , newGroupId );
				}
			}
		}
		return haxe.macro.Context.getBuildFields();
	}

	/**
	 * Search for groupable components in the childs of the given HTML element.
	 * 
	 * @param the HTML element to search in.
	 * @return a List of elements associated with at list one groupable component.
	 */
	static private function discoverGroupableChilds( elt:HtmlElement ) : List<HtmlElement>
	{
		var groupables : List<HtmlElement> = new List();

		var directChilds:cocktail.html.NodeList = elt.childNodes;

		for (childCnt in 0...directChilds.length)
		{
			var childElt : HtmlElement = cast directChilds[childCnt];
			if (childElt.nodeType != Lib.document.body.nodeType)
				continue;

			if ( childElt.className != null )
			{
				for ( classAttr in childElt.className.split(" ") )
				{
					var potentialClasses = Builder.getClassNameFromClassTag(classAttr);

					if ( potentialClasses.length != 1 )
					{
						continue; //can't be a valid component class tag value
					}
					if ( !MacroTools.is( switch( Context.getType(potentialClasses.first()) ) { case TInst( classRef , params ): classRef.get(); default : } , "brix.component.group.IGroupable" ) )
					{
						continue;
					}
					groupables.add(childElt);
					break;
				}
				if (Lambda.has(childElt.className.split(" "), "Group"))
				{
					continue;
				}
			}
			groupables = Lambda.concat(groupables, discoverGroupableChilds(directChilds[childCnt]));
		}
		return groupables;
	}
}