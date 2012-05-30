package slplayer.ui.group;

import js.Dom;

/**
 * Makes a component groupable (ie: gives it a common object - the Group node - to listen to and dispatch events with its group mates).
 */
interface IGroupable
{
	var groupElement : HtmlDom;
}