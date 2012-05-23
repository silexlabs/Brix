package slplayer.core;

import js.Lib;
import js.Dom;

import slplayer.ui.DisplayObject;

/**
 * ...
 * @author Thomas Fétiveau
 */
@:build(slplayer.macro.AppBuilder.buildFromHtml('index.html')) class SLPlayer 
{
	static private var nodeToCmpInstances = new Hash<List<DisplayObject>>();
	
	static private var SLPID_ATTR_NAME = "slpid";
	
	public function new() 
	{
		//Set the body HTML content if not js
		#if !js
			Lib.document.body.innerHTML = _htmlBody;
		#end
	}

	public static function main()
	{
		var mySLPlayerApp = new SLPlayer();
		
		#if js
			Lib.window.onload = callback(mySLPlayerApp.initDisplayObjects);
		#else
			mySLPlayerApp.initDisplayObjects(null);
		#end
	}

	/**
	 * This function is filled in by the macro.
	 * @param	e
	 */
	private function initDisplayObjects(e : Event) { }
	
	/**
	 * TODO determine if it wouldn't be better to pass directly the Class. We would however loose the benefit of resolving it. but we could try catch the exceptions...
	 * TODO Also, need to ask the mailing list if I have to use Reflect to access a Class static field.
	 * @param	displayObjectClassName
	 */
	private function initDisplayObjectsOfType(displayObjectClassName : String , ?args:Hash<String>)
	{
trace("initDisplayObjectsOfType called with displayObjectClassName="+displayObjectClassName);
		
		var displayObjectClass = Type.resolveClass(displayObjectClassName);
		
		if (displayObjectClass != null) // case DisplayObject component
		{
			var tagClassName = Reflect.field(displayObjectClass, "className");
			var tagFilter:List<String> = Reflect.field(displayObjectClass, "rootElementNameFilter");
			
trace(displayObjectClassName+" class resolved and its tag classname is "+tagClassName);
			
			if (tagClassName != null)
			{
				var taggedNodes : Array<HtmlDom> = untyped Lib.document.getElementsByClassName(tagClassName);
trace("taggedNodes = "+taggedNodes.length);
				//for (nodeCntnodeCnt in 0...taggedNodes.length)
				var nodeCnt = 0;
				while (nodeCnt < taggedNodes.length)
				{
					if ( tagFilter == null || Lambda.exists( tagFilter , function(s:String) { return taggedNodes[nodeCnt].nodeName.toLowerCase() == s.toLowerCase(); } ) )
					{
						var newDisplayObject;
						
						try
						{
							if (args != null)
								newDisplayObject = Type.createInstance( displayObjectClass, [taggedNodes[nodeCnt], args] );
							else
								newDisplayObject = Type.createInstance( displayObjectClass, [taggedNodes[nodeCnt]] );
						}
						catch(unknown : Dynamic ) { trace(Std.string(unknown));}
						
						newDisplayObject.init(null);
					}
					else
					{
						trace("ERROR: cannot instanciate "+displayObjectClassName+" on a "+taggedNodes[nodeCnt].nodeName+" tag.");
					}
					nodeCnt++;
				}
			}
			else // case non-visual component
			{
				try
				{
					if (args != null)
						Type.createInstance( displayObjectClass, [args] );
					else
						Type.createInstance( displayObjectClass, [] );
				}
				catch(unknown : Dynamic ) { trace(Std.string(unknown));}
			}
		}
	}
	
	public static function addAssociatedComponent(node : HtmlDom, cmp : DisplayObject) : Void
	{
trace("addAssociatedComponent("+node+", "+cmp+")");
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);
		
		var associatedCmps : List<DisplayObject>;
		
		if (nodeId != null)
		{
			associatedCmps = nodeToCmpInstances.get(nodeId);
		}
		else
		{
			//there may be a better way to get a unique id...
			nodeId = haxe.Md5.encode(Std.string(Math.random()) + Date.now().toString());
			node.setAttribute("data-" + SLPID_ATTR_NAME, nodeId);
			associatedCmps = new List();
		}
		
		associatedCmps.add(cmp);
		
		nodeToCmpInstances.set( nodeId, associatedCmps );
	}
	
	public static function getAssociatedComponents(node : HtmlDom) : Null<List<DisplayObject>>
	{
		//return cast Reflect.field(node, "slPlayerCmps");
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);
		
		if (nodeId != null)
			return nodeToCmpInstances.get(nodeId);
		
		return null;
	}
}