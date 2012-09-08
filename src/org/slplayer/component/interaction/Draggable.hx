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
package org.slplayer.component.interaction;

import js.Lib;
import js.Dom;

import org.slplayer.util.DomTools;
import org.slplayer.component.ui.DisplayObject;

enum DraggableState {
	none;
	dragging;
}
typedef DropZone = {
	parent:HtmlDom,
	position:Int
}
typedef DraggableEvent = {
	dropZone : Null<DropZone>,
	target: HtmlDom,
	draggable: Draggable
}

/**
 * Draggable class
 * Attach mouse events to a "drag zone" and make it drag/drop the "Draggable" node
 * If drop zones are provided, display the best drop zone found and enable only these zones to be parents
 * define the drop zones with a "drop-zone" class name on the elements, or by setting the dropZones attribute
 */
class Draggable extends DisplayObject
{
	////////////////////////////////////
	// events
	////////////////////////////////////
	/**
	 * class name to set on the node which is the drag zone (knob or header)
	 */
	public static inline var CSS_CLASS_DRAGZONE = "draggable-dragzone";
	/**
	 * default class name for the drop zones, used if you do not specify a data-dropzones-class-name attribute
	 */
	public static inline var DEFAULT_CSS_CLASS_DROPZONE = "draggable-dropzone";
	/**
	 * default class name for the phantom style
	 * the phantom is the visualization of the dragged element, while dragging
	 */
	public static inline var DEFAULT_CSS_CLASS_PHANTOM = "draggable-phantom";

	/**
	 * name of the attribute to pass the phantomClassName param to this class
	 * the phantomClassName class name is used to skin the phantom
	 */
	public static inline var ATTR_PHANTOM = "data-phantom-class-name";
	/**
	 * name of the attribute to pass the dropZonesClassName param to this class
	 * the dropZonesClassName class name is to be set on the nodes which accept drops
	 */
	public static inline var ATTR_DROPZONE = "data-dropzones-class-name";

	/**
	 * name of the event dispatched on rootElement when an the element starts to be dragged
	 */
	public static inline var EVENT_DRAG = "dragEventDrag";
	/**
	 * name of the event dispatched on rootElement when the dragged element is dropped
	 */
	public static inline var EVENT_DROPPED = "dragEventDropped";
	/**
	 * name of the event dispatched on rootElement when the dragged element is moved
	 */
	public static inline var EVENT_MOVE = "dragEventMove";
	/**
	 * callback used to add/remove events to the html body
	 */
	private var moveCallback:Event->Void;
	/**
	 * callback used to add/remove events to the html body
	 */
	private var mouseUpCallback:Event->Void;
	/**
	 * div element used to show where the element is about to be dropped
	 */
	private var phantom:HtmlDom;
	/**
	 * state of the draggable element (none, dragging)
	 */
	private var state:DraggableState;
	/**
	 * html elment instance
	 */
	public var dragZone:HtmlDom;
	/**
	 * html elment instances
	 */
	public var dropZones:HtmlCollection<js.HtmlDom>;
	/**
	 * class name to select drop zones 
	 * @default	dropzone 
	 */
	public var dropZonesClassName:String;
	/**
	 * class name to select the phantom 
	 * @default	dropzone 
	 */
	public var phantomClassName:String;
	/**
	 * the latest found best drop zone
	 * it contains the phantom HTML element
	 * @default	null
	 */
	public var bestDropZone:DropZone;
	/**
	 * initial value of the style attr of the root element 
	 */
	public var initialStyle:Dynamic;
	/**
	 * initial position
	 */
	private var initialMouseX:Int;
	/**
	 * initial position
	 */
	private var initialMouseY:Int;
	/**
	 * initial position
	 */
	private var initialX:Int;
	/**
	 * initial position
	 */
	private var initialY:Int;
	/**
	 * constructor
	 * init properties
	 * retrieve atributes of the html dom node
	 */
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);

		// init
		state = none;

		// retrieve atribute of the html dom node 
		phantomClassName = rootElement.getAttribute(ATTR_PHANTOM);

		// default value
		if (phantomClassName == null || phantomClassName == "")
			phantomClassName = DEFAULT_CSS_CLASS_PHANTOM;

		// retrieve atribute of the html dom node 
		dropZonesClassName = rootElement.getAttribute(ATTR_DROPZONE);

		// default value
		if (dropZonesClassName == null || dropZonesClassName == "")
			dropZonesClassName = DEFAULT_CSS_CLASS_DROPZONE;

	}
	/**
	 * init the component
	 */
	override public function init() : Void 
	{ 
		super.init();

		// create the phantom
		phantom = Lib.document.createElement("div");

		// retrieve references to the elements
		dragZone = DomTools.getSingleElement(rootElement, CSS_CLASS_DRAGZONE, false);
		if (dragZone == null)
			dragZone = rootElement;

		// retrieve references to the elements
		dropZones = Lib.document.body.getElementsByClassName(dropZonesClassName);
		if (dropZones.length == 0)
			dropZones[0] = rootElement.parentNode;

		// attach the events
		dragZone.onmousedown = startDrag;
		//dragZone.onmouseup = stopDrag;
		mouseUpCallback = callback(stopDrag);
		Lib.document.body.addEventListener("mouseup", mouseUpCallback, false);
		dragZone.style.cursor = "move";
	}
	/**
	 * set all properties of root element with absolute values 
	 */
	private function initRootElementStyle()
	{
		initialStyle = {};
		
		//for (styleName in Reflect.fields(rootElement.style))
		//{
			//var val:String = Reflect.field(rootElement.style, styleName);
			//Reflect.setField(initialStyle, styleName, val);
			//trace("initRootElementStyle keep style "+styleName+" = "+val);
		//}
		
		initialStyle.width = rootElement.style.width;
		rootElement.style.width = rootElement.clientWidth + "px";

		initialStyle.height = rootElement.style.height;
		rootElement.style.height = rootElement.clientHeight + "px";

		initialStyle.position = rootElement.style.position;
		rootElement.style.position="absolute";
	}
	/**
	 * init phantom according to root element properties
	 */
	private function initPhantomStyle()
	{

		var computedStyle:Style = untyped __js__("window.getComputedStyle(this.rootElement, null)");

		for (styleName in Reflect.fields(computedStyle)){
			// retrieve the computed properties
			var val:String = Reflect.field(computedStyle, styleName);
			// firefox way
			var  mozzVal = untyped __js__("computedStyle.getPropertyValue(val)");
			if (mozzVal != null)
				val = mozzVal;

			// set the style to the phantom
			//trace("set style "+styleName+" = "+val+" - "+mozzVal);
			//DomTools.inspectTrace(val);
			Reflect.setField(phantom.style, styleName, val);
		}
		//trace("initPhantomStyle "+computedStyle.position+" - "+phantom.style.position);
		phantom.className = rootElement.className + " " + phantomClassName;
	}
	/**
	 * init phantom according to root element properties
	 */
	private function resetRootElementStyle()
	{
		for (styleName in Reflect.fields(initialStyle))
		{
			var val:String = Reflect.field(initialStyle, styleName);
			Reflect.setField(rootElement.style, styleName, val);
		}
	}
	/**
	 * start dragging
	 * attach an onmousemove event to the body
	 * memorize the rootElement style values and prepare it to be moved
	 */
	private function startDrag(e:js.Event)
	{
		if (state == none)
		{
			state = dragging;
			initialX = rootElement.offsetLeft;
			initialY = rootElement.offsetTop;
			initialMouseX = e.clientX;
			initialMouseY = e.clientY;
			initPhantomStyle();
			initRootElementStyle();
			//initialStylePosition = rootElement.style.position;

			//Lib.document.onmousemove = function(e){move(e);};
			moveCallback = callback(move);
			Lib.document.body.addEventListener("mousemove", moveCallback, false);

			//rootElement.style.position = "absolute";
			move(e);

			// dispatch a custom event
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_DRAG, false, false, {
				dropZone : bestDropZone,
				target: rootElement,
				draggable: this,
			});
			rootElement.dispatchEvent(event);
		}
		// prevent default behavior
		e.preventDefault();
	}
	/**
	 * stop dragging
	 * remove the onmousemove event to the body 
	 * if there is a best drop zone, set it as the parent of the component
	 * reset the rootElement.style.position value to initial position
	 */
	public function stopDrag(e:js.Event)
	{
		if (state == dragging)
		{
			// change parent node
			if (bestDropZone != null)
			{
				rootElement.parentNode.removeChild(rootElement);
				bestDropZone.parent.insertBefore(rootElement, bestDropZone.parent.childNodes[bestDropZone.position]);
				
				// dispatch a custom event
				var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
				event.initCustomEvent(EVENT_DROPPED, false, false, {
					dropZone : bestDropZone,
					target: bestDropZone.parent
				});
				bestDropZone.parent.dispatchEvent(event);
				
			}
			// dispatch a custom event
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_DROPPED, false, false, {
				dropZone : bestDropZone,
				target: rootElement,
				draggable: this,
			});
			rootElement.dispatchEvent(event);

			// reset state
			state = none;
			//rootElement.style.position = initialStylePosition;
			resetRootElementStyle();
			Lib.document.body.removeEventListener("mousemove", moveCallback, false);
			// Leave the event, in case we miss the mouseup event (happens when the mouse leave the browser window while down)
			// Lib.document.body.removeEventListener("mouseup", mouseUpCallback, false);
			setAsBestDropZone(null);
			// prevent default behavior
			e.preventDefault();
		}
	}
	/**
	 * move during dragging
	 * move the root element
	 * look for closest drop zone if there are some
	 */
	public function move(e:js.Event)
	{
		if (state == dragging)
		{
			var x = e.clientX - initialMouseX + initialX;
			var y = e.clientY - initialMouseY + initialY;
			rootElement.style.left = x + "px";
			rootElement.style.top = y + "px";
			setAsBestDropZone(getBestDropZone(e.clientX, e.clientY));

			// dispatch a custom event
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_MOVE, false, false, {
				dropZone : bestDropZone,
				target: rootElement,
				draggable: this,
			});
			rootElement.dispatchEvent(event);

		}
	}
	/**
	 * the closest drop zone
	 */
	public function getBestDropZone(mouseX:Int, mouseY:Int):Null<DropZone>
	{
		for (zoneIdx in 0...dropZones.length)
		{
			var zone = dropZones[zoneIdx];

			// if the mouse is in the zone
			if ( mouseX > zone.offsetLeft && mouseX < zone.offsetLeft + zone.offsetWidth
				&& mouseY > zone.offsetTop && mouseY < zone.offsetTop + zone.offsetHeight )
			{
				var lastChildIdx:Int = 0;
				// browse all children to see which one is after the desired zone
				for (childIdx in 0...zone.childNodes.length){
					var child = zone.childNodes[childIdx];

					// do not take the phantom into account
					//if (child.className == PHANTOM_CLASS_NAME)
					//	continue;

					// get the child which is after the mouse
					if (mouseX > child.offsetLeft + Math.round(child.offsetWidth / 2))
					{
						lastChildIdx = childIdx;
					}
				}
				return { parent: zone, position: lastChildIdx }
			}
		}
		return null;
	}
	/**
	 * keep a reference to closest drop zone
	 * remove the "dropping" style if there was a previous best drop zone 
	 * apply the "dropping" style to the new best drop zone
	 * pass null if you need to remove the best drop zone
	 */
	public function setAsBestDropZone(zone:DropZone = null)
	{
		//DomTools.inspectTrace(zone.parent.style);
		if (zone == bestDropZone)
			return;
		
		if (bestDropZone != null)
		{
			bestDropZone.parent.removeChild(phantom);
		}
		if (zone != null)
		{
			zone.parent.insertBefore(phantom, zone.parent.childNodes[zone.position]);
		}
		bestDropZone = zone;
	}
}
