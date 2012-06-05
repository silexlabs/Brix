package slplayer.ui;

import slplayer.core.SLPlayer;

import slplayer.core.SLPlayerComponent;
using slplayer.core.SLPlayerComponent;

import js.Lib;
import js.Dom;

import haxe.Template;

/**
 * Structure helping with handling the skinnable elts of a component.
 * TODO keep this and generalize a skining sub-cmps handling logic or remove this.
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
 * In case you want to allow your component only on specific HTML tags, set the @tagNameFilter() with an array value 
 * containing the tag names, for instance: @tagNameFilter("ul", "ol")
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
		
		if (!checkFilterOnElt(rootElement))
			throw "ERROR: cannot instantiate "+Type.getClassName(Type.getClass(this))+" on this kind of node: "+rootElement.nodeName.toLowerCase()+" (type="+rootElement.nodeType+")";
		
		SLPlayerInstanceId = SLPId;
		
		SLPlayer.get(SLPlayerInstanceId).addAssociatedComponent(rootElement, this);
	}
	
	/**
	 * Checks if a given element is allowed to be the component's rootElement against the tag filters.
	 * @param	elt: the HtmlDom to check.
	 * @return true if allowed, false if not.
	 */
	private function checkFilterOnElt( elt:HtmlDom ) : Bool
	{
		if (elt.nodeType != Lib.document.body.nodeType) //FIXME cleaner way to do this comparison ?
			return false;
		
		var tagFilter = haxe.rtti.Meta.getType(Type.getClass(this)).tagNameFilter;
		
		if ( tagFilter == null)
			return true;
		
		if ( Lambda.exists( tagFilter , function(s:Dynamic) { return elt.nodeName.toLowerCase() == Std.string(s).toLowerCase(); } ) )
			return true;
		
		return false;
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