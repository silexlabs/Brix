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
package slplayer.data;

/**
 * TODO clean 
 * 
 * @author Thomas Fétiveau
 */
typedef DataObject = 
{
	src : String,
	srcTitle : Null<String>,
	data : Array<Dynamic>
}

class Common 
{ 
	static var ON_DATA_EVENT_TYPE = "data";
	
	static var ON_DATA_CONSUMER_EVENT_TYPE = "newDataConsumer";
}