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
		hoursText:String="hours", minutesText:String="minutes", secondsText:String="seconds", ?unit="ms"):String
	{//trace("durationFromTimestamp "+(Date.now().getTime())+"-"+(timestamp*1000)+" - "+(Date.now().getTime()-(timestamp*1000)));
		if (StringTools.trim(unit) == "s")
		{
			timestamp *= 1000;
		}
		var elapsed:Float = Date.now().getTime()-timestamp;

		var num = 0;
		var res:String = "";
		var d = Math.floor(elapsed/31536000000);
		if (d > 0)
		{
			elapsed -= d*31536000000;
			res += d + " " + yearsText + " ";
			if (++num>=numMax)
				return res;
		}
		var d = Math.floor(elapsed/2592000000);
		if (d > 0)
		{
			elapsed -= d*2592000000;
			res += d + " " + monthsText + " ";
			if (++num>=numMax)
				return res;
		}
		var d = Math.floor(elapsed/86400000);
		elapsed -= d*86400000;
		
		var week = d/7;
		if (week > 1)
			res += Math.floor(week) + " " + weeksText + " ";
		else if (d > 0)
		{
			res += d + " " + daysText + " ";
			if (++num>=numMax)
				return res;
		}
		var d = Math.floor(elapsed/3600000);
		if (d > 0)
		{
			elapsed -= d*3600000;
			res += d + " " + hoursText + " ";
			if (++num>=numMax)
				return res;
		}
		var d = Math.floor(elapsed/60000);
		if (d > 0)
		{
			elapsed -= d*60000;
			res += d + " " + minutesText + " ";
			if (++num>=numMax)
				return res;
		}
		var d = Math.floor(elapsed/1000);
		if (d > 0)
		{
			elapsed -= d*1000;
			res += d + " " + secondsText + " ";
			if (++num>=numMax)
				return res;
		}
		
		return res;
	}
	/**
	 * make dates readable
	 * @param 	timestamp in milliseconds or seconds
	 * @param 	unit can be "s" or "ms"
	 */
	public static function makeDateReadableFromTimestamp(resolve:String->Dynamic, timestamp:Float, format:String="%Y/%m/%d %H:%M", ?unit:String="ms"):String
	{
		if (StringTools.trim(unit) == "s")
		{
			timestamp *= 1000;
		}

		var date:Date;
		date = Date.fromTime(timestamp);

		var res:String = DateTools.format(date, format);
		return res;
	}
	public static function makeDateReadable(resolve:String->Dynamic, dateOrString:Dynamic, format:String="%Y/%m/%d %H:%M"):String
	{//trace("makeDateReadable "+Type.typeof(dateOrString)+" - "+format);
		try
		{
			var date:Date;
			if (Std.is(dateOrString, String)){
				date = Date.fromString(cast(dateOrString));
			}
			else if (Std.is(dateOrString, Date)){
				date = cast(dateOrString);
			}
			else{
				date = null;
				throw("Error, the parameter is supposed to be String or Date");
			}

			var res:String = DateTools.format(date, format);
			return res;
		}
		catch(e:Dynamic)
		{
			trace("Error, could not convert "+dateOrString+" to Date");
		}
		return dateOrString;
	}
	/**
	 * url encode/decode
	 */
	public static function urlEncode(resolve:String->Dynamic, str:String):String
	{
		return StringTools.urlEncode(str);
	}
	/**
	 * url encode/decode
	 */
	public static function urlDecode(resolve:String->Dynamic, str:String):String
	{
		return StringTools.urlDecode(str);
	}
	/**
	 * Escape/unsecape HTML special characters of the string.
	 */
	public static function htmlEscape(resolve:String->Dynamic, str:String):String
	{
		return StringTools.htmlEscape(str);
	}
	/**
	 * Escape/unsecape HTML special characters of the string.
	 */
	public static function htmlUnescape(resolve:String->Dynamic, str:String):String
	{
		return StringTools.htmlUnescape(str);
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