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

import brix.component.internationalization.adapter.XliffAdapter;

/**
 * @author Thomas Fétiveau
 */
class XliffAdapterTest 
{	
	public function new() 
	{
		
	}
	
	@Test
	public function basicTranslationTest():Void
	{
		var args:Hash<String> = new Hash();
		args.set(brix.component.internationalization.Translator.LOCATION_ATTR, "http://127.0.0.1/brix/test/unit/bin/lang/fr.xlf");

		var myXliff:XliffAdapter = new XliffAdapter(args);

		// normal case where the translation exists
		Assert.areEqual("Bonjour", myXliff.translate(myXliff.getMessageId("Hello","en"), "fr"));
		// test default locale
		Assert.areEqual("Au revoir", myXliff.translate(myXliff.getMessageId("Bye","en"), "fr"));
		// case where the translation doesn't exist
		Assert.areEqual("Bye bye", myXliff.translate(myXliff.getMessageId("Bye bye","en"), "fr"));
	}

}