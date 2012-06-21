package components;

import js.Lib;
import js.Dom;
import Xml;

import components.Utils;
import slplayer.ui.DisplayObject;

/**
 * PannelLayout class
 *
 */
class PannelLayout extends DisplayObject {
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
	public function new(rootElement:HtmlDom){
		super(rootElement);
		haxe.Firebug.redirectTraces();
		var _this_ = this;
		untyped __js__("window.addEventListener('resize', function(e){_this_.redraw()});");
	}
	/**
	 * init the component
	 */
	override public dynamic function init() : Void { 
		super.init();
		trace("PannelLayout init");

		// retrieve references to the elements
		header = Utils.getSingleElement(rootElement, "pannel-layout-header", false);
		body = Utils.getSingleElement(rootElement, "pannel-layout-body", true);
		footer = Utils.getSingleElement(rootElement, "pannel-layout-footer", false);

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
		trace("PannelLayout redraw");
		var bodySize:Int;
		if (isHorizontal){
			bodySize = rootElement.clientWidth;
			if (header != null){
				bodySize -= header.clientWidth;
			}
			if (footer != null){
				bodySize -= footer.clientWidth;
			}
			body.style.width = bodySize+"px";
		}
		else{
			bodySize = rootElement.clientHeight;
			if (header != null){
				bodySize -= header.clientHeight;
			}
			if (footer != null){
				bodySize -= footer.clientHeight;
			}
			body.style.height = bodySize+"px";
		}
	}
}
