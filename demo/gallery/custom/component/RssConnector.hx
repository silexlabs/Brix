package custom.component;

import slplayer.ui.DisplayObject;

import haxe.Http;

import js.Dom;
import js.Lib;

/**
 * TODO determine if it wouldn't be useful to create a DataProvider and a DataConsumer interface or base class
 * @author Thomas Fétiveau
 */

class RssConnector extends DisplayObject
{
	static override var className = "rssconnector";
	
	static var SRC_TAG = "src-rss";
	
	public var src(default, setSrc) : String;
	
	override public function init(e:Event):Void 
	{
//trace("initialization");
		src = this.rootElement.getAttribute("data-" + SRC_TAG);
		
		if (src == null)
			trace("INFO " + SRC_TAG + " attribute not set on html element");
		
		var me = this;
		untyped this.rootElement.addEventListener("newDataConsumer", callback(me.getData) , false);
	}

	public function setSrc(newSrc : String) : String
	{
		if (newSrc == src)
			return src;
		
		src = newSrc;
		getData(null);
		
		return src;
	}
	
	public function getData(e:Event = null)
	{
//trace("getting data...");
		if (src == null)
		{
			trace("INFO src not set.");
			return;
		}
		
		var r = new Http("custom/component/RssProxy.php");
		r.setParameter( "url" , src);
		var me = this;
		r.onData = callback(me.onData);
		r.onError = callback(me.onError);
		r.request(true);
	}
	
	public function onData(data : String)
	{
//trace("data received");
		var xml :  Xml;
		try
		{
			xml = Xml.parse(data);
		}
		catch (e : Dynamic ) { trace("ERROR cannot parse rss feed "+src); return; }

		var items = xml.firstElement().firstElement().elementsNamed("item");

		var data : Array<Dynamic> = new Array();
		while( items.hasNext() )
		{
			data.push( generateDataObject(items.next()) );
		}
//trace("data="+data);
		var onDataEvent = untyped Lib.document.createEvent("CustomEvent");
		untyped onDataEvent.initCustomEvent("data", false, false, data);

		untyped this.rootElement.dispatchEvent(onDataEvent);
	}
	
	function generateDataObject(elt : Xml) : Dynamic
	{
		var data : Dynamic<Dynamic>  = cast {};

		var xmlChilds = elt.elements();
	
		while( xmlChilds.hasNext() )
		{
			var xmlChild = xmlChilds.next();
			var nodeName = StringTools.replace( xmlChild.nodeName, ":", "_" );

			Reflect.setField( data, nodeName, { } );
			
			var atts = xmlChild.attributes();
			while( atts.hasNext() )
			{
				var at = atts.next();
				Reflect.setField( Reflect.field(data, nodeName), at, xmlChild.get(at) );
			}
			
			
			var innerChilds = xmlChild.elements();
			if (innerChilds.hasNext())
			{
				while (innerChilds.hasNext())
				{
					var innerChild = innerChilds.next();
					Reflect.setField( Reflect.field(data, nodeName), innerChild.nodeName, generateDataObject(innerChild) );
				}
			}
			else if(xmlChild.firstChild()!=null)
			{
				Reflect.setField( data, nodeName, xmlChild.firstChild());
			}
		}
	
		return data;
	}
	
	private function onError(msg : String)
	{
		trace("ERROR cannot access to rss feed "+src);
	}
}