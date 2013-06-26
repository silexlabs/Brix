/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.list;

import js.html.HtmlElement;
import js.html.Event;

import brix.component.interaction.Draggable;

import brix.util.DomTools;

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
class List<ElementClass> extends Repeater<ElementClass>
{
	/**
	 * css class applyed to the selected item in the DOM
	 */
	public static inline var LIST_SELECTED_ITEM_CSS_CLASS:String = "listSelectedItem";
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
	 * selected item if any
	 */
	public var selectedItem(get, set):Null<ElementClass>;
	/**
	 * selected item index, in the dataProvider array, or -1 of there is no selected index
	 */
	public var selectedIndex(default, set):Int;
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlElement, brixId:String)
	{
		super(rootElement, brixId);
		selectedIndex = -1;
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

		mapListener(rootElement, "click", click, false);
		mapListener(rootElement, "rollOver", rollOver, false);
		//mapListener(rootElement, Draggable.EVENT_DROPPED, listDOMChanged, false);
	}
	/**
	 * handle click in the list
	 * TODO: multiple selection
	 */
	private function click(e:Event)
	{
		// retrieve the element of the list
		var element = cast(e.target);
		var idx = getItemIdx(element);
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
	private function rollOver(e:Event)
	{
		var element:HtmlElement = cast(e.target);
		var idx = getItemIdx(element);

		// dispatch a custom event
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(EVENT_CHANGE, false, false, {
			target: rootElement,
			item: dataProvider[idx],
		});
		rootElement.dispatchEvent(event);
	}
	/**
	 * redraw the list without calling reloadData
	 */
	override public function doRedraw()
	{
		super.doRedraw();
		updateSelectionDisplay([selectedItem]);
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
			var idxElem:Int = getItemIdx(children[idx]);
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
	function get_selectedItem():Null<ElementClass> 
	{
		return dataProvider[selectedIndex];
	}
	/**
	 * getter/setter
	 */
	function set_selectedItem(selected:Null<ElementClass>):Null<ElementClass> 
	{
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
	function get_selectedIndex():Int 
	{
		return selectedIndex;
	}
	/**
	 * getter/setter
	 */
	function set_selectedIndex(idx:Int):Int 
	{
		if (idx != selectedIndex)
		{
			if (idx >= 0 && dataProvider.length > idx && dataProvider[idx] != null)
			{
				selectedIndex = idx;
			}
			else
			{
				selectedIndex = -1;
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