package slplayer.prototype.player;

import js.Lib;
import js.Dom;

import haxe.Template;

import slplayer.ui.DisplayObject;

//these two lines below are mandatory to be a standard data consumer
import slplayer.data.Common;
import slplayer.data.DataConsumer;
using slplayer.data.DataConsumer;

import slplayer.ui.player.Playable;
using slplayer.ui.player.Playable;

/**
 * Gallery component for SLPlayer applications.
 * @author Thomas Fétiveau
 */
class ImagePlayer extends DisplayObject, implements IDataConsumer, implements IPlayable
{
	/**
	 * The class name associated with this component
	 */
	static var className = "imageplayer";
	/**
	 * A list of allowed tag names for the root element.
	 */
	static var bodyElementNameFilter : List<String> = Lambda.list(["ul"]);
	
	var currentIndex:Int;
	
	var tpl : Template;
	
	/**
	 * This variable may contain data from different sources and/or DataProviders.
	 */
	var dataProviders(default,null) : Hash<Array<Dynamic>>;
	
	override public function init():Void 
	{
		dataProviders = new Hash();
		
		initUI();
		
		tpl = untyped new Template(bodyElement.innerHTML);
		bodyElement.innerHTML = "";
		
		currentIndex = 0;
		updateView();
		
		startConsuming(rootElement);
		
		startPlayable(rootElement);
	}
	
	function initUI():Void
	{
		//rootElement.style.listStyleType = "none";
		//rootElement.style.listStylePosition = "inside";
		//rootElement.style.margin = "0";
		bodyElement.style.paddingLeft = "0";
		//rootElement.style.padding = "0";
	}
	
	/**
	 * The redraw function of the component.
	 */
	function updateView():Void
	{		
		//consolidate providers data
		var providersData : Array<Dynamic> = new Array();
		for (pvdData in dataProviders)
		{
			providersData = providersData.concat(pvdData);
		}
		
		//execute template
		bodyElement.innerHTML = tpl.execute({data:providersData});
		
		dispatchOnChange(rootElement);
		
		dispatchIndex();
		
		//hide all but the selected item
		var liChilds = bodyElement.getElementsByTagName("li");
		for ( liCnt in 0...liChilds.length)
		{
			liChilds[liCnt].style.display = "none";
		}
		liChilds[currentIndex].style.display = "block";
	}
	
	function dispatchIndex()
	{
		var liChilds = bodyElement.getElementsByTagName("li");
		if (currentIndex <= 0)
			dispatchOnFirst(rootElement);
		else if (currentIndex >= liChilds.length-1)
			dispatchOnLast(rootElement);
	}
	
	function next():Void
	{
		if ( currentIndex < bodyElement.getElementsByTagName("li").length - 1 )
			currentIndex++;
		updateView();
	}
	
	function previous():Void
	{
		if ( currentIndex > 0 )
			currentIndex--;
		updateView();
	}
	
	private function first():Void
	{
		currentIndex = 0;
		updateView();
	}
	
	private function last():Void
	{
		currentIndex = bodyElement.getElementsByTagName("li").length - 1;
		updateView();
	}
	
	private function onNewPlayerControl():Void
	{
		dispatchIndex();
	}
	
	private function onData(dataObj:DataObject):Void
	{
		if (dataObj != null)
		{
			dataProviders.set(dataObj.src,dataObj.data);
			updateView();
		}
	}
}