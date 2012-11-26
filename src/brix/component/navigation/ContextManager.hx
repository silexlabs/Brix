/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.navigation;

import brix.component.navigation.Layer;
import brix.component.ui.DisplayObject;
import brix.util.DomTools;

import js.Dom;
import js.Lib;

/**
 * the value for a context
 */
typedef ContextValue = String;

/**
 * The ContextManager component is a component that is in charge to show/hide Layer components when they are in/out of context
 * It takes the parameters data-context-list and data-initial-context in the associated node 
 * It has an invalidation mechanism
 * @example <div class="ContextManager" data-context-list="context1, context2, context3" data-initial-context="context1, context2" />
 */
class ContextManager extends DisplayObject
{
	/**
	 * name of the parameter used to get the list of contexts
	 * coma separated list of class names
	 * case incensitive
	 */
	public static inline var PARAM_DATA_CONTEXT_LIST = "data-context-list";
	/**
	 * name of the parameter used to get the intial value of the context
	 * coma separated list of class names
	 * case incensitive
	 */
	public static inline var PARAM_DATA_INITIAL_CONTEXT = "data-initial-context";
	/**
	 * list of contexts
	 * case incensitive
	 */
	public var allContexts: Array<ContextValue>;
	/**
	 * current contexts
	 * case incensitive
	 */
	public var currentContexts(default, setCurrentContexts): Array<ContextValue>;
	/**
	 * flag used to implement invalidation mechanism
	 * 
	 */
	public var isDirty:Bool = false;
	/**
	 * Stores the style node with the current context as visible 
	 */
	private static var styleSheet:HtmlDom;
	/**
	 * Builds the Context with arguments passed in the html node attributes
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		haxe.Firebug.redirectTraces();

		super(rootElement, brixId);

		// init context list
		if (rootElement.getAttribute(PARAM_DATA_CONTEXT_LIST) != null)
		{
			allContexts = string2ContextList(rootElement.getAttribute(PARAM_DATA_CONTEXT_LIST));
		}
		else
		{
			throw("Error: Context global component needs param "+PARAM_DATA_CONTEXT_LIST);
		}

		// init current context
		if (rootElement.getAttribute(PARAM_DATA_INITIAL_CONTEXT) != null)
		{
			currentContexts = string2ContextList(rootElement.getAttribute(PARAM_DATA_INITIAL_CONTEXT));
		}
		else
		{
			currentContexts = new Array();
		}
		// listen to the page open/close in order to refersh the contexts display
		rootElement.addEventListener(Layer.EVENT_TYPE_SHOW_START, onLayerShow, true);
	}
	/** 
	 * callback for layer show
	 */
	private function onLayerShow(e:Event)
	{
		trace("onLayerShow ");
		invalidate();
	}
	/** 
	 * invalidate
	 */
	private function invalidate()
	{
		trace("invalidate "+isDirty);
		if (isDirty == false)
			DomTools.doLater(refresh);
		isDirty = true;
	}
	////////////////////////////////////////////////////////////
	// The context API
	////////////////////////////////////////////////////////////
	/**
	 * replace the current context
	 */
	public function setCurrentContexts(contextList:Array<ContextValue>):Array<ContextValue>
	{
		trace("setCurrentContexts "+contextList);
		currentContexts = contextList;
		invalidate();
		return contextList;
	}
	/**
	 * add a context to the current contexts list currentContexts
	 */
	public function addContext(context:ContextValue)
	{
		trace("addContext");
		if (!isContext(context))
		{
			throw("Error: unknown context \""+context+"\". It should be defined in the \""+PARAM_DATA_CONTEXT_LIST+"\" parameter of the Context component.");
		}
		if (!hasContext(context))
		{
			currentContexts.push(context);
			invalidate();
		}
		else{
			trace("Warning: Could not add the context \""+context+"\" to the current context, because it is allready in the currentContexts array.");
		}
	}
	/**
	 * remove a context from the current contexts list currentContexts
	 */
	public function removeContext(context:ContextValue)
	{
		trace("removeContext "+context);
		if (!isContext(context))
		{
			throw("Error: unknown context \""+context+"\". It should be defined in the \""+PARAM_DATA_CONTEXT_LIST+"\" parameter of the Context component.");
		}
		if (hasContext(context))
		{
			currentContexts.remove(context);
			invalidate();
		}
		else{
			trace("Warning: Could not remove the context \""+context+"\" from the current context, because it is not in the currentContexts array.");
		}
	}
	/**
	 * check if the given context value is part of the currentContexts list
	 */
	public function hasContext(context:ContextValue):Bool
	{
		// trace("hasContext "+context+" in "+currentContexts+" gives "+Lambda.has(allContexts, context));
		return Lambda.has(currentContexts, context);
	}
	/**
	 * check if the given context value is part of the allContexts list
	 */
	public function isContext(context:ContextValue):Bool
	{
		//trace("isContext");
		return Lambda.has(allContexts, context);
	}
	/**
	 * check if the given node is part of the current context
	 * for each css class of the node, check if it is a context
	 * and then if this context is in the current context
	 */
	public function isInContext(element:HtmlDom):Bool
	{
		//trace("isInContext "+element.className);
		if (element.className != null)
		{
			var elementClasses = element.className.split(" ");
			for (className in elementClasses)
			{
				className = cleanupContextValue(className);
				if (isContext(className) && hasContext(className))
				{
					return true;
				}
			}
		}
		return false;
	}
	/**
	 * check if the given node is part of the current context
	 * for each css class of the node, check if it is a context
	 * and then if this context is in the current context
	 */
	public function isOutContext(element:HtmlDom):Bool
	{
		//trace("isInContext "+element.className);
		if (element.className != null)
		{
			var elementClasses = element.className.split(" ");
			for (className in elementClasses)
			{
				className = cleanupContextValue(className);
				if (isContext(className) && !hasContext(className))
				{
					return true;
				}
			}
		}
		return false;
	}
	/**
	 * refresh the display in order to reflect the context
	 * call show or hide on all Layers
	 * in the group or the document 
	 */
	public function refresh()
	{
		trace("refresh "+currentContexts);

		// reset css style
		if (styleSheet != null){
			Lib.document.getElementsByTagName("head")[0].removeChild(cast(styleSheet));	
		}
		var cssText = "";
		for (context in allContexts){
			cssText += "."+context+" { display : none; visibility : hidden; } ";
		}
		for (context in currentContexts){
			cssText += "."+context+" { display : inline; visibility : visible; } ";
		}
		// adds the css rules
		styleSheet = DomTools.addCssRules(cssText);

/*
		// find all the layers which have the page name in their css class attribute
		var layersToShow = new Array();
		var layersToHide = new Array();

		var nodes = Layer.getLayerNodes("", brixInstanceId, rootElement);

		// show the layers
		for (idxLayerNode in 0...nodes.length)
		{
			var layerNode = nodes[idxLayerNode];
			if (isInContext(layerNode))
			{
				var layerInstances:List<Layer> = getBrixApplication().getAssociatedComponents(layerNode, Layer);
				for (layerInstance in layerInstances)
				{
					if (layerInstance.status != LayerStatus.visible && layerInstance.status != LayerStatus.showTransition)
					{trace("show "+layerNode.className);
						layersToShow.push(layerInstance);
					}
					else
					{trace("show "+layerNode.className+" aborted");

					}
				}
			}
			else if (isOutContext(layerNode))
			{
				var layerInstances:List<Layer> = getBrixApplication().getAssociatedComponents(layerNode, Layer);
				for (layerInstance in layerInstances)
				{
					if (layerInstance.status != LayerStatus.hidden && layerInstance.status != LayerStatus.hideTransition)
					{trace("hide "+layerNode.className);
						layersToHide.push(layerInstance);
					}
					else
					{trace("hide "+layerNode.className+" aborted");

					}
				}
			}
		}
		// show the layers
		for (layerInstance in layersToShow){
			layerInstance.show();
		}
		// hide the layers
		for (layerInstance in layersToHide){
			layerInstance.hide();
		}
*/
		// reset dirty flag
		isDirty = false;
	}
	////////////////////////////////////////////////////////////
	// helpers
	////////////////////////////////////////////////////////////
	/**
	 * Convert a list of contexts, coma separated in a string to an array of contexts
	 */
	private function string2ContextList(string:String):Array<ContextValue> 
	{
		// extract format from args
		var contextList = string.split(",");
		// cleanup
		for (idx in 0...contextList.length)
		{
			contextList[idx] = cleanupContextValue(contextList[idx]);
		}
		return contextList;
	}
	private function cleanupContextValue(contextName:String):String
	{
		return StringTools.trim(contextName).toLowerCase();
	}
	/**
	 * Convert a list of contexts, coma separated in a string to an array of contexts
	 */
	private function contextList2String(contextList:Array<ContextValue>):ContextValue
	{
		return cast(contextList).concat(", ");
	}
}