/*
 * This file is part of SLPlayer http://www.silexlabs.org/groups/labs/slplayer/
 * 
 * This project is © 2011-2012 Silex Labs and is released under the GPL License:
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms 
 * of the GNU General Public License (GPL) as published by the Free Software Foundation; 
 * either version 2 of the License, or (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU General Public License for more details.
 * 
 * To read the license please visit http://www.gnu.org/copyleft/gpl.html
 */
package org.slplayer.component.group;

import org.slplayer.core.Builder;
import org.slplayer.util.MacroTools;

import cocktail.Dom;
import cocktail.Lib;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

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
	@:macro static public function build() : Array<haxe.macro.Field>
	{
		var groupFullClassName = Context.getLocalClass().get().pack.join(".") + "." + Context.getLocalClass().get().name;
		
		var groupClassNames = Builder.getUnconflictedClassTags( groupFullClassName );
		
		var shortestClassName = groupClassNames.first();
		
		for ( scn in groupClassNames ) { if (scn.length < shortestClassName.length) shortestClassName = scn; }
		
		//the group id sequence
		var gCnt = 0;
		
		for ( groupClass in groupClassNames )
		{
			for ( groupElt in Lib.document.body.getElementsByClassName(groupClass) )
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
	static private function discoverGroupableChilds( elt:HtmlDom ) : List<HtmlDom>
	{
		var groupables : List<HtmlDom> = new List();
		
		var directChilds:HtmlCollection<Dynamic> = elt.childNodes;
		
		for (childCnt in 0...directChilds.length)
		{
			var childElt : HtmlDom = cast directChilds[childCnt];
			if (childElt.nodeType != Lib.document.body.nodeType)
				continue;
			
			if ( childElt.getAttribute("class") != null ){
				for ( classAttr in childElt.getAttribute("class").split(" ") )
				{
					var potentialClasses = Builder.getClassNameFromClassTag(classAttr);
					
					if ( potentialClasses.length != 1 ){
						continue; //can't be a valid component class tag value
					}
					
					if ( !MacroTools.is( switch( Context.getType(potentialClasses.first()) ) { case TInst( classRef , params ): classRef.get(); default : } , "org.slplayer.component.group.IGroupable" ) )
						continue;
					groupables.add(childElt);
				}
			}
			
			groupables = Lambda.concat(groupables, discoverGroupableChilds(directChilds[childCnt]));
		}
		return groupables;
	}
}