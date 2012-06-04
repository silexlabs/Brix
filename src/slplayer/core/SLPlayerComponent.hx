package slplayer.core;

/**
 * The toolbox for SLPlayer components.
 * @author Thomas Fétiveau
 */
class SLPlayerComponent 
{
	static public function initSLPlayerComponent(component : ISLPlayerComponent, SLPlayerInstanceId : String)
	{
		component.SLPlayerInstanceId = SLPlayerInstanceId;
	}
}

/**
 * The interface each SLPlayer component should implement to standardly retreive their SLPlayer instance.
 * @author Thomas Fétiveau
 */
interface ISLPlayerComponent
{
	public var SLPlayerInstanceId : String;
}