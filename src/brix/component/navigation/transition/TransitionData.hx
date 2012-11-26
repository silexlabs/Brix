/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.component.navigation.transition;

/**
 * type of transition, i.e. show or hide the content
 */
enum TransitionType
{
	show;
	hide;
}

/** 
 * The transition event is a custom javascript event
 * It takes an object of this class as a data object
 * @example 	event.detail.startStyleName
 */
typedef TransitionData =
{
	var startStyleName:String;
	var endStyleName:String;
}
