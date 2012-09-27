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
import org.slplayer.component.navigation.link.LinkBase;
import org.slplayer.component.navigation.transition.TransitionData;
import org.slplayer.util.DomTools;
import org.slplayer.core.Application;

import org.slplayer.component.group.IGroupable;
using org.slplayer.component.group.IGroupable.Groupable;

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
	static public function openPage(pageName:String, isPopup:Bool, transitionDataShow:TransitionData, transitionDataHide:TransitionData, slPlayerId:String, root:HtmlDom = null)
	{//trace("openPage ("+pageName+", "+isPopup+", "+slPlayerId+", "+root+")");
		// default is the whole document
		var document:Dynamic = root;
		if (root == null)
			document = Lib.document.documentElement;

		// find the pages to open
		var page = getPageByName(pageName, slPlayerId, document);
		if (page == null){
			// look in the main application
			page = getPageByName(pageName, slPlayerId);
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
	static public function closePage(pageName:String, transitionData:TransitionData, slPlayerId:String, root:HtmlDom = null)
	{//trace("closePage "+pageName+" root="+root);
		// default is the whole document
		var document:Dynamic = root;
		if (root == null)
			document = Lib.document.documentElement;

		// find the pages to open
		var page = getPageByName(pageName, slPlayerId, document);
		if (page == null){
			// look in the main application
			page = getPageByName(pageName, slPlayerId);
			if (page == null)
				throw("Error, could not find a page with name "+pageName);
		}
		// close the page
		page.close(transitionData);
	}
	/** 
	 * Retrieve all the pages of this application or group
	 */
	static public function getPageNodes(slPlayerId:String, root:HtmlDom = null):HtmlCollection<HtmlDom>
	{
		// default is the hole document
		var document:Dynamic = root;
		if (root == null)
			document = Lib.document.documentElement;

		// get all pages, i.e. all element with class name "page"
		return document.getElementsByClassName(Page.CLASS_NAME);
	}
	/** 
	 * Retrieve the page whose "name" attribute is pageName
	 */
	static public function getPageByName(pageName:String, slPlayerId:String, root:HtmlDom = null):Null<Page>
	{
		// default is the hole document
		var document:Dynamic = root;
		if (root == null)
			document = Lib.document.documentElement;

		// get all pages, i.e. all element with class name "page"
		var pages:HtmlCollection<HtmlDom> = getPageNodes(slPlayerId, document);
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

		// implementation of IGroupable
		startGroupable();

		name = rootElement.getAttribute(CONFIG_NAME_ATTR);
		if (name == null || name == "")
		{
			throw("Pages have to have a 'name' attribute");
		}
	}

	override public function init()
	{
		super.init();
		// group element is body element by default
		if (groupElement == null)
			groupElement = Lib.document.body;

		// close if it is not the default page
		if ( DomTools.getMeta(CONFIG_INITIAL_PAGE_NAME) == name 
			|| groupElement.getAttribute(ATTRIBUTE_INITIAL_PAGE_NAME) == name
		)
		{
			DomTools.doLater(callback(open, null, null, true, true));
		}
	}

	/**
	 * Open this page, i.e. show all layers which have the page name in their css class attribute
	 * Also close the other pages if doCloseOthers is true
	 */
	public function open(transitionDataShow:TransitionData = null, transitionDataHide:TransitionData = null, doCloseOthers:Bool = true, preventTransitions:Bool = false) 
	{// trace("open - "+doCloseOthers+" - name="+name+" - "+preventTransitions);
		if (doCloseOthers)
			closeOthers(transitionDataHide, preventTransitions);

		doOpen(transitionDataShow, preventTransitions);
	}

	/**
	 * Close all other pages
	 */
	public function closeOthers(transitionData:TransitionData = null, preventTransitions:Bool = false)
	{// trace("closeOthers("+transitionData+") - "+preventTransitions);

		// find all the pages in this application and close them
		var nodes = getPageNodes(SLPlayerInstanceId, groupElement);
		for (idxPageNode in 0...nodes.length)
		{
			var pageNode = nodes[idxPageNode];
			var pageInstances:List<Page> = getSLPlayer().getAssociatedComponents(pageNode, Page);
			for (pageInstance in pageInstances)
			{
				if (pageInstance != this)
					pageInstance.close(transitionData, [name], preventTransitions);
			}
		}
	}

	/**
	 * Open this page, i.e. show all layers which have the page name in their css class attribute
	 */
	public function doOpen(transitionData:TransitionData = null, preventTransitions:Bool = false)
	{// trace("doOpen "+transitionData+", "+name+" - "+preventTransitions);
		// find all the layers which have the page name in their css class attribute
		var nodes = Layer.getLayerNodes(name, SLPlayerInstanceId, groupElement);

		// show the layers
		for (idxLayerNode in 0...nodes.length)
		{
			var layerNode = nodes[idxLayerNode];
			var layerInstances:List<Layer> = getSLPlayer().getAssociatedComponents(layerNode, Layer);
			for (layerInstance in layerInstances)
			{
					layerInstance.show(transitionData, preventTransitions);
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
	{trace("close "+transitionData+", "+name+" - "+preventTransitions+" - "+groupElement);
		// default value
		if (preventCloseByClassName==null)
			preventCloseByClassName = new Array();

		// find all the layers which have the page name in their css class attribute
		var nodes = Layer.getLayerNodes(name, SLPlayerInstanceId, groupElement);

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
					cast(layerInstance, Layer).hide(transitionData, preventTransitions);
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
