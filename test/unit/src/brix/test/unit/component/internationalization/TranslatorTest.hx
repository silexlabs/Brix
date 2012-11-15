/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.test.unit.component.internationalization;

import js.Lib;
import js.Dom;

import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import brix.component.internationalization.Translator;

/**
 * @author Thomas Fétiveau
 */
class TranslatorTest 
{
	public function new() 
	{
		
	}

	@Test
	public function testTranslate():Void
	{
		// generate a test node
		var divElt:HtmlDom = Lib.document.createElement("div");
		divElt.innerHTML = "<h1>Hello</h1>" +
							"<span>Hello world!</span>" + 
							//"<img src='http://127.0.0.1/brix/test/unit/bin/img/en.gif' alt='UK flag'>" + 
							"<span>Bye</span>" + 
							"Bye bye";
		divElt.lang = "en";

		// create Translator instance
		var transArgs:Hash<String> = new Hash();
		transArgs.set(Translator.LOCATION_ATTR, "http://127.0.0.1/brix/test/unit/bin/lang/fr.xlf");
		transArgs.set(Translator.FORMAT_ATTR, "Xliff");
		var translator = new Translator(transArgs);

		// translate node
		translator.translate(divElt, "fr");

		// assertion
		var expectedInnerHTML:String = "<h1>Bonjour</h1>" +
								"<span>Bonjour le monde !</span>" + 
								//"<img src='http://127.0.0.1/brix/test/unit/bin/img/en.gif' alt='UK flag'>" + 
								"<span>Au revoir</span>" + 
								"Bye bye";
		var actualInnerHTML:String = divElt.innerHTML;

		Assert.areEqual(expectedInnerHTML, actualInnerHTML);
	}
}