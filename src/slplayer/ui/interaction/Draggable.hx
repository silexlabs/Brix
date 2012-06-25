package slplayer.ui.interaction;

import js.Lib;
import js.Dom;

import slplayer.util.DomTools;
import slplayer.ui.DisplayObject;

enum DraggableState {
	none;
	dragging;
}
typedef DropZone = {
	parent:HtmlDom,
	position:Int,
}

/**
 * Draggable class
 * Attache mouse events to a "drag zone" and make it drag/drop the "Draggable" node
 * If drop zones are provided, display the best drop zone found and enable only these zones to be parents
 * define the drop zones with a "drop-zone" class name on the elements, or by setting the dropZones attribute
 */
class Draggable extends DisplayObject {
	static inline var CSS_CLASS_DRAGZONE:String = "draggable-dragzone";
	static inline var CSS_CLASS_DROPZONE:String = "draggable-dropzone";
	static inline var CSS_CLASS_PHANTOM:String = "draggable-phantom";

	static inline var ATTR_DROPZONE:String = "data-dropzones-class-name";
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
	 * class name to define drop zones
	 * @default	dropzone 
	 */
	public var dropZonesClassName:String;
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
	public function new(rootElement:HtmlDom, SLPId:String){
		super(rootElement, SLPId);

		// init
		state = none;

		// retrieve atribute of the html dom node 
		dropZonesClassName = rootElement.getAttribute(ATTR_DROPZONE);

		// default value
		if (dropZonesClassName == null || dropZonesClassName == "")
			dropZonesClassName = CSS_CLASS_DROPZONE;
	}
	/**
	 * init the component
	 */
	override public function init() : Void { 
		super.init();
		trace("Draggable init");

		// create the phantom
		phantom = Lib.document.createElement("div");

		// retrieve references to the elements
		dragZone = DomTools.getSingleElement(rootElement, "draggable-dragzone", false);
		if (dragZone == null)
			dragZone = rootElement;

		// retrieve references to the elements
		dropZones = DomTools.getElementsByClassName(Lib.document.body, dropZonesClassName);
		if (dropZones.length == 0)
			dropZones[0] = rootElement.parentNode;

		// attach the events
		dragZone.onmousedown = startDrag;
		Lib.document.body.onmouseup = stopDrag;
		dragZone.style.cursor = "move";
	}
	/**
	 * set all properties of root element with absolute values 
	 */
	private function initRootElementStyle(){
		initialStyle = {};
/*		for (styleName in Reflect.fields(rootElement.style)){
			var val:String = Reflect.field(rootElement.style, styleName);
			Reflect.setField(initialStyle, styleName, val);
			trace("initRootElementStyle keep style "+styleName+" = "+val);
		}*/
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
	private function initPhantomStyle(){

		var computedStyle:Style = untyped __js__("window.getComputedStyle(this.rootElement, null)");
		trace("initPhantomStyle "+computedStyle);

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
		phantom.className = rootElement.className + " " + CSS_CLASS_PHANTOM;
	}
	/**
	 * init phantom according to root element properties
	 */
	private function resetRootElementStyle(){
		for (styleName in Reflect.fields(initialStyle)){
			var val:String = Reflect.field(initialStyle, styleName);
			Reflect.setField(rootElement.style, styleName, val);
		}
	}
	/**
	 * start dragging
	 * attach an onmousemove event to the body
	 * memorize the rootElement style values and prepare it to be moved
	 */
	private function startDrag(e:js.Event){
		trace("Draggable startDrag "+state);
		if (state == none){
			state = dragging;
			initialX = rootElement.offsetLeft;
			initialY = rootElement.offsetTop;
			initialMouseX = e.clientX;
			initialMouseY = e.clientY;
			initPhantomStyle();
			initRootElementStyle();
			//initialStylePosition = rootElement.style.position;

			Lib.document.body.onmousemove = move;
//			rootElement.style.position = "absolute";
		}
	}
	/**
	 * stop dragging
	 * remove the onmousemove event to the body 
	 * if there is a best drop zone, set it as the parent of the component
	 * reset the rootElement.style.position value to initial position
	 */
	public function stopDrag(e:js.Event){
		if (state == dragging){
			//trace("Draggable stopDrag droped! "+initialStylePosition);
			// change parent node
			if (bestDropZone != null){
				rootElement.parentNode.removeChild(rootElement);
				bestDropZone.parent.insertBefore(rootElement, bestDropZone.parent.childNodes[bestDropZone.position]);
				trace("Draggable stopDrag droped! "+state);
			}
			// reset state
			state = none;
			//rootElement.style.position = initialStylePosition;
			resetRootElementStyle();
			Lib.document.body.onmousemove = null;
			setAsBestDropZone(null);
		}
	}
	/**
	 * move during dragging
	 * move the root element 
	 * look for closest drop zone if there are some
	 */
	public function move(e:js.Event){
		//trace("Draggable move "+state);
		if (state == dragging){
			var x = e.clientX - initialMouseX + initialX;
			var y = e.clientY - initialMouseY + initialY;
			rootElement.style.left = x + "px";
			rootElement.style.top = y + "px";
			setAsBestDropZone(getBestDropZone(e.clientX, e.clientY));
		}
	}
	/**
	 * the closest drop zone
	 */
	public function getBestDropZone(mouseX:Int, mouseY:Int):Null<DropZone>{
		for (zoneIdx in 0...dropZones.length){
			var zone = dropZones[zoneIdx];

			// if the mouse is in the zone
			if (mouseX > zone.offsetLeft && mouseX < zone.offsetLeft + zone.offsetWidth
				&& mouseY > zone.offsetTop && mouseY < zone.offsetTop + zone.offsetHeight
			){
				var lastChildIdx:Int = 0;
				// browse all children to see which one is after the desired zone
				for (childIdx in 0...zone.childNodes.length){
					var child = zone.childNodes[childIdx];

					// do not take the phantom into account
//					if (child.className == PHANTOM_CLASS_NAME)
//						continue;

					// get the child which is after the mouse
					if (mouseX > child.offsetLeft + Math.round(child.offsetWidth/2)){
						lastChildIdx = childIdx;
					}
				}
				return {
					parent: zone,
					position: lastChildIdx,
				}
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
	public function setAsBestDropZone(zone:DropZone=null){
		//trace("setAsBestDropZone "+zone.parent.style);
		//DomTools.inspectTrace(zone.parent.style);
		if (zone == bestDropZone)
			return;
		if(bestDropZone != null){
			bestDropZone.parent.removeChild(phantom);
		}
		if (zone != null){
			zone.parent.insertBefore(phantom, zone.parent.childNodes[zone.position]);
		}
		bestDropZone = zone;
	}
}
