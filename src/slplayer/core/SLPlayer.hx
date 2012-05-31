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
@:build(slplayer.macro.AppBuilder.buildFromHtml()) class SLPlayer 
{
	/**
	 * A Hash keeping all component instances indexed by node slplayer id.
	 */
	static private var nodeToCmpInstances = new Hash<List<DisplayObject>>();
	/**
	 * The data- attribute set by the slplayer on the HTML elements associated with one or more component.
	 */
	static private var SLPID_ATTR_NAME = "slpid";
	
	/**
	 * A collection of the <script> declared components with the optionnal data- args passed on the <script> tag.
	 */
	var registeredComponents : Hash<Null<Hash<String>>>;
	
	public function new() 
	{
		//Set the body HTML content if not js
		#if !js
			Lib.document.body.innerHTML = _htmlBody;
		#else
			#if embedHtml
				js.Lib.alert('embedHtml defined');
			#end
		#end
		
		registeredComponents = new Hash();
	}
	
	/**
	 * The main entry point of every SLPlayer application.
	 */
	public static function main()
	{
		var mySLPlayerApp = new SLPlayer();
		
		#if js
			Lib.window.onload = function (e:Event) 	{
														mySLPlayerApp.registerComponentsforInit();
														mySLPlayerApp.initComponents();
													};
		#else
			mySLPlayerApp.registerComponentsforInit();
			mySLPlayerApp.initComponents();
		#end
	}

	/**
	 * This function is filled in by the AppBuilder macro.
	 */
	private function registerComponentsforInit() { }
	
	private function registerComponent(componentClassName : String , ?args:Hash<String>)
	{
		registeredComponents.set(componentClassName, args);
	}

	/**
	 * This function.
	 */
	private function initComponents()
	{
		var registeredComponentsClassNames = registeredComponents.keys();
		
		//Create the components instances
		while (registeredComponentsClassNames.hasNext())
		{
			var registeredComponentsClassName = registeredComponentsClassNames.next();
			
			createComponentsOfType(registeredComponentsClassName, registeredComponents.get(registeredComponentsClassName));
		}
		
		//call init on each component instances
		callInitOnComponents();
	}
	
	/**
	 * This is a kind of factory method for all kinds of components (DisplayObjects and no DisplayObjects).
	 * 
	 * @param	componentClassName the full component class name (with packages, for example : slplayer.ui.player.ImagePlayer)
	 */
	private function createComponentsOfType(componentClassName : String , ?args:Hash<String>)
	{
		var componentClass = Type.resolveClass(componentClassName);
		
		if (componentClass == null)
		{
			trace("WARNING cannot resolve "+componentClassName);
			return;
		}
//trace(componentClassName+" class resolved ");
		if (isDisplayObject(componentClass)) // case DisplayObject component
		{
			var classTag = getUnconflictedClassTag(componentClassName);

			var taggedNodes : Array<HtmlDom> = new Array();
//trace("searching now for class tag = "+classTag);
			var taggedNodesCollection : HtmlCollection<HtmlDom> = untyped Lib.document.getElementsByClassName(classTag);
			for (nodeCnt in 0...taggedNodesCollection.length)
			{
				taggedNodes.push(taggedNodesCollection[nodeCnt]);
			}
			if (componentClassName != classTag)
			{
//trace("searching now for class tag = "+componentClassName);
				taggedNodesCollection = untyped Lib.document.getElementsByClassName(componentClassName);
				for (nodeCnt in 0...taggedNodesCollection.length)
				{
					taggedNodes.push(taggedNodesCollection[nodeCnt]);
				}
			}
//trace("taggedNodes = "+taggedNodes.length);
			for (node in taggedNodes)
			{
				var newDisplayObject;
				
				try
				{
					newDisplayObject = Type.createInstance( componentClass, [node] );
				
					//newDisplayObject.init(args);
				}
				catch(unknown : Dynamic ) { trace(Std.string(unknown));}
			}
		}
		else //case of non-visual component: we just try to create an instance, no call on init()
		{
			try
			{
				if (args != null)
					Type.createInstance( componentClass, [args] );
				else
					Type.createInstance( componentClass, [] );
			}
			catch(unknown : Dynamic ) { trace(Std.string(unknown));}
		}
	}
	
	private function callInitOnComponents()
	{
		for (l in nodeToCmpInstances)
		{
			for (c in l)
			{
				c.init();
			}
		}
	}
	
	/**
	 * Determine the class tag value for a component.
	 * @param	displayObjectClassName
	 * @return	a tag class value for the given component class name that will not conflict with other
	 * components classnames / class tags.
	 */
	private function getUnconflictedClassTag(displayObjectClassName : String) : String
	{
		var classTag = displayObjectClassName;
		
		if (classTag.indexOf(".") != -1)
			classTag = classTag.substr(classTag.lastIndexOf(".") + 1);
		
		var registeredComponentsClassNames = registeredComponents.keys();
		while (registeredComponentsClassNames.hasNext())
		{
			var registeredComponentClassName = registeredComponentsClassNames.next();
			
			if (classTag == registeredComponentClassName.substr(classTag.lastIndexOf(".") + 1))
				return displayObjectClassName;
		}
		return classTag;
	}
	
	/**
	 * Tells if a given class is a DisplayObject.
	 * @param	cmpClass
	 * @return	Bool
	 */
	private function isDisplayObject(cmpClass : Class<Dynamic>):Bool
	{
		if (cmpClass == Type.resolveClass("slplayer.ui.DisplayObject"))
			return true;
		
		if (Type.getSuperClass(cmpClass) != null)
			return isDisplayObject(Type.getSuperClass(cmpClass));
		
		return false;
	}
	
	/**
	 * 
	 * @param	node
	 * @param	cmp
	 */
	public static function addAssociatedComponent(node : HtmlDom, cmp : DisplayObject) : Void
	{
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