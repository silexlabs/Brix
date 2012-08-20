package org.slplayer.component.sound;

import js.Lib;
import js.Dom;

import org.slplayer.component.ui.DisplayObject;

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
	public function new(rootElement:HtmlDom, SLPId:String)
	{
		super(rootElement, SLPId);
		rootElement.onclick = onClick;
	}

	override public function init()
	{
		mute(false);
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
		trace("Sound mute "+doMute);
		// mute/unmute audio tags
		#if js
			var audioTags:HtmlCollection<HtmlDom> = Lib.document.getElementsByTagName("audio");
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
		var soundOffButtons:HtmlCollection<HtmlDom> = Lib.document.getElementsByClassName(SoundOff.CLASS_NAME);
		var soundOnButtons:HtmlCollection<HtmlDom> = Lib.document.getElementsByClassName(SoundOn.CLASS_NAME);

		// display/hide the sound on/off buttons
		for (idx in 0...soundOffButtons.length)
		{
			if (doMute)
				soundOffButtons[idx].style.visibility = "hidden";
			else
				soundOffButtons[idx].style.visibility = "visible";
		}
		// display/hide the sound on/off buttons
		for (idx in 0...soundOnButtons.length)
		{
			if (!doMute)
				soundOnButtons[idx].style.visibility = "hidden";
			else
				soundOnButtons[idx].style.visibility = "visible";
		}
	}
}
