package slplayer.prototype.data;

import slplayer.ui.DisplayObject;
import slplayer.ui.group.IGroupable;

import haxe.Http;

import js.Dom;
import js.Lib;

//need this to be a standard compliant data provider
import slplayer.data.DataProvider;
using slplayer.data.DataProvider;

/**
 * 
 * TODO allow multiple adresses in src
 * TODO cleanup to allow different rss formats
 * @author Thomas Fétiveau
 */
@requires("data-src-rss")
class RssConnector extends DisplayObject, implements IDataProvider, implements IGroupable
{
	static public inline var SRC_TAG = "src-rss";
	
	public var groupElement:HtmlDom;
	
	public var src(default, setSrc) : String;

	public function setSrc(newSrc : String) : String
	{
		if (newSrc == src || newSrc == null)
			return src;
		
		src = newSrc;
		//getData(null);
		
		return src;
	}
	
	override public function init():Void 
	{
		if (groupElement == null)
			groupElement = rootElement;
		
		src = this.rootElement.getAttribute("data-" + SRC_TAG);
		
		var me = this;
		
		startProviding(groupElement);
	}
	
	public function getData()
	{
		if (src == null)
		{
			trace("INFO src not set.");
			return;
		}
		
		var r = new Http("XMLProxy.php");
		r.setParameter( "url" , src);
		var me = this;
		r.onData = callback(me.onData);
		r.onError = callback(me.onError);
		r.request(true);
	}
	
	private function onData(data : String):Void
	{
//trace("data received");
		var dataXml :  Xml;
		try
		{
			dataXml = Xml.parse(data);
		}
		catch (e : Dynamic ) { trace("ERROR cannot parse rss feed "+src); return; }
		
		var items = dataXml.firstElement().firstElement().elementsNamed("item");
		
		var itemsData : Array<Dynamic> = new Array();
		
		while( items.hasNext() )
		{
			itemsData.push( generateDataObject(items.next()) );
		}
		
		groupElement.dispatchData( { src : src, srcTitle : null, data : itemsData } );
	}
	
	/**
	 * Generates the data dynamic object for each item or sub elements of items.
	 * @param	elt
	 * @return a dynamic object having the same scheme as the data tree from the rss feed.
	 */
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