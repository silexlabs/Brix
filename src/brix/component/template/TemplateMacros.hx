/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.template;

/**
 * This class is made to be exposed to the components templates
 * For example when the List component populate itself with data, it duplicates the template found in the HTML DOM. 
 * In this template, one can call "macros" as explained here http://haxe.org/doc/cross/template
 * This is because the List component executes its template with template.execute(item, TemplateMacros);
 * @example 	template.execute(item, TemplateMacros);
 * @example		in the macro you can write $$makeDateReadable(::item.date::)
 */
class TemplateMacros
{
	//public function new(){}
	/**
	 * make dates readable
	 * @param 	date can be a Date or String
	 */
	public static function makeDateReadable(resolve:String->Dynamic, dateOrString:Dynamic, format:String="%Y/%m/%d %H:%M"):String
	{
		var date:Date;
		if (Std.is(dateOrString, String)){
			date = Date.fromString(cast(dateOrString));
			trace("makeDateReadable string "+dateOrString);
		}
		else if (Std.is(dateOrString, Date)){
			trace("makeDateReadable date ");
			date = cast(dateOrString);
		}
		else{
			date = null;
			throw("Error, the parameter is supposed to be String or Date");
		}

		var res:String = DateTools.format(date, format);
		trace("makeDateReadable returns "+res);
		return res;
	}
	/**
	 * trace for the templates
	 */
	public static function trace(resolve:String->Dynamic, obj):String
	{
		trace(obj);
		return "";
	}
}