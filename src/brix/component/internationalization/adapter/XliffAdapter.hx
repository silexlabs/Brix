/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.internationalization.adapter;

import brix.component.internationalization.Adapter;

import haxe.xml.Parser;

import js.XMLHttpRequest;

/**
 * XliffAdapter component for the Translator component. Implement the Xliff 
 * format specific logic for Brix translations.
 * @see http://docs.oasis-open.org/xliff/xliff-core/xliff-core.html
 * 
 * TODO
 * - support bin-unit
 * - test if works with groups
 * 
 * @author Thomas Fétiveau
 */
class XliffAdapter extends Adapter
{
	/**
     * Load translation data (XLIFF file reader)
     *
     * @param  string  locale    Locale/Language to add data for, identical with locale identifier,
     *                            see Locale for more information
     * @param  string  filename  XLIFF file to add, full path must be given for access
     * @param  array   option    OPTIONAL Options to use
     * @return array
     */
    override private function loadTranslationData(filename:String, ?locale:String):Null<Hash<Hash<String>>>
	{
		try
		{
			var xmlHttp = new XMLHttpRequest();
			xmlHttp.open( "GET", filename, false );
			xmlHttp.send( null );
			if (xmlHttp.status != 200 || xmlHttp.readyState != 4)
			{
				trace("WARNING: Can't fetch Xliff file at "+filename);
				return null;
			}
			var data:Xml = Parser.parse(xmlHttp.responseText);
			var fileElement:Xml = data.firstChild().elementsNamed("file").next();

			var transData:Hash<Hash<String>> = new Hash();

			var sourceLocale:String = fileElement.get("source-language");
			var targetLocale:String = fileElement.get("target-language");

			transData.set(sourceLocale, new Hash());
			transData.set(targetLocale, new Hash());

			for (elt in { iterator:function() { return fileElement.elementsNamed("body").next().elementsNamed("trans-unit");} } )
			{
				for (eltChild in { iterator:elt.elements } )
				{
					if (eltChild.nodeName == "source")
					{
						transData.get(sourceLocale).set(elt.get("id"), eltChild.firstChild().nodeValue);
					}
					if (eltChild.nodeName == "target")
					{
						transData.get(targetLocale).set(elt.get("id"),eltChild.firstChild().nodeValue);
					}
				}
			}
			return transData;
		}
		catch (unknown:Dynamic)
		{
			trace("ERROR while trying to load translation data from "+filename+": "+Std.string(unknown));
			var excptArr = haxe.Stack.exceptionStack();
			if ( excptArr.length > 0 )
			{
				trace( haxe.Stack.toString(haxe.Stack.exceptionStack()) );
			}
		}
		return null;
	}
}