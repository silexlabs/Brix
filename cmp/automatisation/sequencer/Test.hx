package ;

import js.Lib;
import js.Dom;

import brix.component.ui.DisplayObject;

import brix.component.automatisation.Sequencer;

class Test extends DisplayObject{
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		rootElement.addEventListener("click", onCLick, true);
	}
	private function onCLick(e:Event){
		trace("onCLick");
		switch(rootElement.getAttribute("data-action")){
			case "add-blocking":
				addBlocking();
			case "add-non-blocking":
				addNonBlocking();
			case "reset-timer":
				resetTimecode();
		}
	}
	private function resetTimecode(){
		trace("resetTimecode");
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(Sequencer.SET_TIMECODE_REQUEST, false, false, 0);
		rootElement.dispatchEvent(event);
	}
	private function addNonBlocking(){
		trace("addNonBlocking");
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(Sequencer.ADD_ACTION_REQUEST, false, false, {
			onStart: function(action:Action){trace("START "+action);haxe.Timer.delay(function(){
				requestEnd(action);
			}, 1000);},
			onEnd: null,
			onCancel: null,
			metaData: null,
			blocking: false,
			timecode: 5000,
		});
		rootElement.dispatchEvent(event);
	}
	private function addBlocking(){
		trace("addBlocking");
		//trace("onMouseMove");
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(Sequencer.ADD_ACTION_REQUEST, false, false, {
			onStart: function(action:Action){trace("START "+action);haxe.Timer.delay(function(){
				requestEnd(action);
			}, 1000);},
			onEnd: null,
			onCancel: null,
			metaData: null,
			blocking: true,
			timecode: 0,
		});
		rootElement.dispatchEvent(event);
	}
	private function requestEnd(action:Action){
		trace("END "+action);
		var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
		event.initCustomEvent(Sequencer.END_ACTION_REQUEST, false, false, action);
		rootElement.dispatchEvent(event);
	}
}