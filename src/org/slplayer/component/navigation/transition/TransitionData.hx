/*
 * This file is part of SLPlayer http://www.silexlabs.org/groups/labs/slplayer/
 * 
 * This project is © 2011-2012 Silex Labs and is released under the GPL License:
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms 
 * of the GNU General Public License (GPL) as published by the Free Software Foundation; 
 * either version 2 of the License, or (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU General Public License for more details.
 * 
 * To read the license please visit http://www.gnu.org/copyleft/gpl.html
 */
package org.slplayer.component.navigation.transition;

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
 * @example 	event.detail.transitionProperty
 */
typedef TransitionData =
{
	var startStyleName:String;
	var endStyleName:String;
}
