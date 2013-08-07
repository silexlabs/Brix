/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.automatisation;

import haxe.Timer;


import js.html.HtmlElement;

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
/**
 * state of an action
 */
enum ActionState {
	queued;
	started;
	ended;
}
/**
 * actions data
 */
typedef Action = {
	var onStart:Sequencer->Action->Void;
	var onEnd:Sequencer->Action->Void;
	var onCancel:Sequencer->Action->Void;
	var metaData:Null<Dynamic>;
	var blocking: Bool;
	var timecode:Timecode;
	var state:ActionState;
}
/**
 * type for timecode values
 * pass it in event.detail of the SET_TIMECODE_REQUEST
 */
typedef Timecode = Float;

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
	 * delay between 2 checks for the delayed actions
	 */
	public static inline var TIMER_DELAY = 250;
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
	 * end the current blocking action and start the next
	 */
	public static inline var NEXT_ACTION_REQUEST = "actionNextRequest";
	/**
	 * name of the event which will provoque the current blocking action to be ended
	 * this is the default event type, used when you do not provide an event type
	 */
	public static inline var CANCEL_ACTION_REQUEST = "actionCancelRequest";
	/**
	 * set the current time code 
	 * by default the current timecode is the system time
	 */
	public static inline var SET_TIMECODE_REQUEST = "setTimecodeRequest";

	////////////////////////////////////
	// properties
	////////////////////////////////////
	/**
	 * current time of the sequencer
	 * use the event SET_TIMECODE_REQUEST event to set the current time code
	 * by default the current timecode is the system time
	 */
	public var currentTimecode(getCurrentTimecode, null):Timecode;
	/**
	 * offset used to compute the timecode from the system current time
	 * use the event SET_TIMECODE_REQUEST event to set the current time code 
	 */
	private var timecodeOffset:Timecode;
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


	////////////////////////////////////
	// DisplayObject methods
	////////////////////////////////////
	/**
	 * retrieve the appropriate actions array, depending on the type of action - blocking or not
	 */
	private function getActions(isBlocking:Bool):Array<Action>
	{
		return if(isBlocking) actionsBlocking;
		else actionsNonBlocking;
	}
	/**
	 * compute the current time code from the current system time and the offset
	 */
	private function getCurrentTimecode():Timecode
	{
		return Date.now().getTime() + timecodeOffset;
	}

	////////////////////////////////////
	// DisplayObject methods
	////////////////////////////////////
	/**
	 * constructor
	 * init properties
	 * retrieve atributes of the html dom node
	 */
	public function new(rootElement:HtmlElement, brixId:String)
	{
		super(rootElement, brixId);
		state = stoped;
		actionsBlocking = new Array();
		actionsNonBlocking = new Array();
		timecodeOffset = 0;

		// attach the events
		mapListener(rootElement, ADD_ACTION_REQUEST, onAddRequest, true);
		mapListener(rootElement, START_ACTION_REQUEST, onStartRequest, true);
		mapListener(rootElement, END_ACTION_REQUEST, onEndRequest, true);
		mapListener(rootElement, CANCEL_ACTION_REQUEST, onCancelRequest, true);
		mapListener(rootElement, NEXT_ACTION_REQUEST, onNextRequest, true);
		mapListener(rootElement, SET_TIMECODE_REQUEST, onSetTimecodeRequest, true);

	}
	/**
	 * init the component
	 */
	override public function init() : Void 
	{
		super.init();

		// timer for delayed events
		var timer = new Timer(TIMER_DELAY);
		timer.run = update;
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
	/**
	 * callback for the event
	 */
	public function onNextRequest(e:Event)
	{
		next();
	}
	/**
	 * callback for the event
	 */
	public function onSetTimecodeRequest(e:Event)
	{
		var newTimecode:Timecode = cast(e).detail;
		timecodeOffset = newTimecode - Date.now().getTime();
		trace("onSetTimecodeRequest new timecode is "+newTimecode);
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
		//trace("Sequencer, computer time is "+Date.now().toString()+", and corrected time is "+Date.fromTime(currentTimecode).toString());
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
			if (action.state == queued && currentTimecode > action.timecode)
			{
				start(action);
				// for optimization?
				// break;
			}
		}
	}
	/**
	 * add an action
	 */
	public function add(action:Action)
	{
		// push the action in the list
		getActions(action.blocking).push(action);

		// update the action state
		action.state = queued;

		// check sequences again
		update();
	}
	/**
	 * dispatch and event for the action start/stop/cancel
	 */
	public function start(action:Action)
	{
		if (Lambda.has(getActions(action.blocking), action))
		{
			// update the sequencer state
			if (action.blocking)
			{
				state = waiting;
			}
			// update the action state
			action.state = started;

			// dispatch the event to other components on the same node
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_ACTION_STARTED, true, true, action);
			rootElement.dispatchEvent(event);

			// call the action callbacks
			if(action.onStart != null)
			{
				action.onStart(this, action);
			}
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
		// update the state 
		if (action.blocking && actionsBlocking.length>0 && actionsBlocking[0]==action)
		{
			state = stoped;
		}

		// remove action 
		var exists = getActions(action.blocking).remove(action);

		if (exists)
		{
			// update the action state
			action.state = ended;

			// dispatch the event to other components on the same node
			var event : CustomEvent = cast Lib.document.createEvent("CustomEvent");
			event.initCustomEvent(EVENT_ACTION_ENDED, true, true, action);
			rootElement.dispatchEvent(event);

			// call the action callbacks
			if(action.onEnd != null)
			{
				action.onEnd(this, action);
			}

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
			// update the action state
			action.state = ended;

			// call the action callbacks
			if(action.onCancel != null)
			{
				action.onCancel(this, action);
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
	/**
	 * dispatch and event for the action start/stop/cancel
	 */
	public function next()
	{
		if (actionsBlocking.length>0)
		{
			var action:Action = actionsBlocking[0];
			end(action);
		}
		else
		{
			throw("could not skip to next action since there is no pending action.");
		}
	}
}
