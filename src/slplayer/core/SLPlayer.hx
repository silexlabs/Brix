package slplayer.core;

import js.Lib;
import js.Dom;

import slplayer.ui.DisplayObject;

/**
 * The main SLPlayer class handles the application initialization. It instanciates the components, tracking for each of them their 
 * association with their DOM rootElement. This class is based on the content of the application HTML file and is thus associated 
 * with the AppBuilder building macro.
 * @author Thomas Fétiveau
 */
@:build(slplayer.macro.AppBuilder.buildFromHtml('index.html')) class SLPlayer 
{
	/**
	 * A Hash keeping all component instances indexed by node slplayer id.
	 */
	static private var nodeToCmpInstances = new Hash<List<DisplayObject>>();
	/**
	 * The data- attribute set by the slplayer on the HTML elements associated with one or more component.
	 */
	static private var SLPID_ATTR_NAME = "slpid";
	
	public function new() 
	{
		//Set the body HTML content if not js
		#if !js
			Lib.document.body.innerHTML = _htmlBody;
		#end
	}
	
	/**
	 * The main entry point of every SLPlayer application.
	 */
	public static function main()
	{
		var mySLPlayerApp = new SLPlayer();
		
		#if js
			Lib.window.onload = function (e:Event) { mySLPlayerApp.initDisplayObjects(); };
		#else
			mySLPlayerApp.initDisplayObjects();
		#end
	}

	/**
	 * This function is filled in by the AppBuilder macro.
	 */
	private function initDisplayObjects() { }
	
	/**
	 * This is a kind of factory method for all kinds of components. This may need some cleanup...
	 * 
	 * TODO determine if it wouldn't be better to pass directly the Class. We would however loose the benefit of resolving it. but we could try catch the exceptions...
	 * 
	 * @param	displayObjectClassName the full component class name (with packages, for example : slplayer.ui.player.ImagePlayer)
	 */
	private function initDisplayObjectsOfType(displayObjectClassName : String , ?args:Hash<String>)
	{
trace("initDisplayObjectsOfType called with displayObjectClassName="+displayObjectClassName);
		
		var displayObjectClass = Type.resolveClass(displayObjectClassName);
		
		if (displayObjectClass != null) // case DisplayObject component
		{
			var tagClassName = Reflect.field(displayObjectClass, "className");
			
trace(displayObjectClassName+" class resolved and its tag classname is "+tagClassName);
			
			if (tagClassName != null)
			{
				var taggedNodes : Array<HtmlDom> = untyped Lib.document.getElementsByClassName(tagClassName);
trace("taggedNodes = "+taggedNodes.length);
				for (nodeCnt in 0...taggedNodes.length)
				{
					var newDisplayObject;
					
					try
					{
						newDisplayObject = Type.createInstance( displayObjectClass, [taggedNodes[nodeCnt]] );
					
						newDisplayObject.init(args);
					}
					catch(unknown : Dynamic ) { trace(Std.string(unknown));}
				}
			}
			else //case of non-visual component: we just try to create an instance, no call on init()
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
	
	/**
	 * 
	 * @param	node
	 * @param	cmp
	 */
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
	
	/**
	 * 
	 * @param	node
	 * @return
	 */
	public static function getAssociatedComponents(node : HtmlDom) : Null<List<DisplayObject>>
	{
		//return cast Reflect.field(node, "slPlayerCmps");
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);
		
		if (nodeId != null)
			return nodeToCmpInstances.get(nodeId);
		
		return null;
	}
}