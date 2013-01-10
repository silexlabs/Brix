/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.automatisation;

import js.Lib;
import js.Dom;

import brix.util.DomTools;
import brix.component.ui.DisplayObject;

/**
 * state of the sequencer
 */
enum SequencerState {
	// no blocking action is pending
	// actions may be in the line, but their time is not yet passed
	stoped;
	// a blocking action is pending
	waiting;
}
typedef Action = {
	var onStart:Action->Void,
	var onEnd:Action->Void,
	var onCancel:Action->Void,
	var metaData:Null<Dynamic>,
	var blocking: Bool,
	var timecode:Int,
}

/**
 * Sequencer class
 * This class is in charge of handling a sequence of actions
 * Actions may be executed one after another or at a given time 
 * An action is a structure holding callbacks to call at the start and end of the action, and a time for "non-blocking" actions, or a priority for "blocking" actions
 * When an action starts, the sequencer calls the start callback, 
 * and if the action is "blocking" then it waits for a ACTION_END_REQUEST event (or another provided event type) to call the end callback and skip to the next action
 */
class Sequencer extends DisplayObject
{
	////////////////////////////////////
	// constants
	////////////////////////////////////
	/**
	 * name of the event dispatched on rootElement when actions have started/stoped
	 */
	public static inline var EVENT_ACTION_STARTED = "actionStarted";
	/**
	 * name of the event dispatched on rootElement when actions have started/stoped
	 */
	public static inline var EVENT_ACTION_ENDED = "actionEnded";
	/**
	 * name of the event dispatched on rootElement when actions have started/stoped
	 */
	public static inline var EVENT_ACTION_CANCELED = "actionCanceled";
	/**
	 * name of the event which will add an action
	 */
	public static inline var ADD_ACTION_REQUEST = "addActionRequest";
	/**
	 * name of the event which will start an action "manually"
	 */
	public static inline var START_ACTION_REQUEST = "startActionRequest";
	/**
	 * name of the event which will provoque the current blocking action to be ended
	 * this is the default event type, used when you do not provide an event type
	 */
	public static inline var END_ACTION_REQUEST = "actionEndRequest";
	/**
	 * name of the event which will provoque the current blocking action to be ended
	 * this is the default event type, used when you do not provide an event type
	 */
	public static inline var CANCEL_ACTION_REQUEST = "actionCancelRequest";

	////////////////////////////////////
	// properties
	////////////////////////////////////
	/**
	 * state of the sequencer
	 * @see SequencerState
	 */
	public var state:SequencerState;
	/**
	 * the registered non blocking actions 
	 */
	private var actionsNonBlocking:Array<Action>;
	/**
	 * the registered blocking actions 
	 */
	private var actionsBlocking:Array<Action>;
	/**
	 * retrieve the appropriate actions array, depending on the type of action - blocking or not
	 */
	private function getActions(isBlocking:Bool):Array<Action>
	{
		return if(isBlocking) actionsBlocking;
		else actionsNonBlocking;
	}

	////////////////////////////////////
	// DisplayObject methods
	////////////////////////////////////
	/**
	 * constructor
	 * init properties
	 * retrieve atributes of the html dom node
	 */
	public function new(rootElement:HtmlDom, brixId:String)
	{
		super(rootElement, brixId);
		state = stoped;
		actionsBlocking = new Array();
		actionsNonBlocking = new Array();
	}
	/**
	 * init the component
	 */
	override public function init() : Void 
	{
		super.init();

		// attach the events
		mapListener(this, ADD_ACTION_REQUEST, onAddRequest, true);
		mapListener(this, START_ACTION_REQUEST, onStartRequest, true);
		mapListener(this, END_ACTION_REQUEST, onEndRequest, true);
		mapListener(this, CANCEL_ACTION_REQUEST, onCancelRequest, true);
	}

	////////////////////////////////////
	// DOM events callbacks
	////////////////////////////////////
	/**
	 * callback for the event
	 */
	public function onAddRequest(e:Event)
	{
		var action:Action = cast(e).detail;
		add(action);
	}
	/**
	 * callback for the event
	 */
	public function onStartRequest(e:Event)
	{
		var action:Action = cast(e).detail;
		end(action);
	}
	/**
	 * callback for the event
	 */
	public function onEndRequest(e:Event)
	{
		var action:Action = cast(e).detail;
		end(action);
	}
	/**
	 * callback for the event
	 */
	public function onCancelRequest(e:Event)
	{
		var action:Action = cast(e).detail;
		cancel(action);
	}
	
	////////////////////////////////////
	// Actions management callbacks
	////////////////////////////////////
	/**
	 * manage actions
	 * check if another action should be started
	 */
	private function update()
	{
		// update time
		update time

		// start new blocking actions
		if (state == stoped && actionsBlocking.length > 0)
		{
			var action = actionsBlocking[0];
			if (currentTimecode > action.timecode)
			{
				start(action);
			}
		}
		// start new non blocking actions
		for (action in actionsNonBlocking)
		{
			if (currentTimecode > action.timecode)
			{
				start(action);
			}
		}
	}
	/**
	 * add an action
	 */
	public function add(action:Action)
	{
		trace("add action "+action);
		getActions(action.blocking).push(action);
	}
	/**
	 * dispatch and event for the action start/stop/cancel
	 */
	public function start(action:Action)
	{
		if (Lambda.has(getActions(action.blocking), action)
		{
			// update the state 
			if (action.blocking)
			{
				state = waiting;
			}

			// call the action callbacks
			if(action.onStart != null)
			{
				action.onStart(action);
			}
			
			// dispatch the event to other components on the same node
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_ACTION_STARTED, true, true, action);
			rootElement.dispatchEvent(event);
		}
		else
		{
			throw("could not start action "+action+" since it was not found.");
		}
	}
	/**
	 * dispatch and event for the action start/stop/cancel
	 */
	public function end(action:Action)
	{
		// remove action 
		var exists = getActions(action.blocking).remove(action);

		if (exists)
		{
			// update the state 
			if (action.blocking)
			{
				state = stoped;
			}

			// call the action callbacks
			if(action.onEnd != null)
			{
				action.onEnd(action);
			}

			// dispatch the event to other components on the same node
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_ACTION_ENDED, true, true, action);
			rootElement.dispatchEvent(event);

			// check sequences again
			update();
		}
		else
		{
			throw("could not end action "+action+" since it was not found.");
		}
	}
	/**
	 * dispatch and event for the action start/stop/cancel
	 */
	public function cancel(action:Action)
	{
		// remove action 
		var exists = getActions(action.blocking).remove(action);

		if (exists)
		{
			// update the state 
			if (action.blocking)
			{
				state = waiting;
			}

			// call the action callbacks
			if(action.onCancel != null)
			{
				action.onCancel(action);
			}

			// dispatch the event to other components on the same node
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_ACTION_CANCELED, true, true, action);
			rootElement.dispatchEvent(event);

			// check sequences again
			update();
		}
		else
		{
			throw("could not cancel action "+action+" since it was not found.");
		}
	}
}
