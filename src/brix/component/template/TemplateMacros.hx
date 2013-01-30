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
	 * @param 	date can be a Date or String or timestamp
	 */
	public static function durationFromTimestamp(resolve:String->Dynamic, timestamp:Float, numMax:Int=999, 
		yearsText:String="years", monthsText:String="months", weeksText:String="weeks", daysText:String="days", 
		hoursText:String="hours", minutesText:String="minutes", secondsText:String="seconds"):String
	{//trace("durationFromTimestamp "+(Date.now().getTime())+"-"+(timestamp*1000)+" - "+(Date.now().getTime()-(timestamp*1000)));
		var date:Date;
		date = Date.fromTime(Date.now().getTime()-(timestamp*1000));
		var zero = Date.fromTime(0);

		var num = 0;
		var res:String = "";
		var d = date.getFullYear()-zero.getFullYear();
		if (d > 0)
		{
			res += d + " " + yearsText + " ";
			if (++num>=numMax)
				return res;
		}
		var d = date.getMonth()-zero.getMonth();
		if (d > 0)
		{
			res += d + " " + monthsText + " ";
			if (++num>=numMax)
				return res;
		}
		var d = date.getDay()-zero.getDay();
		var week = d/7;
		if (week > 1)
			res += Math.round(week) + " " + weeksText + " ";
		else if (d > 0)
		{
			res += d + " " + daysText + " ";
			if (++num>=numMax)
				return res;
		}
		var d = date.getHours()-zero.getHours();
		if (d > 0)
		{
			res += d + " " + hoursText + " ";
			if (++num>=numMax)
				return res;
		}
		var d = date.getMinutes()-zero.getMinutes();
		if (d > 0)
		{
			res += d + " " + minutesText + " ";
			if (++num>=numMax)
				return res;
		}
		var d = date.getSeconds()-zero.getSeconds();
		if (d > 0)
		{
			res += d + " " + secondsText + " ";
			if (++num>=numMax)
				return res;
		}
		

		trace("returns "+res);
		return res;
	}
	/**
	 * make dates readable
	 * @param 	date can be a Date or String or timestamp
	 */
	public static function makeDateReadableFromTimestamp(resolve:String->Dynamic, timestamp:Float, format:String="%Y/%m/%d %H:%M"):String
	{//trace("makeDateReadable "+Type.typeof(dateOrString)+" - "+format);

		var date:Date;
		date = Date.fromTime(timestamp);

		var res:String = DateTools.format(date, format);
		trace("makeDateReadable returns "+res);
		return res;
	}
	public static function makeDateReadable(resolve:String->Dynamic, dateOrString:Dynamic, format:String="%Y/%m/%d %H:%M"):String
	{//trace("makeDateReadable "+Type.typeof(dateOrString)+" - "+format);

		var date:Date;
		if (Std.is(dateOrString, String)){
			trace("makeDateReadable string ");
			date = Date.fromString(cast(dateOrString));
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