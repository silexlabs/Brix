package slplayer.ui.layout;

import js.Lib;
import js.Dom;
import Xml;

import slplayer.util.DomTools;
import slplayer.ui.DisplayObject;

/**
 * Pannel class
 *
 */
class Pannel extends DisplayObject {
	static inline var CSS_CLASS_HEADER:String = "pannel-header";
	static inline var CSS_CLASS_BODY:String = "pannel-body";
	static inline var CSS_CLASS_FOOTER:String = "pannel-footer";

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
		trace("Pannel init");

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
		trace("Pannel redraw");
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
