package slplayer.prototype.player;

import js.Dom;
import js.Lib;

using org.slplayer.util.DomTools;

import org.slplayer.component.ui.DisplayObject;

import org.slplayer.component.player.IPlayerControl;
using org.slplayer.component.player.IPlayerControl.PlayerControl;

import org.slplayer.component.group.IGroupable;
using org.slplayer.component.group.IGroupable.Groupable;

/**
 * Structure helping with handling the skinnable elts of a component.
 * FIXME / TODO keep this and generalize a skining sub-cmps handling logic or remove this.
 */
typedef SkinnableUIElt = 
{
	eltAttrId : String,
	elt : HtmlDom
}

/**
 * A basic control bar for Playable components. Implements the first, previous, next and last methods of IPlayerControl.
 * @author Thomas Fétiveau
 */
class BasicPlayerControl extends DisplayObject, implements IPlayerControl, implements IGroupable
{
	static inline var FIRST_BUTTON_TAG = "controlbar-first";	
	static inline var PREVIOUS_BUTTON_TAG = "controlbar-previous";	
	static inline var NEXT_BUTTON_TAG = "controlbar-next";	
	static inline var LAST_BUTTON_TAG = "controlbar-last";
	
	var firstButton : SkinnableUIElt;
	var previousButton : SkinnableUIElt;
	var nextButton : SkinnableUIElt;
	var lastButton : SkinnableUIElt;
	
	public var groupElement:HtmlDom;
	
	private override function new(rootElement : HtmlDom, SLPId:String)
	{
		super(rootElement,SLPId);
		
		startGroupable();
	}

	override public function init():Void
	{
		if (groupElement == null)
			groupElement = rootElement;
		
		firstButton = { eltAttrId : FIRST_BUTTON_TAG , elt : null };
		previousButton = { eltAttrId : PREVIOUS_BUTTON_TAG , elt : null };
		nextButton = { eltAttrId : NEXT_BUTTON_TAG , elt : null };
		lastButton = { eltAttrId : LAST_BUTTON_TAG , elt : null };
		
		//if no UI elements have been redefined, build the default UI
		if ( !discoverUIElts() )
			buildUI();

		startPlayerControl(groupElement);
		
		var me = this;
		if (firstButton.elt != null)
			firstButton.elt.onclick = function(e:Event) { me.first(groupElement); };
		
		if (previousButton.elt != null)
			previousButton.elt.onclick = function(e:Event) { me.previous(groupElement); };
		
		if (nextButton.elt != null)
			nextButton.elt.onclick = function(e:Event) { me.next(groupElement); };
		
		if (lastButton.elt != null)
			lastButton.elt.onclick = function(e:Event) { me.last(groupElement); };
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
			var rootParent : HtmlDom = cast rootElement.parentNode;
			var results = rootParent.getElementsByAttribute("data-"+searchedPair.eltAttrId, "*");
			
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
		
		rootElement.parentNode.appendChild(buttonContainer);
	}
	
	public function onPlayableFirst():Void
	{
		firstButton.elt.style.display = "none";
		previousButton.elt.style.display = "none";
	}
	
	public function onPlayableLast():Void
	{
		nextButton.elt.style.display = "none";
		lastButton.elt.style.display = "none";
	}
	
	public function onPlayableChange():Void
	{
		firstButton.elt.style.display = previousButton.elt.style.display = nextButton.elt.style.display = lastButton.elt.style.display = "block";
	}
	
}