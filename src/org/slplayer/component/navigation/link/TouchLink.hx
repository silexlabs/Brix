package org.slplayer.component.navigation.link;

import js.Lib;
import js.Dom;

import org.slplayer.component.ui.DisplayObject;
import org.slplayer.util.DomTools;

import org.slplayer.component.group.IGroupable;
using org.slplayer.component.group.IGroupable.Groupable;

enum TouchType{
	swipeLeft; 
	swipeRight; 
	swipeUp; 
	swipeDown;
	pinchOpen;
	pinchClose;
}
/**
 * this component listens to touch events and acts like the user clicked on the link when it detect a given gesture
 * when you place this component on a link node, you can provide the data-touch-type parameter with left, right, up, down (swipe) or open, close (pinch)
 */
class TouchLink extends DisplayObject, implements IGroupable{
	/**
	 * the group element set by the Group class
	 * implementation of IGroupable
	 */
	public var groupElement:HtmlDom;
	/**
	 * name of the attribute to pass the gesture type, 
	 * i.e. left, right, up, down (swipe) or in, out (pinch)
	 */
	public static inline var ATTR_TOUCH_TYPE = "data-touch-type";
	/**
	 * name of the attribute to pass the minimum gesture distance, 
	 * i.e. the distance at which we considere that a swipe or pinch has occured
	 * in pixels
	 */
	public static inline var ATTR_TOUCH_DETECT_DISTANCE = "data-touch-detection-distance";
	/**
	 * default value for the minimum gesture distance
	 * in pixels
	 */
	public static inline var DEFAULT_DETECT_DISTANCE = 200;
	/**
	 * store the detection threshold
	 * in pixels
 	 */
 	private var detectDistance:Int;
	/**
	 * store the type of gesture we are listening to
 	 */
 	private var touchType:TouchType;

	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, SLPId:String){
		super(rootElement, SLPId);
		
		// implementation of IGroupable
		startGroupable();

		// default group is document body
		var element;
		if (groupElement != null)
			element = groupElement;
		else
			element = Lib.document.body;

		// default value
		var attrStr = rootElement.getAttribute(ATTR_TOUCH_DETECT_DISTANCE);
		if (attrStr == null || attrStr == "")
			detectDistance = DEFAULT_DETECT_DISTANCE;
		else
			detectDistance = Std.parseInt(attrStr);

		// touch events
		element.addEventListener("touchmove", onTouchMove, false);
		element.addEventListener("touchstart", onTouchStart, false);
		element.addEventListener("touchend", onTouchEnd, false);
		//rootElement.addEventListener("click", onClick, false);
		//rootElement.onclick = onClick;

		// retrieve the params
		switch(rootElement.getAttribute(ATTR_TOUCH_TYPE)){
			case "left":
				touchType = swipeLeft;
			case "right":
				touchType = swipeRight;
			case "up":
				touchType = swipeUp;
			case "down":
				touchType = swipeDown;
			case "open":
				touchType = pinchOpen;
				throw("not implemented");
			case "close":
				touchType = pinchClose;
				throw("not implemented");
			default:
				throw("Error in param "+ATTR_TOUCH_TYPE+" for touch event type (requires left, right, up, down, in, out)");
		}
	}
	/**
	 * store the starting point of the gesture
	 */
	public var touchStart:{x:Int, y:Int};
	/** 
	 * callback for the touch event
	 */
	private function onTouchStart(e:Event){
		var event:TouchEvent = cast(e);
		// event.preventDefault();
		touchStart = {
			x: event.touches.item(0).screenX,
			y: event.touches.item(0).screenY
		}
		//DomTools.display("onTouchStart "+touchStart);
	}
	private function onClick(e:Event){
		trace("CLICK ");
	}
	/** 
	 * callback for the touch event
	 */
	private function onTouchMove(e:Event){
		var event:TouchEvent = cast(e);
		event.preventDefault();

		if (touchStart == null) 
			return;

		//DomTools.display("onTouchMove "+event);
		var xOffset = event.touches.item(0).screenX - touchStart.x;
		var yOffset = event.touches.item(0).screenY - touchStart.y;
		if (Math.abs(xOffset) > 200){
			touchStart = null;
			if (xOffset>0){
				if (touchType == swipeLeft){
					// DomTools.display("Left");
					dispatchClick();
				}
			}
			else{
				if (touchType == swipeRight){
					//DomTools.display("Right");
					dispatchClick();
				}
			}
		}else if (Math.abs(yOffset) > detectDistance){
			touchStart = null;
			if (yOffset>0){
				if (touchType == swipeUp){
					//DomTools.display("Up");
					dispatchClick();
				}
			}
			else{
				if (touchType == swipeDown){
					//DomTools.display("Down");
					dispatchClick();
				}
			}
		}
	}
	/** 
	 * callback for the touch event
	 */
	private function onTouchEnd(e:Event){
		var event:TouchEvent = cast(e);
		// event.preventDefault();
		//DomTools.display("onTouchEnd "+event);
		touchStart = null;
	}
	public function dispatchClick(){
		var evt = Lib.document.createEvent('MouseEvents');
		//cast(evt).initMouseEvent('click', true, true);
		evt.initEvent(
		   'click'      // event type
		   ,true      // can bubble?
		   ,true      // cancelable?
		);
		rootElement.dispatchEvent(cast(evt));
	}
}