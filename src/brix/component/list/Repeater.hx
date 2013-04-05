/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.list;

import js.Lib;
import js.Dom;

import haxe.Template;

import brix.component.interaction.Draggable;

import brix.util.DomTools;

import brix.component.ui.DisplayObject;
import brix.component.template.TemplateMacros;
import brix.component.navigation.Layer;

#if continuation
import com.dongxiguo.continuation.Continuation;

/**
 * list component
 * display items in a template and expose a data provider interface
 * 	redraw
 * 	template
 * 	datapovider
 */
@:build(com.dongxiguo.continuation.Continuation.cpsByMeta("cps"))
#end
class Repeater<ElementClass> extends DisplayObject
{
	/**
	 * attribute used to store the index of the cell in the generated DOM
	 */
	public static inline var DATA_ATTR_LIST_ITEM_INDEX = "data-list-item-idx";
	/**
	 * list elements template
	 * @example 	&lt;li&gt;::displayName::&lt;/li&gt;
	 */
	public var htmlTemplate:String;
	/**
	 * the raw html strings of the rendered elements
	 * 
	 */
	private var elementsHtml:Array<String>;
	/**
	 * data store
	 */
	public var dataProvider:Array<ElementClass>;

	private var stopContinuationFlag:Bool = false;
	private var isContinuationPending:Bool = false;
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		elementsHtml = new Array();
		dataProvider = new Array();

		// store the template
		htmlTemplate = rootElement.innerHTML;

		// and clear the rootElement contents
		rootElement.innerHTML = "";

		// attach the events
		mapListener(rootElement, ConnectorBase.ON_DATA_RECEIVED, onDataReceived, true);

		mapListener(rootElement, Layer.EVENT_TYPE_HIDE_STOP, onLayerHide, false);
	}
	/**
	 * callback for the event
	 */
	public function onLayerHide(e:Event)
	{
		if (isContinuationPending)
			stopContinuationFlag = true;
	}
	/**
	 * callback for the event
	 */
	public function onDataReceived(e:Event)
	{
		//trace("onDataReceived "+cast(e).detail);
		var newData:Array<ElementClass> = cast(e).detail;
		if (newData != null)
		{
			var stopContinuation = isContinuationPending;
			dataProvider = newData;
			redraw();
			if (stopContinuation)
				stopContinuationFlag = true;
		}
	}
	/**
	 * redraw the list, i.e. reload the dataProvider( ... )
	 * this method calls reloadData which then calls doRedraw
	 */ 
	public function redraw()
	{
		// refresh list data
		reloadData();
	}
	/**
	 * resolve the template
	 * may be overriden to change the way a template is resolved
	 */ 
	private function resolveItem(element: ElementClass, t:Template)
	{
		return t.execute(element, new TemplateMacros());
	}

	/**
	 * Call this when the list's DOM tree has changed, and you want the dataProvider to be updated accoringly
	 */
/*	public function domChanged(?e:Event):Void
	{
		var newDataProvider:Array<ElementClass> = new Array();
		// re-order the items in the dataprovider according to the DOM
		for (i in 0...rootElement.childNodes.length)
		{
			if (rootElement.childNodes[i].nodeType != rootElement.nodeType || 
				rootElement.childNodes[i].getAttribute(DATA_ATTR_LIST_ITEM_INDEX) == null)
			{
				continue;
			}
			// TODO support new elts with no DATA_ATTR_LIST_ITEM_INDEX attribute yet (need retro-template for that)
			newDataProvider.push(dataProvider[Std.parseInt(rootElement.childNodes[i].getAttribute(DATA_ATTR_LIST_ITEM_INDEX))]);
		}
		dataProvider = newDataProvider;
		// reset the item ids
		setItemIds();
	}
	/**
	 * redraw the list without calling reloadData
	 * add/remove/move DOM nodes only when needed:
	 * - generate the html for each dataProvider element
	 * - browse the current dom and remove the nodes which have no equivalent in the dataProvider
	 * - browse all items of the dataProvider, and if it is in the DOM, move it, otherwise create a node
	 * handles the case where several items have the same html rendering
	 */
	static function sleepOneFrame(handler:Void->Void):Void
	{
		//    haxe.Timer.delay(handler, 1000);
		DomTools.doLater(handler, 3);
	}
	public function doRedraw()
	{
/*
		// remove from dom for performance saving
		var rootElementIdx = DomTools.getElementIndex(rootElement);
		var rootElementParent = rootElement.parentNode;
		rootElementParent.removeChild(rootElement);

*/	 	// generate the html for each dataProvider element

		stopContinuationFlag = false;

		var newElementsHtml:Array<String> = new Array();
		var t = new Template(htmlTemplate);
		for (idx in 0...dataProvider.length)
		{
			var element = dataProvider[idx];
			try
			{
				newElementsHtml.push(resolveItem(element, t));
			}
			catch(e:Dynamic){
				trace("Error: an error occured while interpreting the template - "+htmlTemplate+" - for the element "+element);
			}
		}
	 	// browse the current dom and remove the nodes which have no equivalent in the dataProvider
	 	// tmpElementsHtml is used to handle the case of multiple elements having the same html rendering
	 	var tmpElementsHtml = newElementsHtml.copy();
	 	var toBeRemoved:Array<HtmlDom> = new Array();


		for (htmlIdx in 0...elementsHtml.length)
		{
			// check if the node is still in the DP
			if(!Lambda.has(tmpElementsHtml, elementsHtml[htmlIdx]))
			{
				// remove the node
				var nodes = DomTools.getElementsByAttribute(rootElement, DATA_ATTR_LIST_ITEM_INDEX, Std.string(htmlIdx));
				if (nodes.length == 0 )
				{
					trace("Error: doRedraw could not find node with id="+htmlIdx);
				}
				var node = nodes[0];
				toBeRemoved.push(node);
			}
			else
			{
				// remove from tmpElementsHtml in order to handle the case of multiple elements having the same html rendering
				var tmp = tmpElementsHtml.remove(elementsHtml[htmlIdx]);
			}
		}

		// remove the useless nodes
		for (node in toBeRemoved)
		{
			try
			{			
				getBrixApplication().cleanNode(node);
				removeChild(node);
			}
			catch(e:Dynamic)
			{
				trace("Error while removing node: "+e);
			}
		}
#if continuation
		doRedrawContinuation(newElementsHtml, function()
	    {
	      // trace("Continuation has ended.");
				isContinuationPending = false;
	    });
	}
	@cps public function doRedrawContinuation(newElementsHtml:Array<String>)
	{// trace("doRedrawContinuation  "+newElementsHtml.length);

#end
		var time = Date.now().getTime();
		// temp container
		var tmpDiv = Lib.document.createElement("div");
		var numContinuation = 0;
	 	// browse all items of the dataProvider, and if it is in the DOM, move it, otherwise create a node
		for (idx in 0...dataProvider.length)
		{
			if (stopContinuationFlag==true)
			{
				stopContinuationFlag = false;
				trace("stop pending continuation");
				return;
			}
#if continuation
			if (numContinuation++>2)
			{
				isContinuationPending = true;
				// trace("doRedrawContinuation MAKE A PAUSE 1 FRAME "+idx+"/"+newElementsHtml.length);
				numContinuation = 0;
				sleepOneFrame().async();
			}
#end
			var element = dataProvider[idx];
			var found = false;
			// browse all nodes and check if it is our element
			// start at idx in order to handle the case of multiple elements having the same html rendering
			for (htmlIdx in idx...elementsHtml.length)
			{
				// check if it is in the DOM
				if (elementsHtml[htmlIdx]==newElementsHtml[idx])
				{
					found = true;
					// move it if needed
					if (idx != htmlIdx)
					{
						var nodes = DomTools.getElementsByAttribute(rootElement, DATA_ATTR_LIST_ITEM_INDEX, Std.string(htmlIdx));
						if (nodes.length == 0 )
						{
							throw("doRedraw could not find node with id="+htmlIdx);
						}
						var node = nodes[0];
						try
						{
							// will never occure since we start at 1st: if (idx == rootElement.childNodes.length)
							insertAt(node, idx);
						}
						catch(e:Dynamic){
							trace("Error: an error occured while moving a node in the dom: "+node+" - with the data "+element+" - "+e);
							throw("Error: an error occured while moving a node in the dom: "+node+" - with the data "+element+" - "+e);
						}

						// update id in the dom
						node.setAttribute(DATA_ATTR_LIST_ITEM_INDEX, Std.string(idx));
					}
					break;
				}
			}
			// create a new node if needed
			if(!found)
			{
				try
				{
					//newElementsHtml[idx] = StringTools.replace(newElementsHtml[idx], '"', '%22');
					tmpDiv.innerHTML = newElementsHtml[idx];
				}
				catch(e:Dynamic){
					trace("Error: an error occured while creating a container for the node with data "+element+" and html="+newElementsHtml[idx]+" - "+e);
				}
				for (nodeIdx in 0...tmpDiv.childNodes.length)
				{
					var node = tmpDiv.childNodes[nodeIdx];
					if (node!=null && node.nodeType == NodeTypes.ELEMENT_NODE)
					{
						getBrixApplication().initNode(node);

						insertAt(node, idx);
						// update id in the dom
						node.setAttribute(DATA_ATTR_LIST_ITEM_INDEX, Std.string(idx));

						break;
					}
				}
			}
		}
		// store the new raw initial html
		elementsHtml = newElementsHtml;

// trace("elapsed time: "+(Date.now().getTime() - time));

		// reset the item ids
		//setItemIds(true);

		// back in the dom
/*		if (rootElementIdx < rootElementParent.childNodes.length)
		{
			// insert at the desired position
			rootElementParent.insertBefore(rootElement, rootElementParent.childNodes[rootElementIdx]);
		}
		else
		{
			// insert at the end
			rootElementParent.appendChild(rootElement);
		}
*/	}
	private function getChildAt(idx:Int):HtmlDom
	{
		return rootElement.childNodes[idx];
	}
	private function getNumChildren():Int
	{
		return rootElement.childNodes.length;
	}
	private function removeChild(node:HtmlDom) 
	{
		rootElement.removeChild(node);
	}
	private function insertAt(node:HtmlDom, idx:Int) 
	{
		try
		{
			if (idx < rootElement.childNodes.length-1)
			{
				// insert at the desired position
				rootElement.insertBefore(node, rootElement.childNodes[idx]);
			}
			else
			{
				// insert at the end
				rootElement.appendChild(node);
			}
		}
		catch(e:Dynamic){
			trace("Error: an error occured while adding a node to the dom: "+node+" - "+e);
			throw("Error: an error occured while adding a node to the dom: "+node+" - "+e);
		}
	}
	/**
	 * refreh list data, and then redraw the display by calling doRedraw
	 * to be overriden to handle the model or do nothing if you manipulate the list and dataProvider by composition
	 * if you override this, either call super.reloadData() to redraw immediately, or call doRedraw() when the data is ready
	 */
	public function reloadData():Void
	{
		doRedraw();
	}
	/**
	 * Set ids on the items.
	 */
	private function setItemIds(?reset=false):Void
	{
		var idx = 0;
		for (i in 0...getNumChildren())
		{
			var node = getChildAt(i);
			if (node.nodeType != rootElement.nodeType ||
				(reset && node.getAttribute(DATA_ATTR_LIST_ITEM_INDEX) == null))
			{
				continue;
			}
			node.setAttribute(DATA_ATTR_LIST_ITEM_INDEX, Std.string(idx));
			idx++;
		}
	}
	/**
	 * retrieves the id of the item containing a given node
	 * @param the given DOM node
	 */
	public function getItemIdx(childElement:HtmlDom):Int
	{
		if (childElement == rootElement || childElement == null)
		{
			// this happens for example when the list catches a click on an element inside a cell and do not wish to take it into account 
			trace("Warning: could not find the element clicked in the list.");
			return -1;
		}
		if (childElement.nodeType != rootElement.nodeType || childElement.getAttribute(DATA_ATTR_LIST_ITEM_INDEX) == null)
		{
			return getItemIdx(childElement.parentNode);
		}
		return Std.parseInt(childElement.getAttribute(DATA_ATTR_LIST_ITEM_INDEX));
	}
}