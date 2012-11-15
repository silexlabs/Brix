/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.internationalization;

/**
 * Adapter logic common to all formats.
 * Extend this class if you want to add another translation file format.
 * 
 * TODO
 *  - manage plurals ?
 * 
 * @author Thomas Fétiveau
 */
class Adapter 
{
    /**
     * The translation data known by this adapter.
     */
    private var transTable:Hash<Hash<String>>;

	/**
	 * Builds a new Adapter according to variable given parameters.
	 * @param a Hash of String parameters. Main parameters are the lang data locations.
	 */
	public function new( args:Hash<String> ) 
	{
		transTable = new Hash();
		// load initial translation data
		var locations = args.get(Translator.LOCATION_ATTR).split(',');
		for (l in locations)
		{
			args.set(Translator.LOCATION_ATTR, l);
			addTranslationData( args );
		}
	}

	/**
     * Translates a message by id.
     *
     * @param	String	the message id to translate
     * @param	String 	the locale to translate to
	 * @param	Int		the number for plurals. FIXME NOT IMPLEMENTED YET !
     * @return	String 	the translation
     */
    public function translate(messageId:String, ?locale:String=null, ?number:Int=-1):String
	{
		if (locale == null)
		{
			locale = getDefaultAvailableLocale();
		}
		if (!transTable.exists(locale))
		{
			// FIXME manage locale inheritance
			return messageId;
		}
		if (!transTable.get(locale).exists(messageId))
		{
			for (l in {iterator:transTable.keys})
			{
				if (transTable.get(l).exists(messageId))
					return transTable.get(l).get(messageId);	// FIXME should take into account the Locale hierarchy
			}
			return messageId;
		}
		return transTable.get(locale).get(messageId);
	}

	/**
	 * Translates a message string from a locale to another locale.
	 * 
	 * @param	String	the message source to translate
	 * @param	String	optional, the current locale of the message string. If not set, will be set to default available one from user env.
	 * @param	String	optional, the locale to translate the message string to. If not set, will be set to the default available one from user env.
	 * @param	Int		optional, the number for plurals. FIXME not implemented yet!
	 */
	public function translateSource(messageSource:String, ?fromLocale:String=null, ?toLocale:String=null, ?number:Int=-1)
	{
		if (fromLocale == null && toLocale == null)
		{
			return messageSource;
		}
		if (toLocale == null)
		{
			toLocale = getDefaultAvailableLocale();
		}
		var messageId:String = getMessageId(messageSource, fromLocale);
		if (messageId != null)
		{
			return translate(messageId, toLocale, number);
		}
		return messageSource;
	}

    /**
     * Returns the message id for a given translation
     * If no locale is given, the default available language will be used
     *
     * @param  String	the String to search the corresponding id
     * @param  String	(optional) Language to return the message ids from
     * @return String or null if not found
     */
    public function getMessageId(message:String, ?locale:String = null):Null<String>
    {
        if (locale == null)
		{
            locale = getDefaultAvailableLocale();
        }
		if (!transTable.exists(locale))
		{
			return null;
		}
        for (k in {iterator:transTable.get(locale).keys})
		{
			if (transTable.get(locale).get(k) == message)
			{
				return k;
			}
		}
		return null;
    }

	/**
	 * Checks if a string is translated within the source or not.
     *
     * @param  String	the message id
     * @param  Bool     optional) Allow translation only for original language
     *                  when true, a translation for 'en_US' would give false when it can
     *                  be translated with 'en' only
     * @param  String   (optional) Locale/Language to use, identical with locale identifier,
     * @return Bool
	 */
	//public function isTranslated(messageId, original = false, locale = null)
	//{
		//
	//}
	
	/**
	 * Tells if the desired language is available.
	 * 
	 * @param String	the locale
	 * @return Bool
	 */
	public function isAvailable(locale:String):Bool
	{
		return transTable.exists(locale);
	}
	
	/**
	 * Gets the default available locale from translation data and user env.
	 * 
	 * @return String	the locale
	 */
	public function getDefaultAvailableLocale():String
	{
		return transTable.keys().next(); // FIXME decide default language from user env
	}

	/**
	 * Add translation data from another location.
	 * 
	 * @param a Hash<String> of arguments (file location, ...)
	 * 
	 * TODO add options to erase or complete current data
	 */
	public function addTranslationData( args:Hash<String> ):Void
	{
		var newData = loadTranslationData( args.get(Translator.LOCATION_ATTR) );

		for (l in {iterator:newData.keys})
		{
			if (!transTable.exists(l))
			{
				transTable.set(l, new Hash());
			}
			for (id in { iterator:function(){return newData.get(l).keys();} } )
			{
				if (transTable.get(l).exists(id))
					trace("WARNING: message id "+id+" for locale "+l+" overriden by "+args.get(Translator.LOCATION_ATTR));
				transTable.get(l).set(id, newData.get(l).get(id));
			}
		}
	}
	
	/**
	 * Abstract method to implement in specialized adapters.
	 * Loads the translation data from the given filename (in the expected format).
	 * 
	 * @param	filename the file to load the data from.
	 * @param	locale (optional) specify the locale if you want to load data only for a specific local.
	 * @return	Hash<Hash<String>>	the translation data.
	 */
	private function loadTranslationData(filename:String, ?locale:String = null):Null<Hash<Hash<String>>> { return null; }
}