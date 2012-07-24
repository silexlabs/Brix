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
	static inline var CSS_CLASS_HEADER:String = "panel-header";
	static inline var CSS_CLASS_BODY:String = "panel-body";
	static inline var CSS_CLASS_FOOTER:String = "panel-footer";

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
		haxe.Firebug.redirectTraces();
		var _this_ = this;
		untyped __js__("window.addEventListener('resize', function(e){_this_.redraw()});");
	}
	/**
	 * init the component
	 */
	override public function init() : Void { 
		super.init();
		trace("Panel init");

		// retrieve references to the elements
		header = DomTools.getSingleElement(rootElement, CSS_CLASS_HEADER, false);
		body = DomTools.getSingleElement(rootElement, CSS_CLASS_BODY, true);
		footer = DomTools.getSingleElement(rootElement, CSS_CLASS_FOOTER, false);

		// attributes
		if (rootElement.getAttribute("data-is-horizontal") == "true")
			isHorizontal = true;
		else
			isHorizontal = false;

		// redraw
		redraw();
	}
	/**
	 * computes the size of each element
	 */
	public function redraw(dummy=null){
		trace("Panel redraw");
		var bodySize:Int;
		if (isHorizontal){
			bodySize = rootElement.clientWidth;
			if (header != null){
				bodySize -= header.clientWidth;
			}
			if (footer != null){
				bodySize -= footer.clientWidth;
			}
			body.style.width = (bodySize-1)+"px";
		}
		else{
			bodySize = rootElement.clientHeight;
			if (header != null){
				bodySize -= header.clientHeight;
			}
			if (footer != null){
				bodySize -= footer.clientHeight;
			}
			body.style.height = (bodySize-1)+"px";
		}
	}
}
