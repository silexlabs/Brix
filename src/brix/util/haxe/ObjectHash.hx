package brix.util.haxe;

/**
 * A simple implementation of Hash table indexed by objects based on two Arrays.
 * 
 * @author Thomas Fétiveau
 */
class ObjectHash<S,T>
{
	private var _keys:Array<S>;
	
	private var _values:Array<T>;

	public function new() 
	{
		_keys = new Array();
		_values = new Array();
	}

	/**
	 * Tells if a value exists for the given key. In particular, it's useful to tell if a key has a null value versus no value.
	 * @param	key
	 * @return
	 */
	public function exists( key : S ) : Bool
	{
		return Lambda.has(_keys, key);
	}

	/**
	 * Get a value for the given key.
	 * @param	key
	 * @return
	 */
	public function get( key : S ) : Null<T>
	{
		for ( i in 0..._keys.length )
		{
			if (_keys[i]==key)
			{
				return _values[i];
			}
		}
		return null;
	}

	/**
	 * Available in flash8, flash, neko, js, php, cpp
	 * Returns an iterator of all values in the hashtable.
	 * @return
	 */
	public function iterator() : Iterator<T>
	{
		return _values.iterator();
	}

	/**
	 * Available in flash8, flash, neko, js, php, cpp
	 * Returns an iterator of all keys in the hashtable.
	 * 
	 */
	public function keys() : Iterator<S>
	{
		return _keys.iterator();
	}

	/**
	 * Removes a hashtable entry. Returns true if there was such entry.
	 */
	public function remove( key : S ) : Bool
	{
		for ( i in 0..._keys.length )
		{
			if (_keys[i]==key)
			{
				return (_values.splice(i,1)!=null && _keys.splice(i,1)!=null);
			}
		}
		return false;
	}

	/**
	 * Set a value for the given key.
	 * @param	key
	 * @param	value
	 */
	public function set( key : S, value : T ) : Void
	{
		_keys.push(key);
		_values.push(value);
	}

	/**
	 * Returns an displayable representation of the hashtable content.
	 * @return
	 */
	function toString() : String
	{
		var str:String = "";
		
		for (i in 0..._keys.length)
		{
			str += ", [" + _keys[i] + "] => " + _values[i];
		}
		
		return str;
	}
}