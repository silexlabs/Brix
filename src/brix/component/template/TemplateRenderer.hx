/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.template;

import js.Lib;
import js.Dom;
import brix.component.interaction.Draggable;

import brix.util.DomTools;

import brix.component.navigation.Layer;
import brix.component.ui.DisplayObject;
import brix.component.template.TemplateMacros;
import brix.component.list.ConnectorBase;

/**
 * template renderer component
 * display the template with the provided data
 * the template is the content of the node on which this component is placed
 * the data can be provided by a setData event
 */
class TemplateRenderer extends DisplayObject
{
	/**
	 * data store
	 */
	public var data:Dynamic;
	/**
	 * list elements template
	 * @example 	&lt;li&gt;::displayName::&lt;/li&gt;
	 */
	public var htmlTemplate:String;
	/**
	 */
	public var lastRenderedHtml:String="";
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);

		// init data 
		data = {};

		// store the template
		htmlTemplate = rootElement.innerHTML;

		// and clear the rootElement contents
		rootElement.innerHTML = "";

		// attach the events
		mapListener(rootElement, ConnectorBase.ON_DATA_RECEIVED, onDataReceived, false);

		// listen to the layer events
/*		var tmpHtmlDom = rootElement;
		while(tmpHtmlDom!=null && !DomTools.hasClass(tmpHtmlDom, "Layer"))
		{
			tmpHtmlDom = tmpHtmlDom.parentNode;
		}
		if (tmpHtmlDom!=null)
		{
			// tmpHtmlDom is the layer node
			mapListener(tmpHtmlDom, Layer.EVENT_TYPE_SHOW_AGAIN, onLayerShow, false);
			mapListener(tmpHtmlDom, Layer.EVENT_TYPE_SHOW_STOP, onLayerShow, false);
			mapListener(tmpHtmlDom, Layer.EVENT_TYPE_HIDE_STOP, onLayerHide, false);
		}
/**/
		// listen to the Layer class event, in order to loadData when the page opens
		mapListener(rootElement, Layer.EVENT_TYPE_SHOW_AGAIN, onLayerShow, false);
		mapListener(rootElement, Layer.EVENT_TYPE_SHOW_STOP, onLayerShow, false);
		mapListener(rootElement, Layer.EVENT_TYPE_HIDE_STOP, onLayerHide, false);
	}
	/**
	 * callback for the event
	 */
	public function onDataReceived(e:Event)
	{//trace("onDataReceived");
		var newData:Dynamic = cast(e).detail;
		data = newData;
		redraw();
	}
	/**
	 * the layer is being showed
	 */
	public function onLayerShow(e:Event)
	{
		//redraw();
	}
	/**
	 * the layer is being hidden
	 */ 
	public function onLayerHide(e:Event)
	{
		//rootElement.innerHTML = "";
		// lastRenderedHtml = "";
	}
	/**
	 * redraw the list, i.e. reload the dataProvider( ... )
	 * this method calls reloadData which then calls doRedraw
	 */ 
	public function redraw()
	{
		// refresh data
		reloadData();
	}
	/**
	 * Call this when the DOM tree has changed, and you want the data to be updated accoringly
	 */
	public function domChanged(?e:Event):Void
	{
		//not implemented yet
		throw("not implemented yet");
	}
	/**
	 * expose additional macros to the templates
	 * resolve a template with the given data
	 */
	public function resolve(dynamicData:Dynamic)
	{//trace("resolve "+dynamicData);
		var t = new haxe.Template(htmlTemplate);
		var templateMacros = new TemplateMacros();
		templateMacros.loop = loop;
		return t.execute(dynamicData, templateMacros);
	}
	/**
	 * exposed to the templates to make recursive templates
	 * @example $$loop(::children::)
	 */
	function loop (context : String -> Dynamic, dynamicData : Dynamic){
		//trace("loop "+dynamicData+" - "+context);
		if (dynamicData != null)
			return resolve(dynamicData);
		else return "";
	}
	/**
	 * redraw the data without calling reloadData
	 */
	public function doRedraw()
	{
	 	// generate the html for the element
		try
		{
			var res = resolve(data);

			if (lastRenderedHtml != res)
			{
				for (nodeIdx in 0...rootElement.childNodes.length)
				{
					var node = rootElement.childNodes[nodeIdx];
					if (node!=null && node.nodeType == NodeTypes.ELEMENT_NODE)
					{
						getBrixApplication().cleanNode(node);
					}
				}
				lastRenderedHtml = res;
				rootElement.innerHTML = res;
				for (nodeIdx in 0...rootElement.childNodes.length)
				{
					var node = rootElement.childNodes[nodeIdx];
					if (node!=null && node.nodeType == NodeTypes.ELEMENT_NODE)
					{
						getBrixApplication().initNode(node);
					}
				}
			}
			else
			{

				//trace("render not different "+rootElement.className);
				// throws an error "XML parser failure: element is malformed." : trace("render not different "+rootElement.innerHTML);
			}
		}
		catch(e:Dynamic)
		{
			trace("Error: could not render template "+rootElement.className+". Error message: "+e);
		}
	}
	/**
	 * refreh list data, and then redraw the display by calling doRedraw
	 * to be overriden to handle the model or do nothing if you manipulate the list and dataProvider by composition
	 * if you override this, either call super.reloadData() to redraw immediately, or call doRedraw() when the data is ready
	 */
	public function reloadData():Void
	{
		doRedraw();
	}
}