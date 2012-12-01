/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.navigation;

import js.Lib;
import js.Dom;

import brix.component.ui.DisplayObject;
import brix.component.navigation.link.LinkBase;
import brix.component.navigation.transition.TransitionData;
import brix.component.navigation.transition.TransitionObserver;
import brix.util.DomTools;
import brix.core.Application;

import brix.component.group.IGroupable;
using brix.component.group.IGroupable.Groupable;

using StringTools;


/**
 * This component is linked to a DOM element, which is an anchor
 * with the page name/deeplink in the name attribute and the page "displayed name"/description as a child of the node.
 * 
 * This class offers static methods to manipulate pages. Todo: decide wether the static methods should go in org.silex.util.PageTools .
 * When the page is to be opened/closed, then all the layers which have the page deeplink as a class name are shown/hidden
 */
@tagNameFilter("a")
class Page extends DisplayObject, implements IGroupable
{
	/**
	 * constant, name of this class
	 */
	public static inline var CLASS_NAME:String = "Page";
	/**
	 * constant, name of attribute
	 */
	public static inline var CONFIG_NAME_ATTR:String = "name";
	/**
	 * constant, use deeplink or not, meta tag
	 */
	public static inline var CONFIG_USE_DEEPLINK:String = "useDeeplink";
	/**
	 * constant, initial page name, meta tag, name attribute
	 */
	public static inline var CONFIG_INITIAL_PAGE_NAME:String = "initialPageName";
	/**
	 * constant, initial page's name data tag, on the group node
	 */
	public static inline var ATTRIBUTE_INITIAL_PAGE_NAME:String = "data-initial-page-name";
	/**
	 * css class name added to links when their corresponding page is opened
	 */
	public static inline var OPENED_PAGE_CSS_CLASS:String = "page-opened";
	/**
	 * Event fired when a page opens, before all the layers are shown
	 */
	public static inline var EVENT_TYPE_OPEN_START:String = "pageOpenStart";
	/**
	 * Event fired when a page opens, after all the layer transitions have ended
	 */
	public static inline var EVENT_TYPE_OPEN_STOP:String = "pageOpenStop";
	/**
	 * Event fired when a page closes, before all the layers are hidden
	 */
	public static inline var EVENT_TYPE_CLOSE_START:String = "pageCloseStart";
	/**
	 * Event fired when a page closes, after all the layer transitions have ended
	 */
	public static inline var EVENT_TYPE_CLOSE_STOP:String = "pageCloseStop";
	/**
	 * Name of the page.
	 * This is the anchor name to be used as a link/deeplink
	 */
	public var name(default, null):String;
	/**
	 * the group element set by the Group class
	 * implementation of IGroupable
	 */
	public var groupElement:HtmlDom;

	/** 
	 * Open the page with the given "name" attribute
	 * This will close other pages
	 */
	static public function openPage(pageName:String, isPopup:Bool, transitionDataShow:TransitionData, transitionDataHide:TransitionData, brixId:String, root:HtmlDom = null)
	{//trace("openPage ("+pageName+", "+isPopup+", "+brixId+", "+root+")");
		// default is the whole document
		var document:Dynamic = root;
		if (root == null)
			document = Lib.document.documentElement;

		// find the pages to open
		var page = getPageByName(pageName, brixId, document);
		if (page == null)
		{
			// look in the main application
			page = getPageByName(pageName, brixId);
			if (page == null)
				throw("Error, could not find a page with name "+pageName);
		}
		// open the page as a page or a popup
		page.open(transitionDataShow, transitionDataHide, !isPopup);
	}

	/** 
	 * Close the page with the given "name" attribute
	 * This will close only this page
	 */
	static public function closePage(pageName:String, transitionData:TransitionData, brixId:String, root:HtmlDom = null)
	{ //trace("closePage "+pageName+" root="+root);
		// default is the whole document
		var document:Dynamic = root;
		if (root == null)
			document = Lib.document.documentElement;

		// find the pages to open
		var page = getPageByName(pageName, brixId, document);
		if (page == null)
		{
			// look in the main application
			page = getPageByName(pageName, brixId);
			if (page == null)
				throw("Error, could not find a page with name "+pageName);
		}
		// close the page
		page.close(transitionData);
	}

	/** 
	 * Retrieve all the pages of this application or group
	 */
	static public function getPageNodes(brixId:String, root:HtmlDom = null):HtmlCollection<HtmlDom>
	{
		// default is the hole document
		var document:HtmlDom = root;
		if (root == null)
		{
			document = Lib.document.documentElement;
		}
		// get all pages, i.e. all elements with class name "Page"
		return document.getElementsByClassName(Page.CLASS_NAME);
	}

	/** 
	 * Retrieve the page whose "name" attribute is pageName
	 */
	static public function getPageByName(pageName:String, brixId:String, root:HtmlDom = null):Null<Page>
	{
		// default is the hole document
		var document:Dynamic = root;
		if (root == null)
			document = Lib.document.documentElement;

		// get all pages, i.e. all element with class name "page"
		var pages:HtmlCollection<HtmlDom> = getPageNodes(brixId, document);
		// browse all pages
		for (pageIdx in 0...pages.length)
		{
			// check if it has the desired name
			if (pages[pageIdx].getAttribute(Page.CONFIG_NAME_ATTR) == pageName)
			{
				// retrieve the Page class instance associated with this node
				var pageInstances:List<Page> = Application.get(brixId).getAssociatedComponents(pages[pageIdx], Page);
				for (page in pageInstances)
				{
					return page;
				}
				return null;
			}
		}
		return null;
	}

	/**
	 * constructor
	 * Init the attributes
	 * Close the page
	 */
	public function new(rootElement:HtmlDom, brixId:String) 
	{
		super(rootElement, brixId);

		// implementation of IGroupable
		startGroupable();
		// group element is body element by default
		if (groupElement == null)
		{
			groupElement = Lib.document.body; // FIXME shouldn't it be getBrixApplication().htmlRootElement ?
		}
		name = rootElement.getAttribute(CONFIG_NAME_ATTR);
		if (name == null || name.trim() == "")
		{
			throw("Pages must have a 'name' attribute");
		}
		// listen to the history api changes
		Lib.window.addEventListener("popstate", onPopState, true);
	}

	/** 
	 * callback for the history api
	 */
	private function onPopState(e:Event)
	{
		// get the typed event object
		var event:PopStateEvent = cast(e);
		if (event.state != null && event.state.name == name){
			trace("onPopState "+event.state.name);
			open(event.state.transitionDataShow, event.state.transitionDataHide, event.state.doCloseOthers, event.state.preventTransitions, false);

		}
	}
	/** 
	 * init the brix component
	 */
	override public function init()
	{
		super.init();

// workaround window.location not yet implemented in cocktail
#if js
		// open if it is the page in history
		if ((DomTools.getMeta(CONFIG_USE_DEEPLINK) == null || DomTools.getMeta(CONFIG_USE_DEEPLINK) == "true")
			&& Lib.window.history.state != null)
		{
			if (Lib.window.history.state.name == name)
			{
				trace("open the recent history");
				open(null, null, true, true, false);
			}
		}
		// open if it is the page in the deeplink
		else if (StringTools.startsWith(Lib.window.location.search, "?/"))
		{
			if (Lib.window.location.search.substr(2) == name)
			{
				trace("open the deeplink");
				open(null, null, true, true);
			}
		}
		// open if it is the default page and there is no deeplink nor history
		else 
#end
		if (DomTools.getMeta(CONFIG_INITIAL_PAGE_NAME) == name 
			|| groupElement.getAttribute(ATTRIBUTE_INITIAL_PAGE_NAME) == name )
		{
			trace("open the default page");
			open(null, null, true, true);
		}
	}
	/** 
	 * Set the name attribute of the page, i.e. change the name attribute on rootElement
	 */
	public function setPageName(newPageName:String):String
	{
		rootElement.setAttribute(CONFIG_NAME_ATTR, newPageName);
		name = newPageName;
		return newPageName;
	}
	/**
	 * Open this page, i.e. show all layers which have the page name in their css class attribute
	 * Also close the other pages if doCloseOthers is true
	 */
	public function open(transitionDataShow:TransitionData = null, transitionDataHide:TransitionData = null, doCloseOthers:Bool = true, preventTransitions:Bool = false, recordInHistory:Bool=true) 
	{ //trace("open - "+doCloseOthers+" - name="+name+" - "+preventTransitions);
		if (doCloseOthers)
		{
			closeOthers(transitionDataHide, preventTransitions);
		}
		doOpen(transitionDataShow, preventTransitions);

		// history API
		if (recordInHistory && (DomTools.getMeta(CONFIG_USE_DEEPLINK) == null || DomTools.getMeta(CONFIG_USE_DEEPLINK) == "true"))
		{
			Lib.window.history.pushState({
					name: name,
					transitionDataShow: transitionDataShow,
					transitionDataHide: transitionDataHide,
					doCloseOthers: doCloseOthers,
					preventTransitions: preventTransitions,
				}, name, "?/"+name);
		} 
	}

	/**
	 * Close all other pages
	 */
	public function closeOthers(transitionData:TransitionData = null, preventTransitions:Bool = false)
	{ //trace("closeOthers("+transitionData+") - "+preventTransitions);
		// find all the pages in this application and close them
		var nodes = getPageNodes(brixInstanceId, groupElement);
		for (idxPageNode in 0...nodes.length)
		{
			var pageNode = nodes[idxPageNode];
			var pageInstances:List<Page> = getBrixApplication().getAssociatedComponents(pageNode, Page);
			for (pageInstance in pageInstances)
			{
				if (pageInstance != this)
				{ //trace("closing "+pageInstance.name);
					pageInstance.close(transitionData, [name], preventTransitions);
				}
			}
		}
	}

	/**
	 * Open this page, i.e. show all layers which have the page name in their css class attribute
	 * 
	 */
	public function doOpen(transitionData:TransitionData = null, preventTransitions:Bool = false)
	{// trace("doOpen "+transitionData+", "+name+" - "+preventTransitions);

		var transitionObserver = new TransitionObserver(this, EVENT_TYPE_OPEN_START, EVENT_TYPE_OPEN_STOP);

		// find all the layers which have the page name in their css class attribute
		var nodes = Layer.getLayerNodes(name, brixInstanceId, groupElement);

		// show the layers
		for (idxLayerNode in 0...nodes.length)
		{
			var layerNode = nodes[idxLayerNode];
			var layerInstances:List<Layer> = getBrixApplication().getAssociatedComponents(layerNode, Layer);
			for (layerInstance in layerInstances)
			{
					layerInstance.show(transitionData, transitionObserver, preventTransitions);
			}
		}
		// add the page-opened css style on links to this page
		var nodes = DomTools.getElementsByAttribute(groupElement, LinkBase.CONFIG_PAGE_NAME_ATTR, name);
		for (idxLayerNode in 0...nodes.length)
		{
			var element = nodes[idxLayerNode];
			DomTools.addClass(element, OPENED_PAGE_CSS_CLASS);
		}
		var nodes = DomTools.getElementsByAttribute(groupElement, LinkBase.CONFIG_PAGE_NAME_ATTR, "#"+name);
		for (idxLayerNode in 0...nodes.length)
		{
			var element = nodes[idxLayerNode];
			DomTools.addClass(element, OPENED_PAGE_CSS_CLASS);
		}
	}

	/**
	 * Close this page, i.e. hide its content
	 * Remove the children from the DOM
	 */
	public function close(transitionData:TransitionData = null, preventCloseByClassName:Null<Array<String>> = null, preventTransitions:Bool = false) 
	{
		var transitionObserver = new TransitionObserver(this, EVENT_TYPE_CLOSE_START, EVENT_TYPE_CLOSE_STOP);

		// default value
		if (preventCloseByClassName == null)
		{
			preventCloseByClassName = new Array();
		}
		// find all the layers which have the page name in their css class attribute
		var nodes = Layer.getLayerNodes(name, brixInstanceId, groupElement);

		// browse the layers
		for (idxLayerNode in 0...nodes.length)
		{
			var layerNode = nodes[idxLayerNode];
			// do not hide if it has a forbidden class
			var hasForbiddenClass = false;
			for (className in preventCloseByClassName)
			{
				if (DomTools.hasClass(layerNode, className))
				{
					hasForbiddenClass = true;
				}
			}
			if (!hasForbiddenClass)
			{
				var layerInstances:List<Layer> = getBrixApplication().getAssociatedComponents(layerNode, Layer);
				for (layerInstance in layerInstances)
				{
					cast(layerInstance, Layer).hide(transitionData, transitionObserver, preventTransitions);
				}
			}
		}
		// remove the page-opened css style on links to this page
		var nodes = DomTools.getElementsByAttribute(groupElement, LinkBase.CONFIG_PAGE_NAME_ATTR, name);
		for (idxLayerNode in 0...nodes.length)
		{
			var element = nodes[idxLayerNode];
			DomTools.removeClass(element, OPENED_PAGE_CSS_CLASS);
		}
		var nodes = DomTools.getElementsByAttribute(groupElement, LinkBase.CONFIG_PAGE_NAME_ATTR, "#" + name);
		for (idxLayerNode in 0...nodes.length)
		{
			var element = nodes[idxLayerNode];
			DomTools.removeClass(element, OPENED_PAGE_CSS_CLASS);
		}
	}
}
