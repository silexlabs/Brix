package ;

/**
 * ...
 * @author Thomas Fétiveau
 */

class Test 
{

	private function new() 
	{
		trace("test");
	}
	
	static public function create():Test
	{
		return new Test();
	}
	
}