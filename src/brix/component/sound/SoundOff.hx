package brix.component.sound;


import js.html.HtmlElement;

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
		SoundOn.mute(true);
	}
}
