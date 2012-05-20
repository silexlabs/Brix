package;

using haxe.Log;
import js.Lib;
import js.Dom;

import haxe.Template;

import slplayer.ui.DisplayObject;

/**
 * Gallery component for SLPlayer applications.
 * @author Thomas Fétiveau
 */
class Gallery extends DisplayObject
{
	static override var className = "gallery";
	
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
		
		untyped rootElement.addEventListener("data", onData , false);
		
		var onNewDataConsumerEvent:Event = untyped Lib.document.createEvent("CustomEvent");
		untyped onNewDataConsumerEvent.initCustomEvent("newDataConsumer", false, false, me);
		
		untyped this.rootElement.dispatchEvent(onNewDataConsumerEvent);
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
	
	function onData(e:Dynamic):Void
	{
		#if flash9
		var evt:cocktail.core.event.CustomEvent = cast(e);
		#else
		var evt = e;
		#end
		
		if (evt.detail != null)
		{
			dataProviders.set(evt.detail.src,evt.detail.data);
			updateView();
		}
	}
}