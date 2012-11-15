/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.test.unit.util.data;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import brix.util.data.Ini;

import js.XMLHttpRequest;

/**
 * Unit tests for brix.util.data.Ini
 * @author Thomas Fétiveau
 */
class IniTest 
{
	private var timer:Timer;

	public function new() 
	{
		
	}

	@Test
	public function testParsing():Void
	{
		var filename:String = "http://127.0.0.1/brix/test/unit/bin/data/example.ini";
		var xmlHttp = new XMLHttpRequest();
		xmlHttp.open( "GET", filename, false );
		xmlHttp.send( null );
		if (xmlHttp.status != 200 || xmlHttp.readyState != 4)
		{
			trace("WARNING: Can't fetch Ini file at "+filename);
			return;
		}
		
		var ini = Ini.parse(xmlHttp.responseText);
		
		Assert.isFalse( ini.get("BOOLEAN_VALUE"));
		Assert.isTrue( ini.get("OTHER_BOOLEAN"));
		Assert.isNull( ini.get("A_NULL_VALUE", "first"));
		Assert.areEqual( "toto toto toto to", ini.get("TOTO"));
		Assert.areEqual( 15, ini.get("AN_INT_VAL", "first"));
		Assert.areEqual( 0.5, ini.get("A_FLOAT", "second"));
		Assert.areEqual( 0.5, ini.get("ANOTHER_FLOAT", "second"));
		Assert.areEqual( 105.897, ini.get("A_BIGGER_FLOAT", "second"));
		
		Assert.isType( ini.get("AN_ARRAY_OF_STRINGS", "array"), Array );
		
		Assert.areEqual( "toto" , ini.get("AN_ARRAY_OF_STRINGS", "array")[3] );
		Assert.isTrue( ini.get("AN_ARRAY_OF_BOOLS", "array")[2] );
		Assert.isFalse( ini.get("MIXED_ARRAY", "array")[3] );
		Assert.isType( ini.get("MIXED_ARRAY", "array")[1], Float );
		Assert.areEqual( 5, ini.get("MIXED_ARRAY", "array").length);
	}

}