/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.list;

import js.Lib;
import js.Dom;
import brix.component.interaction.Draggable;

import brix.util.DomTools;

import brix.component.navigation.Layer;
import brix.component.ui.DisplayObject;
import brix.component.template.TemplateMacros;

/**
 * list component
 * display items in a template and expose a data provider interface
 * 	redraw
 * 	template
 * 	datapovider
 */
class Repeater<ElementClass> extends DisplayObject
{
	/**
	 * event to request data change 
	 */
	public static inline var SET_DATA_REQUEST = "setData";
	/**
	 * event to request data change 
	 */
	public static inline var ADD_DATA_REQUEST = "addData";
	/**
	 * attribute used to store the index of the cell in the generated DOM
	 */
	public static inline var DATA_ATTR_LIST_ITEM_INDEX = "data-list-item-idx";
	/**
	 * list elements template
	 * @example 	&lt;li&gt;::displayName::&lt;/li&gt;
	 */
	public var htmlTemplate:String;
	/**
	 * data store
	 */
	public var dataProvider:Array<ElementClass>;
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		dataProvider = [];

		// store the template
		htmlTemplate = rootElement.innerHTML;

		// and clear the rootElement contents
		rootElement.innerHTML = "";

		// attach the events
		mapListener(rootElement, SET_DATA_REQUEST, onSetDataRequest, true);
		mapListener(rootElement, ADD_DATA_REQUEST, onAddDataRequest, true);
	}
	/**
	 * callback for the event
	 */
	public function onSetDataRequest(e:Event)
	{
		var newData:Array<ElementClass> = cast(e).detail;
		dataProvider = newData;
		redraw();
	}
	/**
	 * callback for the event
	 */
	public function onAddDataRequest(e:Event)
	{
		var newData:Array<ElementClass> = cast(e).detail;
		dataProvider.concat(newData);
		redraw();
	}
	/**
	 * redraw the list, i.e. reload the dataProvider( ... )
	 * this method calls reloadData which then calls doRedraw
	 */ 
	public function redraw()
	{
		// refresh list data
		reloadData();
	}
	/**
	 * Call this when the list's DOM tree has changed, and you want the dataProvider to be updated accoringly
	 */
	public function domChanged(?e:Event):Void
	{
		var newDataProvider:Array<ElementClass> = new Array();
		// re-order the items in the dataprovider according to the DOM
		for (i in 0...rootElement.childNodes.length)
		{
			if (rootElement.childNodes[i].nodeType != rootElement.nodeType || 
				rootElement.childNodes[i].getAttribute(DATA_ATTR_LIST_ITEM_INDEX) == null)
			{
				continue;
			}
			// TODO support new elts with no DATA_ATTR_LIST_ITEM_INDEX attribute yet (need retro-template for that)
			newDataProvider.push(dataProvider[Std.parseInt(rootElement.childNodes[i].getAttribute(DATA_ATTR_LIST_ITEM_INDEX))]);
		}
		dataProvider = newDataProvider;
		// reset the item ids
		setItemIds(true);
	}
	/**
	 * redraw the list without calling reloadData
	 */
	public function doRedraw()
	{
		// redraw list content
		var newInnerHTML:String = "";
		var t = new haxe.Template(htmlTemplate);
		for (elem in dataProvider)
		{
			try
			{
				newInnerHTML += t.execute(elem, TemplateMacros);
			}
			catch(e:Dynamic){
				throw("Error: an error occured while interpreting the template - "+htmlTemplate+" - for the element "+elem);
			}
		}

		for (i in 0...rootElement.childNodes.length)
		{
			getBrixApplication().cleanNode(rootElement.childNodes[i]);
		}

		rootElement.innerHTML = newInnerHTML;

		for (i in 0...rootElement.childNodes.length)
		{
			getBrixApplication().initNode(rootElement.childNodes[i]);
		}

		setItemIds();
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
	/**
	 * Set ids on the items.
	 */
	private function setItemIds(?reset=false):Void
	{
		var idx = 0;
		for (i in 0...rootElement.childNodes.length)
		{
			if (rootElement.childNodes[i].nodeType != rootElement.nodeType ||
				reset && rootElement.childNodes[i].getAttribute(DATA_ATTR_LIST_ITEM_INDEX) == null)
			{
				continue;
			}
			rootElement.childNodes[i].setAttribute(DATA_ATTR_LIST_ITEM_INDEX, Std.string(idx));
			idx++;
		}
	}
	/**
	 * retrieves the id of the item containing a given node
	 * @param the given DOM node
	 */
	public function getItemIdx(childElement:HtmlDom):Int
	{
		if (childElement == rootElement || childElement == null)
		{
			throw("Error, could not find the element clicked in the list.");
		}
		if (childElement.nodeType != rootElement.nodeType || childElement.getAttribute(DATA_ATTR_LIST_ITEM_INDEX) == null)
		{
			return getItemIdx(childElement.parentNode);
		}
		return Std.parseInt(childElement.getAttribute(DATA_ATTR_LIST_ITEM_INDEX));
	}
}