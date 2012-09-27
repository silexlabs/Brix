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
package org.slplayer.core;

#if macro
import cocktail.Lib;
import cocktail.Dom;
#else
import js.Lib;
import js.Dom;
#end

/**
 * The main SLPlayer class handles the application initialization. It instanciates the components, tracking for each of them their 
 * association with their DOM rootElement. This class is based on the content of the application HTML file and is thus associated 
 * with the AppBuilder building macro.
 * 
 * @author Thomas Fétiveau
 */
class Application 
{
	/**
	 * The data- attribute set by the slplayer on the HTML elements associated with one or more component.
	 */
	static inline private var SLPID_ATTR_NAME = "slpid";
	
	/**
	 * A Hash of SLPlayer instances indexed by their id.
	 */
	static private var instances : Hash<Application> = new Hash();
	/**
	 * Gets an SLPlayer instance corresponding to an id.
	 */
	static public function get(SLPId:String):Null<Application>
	{
		return instances.get(SLPId);
	}
	
	/**
	 * The SLPlayer instance id.
	 */
	public var id(default, null) : String;
	/**
	 * The node ID sequence ( data-slpid="..." ).
	 */
	private var nodesIdSequence : Int;
	/**
	 * A Hash keeping all component instances indexed by node slplayer id.
	 */
	private var nodeToCmpInstances : Hash<List<org.slplayer.component.ui.DisplayObject>>;
	/**
	 * The SLPlayer root application node. Usually, any class used in a SLPlayer application shouldn't use 
	 * Lib.document.documentElement directly but this variable instead.
	 */
	public var htmlRootElement(default,null) : HtmlDom;
	/**
	 * The potential arguments passed to the SLPlayer class at instanciation.
	 */
	public var dataObject(default,null) : Dynamic;
	
	#if !macro
	/**
	 * For runtime only: the context containing the list of registered components, the embedded HTML...
	 */
	private var applicationContext:ApplicationContext;
	#end
	
	/**
	 * A collection of the <script> declared UI components with the optionnal data- args passed on the <script> tag.
	 * A UI component class is a child class of org.slplayer.component.ui.DisplayObject
	 */
	public var registeredUIComponents(getRegisteredUIComponents, null) : Array<RegisteredComponent>;
	public function getRegisteredUIComponents():Array<RegisteredComponent>
	{
		#if macro
		if (registeredUIComponents == null)
		{
			registeredUIComponents = new Array();
		}
		return registeredUIComponents;
		#else
		return applicationContext.registeredUIComponents;
		#end
	}
	/**
	 * A collection of the <script> declared Non UI components with the optionnal data- args passed on the <script> tag.
	 * Ideally, a component class should at least implement org.slplayer.component.ISLPlayerComponent.
	 */
	public var registeredNonUIComponents(getRegisteredNonUIComponents,null) : Array<RegisteredComponent>;
	public function getRegisteredNonUIComponents():Array<RegisteredComponent>
	{
		#if macro
		if (registeredNonUIComponents == null)
		{
			registeredNonUIComponents = new Array();
		}
		return registeredNonUIComponents;
		#else
		return applicationContext.registeredNonUIComponents;
		#end
	}

	/**
	 * The main entry point in autoStart mode. This function is implemented by the AppBuilder macro.
	 */
	static public function main()
	{
		#if !noAutoStart

			#if slpdebug
				trace("noAutoStart not defined: calling init()...");
			#end

			var newApp:Application = createApplication();

			#if (js && disableEmbedHtml)
				//special case in js when auto starting the application, 
				//we need to ensure first that the parent document is ready
				Lib.window.onload = function(e:Event) { 
					newApp.initDom(); 
					newApp.initComponents(); 
				};
			#else
				newApp.initDom(); 
				newApp.initComponents(); 
			#end

		#end
	}

	/**
	 * SLPlayer application constructor.
	 * @param	?args		optional, args of any nature from outside the SLPlayer application.
	 */
	private function new(id:String, ?args:Dynamic) 
	{
		this.dataObject = args;
		this.id = id;
		this.nodesIdSequence = 0;
		this.registeredUIComponents = new Array();
		this.registeredNonUIComponents = new Array();
		this.nodeToCmpInstances = new Hash();
		//this.metaParameters = new Hash();

		#if !macro
		this.applicationContext = new ApplicationContext();
		#end

		#if slpdebug
			trace("new SLPlayer instance built");
		#end
	}

	/**
	 * Factory method for an SLPlayer application.
	 * @param	?args		optional, args of any nature from outside the SLPlayer application.
	 * @return an instance of SLPlayer application.
	 */
	static public function createApplication(?args:Null<Dynamic>) : Application
	{
		#if slpdebug
			trace("SLPlayer createApplication() called with args="+args);
		#end

		//generate a new SLPlayerInstance id
		var newId = generateUniqueId();
		
		#if slpdebug
			trace("New SLPlayer id created : "+newId);
		#end

		//the new SLPlayer instance
		var newInstance = new Application(newId, args);
		#if slpdebug
			trace("setting ref to SLPlayer instance "+newId);
		#end
		instances.set(newId, newInstance);
		
		return newInstance;
	}

	/**
	 * Initialize the application on a given node.
	 * @param	?appendTo	optional, the parent application's node to which to hook this SLplayer application. By default or if
	 * the given node is invalid, it's the document's document element (or equivalent if not js) that is used for that.
	 */
	public function initDom(?appendTo:Null<HtmlDom>) : Void
	{
		#if slpdebug
			trace("Initializing SLPlayer id "+id+" on "+appendTo);
		#end

		//set the SLPlayer application root element
		#if slpdebug
			trace("setting htmlRootElement to "+appendTo);
		#end
		htmlRootElement = appendTo;

		//it can't be a non element node
		if (htmlRootElement == null || htmlRootElement.nodeType != Lib.document.documentElement.nodeType)
		{
			#if slpdebug
				trace("setting htmlRootElement to Lib.document.documentElement");
			#end
			htmlRootElement = Lib.document.documentElement;
		}
		
		if ( htmlRootElement == null )
		{
			#if js
			trace("ERROR Lib.document.documentElement is null => You are trying to start your application while the document loading is probably not complete yet." +
			" To fix that, add the noAutoStart option to your slplayer application and control the application startup with: window.onload = function() { myApplication.init() };");
			#else
			trace("ERROR could not set Application's root element.");
			#end
			//do not continue
			return;
		}
		
		// at macro time, htmlRootElement == Lib.document.documentElement so we already have the source html in 
		// htmlRootElement.innerHTML
		#if (!macro && !disableEmbedHtml)
			//htmlRootElement.innerHTML = ApplicationContext.getEmbeddedHtml();
			htmlRootElement.innerHTML = ApplicationContext.htmlDocumentElement;
		#end
	}
	
	/**
	 * Generates unique ids for SLPlayer instances and for HTML nodes.
	 * FIXME ? there may be a better way to get a unique id...
	 * @return String, a unique id.
	 */
	static private function generateUniqueId():String
	{
		// MD lex: this generates this php error sometimes: uncaught exception: mt_rand() [function.mt-rand]: max(-1959838343) is smaller than min(0)
		// return haxe.Md5.encode(Date.now().toString()+Std.string(Std.random(Std.int(Date.now().getTime()))));
		return Std.string(Math.round(Math.random()*10000));
	}

	/**
	 * Initialize the application's components in 2 stages : first create the instances and then call init()
	 * on each DisplayObject component.
	 */
	public function initComponents()
	{
		// build the SLPlayer instance meta parameters Hash
		//initMetaParameters();
		
		// register the application components for initialization
		//registerComponentsforInit();

		// create the UI components instances
		initNode(htmlRootElement);
		
		// create the non-UI component instances
		createNonUIComponents();
	}
	
	/**
	 * Parses and initializes all declared components on a given node.
	 * 
	 * @param node:HtmlDom the node to initialize.
	 * @return 
	 */
	public function initNode(node:HtmlDom):Void
	{
		var comps:List<org.slplayer.component.ui.DisplayObject> = createUIComponents(node);
		
		if (comps == null)
		{
			return; // case node already initialized or not an element
		}
		
		// initialization
		#if !macro
		initUIComponents(comps);
		#end
	}
	
	/**
	 * Creates the UI component instances on a given node (and recursively on its children).
	 * @param	node the DOM node where to start creating declared components
	 * @return	a List of DisplayObject.
	 */
	private function createUIComponents(node:HtmlDom):Null<List<org.slplayer.component.ui.DisplayObject>>
	{
		if ( node.nodeType != Lib.document.body.nodeType )
		{
			// works only for elements
			return null;
		}
		
		if ( node.getAttribute("data-" + SLPID_ATTR_NAME) != null )
		{
			// means that the node has already been initialized
			return null;
		}
		
		// creation and initialization are two steps. We need to store temporarly the component instances to init while
		// finishing to create them all.
		var compsToInit:List<org.slplayer.component.ui.DisplayObject> = new List();

		if (node.getAttribute("class") != null)
		{
			// we iterate on the node's class attribute values in the order they've been specified
			for (classValue in node.getAttribute("class").split(" "))
			{
				// search for any registered component that could match this class attr value
				for (rc in registeredUIComponents)
				{
					// the possible class attr values for this component
					var componentClassAttrValues:Array<String> = [getUnconflictedClassTag(rc.classname)]; // TODO FIXME, this could probably be stored somewhere to avoid doing it all the time ?

					if (componentClassAttrValues[0] != rc.classname)
					{
						componentClassAttrValues.push(rc.classname);
					}

					if (!Lambda.exists(componentClassAttrValues, function(s:String) { return s == classValue; } ))
					{
						continue;
					}
					// component identified, try now to resolve its class
					var componentClass = resolveCompClass(rc.classname); // TODO FIXME, this could probably be stored somewhere to avoid doing it all the time ?

					if (componentClass == null)
					{
						continue;
					}

					// create a new instance of this component
					var newDisplayObject = null;

					#if !stopOnError
					try
					{
					#end

						newDisplayObject = Type.createInstance( componentClass, [node, id] );

						#if slpdebug
							trace("Successfuly created instance of "+rc.classname);
						#end

					#if !stopOnError
					}
					catch ( unknown : Dynamic )
					{
						trace("ERROR while creating "+rc.classname+": "+Std.string(unknown));
						var excptArr = haxe.Stack.exceptionStack();
						if ( excptArr.length > 0 )
						{
							trace( haxe.Stack.toString(haxe.Stack.exceptionStack()) );
						}
					}
					#end

					compsToInit.add(newDisplayObject);
				}
			}
		}

		// iterate on child nodes
		for (cc in 0...node.childNodes.length)
		{
			var res = createUIComponents(node.childNodes[cc]);

			if (res != null)
			{
				compsToInit = Lambda.concat( compsToInit, res );
			}
		}

		return compsToInit;
	}
	
	/**
	 * Initializes a collection of UI component instances.
	 * @param the List of DisplayObject instances to init.
	 */
	private function initUIComponents(compInstances:List<org.slplayer.component.ui.DisplayObject>):Void
	{
		for (ci in compInstances)
		{
			#if !stopOnError
			try
			{
			#end
				
				#if slpdebug
					trace("call init() on "+Type.getClassName(Type.getClass(ci)));
				#end
				ci.init();
			
			#if !stopOnError
			}
			catch (unknown : Dynamic)
			{
				trace("ERROR while trying to call init() on a "+Type.getClassName(Type.getClass(ci))+": "+Std.string(unknown));
				var excptArr = haxe.Stack.exceptionStack();
				if ( excptArr.length > 0 )
				{
					trace( haxe.Stack.toString(haxe.Stack.exceptionStack()) );
				}
			}
			#end
		}
	}
	
	/**
	 * Instanciates the non UI components.
	 */
	private function createNonUIComponents():Void
	{
		for (rc in registeredNonUIComponents)
		{
			#if slpdebug
				trace("Try to create an instance of "+rc.classname+" non visual component");
			#end
			
			var componentClass = resolveCompClass(rc.classname);
			
			if (componentClass == null)
			{
				continue;
			}
			
			var cmpInstance = null;
			
			#if !stopOnError
			try
			{
			#end
			
				if (rc.args != null)
					cmpInstance = Type.createInstance( componentClass, [rc.args] );
				else
					cmpInstance = Type.createInstance( componentClass, [] );
				
				#if slpdebug
					trace("Successfuly created instance of "+rc.classname);
				#end
			
			#if !stopOnError
			}
			catch (unknown : Dynamic )
			{
				trace("ERROR while creating "+rc.classname+": "+Std.string(unknown));
				var excptArr = haxe.Stack.exceptionStack();
				if ( excptArr.length > 0 )
				{
					trace( haxe.Stack.toString(haxe.Stack.exceptionStack()) );
				}
			}
			#end
			
			//if the component is an SLPlayer cmp (and it should be), then try to give him its SLPlayer instance id
			if (cmpInstance != null && Std.is(cmpInstance, org.slplayer.component.ISLPlayerComponent))
			{
				cmpInstance.initSLPlayerComponent(id);
			}
		}
	}
	
	/**
	 * 
	 * @return
	 */
	private function resolveCompClass(classname:String):Class<Dynamic>
	{
		#if macro
		trace("is std.Type.resolveClass('haxe.Serializer') == null ? "+(std.Type.resolveClass("haxe.Serializer")==null));
		trace("is std.Type.resolveClass('"+classname+"') == null ? "+(std.Type.resolveClass(classname)==null));
		trace("getting module "+classname);
		haxe.macro.Context.getModule(classname);
		trace("is std.Type.resolveClass('"+classname+"') == null ? "+(std.Type.resolveClass(classname)==null));
		#end
		
		var componentClass = std.Type.resolveClass(classname);
			
		if (componentClass == null)
		{
			#if stopOnError
			throw "ERROR cannot resolve "+classname;
			#end
			trace("ERROR cannot resolve "+classname);
		}
		return componentClass;
	}
	
	/**
	 * Removes all the component instances of a given node.
	 * 
	 * @param	node
	 */
	public function cleanNode(node:HtmlDom):Void
	{
		if ( node.nodeType != Lib.document.body.nodeType )
		{
			// works only for elements
			return;
		}
		trace("clean "+node.tagName);
		var comps:List<org.slplayer.component.ui.DisplayObject> = getAssociatedComponents(node, org.slplayer.component.ui.DisplayObject);
		
		for (c in comps)
		{
			c.remove();
		}
		
		for ( childCnt in 0...node.childNodes.length )
		{
			cleanNode(node.childNodes[childCnt]);
		}
	}
	
	/**
	 * Adds a component instance to the list of associated component instances of a given node.
	 * @param	node	the node we want to add an associated component instance to.
	 * @param	cmp		the component instance to add.
	 */
	public function addAssociatedComponent(node : HtmlDom, cmp : org.slplayer.component.ui.DisplayObject) : Void
	{
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);
		
		var associatedCmps : List<org.slplayer.component.ui.DisplayObject>;
		
		if (nodeId != null)
		{
			associatedCmps = nodeToCmpInstances.get(nodeId);
		}
		else
		{
			nodesIdSequence++;
			nodeId = Std.string(nodesIdSequence);
			node.setAttribute("data-" + SLPID_ATTR_NAME, nodeId);
			associatedCmps = new List();
		}
		
		associatedCmps.add(cmp);
		
		nodeToCmpInstances.set( nodeId, associatedCmps );
	}
	/**
	 * Remove a component instance from the list of associated component instances of a given node.
	 * @param	node	the node associated with the component instance.
	 * @param	cmp		the component instance to remove.
	 */
	public function removeAssociatedComponent(node : HtmlDom, cmp : org.slplayer.component.ui.DisplayObject) : Void
	{
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);
		
		var associatedCmps : List<org.slplayer.component.ui.DisplayObject>;
		
		if (nodeId != null)
		{
			// remove the component instance
			associatedCmps = nodeToCmpInstances.get(nodeId);
			var isError = !associatedCmps.remove(cmp);
			if (isError)
			{
				throw("Could not find the component in the node's associated components list.");
			}
			if (associatedCmps.isEmpty())
			{
				// remove the node ID
				node.removeAttribute("data-" + SLPID_ATTR_NAME);
				// remove the empty list from nodeToCmpInstances
				nodeToCmpInstances.remove(nodeId);
			}
		}
		else
		{
			trace("Warning: there are no components associated with this node");
			//throw("Could not remove the components associated with this node. The node has not an ID as an attribute");
		}
	}
	/**
	 * Remove all component instances associated with a given node.
	 * @param	node	the node.
	 */
	public function removeAllAssociatedComponent(node : HtmlDom) : Void
	{
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);

		if (nodeId != null)
		{
			// remove the node ID
			node.removeAttribute("data-" + SLPID_ATTR_NAME);
			// remove all component instances
			var isError = !nodeToCmpInstances.remove(nodeId);
			if (isError)
			{
				throw("Could not find the node in the associated components list.");
			}
		}
		else
		{
			trace("Warning: there are no components associated with this node");
			//throw("Could not remove the components associated with this node. The node has not an ID as an attribute");
		}
	}
	
	/**
	 * Gets the component instance(s) associated with a given node.
	 * @param	node		the HTML node for which we search the associated component instances.
	 * @param	typeFilter	an optionnal type filter (specify here a Type or an Interface, eg : Button, Draggable, List...). 
	 * @return	a List<DisplayObject>, empty if there is no component.
	 */
	public function getAssociatedComponents<TypeFilter : org.slplayer.component.ui.DisplayObject>(node : HtmlDom, typeFilter:Class<TypeFilter>) : List<TypeFilter>
	{
		var nodeId = node.getAttribute("data-" + SLPID_ATTR_NAME);
		
		if (nodeId != null)
		{
			var l = new List<TypeFilter>();
			// if nodeToCmpInstances.exists(nodeId) is false, 
			// this is because we are on the wrong application instance
			// which means that we are looking for instances on a node which has been initialized 
			// by another instance of the SLPlayer
			if (nodeToCmpInstances.exists(nodeId)){
				for (i in nodeToCmpInstances.get(nodeId))
				{
					if (Std.is(i, typeFilter)){
						var inst:TypeFilter = cast(i);
						l.add(inst);
					}
				}
			}
			return l;
		}
		
		return new List<TypeFilter>();
	}
	
	/**
	 * Determine a class tag value for a component that won't be conflicting with other components.
	 * 
	 * @param	displayObjectClassName
	 * @return	a tag class value for the given component class name that will not conflict with other components classnames / class tags.
	 */
	public function getUnconflictedClassTag(displayObjectClassName : String) : String
	{
		var classTag = displayObjectClassName;
		
		if (classTag.indexOf(".") != -1)
			classTag = classTag.substr(classTag.lastIndexOf(".") + 1);
		
		for (rc in registeredUIComponents)
		{
			if (rc.classname != displayObjectClassName && classTag == rc.classname.substr(classTag.lastIndexOf(".") + 1))
			{
				return displayObjectClassName;
			}
		}
		
		return classTag;
	}
}

/**
 * A struct for describing a component declared in the application.
 */
typedef RegisteredComponent = 
{
	var classname : String;
	var args : Null<Hash<String>>;
}