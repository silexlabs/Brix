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

import brix.component.ui.DisplayObject;
import brix.component.template.TemplateMacros;

/**
 * list component
 * display items in a list, according to a template and a dataProvider
 * TODO
 * 	redraw
 * 	template
 * 	datapovider
 * 	selected index/item
 * 	selected indexes / items
 */
@tagNameFilter("ul")
class List<ElementClass> extends DisplayObject
{
	public static inline var LIST_SELECTED_ITEM_CSS_CLASS:String = "listSelectedItem";
	public static inline var DATA_ATTR_LIST_ITEM_INDEX:String = "data-list-item-idx";

	/**
	 * event dispatched when the selection changes
	 */
	public static inline var EVENT_CHANGE:String = "listChange";
	/**
	 * event dispatched when an item is clicked (will likely also change the selection)
	 */
	public static inline var EVENT_CLICK:String = "listClick";
	/**
	 * event dispatched when an item is hovered
	 */
	public static inline var EVENT_ROLL_OVER:String = "listRollOver";

	/**
	 * list elements template
	 * @example 	&lt;li&gt;::displayName::&lt;/li&gt;
	 */
	public var listTemplate:String;
	/**
	 * data store
	 */
	public var dataProvider:Array<ElementClass>;
	/**
	 * selected item if any
	 */
	public var selectedItem(getSelectedItem, setSelectedItem):Null<ElementClass>;
	/**
	 * selected item index, in the dataProvider array, or -1 of there is no selected index
	 */
	public var selectedIndex(getSelectedIndex, setSelectedIndex):Int;
	private var _selectedIndex:Int;
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, BrixId:String)
	{
		super(rootElement, BrixId);
		_selectedIndex = -1;
		dataProvider = [];

		// store the template
		listTemplate = rootElement.innerHTML;
		// and clear the rootElement contents
		rootElement.innerHTML = "";
	}
	/**
	 * init the component
	 * get elements by class names 
	 * you can now initialize the process of refreshing the list by calling redraw()
	 */
	override public function init() : Void
	{ 
		// init the parent class
		super.init();

		rootElement.addEventListener("click", click, false);
		rootElement.addEventListener("rollOver", rollOver, false);
		rootElement.addEventListener(Draggable.EVENT_DROPPED, listDOMChanged, false);
	}

	/**
	 * Cleans the list object before removal.
	 */
	override public function clean() : Void
	{
		super.clean();

		rootElement.removeEventListener("click", click, false);
		rootElement.removeEventListener("rollOver", rollOver, false);
		rootElement.removeEventListener(Draggable.EVENT_DROPPED, listDOMChanged, false);
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
	 * Triggered when the list's DOM tree has changed.
	 */
	public function listDOMChanged(?e:Event):Void
	{
		e.stopPropagation();
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
		var listInnerHtml:String = "";
		var t = new haxe.Template(listTemplate);
		for (elem in dataProvider)
		{
			try
			{
				listInnerHtml += t.execute(elem, TemplateMacros);
			}
			catch(e:Dynamic){
				throw("Error: an error occured while interpreting the template - "+listTemplate+" - for the element "+elem);
			}
		}

		for (i in 0...rootElement.childNodes.length)
		{
			getBrixApplication().cleanNode(rootElement.childNodes[i]);
		}

		rootElement.innerHTML = listInnerHtml;

		for (i in 0...rootElement.childNodes.length)
		{
			getBrixApplication().initNode(rootElement.childNodes[i]);
		}

		setItemIds();
		updateSelectionDisplay([selectedItem]);
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
	private function getItemID(childElement:HtmlDom):Int
	{
		if (childElement == rootElement || childElement == null)
		{
			throw("Error, could not find the element clicked in the list.");
		}
		if (childElement.nodeType != rootElement.nodeType || childElement.getAttribute(DATA_ATTR_LIST_ITEM_INDEX) == null)
		{
			return getItemID(childElement.parentNode);
		}
		return Std.parseInt(childElement.getAttribute(DATA_ATTR_LIST_ITEM_INDEX));
	}
	/**
	 * handle click in the list
	 * TODO: multiple selection
	 */
	private function click(e:js.Event)
	{
		// retrieve the element of the list
		var element = e.target;
		var idx = getItemID(element);
		selectedItem = dataProvider[idx];

		// dispatch a custom event
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(EVENT_CLICK, false, false, {
			target: rootElement,
			item: selectedItem,
		});
		rootElement.dispatchEvent(event);
	}
	/**
	 * handle roll over
	 */
	private function rollOver(e:js.Event)
	{
		var element = e.target;
		var idx = getItemID(element);

		// dispatch a custom event
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(EVENT_CHANGE, false, false, {
			target: rootElement,
			item: dataProvider[idx],
		});
		rootElement.dispatchEvent(event);
	}
	/**
	 * handle a selection change
	 * call onChange if defined
	 * TODO: multiple selection
	 */
	private function updateSelectionDisplay(selection:Array<ElementClass>)
	{
		// handle the selected style 
		var children = rootElement.getElementsByTagName("li");
		for (idx in 0...children.length)
		{
			var idxElem:Int = getItemID(children[idx]);
			if (idxElem >= 0)
			{
				var found = false;
				for (elem in selection)
				{
					if (elem == dataProvider[idxElem])
					{
						found = true;
						break;
					}
				}
				if (children[idx] == null)
				{
					// workaround
					trace("--workaround--" + idx +"- "+children[idx]);
					continue;
				}

				if (found)
				{
					DomTools.addClass(children[idx], LIST_SELECTED_ITEM_CSS_CLASS);
				}
				else
				{
					DomTools.removeClass(children[idx], LIST_SELECTED_ITEM_CSS_CLASS);
				}
			}
		}
	}
	////////////////////////////////////////////////////////////
	// setter / getter
	////////////////////////////////////////////////////////////
	/**
	 * getter/setter
	 */
	function getSelectedItem():Null<ElementClass> 
	{
		return dataProvider[_selectedIndex];
	}
	/**
	 * getter/setter
	 */
	function setSelectedItem(selected:Null<ElementClass>):Null<ElementClass> 
	{
		//trace("setSelectedItem "+selected+" - "+Type.getClassName(Type.getClass(this)));
		//DomTools.inspectTrace(selected, "brix.component.list.List"); 
		if (selected != selectedItem)
		{
			if (selected != null)
			{
				var tmpIdx:Int = -1;
				for (idx in 0...dataProvider.length)
				{
					if (dataProvider[idx] == selected)
					{
						tmpIdx = idx;
						break;
					}
				}
				selectedIndex = tmpIdx;
			}
			else
			{
				selectedIndex = -1;
			}
		}
		return selected;
	}
	/**
	 * getter/setter
	 */
	function getSelectedIndex():Int 
	{
		return _selectedIndex;
	}
	/**
	 * getter/setter
	 */
	function setSelectedIndex(idx:Int):Int 
	{
		//trace("setSelectedIndex "+idx+" - "+Type.getClassName(Type.getClass(this)));
		if (idx != _selectedIndex)
		{
			if (idx >= 0 && dataProvider.length > idx && dataProvider[idx] != null)
			{
				_selectedIndex = idx;
			}
			else
			{
				_selectedIndex = -1;
			}
			updateSelectionDisplay([selectedItem]);

			// dispatch a custom event
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_CHANGE, false, false, {
				target: rootElement,
				item: selectedItem,
			});
			rootElement.dispatchEvent(event);
		}
		return idx;
	}
}