/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.layout;

import js.html.HtmlElement;
import Xml;

import brix.util.DomTools;
import brix.component.ui.DisplayObject;

/**
 * Panel class
 * This is a component which takes html nodes as header, body and footer, 
 * and move/resize them so that only the body takes all the available room between the header and the footer
 */
class Panel extends LayoutBase
{
	/**
	 * default class name for the header
	 * it will be used if you do not specify a data-panel-header-class-name attribute
	 */
	public static inline var DEFAULT_CSS_CLASS_HEADER = "panel-header";
	/**
	 * default class name for the body
	 * it will be used if you do not specify a data-panel-body-class-name attribute
	 */
	public static inline var DEFAULT_CSS_CLASS_BODY = "panel-body";
	/**
	 * default class name for the footer
	 * it will be used if you do not specify a data-panel-footer-class-name attribute
	 */
	public static inline var DEFAULT_CSS_CLASS_FOOTER = "panel-footer";
	/**
	 * name of the attribute to pass the header css class name as a param 
	 */
	public static inline var ATTR_CSS_CLASS_HEADER = "data-panel-header-class-name";
	/**
	 * name of the attribute to pass the body css class name as a param 
	 */
	public static inline var ATTR_CSS_CLASS_BODY = "data-panel-body-class-name";
	/**
	 * name of the attribute to pass the footer css class name as a param 
	 */
	public static inline var ATTR_CSS_CLASS_FOOTER = "data-panel-footer-class-name";
	/**
	 * name of the attribute to configure if the panel is horizontal or vertical
	 * value can be "true" or "false", default is "false"
	 */
	public static inline var ATTR_IS_HORIZONTAL = "data-panel-is-horizontal";
	/**
	 * is the layer vertical or horizontal
	 * default is vertical
	 */
	public var isHorizontal:Bool;
	/**
	 * html elment instance
	 */
	public var body:HtmlElement;
	/**
	 * html elment instance
	 */
	public var header:HtmlElement;
	/**
	 * html elment instance
	 */
	public var footer:HtmlElement;

	/**
	 * constructor
	 */
	public function new(rootElement:HtmlElement, brixId:String)
	{
		super(rootElement, brixId);

		// retrieve references to the elements
		var cssClassName = rootElement.getAttribute(ATTR_CSS_CLASS_HEADER);
		if (cssClassName == null) cssClassName = DEFAULT_CSS_CLASS_HEADER;
		header = DomTools.getSingleElement(rootElement, cssClassName, false);
		if (header == null) 
		{
			trace("Warning, no header for Panel component");
		}
		
		var cssClassName = rootElement.getAttribute(ATTR_CSS_CLASS_BODY);
		if (cssClassName == null) cssClassName = DEFAULT_CSS_CLASS_BODY;
		body = DomTools.getSingleElement(rootElement, cssClassName, true);
		
		var cssClassName = rootElement.getAttribute(ATTR_CSS_CLASS_FOOTER);
		if (cssClassName == null) cssClassName = DEFAULT_CSS_CLASS_FOOTER;
		footer = DomTools.getSingleElement(rootElement, cssClassName, false);
		if (footer == null) 
		{
			trace("Warning, no footer for Panel component");
		}

		// attributes
		if (rootElement.getAttribute(ATTR_IS_HORIZONTAL) == "true")
			isHorizontal = true;
		else
			isHorizontal = false;
	}

	/**
	 * init the component
	 */
	override public function init() : Void
	{ 
		super.init();
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
			var margin = (rootElement.offsetWidth - rootElement.clientWidth);
			var bodyMargin = (body.offsetWidth - body.clientWidth);

			// init body size
			bodySize = boundingBox.w;

			// substract header size, and position the body
			if (header != null){
				var bbHeader = DomTools.getElementBoundingBox(header);
				DomTools.moveTo(body, bbHeader.w, null);
				bodySize -= bbHeader.w;
			}else{
				DomTools.moveTo(body, 0, null);
			}

			// substract largins and
			bodySize -= bodyMargin;
			bodySize -= margin;
			//bodySize -= boundingBox.x;

			if (footer != null){
				var footerMargin = (footer.offsetWidth - footer.clientWidth);
				var boundingBox = DomTools.getElementBoundingBox(footer);
				bodySize -= boundingBox.w;
				bodySize -= footerMargin;
			}
			body.style.width = bodySize+"px";
		}
		else{
			var margin = (rootElement.offsetHeight - rootElement.clientHeight);
			var bodyMargin = (body.offsetHeight - body.clientHeight);

			// init body size
			bodySize = boundingBox.h;

			// substract header size, and position the body
			if (header != null){
				var bbHeader = DomTools.getElementBoundingBox(header);
				DomTools.moveTo(body, null, bbHeader.h);
				bodySize -= bbHeader.h;
			}else{
				DomTools.moveTo(body, null, 0);
			}

			bodySize -= bodyMargin;
			bodySize -= margin;
			//bodySize -= boundingBox.y;
			// case of a pannel which parent is not positioned in absolute, does not initiate the flow 
			//bodySize += boundingBox.y;

			if (footer != null){
				var footerMargin = (footer.offsetHeight - footer.clientHeight);
				var boundingBox = DomTools.getElementBoundingBox(footer);
				bodySize -= boundingBox.h;
				bodySize -= footerMargin;
			}
			body.style.height = bodySize+"px";
		}
		super.redraw();
	}
}
