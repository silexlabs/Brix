/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.interaction;

import js.Lib;
import js.Dom;

import brix.util.DomTools;
import brix.component.ui.DisplayObject;

import brix.component.group.IGroupable;
using brix.component.group.IGroupable.Groupable;

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
 * FIXME: Not compatible with android native browser because of custom events
 */
class Draggable extends DisplayObject, implements IGroupable
{
	/**
	 * the group element set by the Group class
	 * implementation of IGroupable
	 */
	public var groupElement:HtmlDom;

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
	private var moveCallback:MouseEvent->Void;
	/**
	 * callback used to add/remove events to the html body
	 */
	private var mouseUpCallback:MouseEvent->Void;
	/**
	 * div element used to show where the element is about to be dropped
	 */
	private var phantom:HtmlDom;
	/**
	 * div element used to compute the best drop zone
	 * it is placed at every position and its distance to mouse cursor is measured
	 */
	private var miniPhantom:HtmlDom;
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
//	public var dropZones:HtmlCollection<HtmlDom>;
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
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);

		// implementation of IGroupable
		startGroupable();
		if (groupElement == null){
			groupElement = Lib.document.body;
		}

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
		miniPhantom = Lib.document.createElement("div");

		// retrieve references to the elements
		dragZone = DomTools.getSingleElement(rootElement, CSS_CLASS_DRAGZONE, false);
		if (dragZone == null)
			dragZone = rootElement;

		// attach the events
		dragZone.addEventListener("mousedown", cast(startDrag), false);
		//dragZone.onmouseup = stopDrag;
		mouseUpCallback = callback(stopDrag);
		Lib.document.body.addEventListener("mouseup", cast(mouseUpCallback), false);
		dragZone.style.cursor = "move";
	}
	
	/**
	 * clean the component
	 */
	override public function clean() : Void
	{
		super.clean();

		dragZone.removeEventListener("mousedown", cast(startDrag), false);
		Lib.document.body.removeEventListener("mouseup", cast(mouseUpCallback), false);
	}
	
	/**
	 * set all properties of root element with absolute values 
	 */
	private function initRootElementStyle()
	{
		initialStyle = {};
		
		// set all inline styles
		for (styleName in Reflect.fields(rootElement.style))
		{
			var val:String = Reflect.field(rootElement.style, styleName);
			Reflect.setField(initialStyle, styleName, val);
			//trace("initRootElementStyle keep style "+styleName+" = "+val);
		}
		
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
	public function initPhantomStyle(refHtmlDom:HtmlDom=null)
	{
		if (refHtmlDom == null) 
			refHtmlDom = rootElement;

		// set all inline styles
		for (styleName in Reflect.fields(refHtmlDom.style))
		{
			try{
				var val:String = Reflect.field(refHtmlDom.style, styleName);
				Reflect.setField(phantom, styleName, val);
				Reflect.setField(miniPhantom, styleName, val);
				//trace("initPhantomStyle keep style "+styleName+" = "+val);
			}
			catch(e:Dynamic){
				// some properties are read only
			}
		}

		//trace("initPhantomStyle "+computedStyle.position+" - "+phantom.style.position);
		phantom.className = phantomClassName;
		miniPhantom.className = phantomClassName;

		phantom.style.width = refHtmlDom.clientWidth + "px";
		phantom.style.height = refHtmlDom.clientHeight + "px";
		miniPhantom.style.width = refHtmlDom.clientWidth + "px";
		miniPhantom.style.height = refHtmlDom.clientHeight + "px";
	}
	/**
	 * init phantom according to root element properties
	 */
	private function resetRootElementStyle()
	{
		for (styleName in Reflect.fields(initialStyle))
		{
			try{
				var val:String = Reflect.field(initialStyle, styleName);
				Reflect.setField(rootElement.style, styleName, val);
			}
			catch(e:Dynamic){
				// some properties are read only
			}
		}
	}
	/**
	 * start dragging
	 * attach an onmousemove event to the body
	 * memorize the rootElement style values and prepare it to be moved
	 */
	private function startDrag(e:MouseEvent)
	{trace("startDrag "+state);
		if (state == none)
		{
			var boundingBox = DomTools.getElementBoundingBox(rootElement);
			state = dragging;
			initialX = boundingBox.x;
			initialY = boundingBox.y;
			initialMouseX = e.clientX;
			initialMouseY = e.clientY;
			initRootElementStyle();
			initPhantomStyle();
			//initialStylePosition = rootElement.style.position;

			//Lib.document.onmousemove = function(e){move(e);};
			moveCallback = callback(move);
			Lib.document.body.addEventListener("mousemove", cast(moveCallback), false);

			//rootElement.style.position = "absolute";
			move(e);

			// dispatch event so that other components can change the phantom style
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
	public function stopDrag(e:MouseEvent)
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
					target: bestDropZone.parent,
					draggable: this,
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
			Lib.document.body.removeEventListener("mousemove", cast(moveCallback), false);
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
	public function move(e:MouseEvent)
	{trace("move");
		if (state == dragging)
		{
			// find the closest postition 
			var mouseX = e.clientX + initialX;
			var mouseY = e.clientY + initialY;
			var elementX = mouseX - initialMouseX;
			var elementY = mouseY - initialMouseY;
			setAsBestDropZone(getBestDropZone(elementX, elementY));

			// position of the dragged element under the mouse
			rootElement.style.left = elementX + "px";
			rootElement.style.top = elementY + "px";

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
		// retrieve references to the elements
		var dropZones:List<HtmlDom> = new List();
		var taggedDropZones = groupElement.getElementsByClassName(dropZonesClassName);
		for ( dzi in 0...taggedDropZones.length )
		{
			dropZones.add(taggedDropZones[dzi]);
		}
		if (dropZones.isEmpty())
		{
			dropZones.add(rootElement.parentNode);
		}

		for (zone in dropZones)
		{
			// if the mouse is in the zone
			if ( mouseX > zone.offsetLeft && mouseX < zone.offsetLeft + zone.offsetWidth
				&& mouseY > zone.offsetTop && mouseY < zone.offsetTop + zone.offsetHeight )
			{
				var lastChildIdx:Int = 0;
				var nearestDistance:Float = 999999999999;
				// browse all children to see which one is after the desired zone
				for (childIdx in 0...zone.childNodes.length)
				{
					var child = zone.childNodes[childIdx];
					// test the case before this child
					zone.insertBefore(miniPhantom, child);
					var bb = DomTools.getElementBoundingBox(miniPhantom);
					var dist = computeDistance(bb, mouseX, mouseY);
					if (dist < nearestDistance)
					{
						// new closest position
						nearestDistance = dist;
						lastChildIdx = childIdx;
					}
				}

				// test the case of the last child
				zone.appendChild(miniPhantom);
				var bb = DomTools.getElementBoundingBox(miniPhantom);
				var dist = computeDistance(bb, mouseX, mouseY);
				if (dist < nearestDistance)
				{
					nearestDistance = dist;
					lastChildIdx = zone.childNodes.length + 1;
				}
				zone.removeChild(miniPhantom);
				return { parent: zone, position: lastChildIdx }
			}
		}
		return null;
	}
	private function computeDistance(bb:BoundingBox,mouseX:Int, mouseY:Int) :Float
	{
/**/
		return Math.sqrt(
			Math.pow((bb.x)-mouseX, 2)
			+ Math.pow((bb.y)-mouseY, 2)
		);
/*
		// take the size of the dragged element in to account
//this does not work?
		var x = (bb.x+bb.w/2.0);
		var y = (bb.y+bb.h/2.0);
		return Math.sqrt(
			Math.pow(x-mouseX, 2)
			+ Math.pow(y-mouseY, 2)
		);
/**/
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
			if (zone.parent.childNodes.length <= zone.position){
				// insert after the last child
				zone.parent.appendChild(phantom);
			}
			else{
				zone.parent.insertBefore(phantom, zone.parent.childNodes[zone.position]);
			}
		}
		bestDropZone = zone;
	}
}
