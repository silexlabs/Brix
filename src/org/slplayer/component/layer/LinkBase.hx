package org.slplayer.component.layer;

import js.Lib;
import js.Dom;

import org.slplayer.core.Application;
import org.slplayer.component.ui.DisplayObject;
import org.slplayer.component.transition.TransitionData;
import org.slplayer.util.DomTools;

using StringTools;

/**
 * Base class for the links components
 * Retrieve the href attribute and make an action on the pages which node has the targetted class name
 */
@tagNameFilter("a")
class LinkBase extends DisplayObject
{
	/**
	 * constant, name of attribute href
	 */
	public static inline var CONFIG_PAGE_NAME_ATTR:String = "href";
	/**
	 * constant, name of attribute target
	 */
	public static inline var CONFIG_TARGET_ATTR:String = "target";
	/**
	 * constant, name of attribute
	 * defines the param for the transition
	 */
	public static inline var CONFIG_TRANSITION_DURATION:String = "data-transition-duration";
	/**
	 * constant, name of attribute
	 * defines the param for the transition
	 */
	public static inline var CONFIG_TRANSITION_TIMING_FUNCTION:String = "data-transition-timing-function";
	/**
	 * constant, name of attribute
	 * defines the param for the transition
	 * @example	 &lt;a href=&quot;#page2&quot; class=&quot;LinkToPage next&quot; data-transition-delay = &quot;2s&quot; &gt;Test link&lt;/a&gt;
	 */
	public static inline var CONFIG_TRANSITION_DELAY:String = "data-transition-delay";
	/**
	 * constant, name of attribute
	 * defines the param for the transition
	 * @example 	true
	 * @example 	false
	 */
	public static inline var CONFIG_TRANSITION_IS_REVERSED:String = "data-transition-is-reversed";
	/**
	 * value of the href attribute without the #
	 */
	public var linkName:String;
	/**
	 * value of the target attribute 
	 */
	public var targetAttr:Null<String>;
	/**
	 * store the html attribute value
	 * determines which transition to apply 
	 */
	public var transitionData:TransitionData;

	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);
		rootElement.addEventListener("click", onClick, false);

		// retrieve the name of our link 
		if (rootElement.getAttribute(CONFIG_PAGE_NAME_ATTR) != null){
			linkName = rootElement.getAttribute(CONFIG_PAGE_NAME_ATTR).trim();
			// removes the URL before the deep link
			linkName = linkName.substr(linkName.indexOf("#")+1);
		}
		else {
			trace("Warning: the link has no href atribute ("+rootElement+")");
		}
		// retrieve the target attr of our link 
		if (rootElement.getAttribute(CONFIG_TARGET_ATTR) != null){
			targetAttr = rootElement.getAttribute(CONFIG_TARGET_ATTR).trim();
		}
	}
	/**
	 * user clicked the link
	 * do an action to the pages corresponding to our link
	 */
	private function onClick(e:Event)
	{
		// values for the transition
		transitionData = new TransitionData(
			null, 
			rootElement.getAttribute(CONFIG_TRANSITION_DURATION),
			rootElement.getAttribute(CONFIG_TRANSITION_TIMING_FUNCTION),
			rootElement.getAttribute(CONFIG_TRANSITION_DELAY),
			rootElement.getAttribute(CONFIG_TRANSITION_IS_REVERSED) == null
		);

		// show the page with this name
		linkToPagesWithName(linkName, targetAttr);
	}

	/** 
	 * retrieve the pages with linkName in their css style class name
	 */
	private function linkToPagesWithName(linkName:String, targetAttr:Null<String> = null)
	{
		// get all pages, i.e. all element with class name "page"
		var pages:HtmlCollection<HtmlDom> = Lib.document.getElementsByClassName(Page.CLASS_NAME);
		// browse all pages
		for (pageIdx in 0...pages.length)
		{
			// check if it has the desired name
			if (pages[pageIdx].getAttribute(Page.CONFIG_NAME_ATTR) == linkName)
			{
				// retrieve the Page class instance associated with this node
				var pageInstances:List<Page> = getSLPlayer().getAssociatedComponents(pages[pageIdx], Page);
				for (page in pageInstances)
				{
					// link to the page
					linkToPage(page, targetAttr);
				}
				return;
			}
		}
	}

	/**
	 * virtual method, to be implemented in the derived classes
	 */
	private function linkToPage(page:Page, targetAttr:Null<String> = null) { }
}
