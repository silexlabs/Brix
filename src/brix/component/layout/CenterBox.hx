/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.layout;

import js.Lib;
import js.Dom;
import Xml;

import brix.component.navigation.Layer;

import brix.util.DomTools;
import brix.component.ui.DisplayObject;

/**
 * CenterBox class
 * This is a component which will always be centered in its parent container
 * The position is expected to be absolute
 */
class CenterBox extends LayoutBase
{
	private var lastContainerBox:BoundingBox;
	private var lastElementBox:BoundingBox;
	
	private var leftNext:String;
	private var topNext:String;

	public function new(rootElement:HtmlDom, BrixId:String){
		super(rootElement, BrixId);
		rootElement.style.visibility="hidden";
		mapListener(rootElement, Layer.EVENT_TYPE_SHOW_START, hide, true);
	}
	private function hide(e:Event)
	{
		rootElement.style.visibility="hidden";
	}
	/**
	 * computes the size of each element
	 */
	override public function redraw(){
		if (preventRedraw){
			return;
		}
		if (rootElement.parentNode == null){
			// the page is closed
			// trace("The parent node of rootElement is null. "+rootElement.className);
		}
		else {
			// retrieve the bounding boxes
			var containerBox = DomTools.getElementBoundingBox(rootElement.parentNode);
			var elementBox = DomTools.getElementBoundingBox(rootElement);

			if (lastContainerBox == null || lastElementBox == null
				|| containerBox.w != lastContainerBox.w || containerBox.h != lastContainerBox.h 
				|| containerBox.x != lastContainerBox.x || containerBox.y != lastContainerBox.y
				|| elementBox.w != lastElementBox.w || elementBox.h != lastElementBox.h 
				|| elementBox.x != lastElementBox.x || elementBox.y != lastElementBox.y)
			{
				lastElementBox = elementBox;
				lastContainerBox = containerBox;
				// compute the centers
				var containerCenterX = containerBox.x + (containerBox.w / 2);
				var containerCenterY = containerBox.y + (containerBox.h / 2);
				var elementCenterX = elementBox.x + (elementBox.w / 2);
				var elementCenterY = elementBox.y + (elementBox.h / 2);

				// apply the offset between the 2 centers to the element
				var newPosX = rootElement.offsetLeft + (containerCenterX - elementCenterX);
				var newPosY = rootElement.offsetTop + (containerCenterY - elementCenterY);

				// move the element to the center of the container
				leftNext = Math.round(newPosX) + "px";
				topNext = Math.round(newPosY) + "px";
				DomTools.doLater(function ()
				{
					rootElement.style.visibility="visible";
					rootElement.style.left = leftNext;
					rootElement.style.top = topNext;
				}, 2);
			}
		}
		super.redraw();
	}
}
