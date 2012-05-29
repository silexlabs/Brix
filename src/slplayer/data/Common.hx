package slplayer.data;

/**
 * ...
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