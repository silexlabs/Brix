/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.util.data;

using StringTools;

enum State
{
	NEW_LINE;
	CAR_RET(p:Int); // p being the char code of \n or \r when one of them is met
	COMMENT;
	NEW_SECTION;
	END_SECTION;
	NEW_KEY;
	EXPECT_END_KEY;
	NEW_VALUE(v:ValueType,isArray:Bool);
	END_VALUE(isArray:Bool);
}
enum ValueType
{
	UNDEFINED;
	FLOAT;
	INT;
	STRING(delimiterCode:Int);
	CONST;
}

/**
 * A simple Ini file parser and encoder.
 * 
 * As I did not find any official specifications about the ini format (if you found one, please forward it to me on the Brix 
 * Contributor forum), here are some explanation on what this parser expects (and also how are encoded data in the other way):
 * 
 * <code>
 * [SectionName]
 * 
 * keyname=value
 * 
 * ;comment
 * 
 * keyname=value, value, value ;comment
 * </code>
 * 
 * Section names are enclosed in square brackets, and must begin at the beginning of a line. Section and key names are case-insensitive.
 * 
 * Section and key names cannot contain spacing characters. The key name is followed by an equal sign ("=", decimal code 61), 
 * optionally surrounded by spacing characters, which are ignored.
 * 
 * If the same key of the same section appears more than once in the same section, then the last occurrence prevails (however, 
 * a WARNING will be traced).
 * 
 * Multiple values for a key are separated by a comma followed by at least one spacing character (this is different from how the 
 * PHP function parse_ini_file treats the "Array" values: http://fr2.php.net/manual/en/function.parse-ini-file.php).
 * 
 * Comments start with ";" and ends at the end of their line.
 * 
 * When the parser encounters any unconformity, an error message is thrown and the parsing stops.
 * 
 * 
 * This version is a draft. It very probably needs improvments, optimization, fixes... Also, the serialize method is not yet implemented.
 * 
 * @author Thomas Fétiveau
 */
class Ini 
{
	private var data:Hash<Hash<Dynamic>>;

	/**
	 * Build a new empty Ini object.
	 */
	public function new() 
	{
		data = new Hash();
	}
	
	/**
	 * Encode directly in the Ini's data the data passed in parameters.
	 * @param Dynamic	the values to encode.
	 */
	static public function encode(values:{}):Ini
	{
		// TODO
		throw("not yet implemented");
		return null;
	}

	/**
	 * Builds a Ini object from a String in the INI format.
	 * @param	s	the String in the INI format
	 * @return	an Ini object
	 */
	static public function parse(s:String):Ini
	{
		var ini = new Ini();
		doParse(s, ini);
//trace("debug");
//for ( s in {iterator:ini.sections})
//{
	//for ( k in { iterator:function() { return ini.keys(s); }} )
	//{
		//trace(s + " => " + k + " => " + ini.get(k,s));
	//}
//}
//trace("end debug");
		return ini;
	}
	/**
	 * Parses a String in the INI format to assemble an Ini object.
	 * @param	s	the String to parse
	 * @param	ini	the ini object to feed with data from ini file.
	 */
	static private function doParse(s:String,ini:Ini):Void
	{
		var section:String = ""; // default/root section
		ini.data.set(section, new Hash());
		var key:String = null;
		var state:State = NEW_LINE;
		var str:String = null;
		var li:Int = 0;
		var ci:Int = 0;
		// temp fix for last value parsing when no space nor new line at the end
		s += " ";
//trace("s="+s);
		while (ci < s.length)
		{
			var c = s.fastCodeAt(ci);
//trace("char "+s.charAt(ci)+"  state="+Std.string(state)+"   currentSection="+section+"   str="+str+"  li="+li+"  ci="+ci);
			switch (state)
			{
				case NEW_LINE:
					switch (c)
					{
						case '\t'.code, ' '.code:
							// spaces allowed but ignored
						case '['.code:
							state = NEW_SECTION;
							str = "";
						case ';'.code:
							state = COMMENT;
						case '\n'.code, '\r'.code:
							state = CAR_RET(c);
						default:
							if (!isValidChar(c))
							{
								throw("Unexpected character "+c+" at line "+li);
							}
							state = NEW_KEY;
							str = s.charAt(ci);
					}

				case COMMENT:
					switch (c)
					{
						case '\n'.code, '\r'.code:
							state = CAR_RET(c);
						default:
							// nothing
					}

				case NEW_SECTION:
					switch (c)
					{
						case ']'.code:
							state = END_SECTION;
							section = str.toLowerCase();
							if (ini.data.exists(section))
							{
								trace("WARNING: SECTION '"+section+"' declared twice!");
							}
							else
							{
								ini.data.set(section, new Hash());
							}
						default:
							if (!isValidChar(c))
							{
								throw("Unexpected character "+c+" at line "+li);
							}
							str += s.charAt(ci);
					}

				case END_SECTION:
					switch (c)
					{
						case ';'.code:
							state = COMMENT;
						case '\n'.code, '\r'.code:
							state = CAR_RET(c);
						case '\t'.code, ' '.code:
							// spaces allowed but ignored
						default:
							throw("Unexpected character "+c+" at line "+li);
					}

				case NEW_KEY:
					switch (c)
					{
						case '='.code:
							state = NEW_VALUE(UNDEFINED,false);
							key = str;
						case '\t'.code, ' '.code:
							state = EXPECT_END_KEY;
							key = str;
						default:
							if (!isValidChar(c))
							{
								throw("Unexpected character "+c+" at line "+li);
							}
							str += s.charAt(ci);
					}

				case EXPECT_END_KEY:
					switch (c)
					{
						case '='.code:
							state = NEW_VALUE(UNDEFINED,false);
						case '\t'.code, ' '.code:
							// nothing
						default:
							throw("Expected char '=' after " + key + " at line " +li);
					}

				case NEW_VALUE(v,a):
					switch (v)
					{
						case UNDEFINED:
							switch (c)
							{
								case ','.code:
									// no value => null
									a ? ini.data.get(section).get(key).push(null) : ini.data.get(section).set(key, [null]);
									state = NEW_VALUE(UNDEFINED,true);
								case '\n'.code, '\r'.code:
									// no value => null
									a ? ini.data.get(section).get(key).push(null) : ini.data.get(section).set(key, null);
									state = CAR_RET(c);
								case ';'.code:
									// no value => null
									a ? ini.data.get(section).get(key).push(null) : ini.data.get(section).set(key, null);
									state = COMMENT;
								case '\t'.code, ' '.code:
									// spaces allowed but ignored
								// VALUES
								case '.'.code:
									// test is float; .5 is valid (=0.5)
									str = s.charAt(ci);
									state = NEW_VALUE(FLOAT,a);
								case '"'.code, "'".code:
									// test is string
									str = "";
									state = NEW_VALUE(STRING(c), a);
								default:
									// test is int
									if (c >= '0'.code && c <= '9'.code)
									{
										str = s.charAt(ci);
										state = NEW_VALUE(INT,a);
									}
									// test const; const starts with letter or number, we may change that if it's too restrictive
									else if ((c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code))
									{
										str = s.charAt(ci);
										state = NEW_VALUE(CONST,a);
									}
									// Invalid
									else
									{
										throw("Unexpected char "+c+" at line "+li);
									}
							}

						case FLOAT:
							switch (c)
							{
								case ','.code:
									if (str.fastCodeAt(0) == '.'.code)
									{
										str = "0" + str;
									}
									a ? ini.data.get(section).get(key).push(Std.parseFloat(str)) : ini.data.get(section).set(key, [Std.parseFloat(str)]);
									state = NEW_VALUE(UNDEFINED,true);
								case '\n'.code, '\r'.code, '\t'.code, ' '.code, ';'.code:
									if (str.fastCodeAt(0) == '.'.code)
									{
										str = "0" + str;
									}
									a ? ini.data.get(section).get(key).push(Std.parseFloat(str)) : ini.data.get(section).set(key, Std.parseFloat(str));
									if ( c == '\n'.code || c == '\r'.code)
										state = CAR_RET(c);
									else if ( c == '\t'.code || c == ' '.code)
										state = END_VALUE(a);
									else // ( c == ';'.code )
										state = COMMENT;
								default:
									str += s.charAt(ci);
									if ( c == '.'.code && str.fastCodeAt(0) != '.'.code)
									{
										state = NEW_VALUE(CONST,a);
									}
									else if (!(c >= '0'.code && c <= '9'.code) && !(str.indexOf('.') == -1 && c == '.'.code))
									{
										throw("Unexpected "+str+" at line " + li);
									}
							}

						case INT:
							switch(c)
							{
								case ','.code:
									a ? ini.data.get(section).get(key).push(Std.parseInt(str)) : ini.data.get(section).set(key, [Std.parseInt(str)]);
									state = NEW_VALUE(UNDEFINED,true);
								case '\n'.code, '\r'.code, ';'.code, '\t'.code, ' '.code:
									a ? ini.data.get(section).get(key).push(Std.parseInt(str)) : ini.data.get(section).set(key, Std.parseInt(str)) ;
									if ( c == '\n'.code || c == '\r'.code )
										state = CAR_RET(c);
									else if ( c == ';'.code )
										state = COMMENT;
									else // ( c == '\t'.code || c == ' '.code )
										state = END_VALUE(a);
								case '.'.code:
									state = NEW_VALUE(FLOAT,a);
									str += s.charAt(ci);
								default:
									if (c >= '0'.code && c <= '9'.code)
									{
										// int
									}
									else if (isValidChar(c))
									{
										state = NEW_VALUE(CONST,a);
									}
									else
									{
										throw("Unexpected "+s.charAt(ci)+" at line "+li);
									}
									str += s.charAt(ci);
							}

						case STRING(d):
							switch (c)
							{
								case d:
									a ? ini.data.get(section).get(key).push(str) : ini.data.get(section).set(key, str);
									state = END_VALUE(a);
								case '\n'.code, '\r'.code:
									throw('Expected " before end of line at line '+li);
								default:
									str += s.charAt(ci);
							}

						case CONST:
							switch (c)
							{
								case ','.code:
									a ? ini.data.get(section).get(key).push(constValue(str)): ini.data.get(section).set(key, [constValue(str)]);
									state = NEW_VALUE(UNDEFINED,true);
								case '\n'.code, '\r'.code, ';'.code, '\t'.code, ' '.code:
									a ? ini.data.get(section).get(key).push(constValue(str)) : ini.data.get(section).set(key, constValue(str)); // TODO resolve const
									if ( c == '\n'.code || c == '\r'.code )
										state = CAR_RET(c);
									else if ( c == ';'.code )
										state = COMMENT;
									else // ( c == '\t'.code || c == ' '.code )
										state = END_VALUE(a);
								default:
									if (!isValidChar(c))
									{
										throw("Unexpected "+s.charAt(ci)+" at line "+li);
									}
									str += s.charAt(ci);
							}
					}

					case END_VALUE(a):
						switch (c)
						{
							case ','.code:
								if (!a)
								{
									ini.data.get(section).set(key, [ini.data.get(section).get(key)]);
								}
								str = "";
								state = NEW_VALUE(UNDEFINED, true);
							case ';'.code:
								state = COMMENT;
							case '\n'.code, '\r'.code:
								state = CAR_RET(c);
							case '\t'.code, ' '.code:
								// spaces allowed but ignored
							default:
								throw("Unexpected character "+c+" at line "+li);
						}

					case CAR_RET(p):
						li++;
						switch(c)
						{
							case '\n'.code:
								state = NEW_LINE;
								if (p == c)
								{
									li++; // case \n\n
								}
							case '\r'.code:
								state = CAR_RET(c);
							default:
								state = NEW_LINE;
								continue; // the current char needs to be analyzed with the NEW_LINE state
						}
			}
			ci++;
		}
	}
	static inline function isValidChar(c):Bool
	{
		return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code) || c == ':'.code || c == '.'.code || c == '_'.code || c == '-'.code;
	}
	static function constValue(str:String):Dynamic
	{
		switch (str)
		{
			case "true", "on", "yes":
				return true;
			case "false", "off", "no":
				return false;
			case "null":
				return null;
			default:
				return str;
		}
	}

	////////////
	// Accessors
	////////////
	/**
	 * Gets the sections id of the Ini object.
	 * @return Iterator<String>
	 */
	public function sections():Iterator<String>
	{
		return data.keys();
	}
	/**
	 * Gets the keys of a specific section.
	 * @param	?section	optional, default is the root section (names "").
	 * @return	Iterator<String> or null if no matching section
	 */
	public function keys(?section:String=null):Null<Iterator<String>>
	{
		if (section == null)
			section = "";
		if (data.exists(section))
			return data.get(section).keys();
		return null;
	}
	/**
	 * Gets a value by key and section.
	 * @param	String, the key
	 * @param	String, optional, the section, default is root section (named "")
	 * @return	null if no matching key or section, else the desired value (can be String, Int, Float, null).
	 */
	public function get(key:String, ?section:String=null):Null<Dynamic>
	{
		if (section == null)
			section = "";
		if (data.exists(section))
			return data.get(section).get(key);
		return null;
	}
	/**
	 * Sets a given key/pair value un a section.
	 * @param	String, the key	
	 * @param	Dynamic, the value (can be String, Int, Float, null).
	 * @param	?section, optional, the section, default is root section (named "")
	 */
	public function set(key:String, value:Dynamic, ?section:String = null):Void
	{
		var valueStr:String = encodeValue(value);
		if (section == null)
			section = "";
		if (!data.exists(section))
			data.set(section, new Hash());
		data.get(section).set(key, valueStr);
	}
	private function encodeValue(v:Dynamic):String
	{
		// TODO check if String or Array<String>. Manage Bool, Int, Float... ?
		throw("not yet implemented");
		return "";
	}
	/**
	 * Generates the string representation of the ini data.
	 * @return a String representing the data in the INI format.
	 */
	public function serialize():String
	{
		// TODO
		throw("not yet implemented");
		return "";
	}
}