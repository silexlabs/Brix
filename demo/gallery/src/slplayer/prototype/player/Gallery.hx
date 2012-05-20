package slplayer.prototype.player;

using haxe.Log;

import js.Lib;
import js.Dom;

import haxe.Template;

import slplayer.ui.DisplayObject;

//these two lines below are mandatory to be a standard data consumer
import slplayer.data.DataConsumer;
using slplayer.data.DataConsumer;

/**
 * Gallery component for SLPlayer applications.
 * @author Thomas Fétiveau
 */
class Gallery extends DisplayObject, implements IDataConsumer
{
	static var className = "gallery";
	
	var currentIndex:Int;
	
	var tpl : Template;
	
	var dataProviders(default,null) : Hash<Array<Dynamic>>;
	
	override public function init(e:Event):Void 
	{
		dataProviders = new Hash();
		
		tpl = untyped new Template(rootElement.innerHTML);
		rootElement.innerHTML = "";
		
		currentIndex = 0;
		updateView();
		
		//add left and right buttons
		var leftButton = Lib.document.createElement("img");
		leftButton.setAttribute("src", "assets/prev.png");
		var me = this;
		leftButton.onclick = callback(me.previousPicture);
		
		var rightButton = Lib.document.createElement("img");
		rightButton.setAttribute("src", "assets/next.png");
		rightButton.onclick = callback(me.nextPicture);
		
		var buttonContainer = Lib.document.createElement("div");
		buttonContainer.appendChild(leftButton);
		buttonContainer.appendChild(rightButton);
		
		rootElement.parentNode.appendChild(buttonContainer);
		
		startConsuming(rootElement);
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
		//hide all but the selected item
		var liChilds = rootElement.getElementsByTagName("li");
		for ( liCnt in 0...liChilds.length)
		{
			liChilds[liCnt].style.display = "none";
		}
		liChilds[currentIndex].style.display = "block";
	}
	
	function nextPicture(e:Event):Void
	{
		if ( currentIndex < rootElement.getElementsByTagName("li").length - 1 )
			currentIndex++;
		updateView();
	}
	
	function previousPicture(e:Event):Void
	{
		if ( currentIndex > 0 )
			currentIndex--;
		updateView();
	}
	
	private function onData(e:Dynamic):Void
	{
		if (untyped e.detail != null)
		{
			dataProviders.set(e.detail.src,e.detail.data);
			updateView();
		}
	}
}