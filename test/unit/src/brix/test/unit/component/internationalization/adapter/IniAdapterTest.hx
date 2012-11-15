/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.test.unit.component.internationalization.adapter;

import massive.munit.Assert;

import brix.component.internationalization.adapter.IniAdapter;

/**
 * @author Thomas Fétiveau
 */
class IniAdapterTest 
{	
	public function new() 
	{
		
	}
	
	@Test
	public function oneFilePerLocaleTest():Void
	{
		var args:Hash<String> = new Hash();
		args.set(brix.component.internationalization.Translator.LOCATION_ATTR, "http://127.0.0.1/brix/test/unit/bin/lang/en.ini,http://127.0.0.1/brix/test/unit/bin/lang/fr.ini");

		var myIni:IniAdapter = new IniAdapter(args);

		Assert.areEqual("Bonjour", myIni.translate("id01", "fr"));

		Assert.areEqual("le monde", myIni.translate(myIni.getMessageId("world","en"), "fr"));

		Assert.areEqual("Salut tout le monde!", myIni.translate(myIni.getMessageId("Hi there!","en"), "fr"));
	}
	
	@Test
	public function oneFileForApplicationTest():Void
	{
		var args:Hash<String> = new Hash();
		args.set(brix.component.internationalization.Translator.LOCATION_ATTR, "http://127.0.0.1/brix/test/unit/bin/lang/lang.ini");

		var myIni:IniAdapter = new IniAdapter(args);

		Assert.areEqual("Bonjour", myIni.translate("id01", "fr"));

		Assert.areEqual("le monde", myIni.translate(myIni.getMessageId("world","en"), "fr"));

		Assert.areEqual("Salut tout le monde!", myIni.translate(myIni.getMessageId("Hi there!","en"), "fr"));
	}
}