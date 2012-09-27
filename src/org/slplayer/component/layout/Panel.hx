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
package org.slplayer.component.layout;

import js.Lib;
import js.Dom;
import Xml;

import org.slplayer.util.DomTools;
import org.slplayer.component.ui.DisplayObject;

/**
 * Panel class
 *
 */
class Panel extends DisplayObject
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
	public var body:HtmlDom;
	/**
	 * html elment instance
	 */
	public var header:HtmlDom;
	/**
	 * html elment instance
	 */
	public var footer:HtmlDom;
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, SLPId:String){
		super(rootElement, SLPId);
		var _this_ = this;

		Lib.window.addEventListener('resize', callback(redrawCallback), false);

		// do not work: Lib.document.addEventListener("resize", redraw, false);
		// do not compile: Lib.window.addEventListener("resize", redraw, false);
		// yes but only 1 instance can listen: Lib.window.onresize = redraw;
	}
	/**
	 * init the component
	 */
	override public function init() : Void { 
		super.init();

		// retrieve references to the elements
		var cssClassName = rootElement.getAttribute(ATTR_CSS_CLASS_HEADER);
		if (cssClassName == null) cssClassName = DEFAULT_CSS_CLASS_HEADER;
		header = DomTools.getSingleElement(rootElement, cssClassName, false);
		if (header == null) trace("Warning, no header for Panel component");
		
		var cssClassName = rootElement.getAttribute(ATTR_CSS_CLASS_BODY);
		if (cssClassName == null) cssClassName = DEFAULT_CSS_CLASS_BODY;
		body = DomTools.getSingleElement(rootElement, cssClassName, true);
		
		var cssClassName = rootElement.getAttribute(ATTR_CSS_CLASS_FOOTER);
		if (cssClassName == null) cssClassName = DEFAULT_CSS_CLASS_FOOTER;
		footer = DomTools.getSingleElement(rootElement, cssClassName, false);
		if (footer == null) trace("Warning, no footer for Panel component");

		// attributes
		if (rootElement.getAttribute(ATTR_IS_HORIZONTAL) == "true")
			isHorizontal = true;
		else
			isHorizontal = false;

		// redraw
		DomTools.doLater(redraw);
	}
	/**
	 * call redraw when an event occures
	 */
	public function redrawCallback(e:Event){
		redraw();
	}

	/**
	 * computes the size of each element
	 */
	public function redraw(){
		var bodySize:Int;
		var boundingBox = DomTools.getElementBoundingBox(rootElement);
		if (isHorizontal){
			var margin = (rootElement.offsetWidth - rootElement.clientWidth);
			var bodyMargin = (body.offsetWidth - body.clientWidth);

			bodySize = boundingBox.w;
			bodySize += bodyMargin;
			bodySize -= margin;
			bodySize -= body.offsetLeft;

			if (footer != null){
				var footerMargin = (footer.offsetWidth - footer.clientWidth);
				var boundingBox = DomTools.getElementBoundingBox(footer);
				bodySize -= boundingBox.w;
				bodySize -= footerMargin;
			}
			bodySize-=5;
			body.style.width = bodySize+"px";
		}
		else{
			var margin = (rootElement.offsetHeight - rootElement.clientHeight);
			var bodyMargin = (body.offsetHeight - body.clientHeight);

			if (header != null){
				body.style.top = header.offsetHeight + "px";
			}

			bodySize = boundingBox.h;
			bodySize += bodyMargin;
			bodySize -= margin;
			bodySize -= body.offsetTop;
			// case of a pannel which parent is not positioned in absolute, does not initiate the flow 
			bodySize += boundingBox.y;

			if (footer != null){
				var footerMargin = (footer.offsetHeight - footer.clientHeight);
				var boundingBox = DomTools.getElementBoundingBox(footer);
				bodySize -= boundingBox.h;
				bodySize -= footerMargin;
			}
			bodySize-=5;
			body.style.height = bodySize+"px";
		}
	}
}
