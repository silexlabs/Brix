package slplayer.ui;

import slplayer.core.SLPlayer;

import slplayer.core.SLPlayerComponent;
using slplayer.core.SLPlayerComponent;

import js.Lib;
import js.Dom;

import haxe.Template;

/**
 * Structure helping with handling the skinnable elts of a component.
 * FIXME / TODO keep this and generalize a skining sub-cmps handling logic or remove this.
 */
typedef SkinnableUIElt = 
{
	eltAttrId : String,
	elt : HtmlDom
}

/**
 * A displayObject is a UI component associated with an HTML DOM element. You declare an instance of a DisplayObject by putting
 * class="[YourDisplayObjectClassName]" in the attributes of the HTML DOM element you want to associate to.
 * 
 * In case you want to allow your component only on specific HTML tags, set the @tagNameFilter() meta tag before your component 
 * Class declaration with an array value containing the tag names, for instance:
 * 
 * @tagNameFilter("ul", "ol") class MyComponent extends DisplayObject { }
 * 
 * If you want to ensure that users of your component sets required "data-<MyCustonParam>" attributes on its HTML element, you can 
 * set the @requires() meta tag before your component Class declaration, like below : 
 * 
 * @requires(<MyCustonParam>, <MyCustonParam2>, ...) class MyComponent extends DisplayObject { }
 * 
 * @author Thomas Fétiveau
 */
class DisplayObject implements ISLPlayerComponent
{
	/**
	 * The id of the containing SLPlayer instance.
	 */
	public var SLPlayerInstanceId : String;
	/**
	 * The dom node associated with the instance of this component. By default, all events used for communication with other 
	 * components are dispatched to and listened from this DOM element.
	 */
	public var rootElement(default, null) : HtmlDom;
	
	/**
	 * Common constructor for all DisplayObjects. If there is anything specific to a given component class initialization, override the init() method.
	 * @param	rootElement
	 */
	private function new(rootElement : HtmlDom, SLPId:String) 
	{
		this.rootElement = rootElement;
		
		slplayer.core.SLPlayerComponentTools.checkFilterOnElt(Type.getClass(this), rootElement);
		
		slplayer.core.SLPlayerComponentTools.checkRequiredParameters(Type.getClass(this), rootElement);
		
		SLPlayerInstanceId = SLPId;
		
		SLPlayer.get(SLPlayerInstanceId).addAssociatedComponent(rootElement, this);
	}
	
	/**
	 * Get the containing SLPlayer instance.
	 * @return SLPlayer
	 */
	public function getSLPlayer():SLPlayer
	{
		return SLPlayer.get(SLPlayerInstanceId);
	}
	
	// --- CUSTOMIZABLE API ---
	
	/**
	 * For specific initialization logic specific to your component class, override this method.
	 */
	public dynamic function init() : Void { }
}