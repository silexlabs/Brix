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
	 * The data- attribute set by the slplayer on the HTML elements associated with one or more component.
	 */
	static private var SLPID_ATTR_NAME = "slpid";
	/**
	 * A Hash of SLPlayer instances indexed by their id.
	 */
	static private var instance : Null<SLPlayer>;
	
	/**
	 * A Hash keeping all component instances indexed by node slplayer id.
	 */
	private var nodeToCmpInstances : Hash<List<DisplayObject>>;
	/**
	 * The SLPlayer root application node. Usually, any class used in a SLPlayer application shouldn't use 
	 * Lib.document.body directly but this variable instead.
	 */
	public var htmlRootElement(default,null) : HtmlDom;
	/**
	 * The potential arguments passed to the SLPlayer class at instanciation.
	 */
	public var dataObject(default,null) : Dynamic;
	/**
	 * A collection of the <script> declared components with the optionnal data- args passed on the <script> tag.
	 */
	private var registeredComponents : Hash<Null<Hash<String>>>;
	
	/**
	 * Gets an SLPlayer instance corresponding to an id.
	 */
	static public function get():Null<SLPlayer>
	{
		return instance;
	}
	
	/**
	 * SLPlayer application constructor.
	 * @param	?args		optional, args of any nature from outside the SLPlayer application.
	 */
	private function new(?args:Dynamic) 
	{
		dataObject = args;
		
		//Set the body HTML content if not js
		#if (!js || embedHtml)
			_htmlBody = haxe.Unserializer.run(_htmlBody);
		#end
		
		registeredComponents = new Hash();
		
		nodeToCmpInstances = new Hash();
	}
	
	/**
	 * Launch the application on a given node.
	 * @param	?appendTo	optional, the parent application's node to which to hook this SLplayer application. By default or if
	 * the given node is invalid, it's the document's body element (or equivalent if not js) that is used for that.
	 */
	private function launch(?appendTo:Dynamic)
	{
		if (appendTo != null) //set the SLPlayer application root element
			htmlRootElement = cast appendTo;
		
		//it can't be a non element node
		if (htmlRootElement == null || htmlRootElement.nodeType != Lib.document.body.nodeType)
			htmlRootElement = Lib.document.body;
		
		#if (!js || embedHtml)
			htmlRootElement.innerHTML = _htmlBody;
		#end
		
		registerComponentsforInit();
		initComponents();
	}
	
	/**
	 * The main entry point of every SLPlayer application.
	 * @param	?appendTo	optional, the element (HTML DOM in js, Sprite in Flash) to which append the SLPlayer application to.
	 * @param	?args		optional, args of any nature from outside the SLPlayer application.
	 */
	public static function init(?appendTo:Dynamic, ?args:Dynamic )
	{
		if (instance != null)
			throw "ERROR cannot build more than one instance of SLPlayer in the same runtime.";
		
		instance = new SLPlayer(args);
		
		#if (js && !embedHtml) //in js, if the HTML code isn't embedded, the SLPlayer application starts on window.onload
			Lib.window.onload = function (e:Event) 	{ instance.launch(appendTo); }; //FIXME should this be managed by SLPlayer ?! 
		#else
			instance.launch(appendTo);
		#end
	}
	
	/**
	 * The main entry point in autoStart mode.
	 */
	static public function main()
	{
		#if (js && embedHtml && !noAutoStart)
			trace("WARNING you've chosen the embedHtml option for the js target but didn't deactivate the auto start. The application will thus try to startup as soon as it's .js script will be included in your page. To deactivate auto start, use -D noAutoStart in your compile command line.");
		#end
		#if !noAutoStart
			init();
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
	 * 
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
		
		#if debug
			trace(componentClassName+" class resolved ");
		#end
		
		if (isDisplayObject(componentClass)) // case DisplayObject component
		{
			var classTag = getUnconflictedClassTag(componentClassName);
			
			#if debug
				trace("searching now for class tag = "+classTag);
			#end
			
			var taggedNodes : Array<HtmlDom> = new Array();
			
			var taggedNodesCollection : HtmlCollection<HtmlDom> = untyped htmlRootElement.getElementsByClassName(classTag);
			for (nodeCnt in 0...taggedNodesCollection.length)
			{
				taggedNodes.push(taggedNodesCollection[nodeCnt]);
			}
			if (componentClassName != classTag)
			{
				#if debug
					trace("searching now for class tag = "+componentClassName);
				#end
				
				taggedNodesCollection = untyped htmlRootElement.getElementsByClassName(componentClassName);
				for (nodeCnt in 0...taggedNodesCollection.length)
				{
					taggedNodes.push(taggedNodesCollection[nodeCnt]);
				}
			}
			
			#if debug
				trace("taggedNodes = "+taggedNodes.length);
			#end
			
			for (node in taggedNodes)
			{
				var newDisplayObject;
				
				try
				{
					newDisplayObject = Type.createInstance( componentClass, [node] );
				}
				catch(unknown : Dynamic ) { trace(Std.string(unknown));}
			}
		}
		else //case of non-visual component: we just try to create an instance, no call on init()
		{
			#if debug
				trace("Try to create an instance of "+componentClassName+" non visual component");
			#end
		
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
	
	/**
	 * Initializes all registered component instances.
	 */
	private function callInitOnComponents():Void
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
	 * @param	cmpClass	the Class to check.
	 * @return	Bool		true if DisplayObject is in the Class inheritance tree.
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
	 * Adds a component instance to the list of associated component instances of a given node.
	 * @param	node	the node we want to add an associated component instance to.
	 * @param	cmp		the component instance to add.
	 */
	public static function addAssociatedComponent(node : HtmlDom, cmp : DisplayObject) : Void
	{
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);
		
		var associatedCmps : List<DisplayObject>;
		
		if (nodeId != null)
		{
			associatedCmps = instance.nodeToCmpInstances.get(nodeId);
		}
		else
		{
			//FIXME ? there may be a better way to get a unique id...
			nodeId = haxe.Md5.encode(Std.string(Math.random()) + Date.now().toString());
			node.setAttribute("data-" + SLPID_ATTR_NAME, nodeId);
			associatedCmps = new List();
		}
		
		associatedCmps.add(cmp);
		
		instance.nodeToCmpInstances.set( nodeId, associatedCmps );
	}
	
	/**
	 * Gets the component instance(s) associated with a given node.
	 * @param	node	the HTML node for which we search the associated component instances.
	 * @return	null if no associated component, else a List<DisplayObject>.
	 */
	public static function getAssociatedComponents(node : HtmlDom) : Null<List<DisplayObject>>
	{
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);
		
		if (nodeId != null)
			return instance.nodeToCmpInstances.get(nodeId);
		
		return null;
	}
}