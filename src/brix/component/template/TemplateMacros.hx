/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.template;


import js.html.HtmlElement;

/**
 * This class is made to be exposed to the components templates
 * For example when the List component populate itself with data, it duplicates the template found in the HTML DOM. 
 * In this template, one can call "macros" as explained here http://haxe.org/doc/cross/template
 * This is because the List component executes its template with template.execute(item, TemplateMacros);
 * @example 	template.execute(item, TemplateMacros);
 * @example		in the macro you can write $$makeDateReadable(::item.date::)
 */
class TemplateMacros implements Dynamic
{
	public function new(){}
	/**
	 * make dates readable
	 * @param 	date can be a Date or String or timestamp
	 */
	public function makeDurationReadable(resolve:String->Dynamic, duration:Float, numMax:Int=999, 
		yearsText:String="year", monthsText:String="month", weeksText:String="week", daysText:String="day", 
		hoursText:String="hour", minutesText:String="minute", secondsText:String="second", 
		yearsTextPlural:String="years", monthsTextPlural:String="months", weeksTextPlural:String="weeks", daysTextPlural:String="days", 
		hoursTextPlural:String="hours", minutesTextPlural:String="minutes", secondsTextPlural:String="seconds", 
		?unit="ms", ?prefix:String="", ?suffix:String="", ?defaultValue:String="Very old."):String
	{//trace("makeDurationReadable "+duration);
		if (StringTools.trim(unit) == "s")
		{
			duration *= 1000;
		}
		var num = 0;
		var res:String = "";
		var d = Math.floor(duration/31536000000);
		if (d > 0)
		{
			duration -= d*31536000000;
			if (yearsText != null && yearsText != "")
			{
				if (d>1 && yearsTextPlural != null && yearsTextPlural != "")
					res += d + yearsTextPlural + " ";
				else
				res += d + yearsText + " ";
				if (++num>=numMax)
					return prefix+res+suffix;
			}
			else
			{
				return defaultValue;
			}
		}
		var d = Math.floor(duration/2592000000);
		if (d > 0)
		{
			duration -= d*2592000000;
			if (monthsText != null && monthsText != "")
			{
				if (d>1 && monthsTextPlural != null && monthsTextPlural != "")
					res += d + monthsTextPlural + " ";
				else
				res += d + monthsText + " ";
				if (++num>=numMax)
					return prefix+res+suffix;
			}
			else
			{
				return defaultValue;
			}
		}
		var d = Math.floor(duration/86400000);
		duration -= d*86400000;
		
		var week = d/7;
		if (week > 1 && weeksText != null && weeksText != "")
		{
			res += Math.floor(week) + weeksText + " ";
			if (++num>=numMax)
				return prefix+res+suffix;
		}
		else if (d > 0)
		{
			if (daysText != null && daysText != "")
			{
				if (d>1 && daysTextPlural != null && daysTextPlural != "")
					res += d + daysTextPlural + " ";
				else
				res += d + daysText + " ";
				if (++num>=numMax)
					return prefix+res+suffix;
			}
			else
			{
				return defaultValue;
			}
		}
		var d = Math.floor(duration/3600000);
		if (d > 0)
		{
			duration -= d*3600000;
			if (hoursText != null && hoursText != "")
			{
				if (d>1 && hoursTextPlural != null && hoursTextPlural != "")
					res += d + hoursTextPlural + " ";
				else
				res += d + hoursText + " ";
				if (++num>=numMax)
					return prefix+res+suffix;
			}
			else
			{
				return defaultValue;
			}
		}
		var d = Math.floor(duration/60000);
		if (d > 0)
		{
			duration -= d*60000;
			if (minutesText != null && minutesText != "")
			{
				if (d>1 && minutesTextPlural != null && minutesTextPlural != "")
					res += d + minutesTextPlural + " ";
				else
				res += d + minutesText + " ";
				if (++num>=numMax)
					return prefix+res+suffix;
			}
			else
			{
				return defaultValue;
			}
		}
		var d = Math.floor(duration/1000);
		if (d > 0)
		{
			duration -= d*1000;
			if (secondsText != null && secondsText != "")
			{
				if (d>1 && secondsTextPlural != null && secondsTextPlural != "")
					res += d + secondsTextPlural + " ";
				else
				res += d + secondsText + " ";
				if (++num>=numMax)
					return prefix+res+suffix;
			}
			else
			{
				return defaultValue;
			}
		}
		//trace("makeDurationReadable returns "+prefix+res+suffix);
		return prefix+res+suffix;
	}
	/**
	 * make dates readable
	 * @param 	date can be a Date or String or timestamp
	 */
	public function durationFromTimestamp(resolve:String->Dynamic, timestamp:Float, numMax:Int=999, 
		yearsText:String="year", monthsText:String="month", weeksText:String="week", daysText:String="day", 
		hoursText:String="hour", minutesText:String="minute", secondsText:String="second", 
		yearsTextPlural:String="years", monthsTextPlural:String="months", weeksTextPlural:String="weeks", daysTextPlural:String="days", 
		hoursTextPlural:String="hours", minutesTextPlural:String="minutes", secondsTextPlural:String="seconds", 
		?unit="ms", ?prefix:String="", ?suffix:String=""):String
	{//trace("durationFromTimestamp "+(Date.now().getTime())+"-"+(timestamp*1000)+" - "+(Date.now().getTime()-(timestamp*1000)));
		var initialTimestamp = timestamp;
		if (StringTools.trim(unit) == "s")
		{
			timestamp *= 1000;
		}
		var elapsed:Float = Date.now().getTime()-timestamp;
		return makeDurationReadable(resolve, elapsed, numMax, 
			yearsText, monthsText, weeksText, daysText, 
			hoursText, minutesText, secondsText, 
			yearsTextPlural, monthsTextPlural, weeksTextPlural, daysTextPlural, 
			hoursTextPlural, minutesTextPlural, secondsTextPlural, 
			"ms", prefix, suffix, 
			makeDateReadableFromTimestamp(resolve, initialTimestamp, null, unit));
	}
	/**
	 * make dates readable
	 * @param 	timestamp in milliseconds or seconds
	 * @param 	unit can be "s" or "ms"
	 */
	public function makeDateReadableFromTimestamp(resolve:String->Dynamic, timestamp:Float, format:String="%Y/%m/%d %H:%M", ?unit:String="ms"):String
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
	public function makeDateReadable(resolve:String->Dynamic, dateOrString:Dynamic, format:String="%Y/%m/%d %H:%M"):String
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
	public function urlEncode(resolve:String->Dynamic, str:String):String
	{
		return StringTools.urlEncode(str);
	}
	/**
	 * url encode/decode
	 */
	public function urlDecode(resolve:String->Dynamic, str:String):String
	{
		return StringTools.urlDecode(str);
	}
	/**
	 * Escape/unsecape HTML special characters of the string.
	 */
	public function htmlEscape(resolve:String->Dynamic, str:String):String
	{
		return StringTools.htmlEscape(str);
	}
	/**
	 * Escape/unsecape HTML special characters of the string.
	 */
	public function htmlUnescape(resolve:String->Dynamic, str:String):String
	{
		return StringTools.htmlUnescape(str);
	}
	/**
	 * 
	 */
	public function getAttribute (resolve:String->Dynamic, element:HtmlElement, attr:String):String
	{
		if (element == null) return null;
		return element.getAttribute(attr);
	}
	/**
	 * trace for the templates
	 */
	public function trace(resolve:String->Dynamic, obj):String
	{
		trace(obj);
		return "";
	}
}