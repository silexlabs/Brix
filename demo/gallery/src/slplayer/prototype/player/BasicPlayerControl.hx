package slplayer.prototype.player;

import js.Dom;
import js.Lib;

import slplayer.ui.DisplayObject;

import slplayer.ui.player.PlayerControl;
using slplayer.ui.player.PlayerControl;

/**
 * ...
 * @author Thomas Fétiveau
 */

class BasicPlayerControl extends DisplayObject, implements IPlayerControl
{
	static var className = "controlbar";
	
	var firstButton:HtmlDom;
	
	var previousButton:HtmlDom;
	
	var nextButton:HtmlDom;
	
	var lastButton:HtmlDom;

	override public function init(e:Event):Void
	{
		buildUI();
		
		startPlayerControl(rootElement);
		
		var me = this;
		firstButton.onclick = function(e:Event) { me.first(rootElement); };
		previousButton.onclick = function(e:Event) { me.previous(rootElement); };
		nextButton.onclick = function(e:Event) { me.next(rootElement); };
		lastButton.onclick = function(e:Event) { me.last(rootElement); };
	}
	
	private function buildUI():Void
	{
		var divFirst = Lib.document.createElement("div");
		var divPrev = Lib.document.createElement("div");
		var divNext = Lib.document.createElement("div");
		var divLast = Lib.document.createElement("div");
		
		divFirst.style.display = divPrev.style.display = divNext.style.display = divLast.style.display = "inline-block";
		divFirst.style.width = divPrev.style.width = divNext.style.width = divLast.style.width = "40px";
		divFirst.style.height = divPrev.style.height = divNext.style.height = divLast.style.height = "30px";
		
		firstButton = Lib.document.createElement("img");
		firstButton.setAttribute("src", "assets/first.png");
		divFirst.appendChild(firstButton);
		
		previousButton = Lib.document.createElement("img");
		previousButton.setAttribute("src", "assets/prev.png");
		divPrev.appendChild(previousButton);
		
		nextButton = Lib.document.createElement("img");
		nextButton.setAttribute("src", "assets/next.png");
		divNext.appendChild(nextButton);
		
		lastButton = Lib.document.createElement("img");
		lastButton.setAttribute("src", "assets/last.png");
		divLast.appendChild(lastButton);
		
		var buttonContainer = Lib.document.createElement("div");
		buttonContainer.style.width = "160px";
		buttonContainer.appendChild(divFirst);
		buttonContainer.appendChild(divPrev);
		buttonContainer.appendChild(divNext);
		buttonContainer.appendChild(divLast);
		
		var parent:HtmlDom = cast(rootElement.parentNode);
		parent.style.textAlign = "center";
		rootElement.parentNode.appendChild(buttonContainer);
	}
	
	private function onPlayableFirst(e:Event):Void
	{
		firstButton.style.display = "none";
		previousButton.style.display = "none";
	}
	
	private function onPlayableLast(e:Event):Void
	{
		nextButton.style.display = "none";
		lastButton.style.display = "none";
	}
	
	private function onPlayableChange(e:Event):Void
	{
		firstButton.style.display = previousButton.style.display = nextButton.style.display = lastButton.style.display = "block";
	}
	
}