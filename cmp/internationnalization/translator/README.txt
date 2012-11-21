/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */

Component: brix.component.internationalization.Translator
Version: V0.1_alpha

The Translator component translates the HTML DOM content recursively, basing its translations on several parameters.
The main parameter is the HTMLElement's lang attribute. This is the standard attribute you should use to specify the 
current language of an HTML document or element.

When the Translator component is asked to translate an HTMLElement's content, it will first looked at its current lang 
value (can be inherited from parent nodes or user environment). If the translator knows this language (from the translation
data it has been given), if will then check if it knows the language it is asked to translate to. If both languages are known,
all known string in both languages will be converted from current language to desired language.

Note that the Translator component tries to translate all TextNodes and few other things like:
	- img src attributes
	- img alt attributes
	=> This list is about to extend when we'll find other HTML element attributes that could be candidates for translations. Do 
	not hesitate to suggest some on the Brix forum on silexlabs.org.

The current version supports two format of translation data: Xliff and Ini.

Please note that the current version of the Translator is a draft and is about to evolve quite a lot in the future. If you have any 
suggestion to make it better, do not hesitate to make suggestions (on the 
<a href="http://www.silexlabs.org/groups/labs/slplayer-project/slplayer/">the Brix forum</a> or event to contribute on 
<a href="https://github.com/silexlabs/Brix">GitHub</a>).

HOW TO

 - run the use case?
 
	Simple compile (haxe build_js.hxml) it, open /bin/index.html in a browser and click on the French or English 
 flags at the bottom of the page to translate the page contents alternatively to French or English language.

 
 - add translation data?

	This use case uses the Xliff format for the translation data (see /bin/lang/fr.xlf). Let's say you would like this 
use case application to support the german langage as well. What you would have to do is to copy the current fr.xlf and 
rename it de.xlf. Then, open it in a Xliff Translation tool to translate one by one each message string. Xliff being a 
open format, there are plenty of translation tool that support this format:

	-> <a href="http://open-language-tools.java.net/editor/about-xliff-editor.html">Open Language Tools XLIFF Translation Editor</a>
	-> <a href="http://felix-cat.com/tools/xliff-translator/">XLIFF Translator</a>
	-> and many other...

	Actually, you can also translate it directly in a text file editor, xliff being an XML format.

	Then, you need to add your de.xlf to your Brix application. To do so, edit your HTML source and add it to the data-location of your
Translator component, ie:
<code>
	<script data-brix-use="brix.component.internationalization.Translator" data-location="lang/fr.xlf,lang/de.xlf" data-format="xliff"></script>
</code>
	Also, you need to update the source so that a german flag will propose the german language to users. To make it simple, you shall replace this :
<code>
	<img id="flag" height="20px" src="images/fr.gif" alt="Version Française"/>
</code>
	by three flags (the English, the French and the German one), so it would look like:
<code>
	<img id="en" height="20px" src="images/en.gif" alt="English version"/><img id="fr" height="20px" src="images/fr.gif" alt="Version Française"/><img id="de" height="20px" src="images/de.gif" alt="Deutsch Version"/>
</code>
	But now, the flags need to call the Translator component on click. To do so, edit the <script> tag in the source HTML by replacing its content with:
<code>
	<script class="ScriptContainer" type="text/hscript">
		function translateOnClick(lang)
		{
			var flagImg = js_Lib.document.getElementById(lang);
			flagImg.onclick = function(e) {
				brix_component_internationalization_Translator.translate(js_Lib.document.documentElement, lang);
			};
		}
		translateOnClick("en");
		translateOnClick("fr");
		translateOnClick("de");
	</script>
</code>
	Once done, recompile the application and it should now support the german language.


