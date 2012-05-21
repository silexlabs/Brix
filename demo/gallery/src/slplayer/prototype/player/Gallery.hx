package slplayer.prototype.player;

using haxe.Log;

import js.Lib;
import js.Dom;

import haxe.Template;

import slplayer.ui.DisplayObject;

//these two lines below are mandatory to be a standard data consumer
import slplayer.data.DataConsumer;
using slplayer.data.DataConsumer;

import slplayer.ui.player.Playable;
using slplayer.ui.player.Playable;

/**
 * Gallery component for SLPlayer applications.
 * @author Thomas Fétiveau
 */
class Gallery extends DisplayObject, implements IDataConsumer, implements IPlayable
{
	static var className = "gallery";
	
	var currentIndex:Int;
	
	var tpl : Template;
	
	var dataProviders(default,null) : Hash<Array<Dynamic>>;
	
	override public function init(e:Event):Void 
	{
		dataProviders = new Hash();
		
		initUI();
		
		tpl = untyped new Template(rootElement.innerHTML);
		rootElement.innerHTML = "";
		
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
		rootElement.innerHTML = tpl.execute({data:providersData});
		
		var liChilds = rootElement.getElementsByTagName("li");
		
		dispatchOnChange(rootElement);
		
		if (currentIndex <= 0)
			dispatchOnFirst(rootElement);
		else if (currentIndex >= liChilds.length-1)
			dispatchOnLast(rootElement);
			
		
		//hide all but the selected item
		for ( liCnt in 0...liChilds.length)
		{
			liChilds[liCnt].style.display = "none";
		}
		liChilds[currentIndex].style.display = "block";
	}
	
	function next(e:Event):Void
	{
		if ( currentIndex < rootElement.getElementsByTagName("li").length - 1 )
			currentIndex++;
		updateView();
	}
	
	function previous(e:Event):Void
	{
		if ( currentIndex > 0 )
			currentIndex--;
		updateView();
	}
	
	private function first(e:Event):Void
	{
		currentIndex = 0;
		updateView();
	}
	
	private function last(e:Event):Void
	{
		currentIndex = rootElement.getElementsByTagName("li").length - 1;
		updateView();
	}
	
	private function onData(e:Dynamic):Void
	{
		#if flash9
		var evt:cocktail.core.event.CustomEvent = cast(e);
		#else
		var evt = e;
		#end
		
		if (untyped evt.detail != null)
		{
			dataProviders.set(evt.detail.src,evt.detail.data);
			updateView();
		}
	}
}