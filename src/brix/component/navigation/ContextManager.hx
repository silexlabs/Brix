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
import brix.core.Application;

import js.Dom;
import js.Lib;

/**
 * the value for a context
 */
typedef ContextValue = String;

/**
 * the value for the context events
 * use as event.detail for the add/remove events
 */
typedef ContextEventDetail = Array<ContextValue>;

/**
 * The ContextManager component is a component that is in charge to show/hide DOM elements when they are in/out of context
 * It takes the parameters data-context-list and data-initial-context in the associated node 
 * When the context XXX is added/removed to the current context, this components shows/hide all the DOM elements wich have XXX in theyre css class name
 * This is done by adding/removing the style definition .XXX{ display : none; visibility : hidden; } to the html head
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
	 * name of the event dispatched when the context changes
	 */
	public static inline var EVENT_CONTEXT_CHANGE = "changeContextEvent";
	/**
	 * name of the event which you can dispatch from your components to change the value of the contexts
	 */
	public static inline var EVENT_ADD_CONTEXTS = "addContextsEvent";
	/**
	 * name of the event which you can dispatch from your components to change the value of the contexts
	 */
	public static inline var EVENT_REMOVE_CONTEXTS = "removeContextsEvent";
	/**
	 * name of the event which you can dispatch from your components to toggle the value of the contexts
	 */
	public static inline var EVENT_TOGGLE_CONTEXTS = "toggleContextsEvent";
	/**
	 * name of the event which you can dispatch from your components to change the value of the contexts
	 */
	public static inline var EVENT_REPLACE_CONTEXTS = "replaceContextsEvent";
	/**
	 * name of the event which you can dispatch from your components to change the value of the contexts
	 */
	public static inline var EVENT_RESET_CONTEXTS = "resetContextsEvent";
	/**
	 * name of the event which you can dispatch from your components to change the value of the contexts
	 */
	public static inline var EVENT_REQUEST_CONTEXTS = "requestContextsEvent";
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
	//private static var styleSheet:HtmlDom;
	///////////////////////////////////////////////////////////////
	// main methods
	///////////////////////////////////////////////////////////////
	/**
	 * Builds the Context with arguments passed in the html node attributes
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		// init context list
		if (rootElement.getAttribute(PARAM_DATA_CONTEXT_LIST) != null)
		{
			allContexts = string2ContextList(rootElement.getAttribute(PARAM_DATA_CONTEXT_LIST));
		}
		else
		{
			throw("Error: Context component needs param in "+PARAM_DATA_CONTEXT_LIST);
		}

		// listen to other components events
		mapListener(rootElement, EVENT_ADD_CONTEXTS, cast(onAddContextEvent), true);
		mapListener(rootElement, EVENT_REMOVE_CONTEXTS, cast(onRemoveContextEvent), true);
		mapListener(rootElement, EVENT_RESET_CONTEXTS, cast(onResetContextEvent), true);
		mapListener(rootElement, EVENT_REPLACE_CONTEXTS, cast(onReplaceContextsEvent), true);
		mapListener(rootElement, EVENT_TOGGLE_CONTEXTS, cast(onToggleContextsEvent), true);
		mapListener(rootElement, EVENT_REQUEST_CONTEXTS, cast(onRequestContextsEvent), true);
	}
	override public function init()
	{
		super.init();

		// init current context
		resetContexts();
		// listen to the page open/close in order to refersh the contexts display
		// rootElement.addEventListener(Layer.EVENT_TYPE_SHOW_START, onLayerShow, true);
	}
	/** 
	 * reset contexts 
	 */
	private function resetContexts()
	{
		// init current context
		if (rootElement.getAttribute(PARAM_DATA_INITIAL_CONTEXT) != null)
		{
			currentContexts = string2ContextList(rootElement.getAttribute(PARAM_DATA_INITIAL_CONTEXT));
		}
		else
		{
			currentContexts = new Array();
		}
	}
	/** 
	 * callback for a request comming from another brix component
	 */
	private function onAddContextEvent(e:CustomEvent)
	{trace("onAddContextEvent"+e.detail);
		//e.stopPropagation();
		var contextValues:Array<ContextValue> = cast(e.detail);
		for (contextValue in contextValues)
			addContext(contextValue);
	}
	/** 
	 * callback for a request comming from another brix component
	 */
	private function onRemoveContextEvent(e:CustomEvent)
	{trace("onRemoveContextEvent"+e.detail);
		//e.stopPropagation();
		var contextValues:Array<ContextValue> = cast(e.detail);
		for (contextValue in contextValues)
			removeContext(contextValue);
	}
	/** 
	 * callback for a request comming from another brix component
	 */
	private function onReplaceContextsEvent(e:CustomEvent)
	{trace("onReplaceContextsEvent"+e.detail);
		//e.stopPropagation();
		var contextValues:Array<ContextValue> = cast(e.detail);
		setCurrentContexts(contextValues);
	}
	
	private function onToggleContextsEvent(e:CustomEvent)
	{trace("onToggleContextEvent"+e.detail);
		var contextValues:Array<ContextValue> = cast(e.detail);
		for (contextValue in contextValues)
			toggleContext(contextValue);
	}
	private function onRequestContextsEvent(e:CustomEvent)
	{trace("onRequestContextsEvent"+e.detail);
		invalidate();
	}
	/** 
	 * callback for a request comming from another brix component
	 */
	private function onResetContextEvent(e:CustomEvent)
	{
		//e.stopPropagation();
		resetContexts();
	}
	/** 
	 * callback for layer show
	 */
/*	private function onLayerShow(e:Event)
	{
		invalidate();
	}
	/** 
	 * invalidate
	 */
	private function invalidate()
	{
		// no more invalidation system is required since I changed the ContextManager to use styles instead of layers
		//		if (isDirty == false)
		//			DomTools.doLater(refresh);
		refresh();
		isDirty = true;
		// dispatch a change event
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(EVENT_CONTEXT_CHANGE, true, true, this);
		rootElement.dispatchEvent(event);
	}
	////////////////////////////////////////////////////////////
	// The context API
	////////////////////////////////////////////////////////////
	/**
	 * replace the current context
	 */
	public function setCurrentContexts(contextList:Array<ContextValue>):Array<ContextValue>
	{
		currentContexts = contextList;
		invalidate();
		return contextList;
	}
	/**
	 * add a context to the current contexts list currentContexts
	 */
	public function addContext(context:ContextValue)
	{
		if (!isContext(context))
		{
			trace("Error: unknown context \""+context+"\". It should be defined in the \""+PARAM_DATA_CONTEXT_LIST+"\" parameter of the Context component.");
		}
		if (!hasContext(context))
		{
			currentContexts.push(context);
			invalidate();
		}
		else{
			//trace("Warning: Could not add the context \""+context+"\" to the current context, because it is allready in the currentContexts array.");
		}
	}
	/**
	 * remove a context from the current contexts list currentContexts
	 */
	public function removeContext(context:ContextValue)
	{
		if (!isContext(context))
		{
			trace("Error: unknown context \""+context+"\". It should be defined in the \""+PARAM_DATA_CONTEXT_LIST+"\" parameter of the Context component.");
		}
		if (hasContext(context))
		{
			currentContexts.remove(context);
			invalidate();
		}
		else{
			//trace("Warning: Could not remove the context \""+context+"\" from the current context, because it is not in the currentContexts array.");
		}
	}
	
	/**
	 * toggle (remove if present, add if not) a context from the
	 * current contexts list currentContexts
	 */
	public function toggleContext(context:ContextValue)
	{
		if (!isContext(context))
		{
			throw("Error: unknown context \""+context+"\". It should be defined in the \""+PARAM_DATA_CONTEXT_LIST+"\" parameter of the Context component.");
		}
		if (hasContext(context))
		{
			removeContext(context);
		}
		else
		{
			addContext(context);
		}
	}
	
	/**
	 * check if the given context value is part of the currentContexts list
	 */
	public function hasContext(context:ContextValue):Bool
	{
		return Lambda.has(currentContexts, context);
	}
	/**
	 * check if the given context value is part of the allContexts list
	 */
	public function isContext(context:ContextValue):Bool
	{
		return Lambda.has(allContexts, context);
	}
	/**
	 * check if the given node is part of the current context
	 * for each css class of the node, check if it is a context
	 * and then if this context is in the current context
	 */
	public function isInContext(element:HtmlDom):Bool
	{
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
		// reset css style
/*		if (styleSheet != null){
			getBrixApplication().htmlRootElement.getElementsByTagName("head")[0].removeChild(cast(styleSheet));	
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