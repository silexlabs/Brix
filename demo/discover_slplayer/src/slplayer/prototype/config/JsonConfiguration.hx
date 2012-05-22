package slplayer.prototype.config;

import js.Lib;
import js.Dom;

using slplayer.prototype.util.DomTools;

import slplayer.data.DataProvider;
using slplayer.data.DataProvider;

/**
 * ...
 * @author Thomas Fétiveau
 */
class JsonConfiguration implements IDataProvider
{
	static var TAG_SRC = "json-src";
	
	static var TAG_LISTENERS = "json-conf-listen";
	
	static var instance : JsonConfiguration;
	
	var src:String;
	
	var consumers:Array<HtmlDom>;

	public function new(args:Hash<String>) 
	{
		if (instance!=null)
		{
			throw "ERROR: Cannot instanciate more than one JsonConfiguration !";
		}
		
		src = args.get("data-"+TAG_SRC);
		
		if (src == null)
		{
			throw "ERROR: tag data-"+TAG_SRC+" not set on JsonConfiguration component !";
		}
		
		//discover consumers
		consumers = Lib.document.getElementsByAttribute("data-" + TAG_LISTENERS, "*");
		
		for (consCnt in 0...consumers.length)
		{
			startProviding(consumers[consCnt]);
		}
		
		instance = this;
	}
	
	public function getData():Void {}
}