/*
 * This file is part of SLPlayer http://www.silexlabs.org/groups/labs/slplayer/
 * 
 * This project is © 2011-2012 Silex Labs and is released under the GPL License:
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms 
 * of the GNU General Public License (GPL) as published by the Free Software Foundation; 
 * either version 2 of the License, or (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU General Public License for more details.
 * 
 * To read the license please visit http://www.gnu.org/copyleft/gpl.html
 */
package org.slplayer.component.list;

import js.Lib;
import js.Dom;
import org.slplayer.util.DomTools;

import org.slplayer.component.ui.DisplayObject;
import org.slplayer.component.template.TemplateMacros;

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
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);
		_selectedIndex = -1;
		dataProvider = [];
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
		// store the template
		listTemplate = rootElement.innerHTML;

		rootElement.addEventListener("click", click, false);
		rootElement.addEventListener("rollOver", rollOver, false);
	}
	/**
	 * redraw the list, i.e. reload the dataProvider( ... )
	 * this method calls reloadData which then calls doRedraw
	 */ 
	public function redraw()
	{
		//trace("redraw "+" - "+Type.getClassName(Type.getClass(this)));

		// refresh list data
		reloadData();
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
			try{
				listInnerHtml += t.execute(elem, TemplateMacros);
			}
			catch(e:Dynamic){
				throw("Error: an error occured while interpreting the template - "+listTemplate+" - for the element "+elem);
			}
		}
		rootElement.innerHTML = listInnerHtml;

		
		attachListEvents();
		updateSelectionDisplay([selectedItem]);
	}
	/**
	 * refreh list data, and then redraw the display by calling doRedraw
	 * to be overriden to handle the model or do nothing if you manipulate the list and dataProvider by composition
	 * if you override this, either call super.reloadData() to redraw immediately, or call doRedraw() when the data is ready
	 */
	public function reloadData()
	{
		doRedraw();
	}
	/**
	 * attach mouse events to the list and the items
	 */
	private function attachListEvents()
	{
		var children = rootElement.getElementsByTagName("li");
		for (idx in 0...children.length)
		{
			children[idx].setAttribute(DATA_ATTR_LIST_ITEM_INDEX, Std.string(idx));
		}
	}

	/**
	 * retrieve the id of a node
	 */
	private function getItemID(childElement:HtmlDom):Int
	{
		var element = childElement;
		var idx = element.getAttribute(DATA_ATTR_LIST_ITEM_INDEX);
		while (idx == null && element!=rootElement && element!=null){
			element = element.parentNode;
			idx = element.getAttribute(DATA_ATTR_LIST_ITEM_INDEX);
		}
		if (idx == null)
		{
			throw("Error, could not find the element clicked in the list.");
		}
		return Std.parseInt(idx);
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
		//trace("updateSelectionDisplay "+selection+" - "+Type.getClassName(Type.getClass(this)));

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
		//DomTools.inspectTrace(selected, "org.slplayer.component.list.List"); 
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