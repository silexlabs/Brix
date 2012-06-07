package slplayer.core;

import js.Lib;
import js.Dom;

import slplayer.ui.DisplayObject;

import slplayer.core.SLPlayerComponent;

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
	static private var instances : Hash<SLPlayer> = new Hash();
	/**
	 * Gets an SLPlayer instance corresponding to an id.
	 */
	static public function get(SLPId:String):Null<SLPlayer>
	{
		return instances.get(SLPId);
	}
	
	/**
	 * The SLPlayer instance id.
	 */
	private var id : String;
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
	 * A collection of name => content <meta> header parameters from the source HTML page.
	 */
	private var metaParameters : Hash<String>;
	
	/**
	 * Gets a meta parameter value.
	 */
	public function getMetaParameter(metaParamKey:String):Null<String>
	{
		return metaParameters.get(metaParamKey);
	}
	
	/**
	 * SLPlayer application constructor.
	 * @param	?args		optional, args of any nature from outside the SLPlayer application.
	 */
	private function new(id:String, ?args:Dynamic) 
	{
		this.dataObject = args;
		
		this.id = id;
		
		this.registeredComponents = new Hash();
		
		this.nodeToCmpInstances = new Hash();
		
		this.metaParameters = new Hash();
		
		#if slpdebug
			trace("new SLPlayer instance built");
		#end
	}
	
	/**
	 * Launch the application on a given node.
	 * @param	?appendTo	optional, the parent application's node to which to hook this SLplayer application. By default or if
	 * the given node is invalid, it's the document's body element (or equivalent if not js) that is used for that.
	 */
	private function launch(?appendTo:Null<Dynamic>)
	{
		#if slpdebug
			trace("Launching SLPlayer id "+id+" on "+appendTo);
		#end
		
		if (appendTo != null) //set the SLPlayer application root element
			htmlRootElement = cast appendTo;
		
		//it can't be a non element node
		if (htmlRootElement == null || htmlRootElement.nodeType != Lib.document.body.nodeType)
			htmlRootElement = Lib.document.body;
		
		initHtmlRootElementContent();
		
		//build the SLPlayer instance meta parameters Hash
		initMetaParameters();
		
		//register the application components for initialization
		registerComponentsforInit();
		
		//call the UI components init() method
		initComponents();
		
		#if slpdebug
			trace("SLPlayer id "+id+" launched !");
		#end
	}
	
	/**
	 * This function is implemented by the AppBuilder macro
	 */
	private function initHtmlRootElementContent()
	{
		//#if (!js || embedHtml)
		//htmlRootElement.innerHTML = _htmlBody; // this call is added by the macro if needed
		//#end
	}
	
	/**
	 * Generates unique ids for SLPlayer instances and for HTML nodes.
	 * FIXME ? there may be a better way to get a unique id...
	 * @return String, a unique id.
	 */
	static private function generateUniqueId():String
	{
		return haxe.Md5.encode(Date.now().toString()+Std.string(Std.random(Std.int(Date.now().getTime()))));
	}
	
	/**
	 * The main entry point of every SLPlayer application. The implementation of this method is completed by the AppBuilder macro.
	 * @param	?appendTo	optional, the element (HTML DOM in js, Sprite in Flash) to which append the SLPlayer application to.
	 * @param	?args		optional, args of any nature from outside the SLPlayer application.
	 */
	static public function init(?appendTo:Dynamic, ?args:Dynamic )
	{
		#if slpdebug
			trace("SLPlayer init() called with appendTo="+appendTo+" and args="+args);
		#end
		
		//generate a new SLPlayerInstance id
		var newId = generateUniqueId();
		
		#if slpdebug
			trace("New SLPlayer id created : "+newId);
		#end
		
		//the new SLPlayer instance
		var newInstance = new SLPlayer(newId, args);
		#if slpdebug
			trace("setting ref to SLPlayer instance "+newId);
		#end
		instances.set(newId, newInstance);
	}
	
	/**
	 * The main entry point in autoStart mode. This function is implemented by the AppBuilder macro.
	 */
	static public function main() {	}
	
	/**
	 * This function is implemented by the AppBuilder macro.
	 */
	private function initMetaParameters() { }
	
	/**
	 * This function is implemented by the AppBuilder macro.
	 */
	private function registerComponentsforInit() { }
	
	private function registerComponent(componentClassName : String , ?args:Hash<String>)
	{
		registeredComponents.set(componentClassName, args);
	}

	/**
	 * Initialize the application's components in 2 stages : first create the instances and then call init()
	 * on each DisplayObject component.
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
		#if slpdebug
			trace("Creating "+componentClassName+"...");
		#end
		
		var componentClass = Type.resolveClass(componentClassName);
		
		if (componentClass == null)
		{
			trace("WARNING cannot resolve "+componentClassName);
			return;
		}
		
		#if slpdebug
			trace(componentClassName+" class resolved ");
		#end
		
		if (DisplayObject.isDisplayObject(componentClass)) // case DisplayObject component
		{
			var classTag = SLPlayerComponentTools.getUnconflictedClassTag(componentClassName, registeredComponents.keys());
			
			#if slpdebug
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
				#if slpdebug
					trace("searching now for class tag = "+componentClassName);
				#end
				
				taggedNodesCollection = untyped htmlRootElement.getElementsByClassName(componentClassName);
				for (nodeCnt in 0...taggedNodesCollection.length)
				{
					taggedNodes.push(taggedNodesCollection[nodeCnt]);
				}
			}
			
			#if slpdebug
				trace("taggedNodes = "+taggedNodes.length);
			#end
			
			for (node in taggedNodes)
			{
				var newDisplayObject;
				
				try
				{
					newDisplayObject = Type.createInstance( componentClass, [node, id] );
				}
				catch( unknown : Dynamic ) { trace(Std.string(unknown));}
			}
		}
		else //case of non-visual component: we just try to create an instance, no call on init()
		{
			#if slpdebug
				trace("Try to create an instance of "+componentClassName+" non visual component");
			#end
			
			var cmpInstance = null;
			
			try
			{
				if (args != null)
					cmpInstance = Type.createInstance( componentClass, [args] );
				else
					cmpInstance = Type.createInstance( componentClass, [] );
			}
			catch(unknown : Dynamic ) { trace(Std.string(unknown));}
			
			//if the component is an SLPlayer cmp (and it should be), then try to give him its SLPlayer instance id
			if (cmpInstance != null && Std.is(cmpInstance, ISLPlayerComponent))
			{
				cmpInstance.initSLPlayerComponent(id);
			}
		}
	}
	
	/**
	 * Initializes all registered UI component instances.
	 */
	private function callInitOnComponents():Void
	{
		#if slpdebug
			trace("call Init On Components");
		#end
		
		for (l in nodeToCmpInstances)
		{
			for (c in l)
			{
				c.init();
			}
		}
	}
	
	/**
	 * Adds a component instance to the list of associated component instances of a given node.
	 * @param	node	the node we want to add an associated component instance to.
	 * @param	cmp		the component instance to add.
	 */
	public function addAssociatedComponent(node : HtmlDom, cmp : DisplayObject) : Void
	{
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);
		
		var associatedCmps : List<DisplayObject>;
		
		if (nodeId != null)
		{
			associatedCmps = nodeToCmpInstances.get(nodeId);
		}
		else
		{
			nodeId = generateUniqueId();
			node.setAttribute("data-" + SLPID_ATTR_NAME, nodeId);
			associatedCmps = new List();
		}
		
		associatedCmps.add(cmp);
		
		nodeToCmpInstances.set( nodeId, associatedCmps );
	}
	
	/**
	 * Gets the component instance(s) associated with a given node.
	 * @param	node	the HTML node for which we search the associated component instances.
	 * @return	a List<DisplayObject>, empty if there is no component
	 */
	public function getAssociatedComponents(node : HtmlDom) : List<DisplayObject>
	{
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);
		
		if (nodeId != null)
			return nodeToCmpInstances.get(nodeId);
		
		return new List();
	}
}
