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

import brix.util.DomTools;
import brix.component.ui.DisplayObject;

/**
 * CenterBox class
 * This is a component which will always be centered in its parent container
 * The position is expected to be absolute
 */
class CenterBox extends LayoutBase
{
	/**
	 * computes the size of each element
	 */
	override public function redraw(){
		if (preventRedraw){
			return;
		}
		if (rootElement.parentNode == null){
			throw("The parent node of rootElement is null.");
		}
		// retrieve the bounding boxes
		var containerBox = DomTools.getElementBoundingBox(rootElement.parentNode);
		var elementBox = DomTools.getElementBoundingBox(rootElement);

		// compute the centers
		var containerCenterX = containerBox.x + (containerBox.w / 2);
		var containerCenterY = containerBox.y + (containerBox.h / 2);
		var elementCenterX = elementBox.x + (elementBox.w / 2);
		var elementCenterY = elementBox.y + (elementBox.h / 2);

		// apply the offset between the 2 centers to the element
		var newPosX = rootElement.offsetLeft + (containerCenterX - elementCenterX);
		var newPosY = rootElement.offsetTop + (containerCenterY - elementCenterY);

		// move the element to the center of the container
		rootElement.style.left = Math.round(newPosX) + "px";
		rootElement.style.top = Math.round(newPosY) + "px";

		super.redraw();
	}
}
