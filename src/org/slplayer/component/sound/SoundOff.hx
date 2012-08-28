package org.slplayer.component.sound;

import js.Lib;
import js.Dom;

/**
 * Let you specify a button to switch on/off the sound of the whole app
 */
@tagNameFilter("a")
class SoundOff extends SoundOn
{
	/**
	 * constant, name of this class
	 */
	public static inline var CLASS_NAME:String = "SoundOff";
	/**
	 * user clicked the button
	 * turn on/off the sound
	 * show/hide the on/off buttons
	 */
	override private function onClick(e:Event)
	{
		trace("Sound onClick");
		SoundOn.mute(true);
	}
}
