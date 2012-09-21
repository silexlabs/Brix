package org.slplayer.component.navigation.transition;

import js.Lib;
import js.Dom;

import org.slplayer.component.navigation.transition.TransitionData;
import org.slplayer.util.DomTools;

/**
 * Holds the static methods used to manipulate the CSS and implement a transition system
 */
class TransitionTools
{
	public static inline var SHOW_START_STYLE_ATTR_NAME = "data-show-start-style";
	public static inline var SHOW_END_STYLE_ATTR_NAME = "data-show-end-style";
	public static inline var HIDE_START_STYLE_ATTR_NAME = "data-hide-start-style";
	public static inline var HIDE_END_STYLE_ATTR_NAME = "data-hide-end-style";


	public static inline var EVENT_TYPE_REQUEST = "transitionEventTypeRequest";
	public static inline var EVENT_TYPE_STARTED = "transitionEventTypeStarted";
	public static inline var EVENT_TYPE_ENDED = "transitionEventTypeEnded";
	/**
	 * @return the default transition data, i.e. these attributes defined on the root node: (data-show-start-style and data-show-end-style) or (data-hide-start-style and data-hide-end-style)
	 * @return null if these attributes are not defined on the root node: (data-show-start-style and data-show-end-style) or (data-hide-start-style and data-hide-end-style)
	 */
	public static function getTransitionData(rootElement:HtmlDom, type:TransitionType) : Null<TransitionData> 
	{
		var res:TransitionData = null;

		// build the attribute name
		if (type == TransitionType.show){
			var start = rootElement.getAttribute(SHOW_START_STYLE_ATTR_NAME);
			var end = rootElement.getAttribute(SHOW_END_STYLE_ATTR_NAME);
			if (start != null && end != null){
				res = {
					startStyleName : start,
					endStyleName : end,
				};
			}
		}
		else{
			var start = rootElement.getAttribute(HIDE_START_STYLE_ATTR_NAME);
			var end = rootElement.getAttribute(HIDE_END_STYLE_ATTR_NAME);
			if (start != null && end != null){
				res = {
					startStyleName : start,
					endStyleName : end,
				};
			}
		}
		return res;
	}
	public static function setTransitionProperty(rootElement:HtmlDom, name, value) 
	{
		Reflect.setProperty(rootElement.style, name, value);
	// only for pure js, not for cocktail compilation
	#if js
		// idem for Firefox
		var prefixed = "MozT"+name.substr(1);
		Reflect.setField(rootElement.style, prefixed, value);
		// idem for Safari and Chrome
		var prefixed = "webkitT"+name.substr(1);
		Reflect.setField(rootElement.style, prefixed, value);
		// idem for Opera
		var prefixed = "oT"+name.substr(1);
		Reflect.setField(rootElement.style, prefixed, value);
	#end
	}
}