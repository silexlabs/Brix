package components;

import js.Lib;
import js.Dom;

import components.Utils;
import slplayer.ui.DisplayObject;

enum DragableState {
	none;
	dragging;
}
typedef DropZone = {
	parent:HtmlDom,
	position:Int,
}

/**
 * Dragable class
 * Attache mouse events to a "drag zone" and make it drag/drop the "dragable" node
 * If drop zones are provided, display the best drop zone found and enable only these zones to be parents
 * define the drop zones with a "drop-zone" class name on the elements, or by setting the dropZones attribute
 */
class Dragable extends DisplayObject {
	static inline var PHANTOM_CLASS_NAME:String = "dragable-phantom";
	static inline var DROPZONE_ATTR:String = "data-dropzones-class-name";
	/**
	 * div element used to show where the element is about to be dropped
	 */
	private var phantom:HtmlDom;
	/**
	 * state of the dragable element (none, dragging)
	 */
	private var state:DragableState;
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
	 * initial value of style.position of the root element 
	 * @default	dropzone 
	 */
//	public var initialStylePosition:String;
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
	public function new(rootElement:HtmlDom){
		super(rootElement);

		// init
		state = none;

		// retrieve atribute of the html dom node 
		dropZonesClassName = rootElement.getAttribute(DROPZONE_ATTR);

		// default value
		if (dropZonesClassName == null || dropZonesClassName == "")
			dropZonesClassName = "dropzone";
	}
	/**
	 * init the component
	 */
	override public dynamic function init() : Void { 
		super.init();
		trace("Dragable init");

		// create the phantom
		phantom = Lib.document.createElement("div");

		// retrieve references to the elements
		dragZone = Utils.getSingleElement(rootElement, "dragzone", false);
		if (dragZone == null)
			dragZone = rootElement;

		// retrieve references to the elements
		dropZones = Utils.getElementsByClassName(Lib.document.body, dropZonesClassName);
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
		rootElement.style.width = rootElement.clientWidth + "px";
		rootElement.style.height = rootElement.clientHeight + "px";
		rootElement.style.position="absolute";
	}
	/**
	 * init phantom according to root element properties
	 */
	private function initPhantomStyle(){
/*		for (prop in Reflect.fields(rootElement)){
			trace("set "+prop+" = "+Reflect.field(rootElement, prop));
			//Reflect.setField(phantom, prop, Reflect.field(rootElement, prop));
		}
/*		for (styleName in Reflect.fields(rootElement.style)){
			trace("set style "+styleName+" = "+Reflect.field(rootElement.style, styleName));
			Reflect.setField(phantom.style, styleName, Reflect.field(rootElement.style, styleName));
		}
*/
// use currentStyle ?
//		trace(""+rootElement.currentStyle);
		// FIXME: use computed style of rootElement instead of absolute values
		phantom.style.width = rootElement.clientWidth + "px";
		phantom.style.height = rootElement.clientHeight + "px";
//		phantom.style.width = rootElement.style.width;
//		phantom.style.height = rootElement.style.height;
		phantom.className = PHANTOM_CLASS_NAME;

//		phantom.style.position="static";
		phantom.style.display="block";
		phantom.style.cssFloat = "left";
	}
	/**
	 * init phantom according to root element properties
	 */
	private function resetRootElementStyle(){
		for (styleName in Reflect.fields(phantom.style))
			Reflect.setField(rootElement.style, styleName, Reflect.field(phantom.style, styleName));
	}
	/**
	 * start dragging
	 * attach an onmousemove event to the body
	 * memorize the rootElement style values and prepare it to be moved
	 */
	private function startDrag(e:js.Event){
		trace("Dragable startDrag "+state);
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
			//trace("Dragable stopDrag droped! "+initialStylePosition);
			// change parent node
			if (bestDropZone != null){
				rootElement.parentNode.removeChild(rootElement);
				bestDropZone.parent.insertBefore(rootElement, bestDropZone.parent.childNodes[bestDropZone.position]);
				trace("Dragable stopDrag droped! "+state);
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
//		trace("Dragable move "+state);
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
