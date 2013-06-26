/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.scripting;

import brix.component.ui.DisplayObject;

import hscript.Interp;
import hscript.Parser;

import js.html.HtmlElement;


/**
 * The ScriptContainer allows you to add hscript in <script> HTML elements before or at runtime.
 * 
 * It exposes by default js.Lib and the brix application global components. Note that they are 
 * exposed as a variable named like this:
 * 
 * 	- js.Lib is available in your <script> tag through js_Lib
 * 
 * 	- any other global component (for example brix.component.internationalization.Translator) is
 * available in the same way, ie: by full classname with '.' replaced by '_' (for example 
 * brix_component_internationalization_Translator)
 * 
 * 
 * TODO
 *  - include automatically a ScriptContainer component as soon as a <script> tag has type="text/hscript"
 *  - add -lib hscript in compile line as soon as ScriptContainer is used
 * 
 * @author Thomas Fétiveau
 */
@tagNameFilter("script")
class ScriptContainer extends DisplayObject
{
	/**
	 * The hscript parser
	 */
	private var parser:Parser;
	/**
	 * The hscript interpreter
	 */
	private var interp:Interp;

	/**
	 * Builds the ScriptContainer component.
	 */
	public function new(rootElement:HtmlElement, brixId:String) 
	{
		super(rootElement, brixId);

		parser = new Parser();
		interp = new Interp();
	}

	/**
	 * 
	 * Gives the Interpreter references to the global components.
	 */
	override public function init()
	{
		super.init();

		// inject the js.Lib
		interp.variables.set("js_Lib", Lib);
		// inject the DisplayObject object
		interp.variables.set("this", this);
		// inject the global components
		for (cn in getBrixApplication().getGlobalComponentList())
		{
			interp.variables.set(StringTools.replace(cn,".","_"),getBrixApplication().getGlobalComponent(cn));
		}

		// try to interprete the inner script content (separate function)
		try
		{
			interprete();
		}
		catch (unknown:Dynamic)
		{
			trace("ERROR while interpreting script: "+Std.string(unknown));
		}
	}

	/**
	 * Interpretes the script content.
	 * @return Dynamic	
	 */
	public function interprete():Dynamic
	{
		var program = parser.parseString(rootElement.innerHTML);
		return interp.execute(program);
	}
}