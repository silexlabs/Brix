package slplayer.prototype.player;

import js.Lib;
import js.Dom;

import haxe.Template;

import org.slplayer.component.ui.DisplayObject;

//these two lines below are mandatory to be a standard data consumer
import org.slplayer.component.data.IDataConsumer;
using org.slplayer.component.data.IDataConsumer.DataConsumer;
import org.slplayer.component.data.IDataProvider;

import org.slplayer.component.player.IPlayable;
import org.slplayer.component.player.IPlayerControl;
using org.slplayer.component.player.IPlayable.Playable;

import org.slplayer.component.group.IGroupable;
using org.slplayer.component.group.IGroupable.Groupable;

/**
 * Gallery component for SLPlayer applications.
 * @author Thomas Fétiveau
 */
@tagNameFilter("ul","ol")
class ImagePlayer extends DisplayObject, implements IDataConsumer, implements IPlayable, implements IGroupable
{
	var currentIndex:Int;
	
	var tpl : Template;
	
	public var groupElement:HtmlDom;
	
	/**
	 * This variable may contain data from different sources and/or DataProviders.
	 */
	var dataProviders(default,null) : Hash<Array<Dynamic>>;
	
	private override function new(rootElement : HtmlDom, SLPId:String)
	{
		super(rootElement,SLPId);
		
		startGroupable();
	}
	
	override public function init():Void 
	{
		dataProviders = new Hash();
		
		initUI();
		
		tpl = untyped new Template(rootElement.innerHTML);
		rootElement.innerHTML = "";
		
		currentIndex = 0;
		
		if (groupElement == null)
		{
			groupElement = rootElement;
		}

		startConsuming(groupElement);
		
		startPlayable(groupElement);
		
		updateView();
	}
	
	function initUI():Void
	{
		//rootElement.style.listStyleType = "none";
		//rootElement.style.listStylePosition = "inside";
		//rootElement.style.margin = "0";
		rootElement.style.paddingLeft = "0";
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
		
		dispatchOnChange(groupElement);
		
		dispatchIndex();
		
		//hide all but the selected item
		var liChilds = rootElement.getElementsByTagName("li");
		for ( liCnt in 0...liChilds.length)
		{
			liChilds[liCnt].style.display = "none";
		}
		liChilds[currentIndex].style.display = "block";
	}
	
	function dispatchIndex()
	{
		var liChilds = rootElement.getElementsByTagName("li");
		if (currentIndex <= 0)
			dispatchOnFirst(groupElement);
		else if (currentIndex >= liChilds.length-1)
			dispatchOnLast(groupElement);
	}
	
	public function next():Void
	{
		if ( currentIndex < rootElement.getElementsByTagName("li").length - 1 )
			currentIndex++;
		updateView();
	}
	
	public function previous():Void
	{
		if ( currentIndex > 0 )
			currentIndex--;
		updateView();
	}
	
	public function first():Void
	{
		currentIndex = 0;
		updateView();
	}
	
	public function last():Void
	{
		currentIndex = rootElement.getElementsByTagName("li").length - 1;
		updateView();
	}
	
	public function onNewPlayerControl(newPlayerControl:IPlayerControl):Void
	{
		dispatchIndex();
	}
	
	public function onData(dataObj:DataObject):Void
	{
		if (dataObj != null)
		{
			dataProviders.set(dataObj.src,dataObj.data);
			updateView();
		}
	}
	
	/**
	 * Callback invoked when a new data provider is showing up.
	 */
	public function onNewDataProvider( dataProvider : IDataProvider ):Void
	{
		dataProvider.onNewDataConsumer(this);
	}
}