package brix.component.sound;

import js.html.HtmlElement;
import js.html.Event;
import js.html.NodeList;
import js.Browser;

import brix.component.ui.DisplayObject;
import brix.util.DomTools;

/**
 * Let you specify a button to switch on/off the sound of the whole app
 */
@tagNameFilter("a")
class SoundOn extends DisplayObject
{
	/**
	 * constant, name of this class
	 */
	public static inline var CLASS_NAME:String = "SoundOn";
	/**
	 * true when the global sound is on
	 * read only, use mute() to change this state
	 */
	public static var isMuted(default, null):Bool = false;

	/**
	 * constructor
	 */
	public function new(rootElement:HtmlElement, brixId:String)
	{
		super(rootElement, brixId);
		rootElement.onclick = onClick;
	}

	override public function init()
	{
		DomTools.doLater(mute.bind(false));
	}

	/**
	 * user clicked the button
	 * turn on/off the sound
	 * show/hide the on/off buttons
	 */
	private function onClick(e:Event)
	{
		mute(false);
	}

	/**
	 * turn on/off the global sound
	 * show/hide the on/off buttons
	 */
	public static function mute(doMute:Bool)
	{
		// mute/unmute audio tags
		#if js
			var audioTags:NodeList = Browser.document.getElementsByTagName("audio");
			for (idx in 0...audioTags.length)
			{
				cast(audioTags[idx]).muted = doMute;
			}
		#end
		// mute/unmute all in flash (not possible in js)
		#if flash 
			if (doMute)
				flash.media.SoundMixer.soundTransform = new flash.media.SoundTransform(0);
			else
				flash.media.SoundMixer.soundTransform = new flash.media.SoundTransform(1);

		#end

		// memorize the current state
		isMuted = doMute;

		// get all the "sound on/off" button(s)
		var soundOffButtons:NodeList = Browser.document.getElementsByClassName(SoundOff.CLASS_NAME);
		var soundOnButtons:NodeList = Browser.document.getElementsByClassName(SoundOn.CLASS_NAME);

		// display/hide the sound on/off buttons
		for (idx in 0...soundOffButtons.length)
		{
			var soundOffButton : HtmlElement = cast soundOffButtons[idx];
			if (doMute)
				soundOffButton.style.visibility = "hidden";
			else
				soundOffButton.style.visibility = "visible";
		}
		// display/hide the sound on/off buttons
		for (idx in 0...soundOnButtons.length)
		{
			var soundOnButton : HtmlElement = cast soundOnButtons[idx];
			if (!doMute)
				soundOnButton.style.visibility = "hidden";
			else
				soundOnButton.style.visibility = "visible";
		}
	}
}
