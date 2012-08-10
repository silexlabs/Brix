package org.slplayer.component.layer;

import js.Lib;
import js.Dom;

import org.slplayer.core.Application;
import org.slplayer.component.ui.DisplayObject;
import org.slplayer.component.transition.TransitionData;

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
		rootElement.onclick = onClick;
	}
	/**
	 * user clicked the link
	 * do an action to the pages corresponding to our link
	 */
	private function onClick(e:Event)
	{
		// retrieve the name of our link 
		var linkName : String;
		if ( rootElement.getAttribute(CONFIG_PAGE_NAME_ATTR) != null && rootElement.getAttribute(CONFIG_PAGE_NAME_ATTR).trim() != "" )
		{
			linkName = rootElement.getAttribute(CONFIG_PAGE_NAME_ATTR).trim();
			// removes the URL before the deep link
			linkName = linkName.substr(linkName.indexOf("#")+1);
		}
		else throw("error, the link has no href atribute ("+rootElement+")");

		trace("LinkBase onClick "+linkName+" - "+CONFIG_TRANSITION_IS_REVERSED+ " -- "+rootElement.getAttribute(CONFIG_TRANSITION_IS_REVERSED));

		// retrieve the target attr of our link 
		var targetAttr:Null<String> = null;
		if (rootElement.getAttribute(CONFIG_TARGET_ATTR) != null && rootElement.getAttribute(CONFIG_TARGET_ATTR).trim() != "")
		{
			targetAttr = rootElement.getAttribute(CONFIG_TARGET_ATTR).trim();
		}

		// values for the transition
		transitionData = new TransitionData(
			null, 
			rootElement.getAttribute(CONFIG_TRANSITION_DURATION).trim(),
			rootElement.getAttribute(CONFIG_TRANSITION_TIMING_FUNCTION).trim(),
			rootElement.getAttribute(CONFIG_TRANSITION_DELAY).trim(),
			rootElement.getAttribute(CONFIG_TRANSITION_IS_REVERSED).toLowerCase().trim() == "true"
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
