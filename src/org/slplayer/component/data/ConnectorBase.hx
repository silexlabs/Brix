package org.slplayer.component.data;

import org.slplayer.component.ui.DisplayObject;

import org.slplayer.component.group.IGroupable;
using org.slplayer.component.group.IGroupable.Groupable;

import haxe.Http;

import js.Dom;
import js.Lib;

//need this to be a standard compliant data provider
import org.slplayer.component.data.IDataProvider;
using org.slplayer.component.data.IDataProvider.DataProvider;

/**
 * An RSS data provider component.
 * 
 * TODO allow multiple adresses in src
 * TODO cleanup to allow different rss formats
 * @author Thomas Fétiveau
 */
@requires("data-src-rss")
class ConnectorBase<DataType> extends DisplayObject, implements IDataProvider, implements IGroupable
{
	static public inline var SRC_TAG = "src";
	
	public var groupElement:HtmlDom;
	
	public var src(default, setSrc) : String;
	
	var lastResult : DataObject;
	
	var gettingData : Bool;

	public function setSrc(newSrc : String) : String
	{
		if (newSrc == src || newSrc == null)
			return src;
		
		src = newSrc;
		//getData(null);
		
		return src;
	}
	
	private override function new(rootElement : HtmlDom, SLPId:String)
	{
		super(rootElement,SLPId);
		
		startGroupable();
		
		if (groupElement == null)
			groupElement = rootElement;
	}
	
	override public function init():Void 
	{
		src = this.rootElement.getAttribute("data-" + SRC_TAG);
		
		var me = this;
		
		gettingData = false;
		
		startProviding(groupElement);
	}
	
	public function getData()
	{
		if (src == null)
		{
			trace("INFO src not set.");
			return;
		}
		gettingData = true;
		
		var r = new Http("XMLProxy.php");
		r.setParameter( "url" , src);
		var me = this;
		r.onData = callback(me.onData);
		r.onError = callback(me.onError);
		r.request(true);
	}
	
	/**
	 * Callback invoked when a new data consumer is showing up.
	 */
	public function onNewDataConsumer( dataConsumer : org.slplayer.component.data.IDataConsumer ):Void
	{
		if ( lastResult != null )
			dataConsumer.onData( lastResult );
		else
			getData();
	}
	
	private function onData(data : String):Void
	{
		gettingData = false;
		
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
		
		lastResult = { src : src, srcTitle : null, data : itemsData };
		
		groupElement.dispatchData( lastResult );
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
		gettingData = false;
		trace("ERROR cannot access to rss feed "+src);
	}
}