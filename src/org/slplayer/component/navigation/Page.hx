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
package org.slplayer.component.navigation;

import js.Lib;
import js.Dom;

import org.slplayer.component.ui.DisplayObject;
import org.slplayer.component.navigation.transition.TransitionData;
import org.slplayer.util.DomTools;
import org.slplayer.core.Application;

/**
 * This component is linked to a DOM element, which is an anchor
 * with the page name/deeplink in the name attribute and the page "displayed name"/description as a child of the node.
 * 
 * This class offers static methods to manipulate pages. Todo: decide wether the static methods should go in org.silex.util.PageTools .
 * When the page is to be opened/closed, then all the layers which have the page deeplink as a class name are shown/hidden
 */
@tagNameFilter("a")
class Page extends DisplayObject
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
	 * constant, initial page's name
	 */
	public static inline var CONFIG_INITIAL_PAGE_NAME:String = "initialPageName";
	
	/**
	 * Display name of the page.
	 * This is a name to be displayed, not used as the deeplink/anchor name
	 */
	private var displayName:String;
	/**
	 * Name of the page.
	 * This is the anchor name to be used as a link/deeplink
	 */
	private var name:String;

	/** 
	 * Open the page with the given "name" attribute
	 * This will close other pages
	 */
	static public function openPage(pageName:String, isPopup:Bool, transitionData:TransitionData, slPlayerId:String)
	{trace("openPage "+pageName);
		// find the pages to open
		var page = getPageByName(pageName, slPlayerId);
		if (page == null)
			throw("Error, could not find a page with name "+pageName);
		// open the page as a page or a popup
		page.open(transitionData, isPopup);
	}
	/** 
	 * Close the page with the given "name" attribute
	 * This will close only this page
	 */
	static public function closePage(pageName:String, transitionData:TransitionData, slPlayerId:String)
	{trace("closePage "+pageName);
		// find the pages to open
		var page = getPageByName(pageName, slPlayerId);
		if (page == null)
			throw("Error, could not find a page with name "+pageName);
		// close the page
		page.close(transitionData);
	}
	/** 
	 * Retrieve the page whose "name" attribute is pageName
	 */
	static public function getPageByName(pageName:String, slPlayerId:String):Null<Page>
	{
		// get all pages, i.e. all element with class name "page"
		var pages:HtmlCollection<HtmlDom> = Lib.document.getElementsByClassName(Page.CLASS_NAME);
		// browse all pages
		for (pageIdx in 0...pages.length)
		{
			// check if it has the desired name
			if (pages[pageIdx].getAttribute(Page.CONFIG_NAME_ATTR) == pageName)
			{
				// retrieve the Page class instance associated with this node
				var pageInstances:List<Page> = Application.get(slPlayerId).getAssociatedComponents(pages[pageIdx], Page);
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
	public function new(rootElement:HtmlDom, SLPId:String) 
	{
		super(rootElement, SLPId);
		name = rootElement.getAttribute(CONFIG_NAME_ATTR);
		if (name == null || name == "")
		{
			throw("Pages have to have a 'name' attribute");
		}
	}

	override public function init()
	{
		// close if it is not the default page
		if ( DomTools.getMeta(CONFIG_INITIAL_PAGE_NAME) == name)
		{
			var transitionData = new TransitionData(show, "0.01s"); 
			open(transitionData);
		}
	}

	/**
	 * Open this page, i.e. show all layers which have the page name in their css class attribute
	 * Also close the other pages if doCloseOthers is true
	 */
	public function open(transitionData:TransitionData = null, doCloseOthers:Bool = true) 
	{trace("open "+transitionData+" - "+name+" - "+doCloseOthers);
		if (doCloseOthers)
			closeOthers(transitionData);

		doOpen(transitionData);
	}

	/**
	 * Close all other pages
	 */
	public function closeOthers(transitionData:TransitionData = null)
	{
		// find all the pages in this application and close them
		var nodes = Lib.document.getElementsByClassName(CLASS_NAME);
		for (idxPageNode in 0...nodes.length)
		{
			var pageNode = nodes[idxPageNode];
			var pageInstances:List<Page> = getSLPlayer().getAssociatedComponents(pageNode, Page);
			for (pageInstance in pageInstances)
			{
				if (pageInstance != this)
					pageInstance.close(transitionData, [name]);
			}
		}
	}

	/**
	 * Open this page, i.e. show all layers which have the page name in their css class attribute
	 */
	public function doOpen(transitionData:TransitionData = null)
	{trace("doOpen "+transitionData+" - "+name);
		// by default no transition
		if (transitionData == null)
			transitionData = new TransitionData(show, "2s");

		// update transition type
		transitionData.type = TransitionType.show;

		// find all the layers which have the page name in their css class attribute
		var nodes = Lib.document.getElementsByClassName(name);

		// show the layers
		for (idxLayerNode in 0...nodes.length)
		{
			var layerNode = nodes[idxLayerNode];
			var layerInstances:List<Layer> = getSLPlayer().getAssociatedComponents(layerNode, Layer);
			for (layerInstance in layerInstances)
			{
					layerInstance.show(transitionData);
			}
		}

	}

	/**
	 * Close this page, i.e. hide its content
	 * Remove the children from the DOM
	 */
	public function close(transitionData:TransitionData = null, preventCloseByClassName:Null<Array<String>> = null) 
	{trace("close "+transitionData+" - "+name);
		// default transition is the one of the layer
		if (transitionData == null)
			transitionData = new TransitionData(hide, "2s");

		// update transition type
		transitionData.type = TransitionType.hide;

		// default value
		if (preventCloseByClassName==null)
			preventCloseByClassName = new Array();

		// find all the layers which have the page name in their css class attribute
		var nodes = Lib.document.getElementsByClassName(name);

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
					break;
				}
			}
			if (!hasForbiddenClass)
			{
				var layerInstances:List<Layer> = getSLPlayer().getAssociatedComponents(layerNode, Layer);
				for (layerInstance in layerInstances)
				{
					cast(layerInstance, Layer).hide(transitionData);
				}
			}
		}
	}
}
