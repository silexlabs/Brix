package;

using haxe.Log;
import js.Lib;
import js.Dom;

import slplayer.ui.DisplayObject;

/**
 * Gallery component for SLPlayer applications.
 * @author Thomas Fétiveau
 */
class Gallery extends DisplayObject
{
	static override var className = "gallery";
	
	var currentIndex:Int;
	
	//var ulElt : HtmlDom;
	
	//static override public function initAll():Void
	//{
		//var ulElts = Lib.document.getElementsByTagName("ul");
	//
		//for (ulCnt in 0...ulElts.length)
		//{	
			//if (ulElts[ulCnt].id == className)
			//{
				//var newGallery = Gallery.create(ulElts[ulCnt]);
				//newGallery.init();
			//}
		//}
	//}
	
	override public function init(e:Event):Void 
	{
		trace("Gallery component initialized");
		//hide all li childs but the first one.
		var liChilds = rootElement.getElementsByTagName("li");
		//trace("li childs length= "+liChilds.length);
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
		
		rootElement.appendChild(buttonContainer);
	}
	
	function updateView():Void
	{
		//trace("[updateView] currentIndex= "+currentIndex);
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
	
	//public static function main():Void
	//{
		//#if js
			//Lib.window.onload = callback(init);
		//#else
			//init(null);
		//#end
	//}
}