/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.internationalization;

import brix.component.IBrixComponent;
import brix.core.Application;
import brix.util.DomTools;

import js.html.HtmlElement;

// FIXME for the moment, import manually all Adapters
// but as soon as it will be possible to resolve classes at 
// macro time, we shall import only the adapter we need...
import brix.component.internationalization.adapter.XliffAdapter;
import brix.component.internationalization.adapter.IniAdapter;

/**
 * The Translator component is a global component that can translate your application content in 
 * as many languages as translation data you'll give him.
 * 
 * The default behavior of the Translator is based on the standard lang attribute of HTML elements.
 * If you use this attribute on an HTML element, it must reflect the actual language it contains. For 
 * 
 * Example:
 * 
 * 	<html lang="en">
 * 		<head>
 * 			<title>Title in English</title>
 * 			<script data-brix-use="brix.component.internationalization.Translator" data-location="lang/fr.xlf" data-format="xliff"></script>
 * 		</head>
 *		<body>
 * 			<div lang="la">
 * 				<!-- Contents here, eg TextNodes, must be in the latin language -->
 * 			</div>
 * 			<div>
 * 				<!-- Contents here, eg TextNodes, must be in the english language -->
 * 			</div>
 * 		</body>
 * 	</html>
 * 
 * In this example, the Translator knows only the english and french languages (contained in fr.xlf).
 * If the Translator.translate( *<html> node* , "fr" ) method is called, it will translate only the 
 * english contents it knows to the french contents it knows. The node with lang="la" will remain 
 * unchanged as the translator hasn't been given the latin translation data. Also, once translated to
 * french, the lang attributes that were set to "en" will be set to "fr".
 * 
 * This behavior allows you to work on your HTML source file directly with the message strings of a 
 * specific language.
 * 
 * But you can also optionally work on your HTML source file with message ids if you specify the option 
 * data-use-message-ids. In that case, on application startup, the Translator will translate the application 
 * to the default language (either the one specified by the lang attribute, or if not present, the default
 * one from user environment). Then, the runtime behavior after application startup is the same as previously.
 * This option is just a ease of use for those who prefer to work on application sources with message ids.
 * 
 * SETUP STEPS
 * 
 * Simply declare the component in your source HTML headers and specify the data-location (where are 
 * your translation data) and data-format (what is their format) attributes.
 * 
 * The data-location attribute must specify the path (or URL) to the language files (not folder).
 * If several files are used, separate them by commas.
 * 
 * The data-format attribute specify in which format are these files (currently supported format are Xliff and Ini).
 * Set it to "Ini" or "Xliff" (case insensitive).
 * 
 * If you want your HTML source file to contain message ids instead of message strings, set the data-use-message-ids 
 * attribute to "true". Else, do not specify it.
 * 
 * If you work on your sources with message strings, specify the lang attribute on your HTML elements to the 
 * corresponding language it contains. ie: if you use english message strings and that you have given a 
 * translation data file for the "en" locale, set lang="en" on the <html> root node. All child nodes will inherit 
 * then of this value but can also override it by specifying again this attribute to another value.
 * 
 * To call the translator at runtime, you then need another component or script to call it (see the 
 * /cmp/internationalization/translator/ use case for that).
 * 
 *  
 * 
 * Note: The Translator component current version is a draft. It may evolve a lot in a near future. It should
 * however cover most of your basic translation needs for your application. Thank you to report any bug 
 * in the Brix GitHub bug issue tracker and any RFE or suggestion in the Brix forum on silexlabs.org
 * 
 * 
 * 
 * TODO
 * - based on the lang attribute http://www.whatwg.org/specs/web-apps/current-work/multipage/elements.html#the-lang-and-xml:lang-attributes
 * 								 http://www.w3.org/TR/html5/global-attributes.html#attr-lang
 * 								 http://www.w3.org/TR/1999/REC-html401-19991224/struct/dirlang.html#adef-lang
 * - fr-FR => fr_FR (support locales as soon as a Locale class will be available in Brix)
 * - support several adapters at a time ?
 * - support several formats ?
 * - auto detect the data format ?
 * - add a google translation adapter ?
 * 
 * @author Thomas Fétiveau
 */
class Translator implements IBrixComponent
{
	/**
	 * The location attribute. You can specify here one file or several 
	 * files separated by commas.
	 */
	public static inline var LOCATION_ATTR:String = "data-location";
	/**
	 * The format attribute. You can use only one format at a time.
	 */
	public static inline var FORMAT_ATTR:String = "data-format";
	/**
	 * The use_message_ids attribute. Set it to "true" (or "yes" or "on") if you want 
	 * to write your HTML source the message ids (that will be then translated in desired 
	 * languages). In that case, you shall not specify any lang attribute on nodes containing 
	 * message ids instead of messages.
	 */
	public static inline var USE_MESSAGE_IDS_ATTR:String = "data-use-message-ids";

	/**
	 * The adapter used by the Translator.
	 */
	private var adapter:Adapter; // FIXME should be able to use several adapters ?

	/**
	 * Builds the Translator with arguments passed to data-brix-use declaration.
	 */
	public function new(args:Hash<String>) 
	{
		// build the adapter
		if (args.exists(LOCATION_ATTR) && args.exists(FORMAT_ATTR))
		{
			// extract format from args
			var format:String = args.get(FORMAT_ATTR).charAt(0).toUpperCase();
			for (i in 1...args.get(FORMAT_ATTR).length)
			{
				format += args.get(FORMAT_ATTR).charAt(i).toLowerCase();
			}
			args.remove(FORMAT_ATTR);
			// use ids?
			var use_ids = args.get(USE_MESSAGE_IDS_ATTR);
			args.remove(USE_MESSAGE_IDS_ATTR);
			// create corresponding adapter instance
			try
			{
				adapter = Type.createInstance(Type.resolveClass("brix.component.internationalization.adapter." + format + "Adapter"), [ args ]);
			}
			catch(unknown:Dynamic)
			{
				trace("ERROR while creating brix.component.internationalization.adapter."+format+"Adapter: "+Std.string(unknown));
				var excptArr = haxe.Stack.exceptionStack();
				if ( excptArr.length > 0 )
				{
					trace( haxe.Stack.toString(haxe.Stack.exceptionStack()) );
				}
			}
			if (use_ids != null)
			{
				use_ids = use_ids.toLowerCase();
				if (use_ids == "true" || use_ids == "yes" || use_ids == "on")
					translate(getBrixApplication().htmlRootElement, null, null, true);
			}
		}
		else
		{
			trace("WARNING: Translator cannot initialize without "+LOCATION_ATTR+" and "+FORMAT_ATTR+" values.");
		}
	}

	/**
	 * Translate a DOM node and its children to a given locale.
	 * @param	node			the DOM node to translate
	 * @param	toLocale		specify the locale to translate to
	 * @param	parentLocale	(optional) the locale of the parent node if known
	 */
	public function translate(node:HtmlElement, ?toLocale:String=null, ?parentLocale:String=null, ?useIds:Bool=false):Void
	{
		if (toLocale == null)
		{
			toLocale = adapter.getDefaultAvailableLocale();
		}
		// Get the current node's locale
		var currentLocale:String = ((DomTools.isUndefined(node.lang)||node.lang=="") && parentLocale!=null) ? parentLocale : getNodeLang(node);

		switch (node.nodeType)
		{
			case NodeTypes.ELEMENT_NODE:
				// TODO translate some attributes (img source, img alt, ...)
				for (i in 0...node.childNodes.length)
				{
					translate(node.childNodes[i], toLocale, currentLocale);
				}
				if (node.lang!="" && adapter.isAvailable(node.lang))
				{
					// then it should be possible to be considered as translated
					node.lang = toLocale;
				}

			case NodeTypes.TEXT_NODE:
				//translate the nodeValue
				node.nodeValue = adapter.translateSource(node.nodeValue, currentLocale, toLocale);

			default:
				// do nothing
		}
	}

	/**
	 * TODO
	 * To determine the language of a node, user agents must look at the nearest ancestor element (including the element itself if the node is an element) 
	 * that has a lang attribute in the XML namespace set or is an HTML element and has a lang in no namespace attribute set. That attribute specifies the 
	 * language of the node (regardless of its value).
	 * If both the lang attribute in no namespace and the lang attribute in the XML namespace are set on an element, user agents must use the lang attribute 
	 * in the XML namespace, and the lang attribute in no namespace must be ignored for the purposes of determining the element's language.
	 * If neither the node nor any of the node's ancestors, including the root element, have either attribute set, but there is a pragma-set default language 
	 * set, then that is the language of the node. If there is no pragma-set default language set, then language information from a higher-level protocol 
	 * (such as HTTP), if any, must be used as the final fallback language instead. In the absence of any such language information, and in cases where the 
	 * higher-level protocol reports multiple languages, the language of the node is unknown, and the corresponding language tag is the empty string.
	 * If the resulting value is not a recognized language tag, then it must be treated as an unknown language having the given language tag, distinct from 
	 * all other languages. For the purposes of round-tripping or communicating with other services that expect language tags, user agents should pass unknown 
	 * language tags through unmodified.
	 * Thus, for instance, an element with lang="xyzzy" would be matched by the selector :lang(xyzzy) (e.g. in CSS), but it would not be matched by :lang(abcde), 
	 * even though both are equally invalid. Similarly, if a Web browser and screen reader working in unison communicated about the language of the element, the 
	 * browser would tell the screen reader that the language was "xyzzy", even if it knew it was invalid, just in case the screen reader actually supported a 
	 * language with that tag after all.
	 * If the resulting value is the empty string, then it must be interpreted as meaning that the language of the node is explicitly unknown.
	 * User agents may use the element's language to determine proper processing or rendering (e.g. in the selection of appropriate fonts or pronunciations, 
	 * for dictionary selection, or for the user interfaces of form controls such as date pickers).
	 * The lang IDL attribute must reflect the lang content attribute in no namespace.
	 * @param	node
	 * @return
	 */
	public function getNodeLang(node:HtmlElement):String
	{
		if (!DomTools.isUndefined(node.lang) && node.lang != "")
		{
			return node.lang;
		}
		return getNodeLang(node.parentNode);
	}

	/**
	 * The id of the containing Brix Application instance.
	 */
	public var brixInstanceId : String;
	/**
	 * Returns the associated running Application instance.
	 * 
	 * @return	an Application object.
	 */
	public function getBrixApplication() : Application
	{
		return BrixComponent.getBrixApplication(this);
	}
}