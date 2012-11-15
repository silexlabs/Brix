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
import brix.util.data.Ini;

import js.XMLHttpRequest;

/**
 * Translator Adapter for the INI file format.
 * 
 * You have two possibilities to use this adapter. The first is to have all your language data in the same file
 * where the section [] specify the locale, the keys specify the message id and the value the message in the 
 * corresponding language.
 * 
 * For example: file lang.ini
 * <code>
 * [en]
 * id01=Hello
 * id02=world
 * id03="Hi there!"
 * 
 * [fr]
 * id01=Bonjour
 * id02="le monde"
 * id03="Salut tout le monde!"
 * </code>
 * 
 * Or you can also have one file per language (it's actually the recommended way) with the file name corresponding to 
 * the locale (en.ini, en_US.ini...)
 * 
 * For example: file en.ini
 * <code>
 * id01=Hello
 * id02=world
 * id03="Hi there!"
 * </code>
 * 
 * And file fr.ini
 * <code>
 * id01=Bonjour
 * id02="le monde"
 * id04="Salut tout le monde!"
 * </code>
 * 
 * @author Thomas Fétiveau
 */
class IniAdapter extends Adapter
{
	/**
     * Load translation data (Ini file reader)
	 * @param the ini file path
	 * @param the locale, optional
     */
    override private function loadTranslationData(filename:String, ?locale:String=null):Null<Hash<Hash<String>>>
	{
		try
		{
			var xmlHttp = new XMLHttpRequest();
			xmlHttp.open( "GET", filename, false );
			xmlHttp.send( null );
			if (xmlHttp.status != 200 || xmlHttp.readyState != 4)
			{
				trace("WARNING: Can't fetch Ini file at "+filename);
				return null;
			}
			var data:Ini = Ini.parse(xmlHttp.responseText);

			var transData:Hash<Hash<String>> = new Hash();

			for (s in { iterator:data.sections })
			{
				var section = s;
				if (s == "")
				{
					if (locale!=null)
						section = locale;
					else
					{
						// take filename as locale for the root section when no locale specified
						section = filename.substr(filename.lastIndexOf('/') + 1);
						section = section.substr(0, (section.lastIndexOf('.')>-1)?section.lastIndexOf('.'):0);
					}
				}
				transData.set(section, new Hash());
				for (k in { iterator:function(){return data.keys(s);} } )
				{
					transData.get(section).set(k, data.get(k, s));
				}
			}
			return transData;
		}
		catch (unknown:Dynamic)
		{
			trace("ERROR while trying to load translation data from "+filename+": "+Std.string(unknown));
		}
		return null;
	}
	
}