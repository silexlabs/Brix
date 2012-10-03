/*
 * This file is part of Brix http://www.silexlabs.org/groups/labs/slplayer/
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
package org.brix.test.unit;

import utest.Assert;
import utest.Runner;
import utest.ui.Report;

import org.slplayer.util.DomTools;

import js.Dom;
import js.Lib;

/**
 * ...
 * @author Thomas Fétiveau
 */
class DomToolsTests
{
	
	public static function main()
	{	
		var runner = new Runner();
		runner.addCase(new DomToolsTests());
		Report.create(runner);
		runner.run();
	}
	
	public function new() { }

	/**
	 * Tests DomTools.removeClass(element:HtmlDom, className:String):Void
	 */
	public function testRemoveClass():Void
	{
		var myDiv:HtmlDom = Lib.document.createElement("div");
		myDiv.className = "myClass1";

		DomTools.removeClass( myDiv, "myClass2");
		Assert.equals( "myClass1", myDiv.className);
		DomTools.removeClass( myDiv, "myClass2 myClass3");
		Assert.equals( "myClass1", myDiv.className);
		DomTools.removeClass( myDiv, "myClass1");
		Assert.equals( "", myDiv.className);
		myDiv.className = "myClass4";
		DomTools.removeClass( myDiv, "myClass3 myClass4");
		Assert.equals( "", myDiv.className);

		var myDiv2:HtmlDom = Lib.document.createElement("div");
		myDiv2.className = "myClass1 myClass2 myClass3";

		DomTools.removeClass( myDiv2, "myClass2");
		Assert.equals( "myClass1 myClass3", myDiv2.className);
		DomTools.removeClass( myDiv2, "myClass2 myClass3");
		Assert.equals( "myClass1", myDiv2.className);
		DomTools.removeClass( myDiv2, "myClass1");
		Assert.equals( "", myDiv2.className);
		myDiv2.className = "myClass4 myClass3";
		DomTools.removeClass( myDiv2, "myClass3 myClass4");
		Assert.equals( "", myDiv2.className);

		var myDiv3:HtmlDom = Lib.document.createElement("div");

		Assert.equals( "", myDiv3.className);
		DomTools.removeClass( myDiv3, "myClass2");
		Assert.equals( "", myDiv3.className);
	}

	/**
	 * Tests DomTools.addClass(element:HtmlDom, className:String):Void
	 */
	public function testAddClass():Void
	{
		var myDiv:HtmlDom = Lib.document.createElement("div");
		myDiv.className = "myClass1";

		DomTools.addClass( myDiv , "myClass2" );
		Assert.equals( "myClass1 myClass2", myDiv.className);
		DomTools.addClass( myDiv , "myClass2 myClass3" );
		Assert.equals( "myClass1 myClass2 myClass3", myDiv.className);
		DomTools.addClass( myDiv , "myClass1" );
		Assert.equals( "myClass1 myClass2 myClass3", myDiv.className);

		var myDiv2:HtmlDom = Lib.document.createElement("div");
		myDiv2.className = "myClass1 myClass2 myClass3";

		DomTools.addClass( myDiv2 , "myClass2" );
		Assert.equals( "myClass1 myClass2 myClass3", myDiv2.className);
		DomTools.addClass( myDiv2 , "myClass2 myClass3" );
		Assert.equals( "myClass1 myClass2 myClass3", myDiv2.className);
		DomTools.addClass( myDiv2 , "myClass4" );
		Assert.equals( "myClass1 myClass2 myClass3 myClass4", myDiv2.className);

		var myDiv3:HtmlDom = Lib.document.createElement("div");

		DomTools.addClass( myDiv3 , "myClass2" );
		Assert.equals( "myClass2", myDiv3.className);
		DomTools.addClass( myDiv3 , "myClass2 myClass3" );
		Assert.equals( "myClass2 myClass3", myDiv3.className);
		DomTools.addClass( myDiv3 , "myClass4" );
		Assert.equals( "myClass2 myClass3 myClass4", myDiv3.className);
	}

	/**
	 * Tests DomTools.hasClass(element:HtmlDom, className:String, ?orderedClassName:Bool=false):Bool
	 */
	public function testHasClass():Void
	{
		var myDiv:HtmlDom = Lib.document.createElement("div");
		myDiv.className = "myClass1 myClass2 myClass3";
		
		// unordered
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass1") );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass2") );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass3") );
		Assert.isFalse( DomTools.hasClass(myDiv, "myClass4") );

		Assert.isTrue( DomTools.hasClass(myDiv, "myClass3 myClass1") );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass2 myClass1") );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass1 myClass3") );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass1 myClass2") );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass1 myClass2 myClass3") );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass2 myClass1 myClass3") );
		Assert.isFalse( DomTools.hasClass(myDiv, "myClass4 myClass1 myClass3") );
		Assert.isFalse( DomTools.hasClass(myDiv, "myClass1 myClass2 myClass3 myClass4") );

		// ordered
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass1", true) );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass2", true) );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass3", true) );
		Assert.isFalse( DomTools.hasClass(myDiv, "myClass4", true) );
		
		Assert.isFalse( DomTools.hasClass(myDiv, "myClass3 myClass1", true) );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass1 myClass3", true) );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass1 myClass2 myClass3", true) );
		Assert.isTrue( DomTools.hasClass(myDiv, "myClass2 myClass3", true) );
		Assert.isFalse( DomTools.hasClass(myDiv, "myClass3 myClass2 myClass1", true) );
		Assert.isFalse( DomTools.hasClass(myDiv, "myClass1 myClass3 myClass2", true) );
		Assert.isFalse( DomTools.hasClass(myDiv, "myClass1 myClass2 myClass3 myClass4", true) );

		// single classed node
		var myDiv2:HtmlDom = Lib.document.createElement("div");
		myDiv2.className = "myClass4";

		// unordered
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass1") );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass2") );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass3") );
		Assert.isTrue( DomTools.hasClass(myDiv2, "myClass4") );

		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass3 myClass1") );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass2 myClass1") );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass1 myClass3") );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass1 myClass2") );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass1 myClass2 myClass3") );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass2 myClass1 myClass3") );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass4 myClass1 myClass3") );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass1 myClass2 myClass3 myClass4") );

		// ordered
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass1", true) );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass2", true) );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass3", true) );
		Assert.isTrue( DomTools.hasClass(myDiv2, "myClass4", true) );
		
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass3 myClass1", true) );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass1 myClass3", true) );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass1 myClass2 myClass3", true) );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass2 myClass3", true) );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass3 myClass2 myClass1", true) );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass1 myClass3 myClass2", true) );
		Assert.isFalse( DomTools.hasClass(myDiv2, "myClass1 myClass2 myClass3 myClass4", true) );

		// not classed node
		var myDiv3:HtmlDom = Lib.document.createElement("div");

		// unordered
		Assert.isFalse( DomTools.hasClass(myDiv3, "myClass1") );
		Assert.isFalse( DomTools.hasClass(myDiv3, "myClass1 myClass2") );
		// ordered
		Assert.isFalse( DomTools.hasClass(myDiv3, "myClass1", true) );
		Assert.isFalse( DomTools.hasClass(myDiv3, "myClass1 myClass2", true) );
		Assert.isFalse( DomTools.hasClass(myDiv3, "myClass1", true) );
		
	}
	/*
	function testDocument()
	{
		
		Assert.equals(Lib.document.nodeType, Node.DOCUMENT_NODE);
		
		var div = Lib.document.createElement("div");
		
		Assert.equals(div.tagName, "div");
		
		var txt = Lib.document.createTextNode("test text");
		
		Assert.equals(txt.nodeValue, "test text");
		
		Lib.document.body.appendChild(div);
		
		div.setIdAttribute("id", true);
		div.setAttribute("id", "myDiv");
		var retrievedDiv = Lib.document.getElementById("myDiv");
		
		Assert.equals(div, retrievedDiv);
		
		var li = Lib.document.createElement("li");
		
		var li2 = Lib.document.createElement("li");
		
		li.appendChild(li2);
		
		Lib.document.body.appendChild(li);
		
		var lis = Lib.document.getElementsByTagName("li");
		
		Assert.equals(lis[0], li);
		Assert.equals(lis[1], li2);
		
		
		var attr = Lib.document.createAttribute("bim");
		
		Assert.equals(attr.nodeName, "bim");
		Assert.equals(attr.value, "");
		
		
	}*/
}