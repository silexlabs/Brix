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
 * Accordion class
 * This is a component which takes html nodes as header and items, 
 * and move/resize them so that the body elements have the size of the container minus the header elements
 * Use with LinkToPage as headers and build an accordion UI with it
 */
class Accordion extends LayoutBase
{
	/**
	 * default class name for the header
	 */
	public static inline var DEFAULT_CSS_CLASS_HEADER = "accordion-header";
	/**
	 * default class name for the items
	 */
	public static inline var DEFAULT_CSS_CLASS_ITEM = "accordion-item";
	/**
	 * name of the attribute to configure if the accordion is horizontal or vertical
	 * value can be "true" or "false", default is "false"
	 */
	public static inline var ATTR_IS_HORIZONTAL = "data-accordion-is-horizontal";
	/**
	 * is the layer vertical or horizontal
	 * default is vertical
	 */
	public var isHorizontal:Bool;
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, BrixId:String){
		super(rootElement, BrixId);
	}
	/**
	 * init the component
	 */
	override public function init() : Void { 
		super.init();

		// attributes
		if (rootElement.getAttribute(ATTR_IS_HORIZONTAL) == "true")
			isHorizontal = true;
		else
			isHorizontal = false;
	}
	/**
	 * computes the size of each element
	 */
	override public function redraw(){
		if (preventRedraw){
			return;
		}

		var bodySize:Int;
		var boundingBox = DomTools.getElementBoundingBox(rootElement);
		if (isHorizontal){
			// init body size
			bodySize = boundingBox.w;
			
			var margin = (rootElement.offsetWidth - rootElement.clientWidth);
			bodySize -= margin;

			// compute body size by adding all headers size
			var elements = rootElement.getElementsByClassName(DEFAULT_CSS_CLASS_HEADER);
			if (elements == null || elements.length == 0){
				throw("No headers found for the accordion.");
			}
			for (idx in 0...elements.length){
				var element = elements[idx];
				bodySize -= element.offsetWidth;
				var margin = (element.offsetWidth - element.clientWidth);
				bodySize -= margin;
				// adjust to prevent approximations problems (size which increases after each redraw?)
				//bodySize-=5;
			}
			// apply body size to all body elements
			var elements = rootElement.getElementsByClassName(DEFAULT_CSS_CLASS_ITEM);
			for (idx in 0...elements.length){
				var element = elements[idx];
				var margin = (element.offsetWidth - element.clientWidth);
				element.style.width = (bodySize-margin)+"px";
			}
		}
		else{
			// init body size
			bodySize = boundingBox.h;
			
			var margin = (rootElement.offsetHeight - rootElement.clientHeight);
			bodySize -= margin;

			// compute body size by adding all headers size
			var elements = rootElement.getElementsByClassName(DEFAULT_CSS_CLASS_HEADER);
			if (elements == null || elements.length == 0){
				throw("No headers found for the accordion.");
			}
			for (idx in 0...elements.length){
				var element = elements[idx];
				bodySize -= element.offsetHeight;
				var margin = (element.offsetHeight - element.clientHeight);
				bodySize -= margin;
				// adjust to prevent approximations problems (size which increases after each redraw?)
				//bodySize-=5;
			}
			// apply body size to all body elements
			var elements = rootElement.getElementsByClassName(DEFAULT_CSS_CLASS_ITEM);
			for (idx in 0...elements.length){
				var element = elements[idx];
				var margin = (element.offsetHeight - element.clientHeight);
				element.style.height = (bodySize-margin)+"px";
			}
		}

		super.redraw();
	}
}
