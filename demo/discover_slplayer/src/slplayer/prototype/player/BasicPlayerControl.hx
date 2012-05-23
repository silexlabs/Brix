package slplayer.prototype.player;

import js.Dom;
import js.Lib;

using slplayer.prototype.util.DomTools;

import slplayer.ui.DisplayObject;

import slplayer.ui.player.PlayerControl;
using slplayer.ui.player.PlayerControl;

/**
 * A basic control bar for Playable components. Implements the first, previous, next and last methods of IPlayerControl.
 * @author Thomas Fétiveau
 */
class BasicPlayerControl extends DisplayObject, implements IPlayerControl
{
	static var className = "controlbar";
	
	static var FIRST_BUTTON_TAG = "controlbar-first";	
	static var PREVIOUS_BUTTON_TAG = "controlbar-previous";	
	static var NEXT_BUTTON_TAG = "controlbar-next";	
	static var LAST_BUTTON_TAG = "controlbar-last";
	
	var firstButton : SkinnableUIElt;
	var previousButton : SkinnableUIElt;
	var nextButton : SkinnableUIElt;
	var lastButton : SkinnableUIElt;

	override public function init():Void
	{
		firstButton = { eltAttrId : FIRST_BUTTON_TAG , elt : null };
		previousButton = { eltAttrId : PREVIOUS_BUTTON_TAG , elt : null };
		nextButton = { eltAttrId : NEXT_BUTTON_TAG , elt : null };
		lastButton = { eltAttrId : LAST_BUTTON_TAG , elt : null };
		
		//if no UI elements have been redefined, build the default UI
		if ( !discoverUIElts() )
			buildUI();
		trace("firstButton="+firstButton+"  previousButton="+previousButton+"  nextButton="+nextButton+"  lastButton="+lastButton);
		startPlayerControl(rootElement);
		
		var me = this;
		if (firstButton.elt != null)
			firstButton.elt.onclick = function(e:Event) { me.first(rootElement); };
		
		if (previousButton.elt != null)
			previousButton.elt.onclick = function(e:Event) { me.previous(rootElement); };
		
		if (nextButton.elt != null)
			nextButton.elt.onclick = function(e:Event) { me.next(rootElement); };
		
		if (lastButton.elt != null)
			lastButton.elt.onclick = function(e:Event) { me.last(rootElement); };
	}
	
	/**
	 * FIXME we may improve the pair system => new mixin/interface contract ?
	 */
	private function discoverUIElts() : Bool
	{
		var discoverySucceed = false;
		
		//check if no inner element have the buttons data- tags
		for (searchedPair in [ firstButton , previousButton , nextButton , lastButton ])
		{
			var results = bodyElement.getElementsByAttribute("data-"+searchedPair.eltAttrId, "*");
			
			if (results.length > 0)
			{
				searchedPair.elt = results[0]; //we take the first one found
				
				discoverySucceed = true;
			}
		}
		return discoverySucceed;
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
		
		firstButton.elt = Lib.document.createElement("img");
		firstButton.elt.setAttribute("src", "assets/first.png");
		divFirst.appendChild(firstButton.elt);
		
		previousButton.elt = Lib.document.createElement("img");
		previousButton.elt.setAttribute("src", "assets/prev.png");
		divPrev.appendChild(previousButton.elt);
		
		nextButton.elt = Lib.document.createElement("img");
		nextButton.elt.setAttribute("src", "assets/next.png");
		divNext.appendChild(nextButton.elt);
		
		lastButton.elt = Lib.document.createElement("img");
		lastButton.elt.setAttribute("src", "assets/last.png");
		divLast.appendChild(lastButton.elt);
		
		var buttonContainer = Lib.document.createElement("div");
		buttonContainer.style.width = "160px";
		buttonContainer.appendChild(divFirst);
		buttonContainer.appendChild(divPrev);
		buttonContainer.appendChild(divNext);
		buttonContainer.appendChild(divLast);
		
		bodyElement.parentNode.appendChild(buttonContainer);
	}
	
	private function onPlayableFirst():Void
	{
		firstButton.elt.style.display = "none";
		previousButton.elt.style.display = "none";
	}
	
	private function onPlayableLast():Void
	{
		nextButton.elt.style.display = "none";
		lastButton.elt.style.display = "none";
	}
	
	private function onPlayableChange():Void
	{
		firstButton.elt.style.display = previousButton.elt.style.display = nextButton.elt.style.display = lastButton.elt.style.display = "block";
	}
	
}