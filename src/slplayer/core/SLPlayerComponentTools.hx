package slplayer.core;

/**
 * ...
 * @author Thomas Fétiveau
 */
class SLPlayerComponentTools 
{
	/**
	 * Tells if a given class is a DisplayObject. 
	 * FIXME we should probably expose and generalize this ? (in a SLPlayerTools.hx for example)
	 * @param	cmpClass	the Class to check.
	 * @return	Bool		true if DisplayObject is in the Class inheritance tree.
	 */
	static public function isDisplayObject(cmpClass : Class<Dynamic>):Bool
	{
		if (cmpClass == Type.resolveClass("slplayer.ui.DisplayObject"))
			return true;
		
		if (Type.getSuperClass(cmpClass) != null)
			return isDisplayObject(Type.getSuperClass(cmpClass));
		
		return false;
	}
	
	/**
	 * Checks if a given element is allowed to be the component's rootElement against the tag filters.
	 * @param	elt: the DOM element to check. By default the rootElement.
	 */
	static public function checkFilterOnElt( cmpClass : Class<Dynamic> , elt:Dynamic ) : Void
	{
		#if macro
		
		var xmlElt : Xml = cast elt; trace("macro checkFilterOnElt ELT **************** ");
		var isElt = (xmlElt.nodeType == Xml.Element);
		
		#else
		
		var htmlElt : js.Dom.HtmlDom = cast elt;
		var isElt = (htmlElt.nodeType == js.Lib.document.body.nodeType); //FIXME cleaner way to do this comparison ?
		
		#end
		
		if (!isElt)
			throw "ERROR: cannot instantiate "+Type.getClassName(cmpClass)+" on a non element node.";
		
		var tagFilter = haxe.rtti.Meta.getType(cmpClass).tagNameFilter;
		
		if ( tagFilter == null)
			return;
		
		if ( Lambda.exists( tagFilter , function(s:Dynamic) { return elt.nodeName.toLowerCase() == Std.string(s).toLowerCase(); } ) )
			return;
		
		throw "ERROR: cannot instantiate "+Type.getClassName(cmpClass)+" on this type of HTML element: "+elt.nodeName.toLowerCase();
	}
	
	/**
	 * Checks if there is any missing required attribute on the associated HTML element of this component.
	 * @param	elt: the DOM element to check. By default the rootElement.
	 */
	static public function checkRequiredParameters( cmpClass : Class<Dynamic> , elt:Dynamic ) : Void
	{
		#if macro
		
		var xmlElt : Xml = cast elt;
		var getAttr : String -> Null<String> = xmlElt.get;
		
		#else
		
		var htmlElt : js.Dom.HtmlDom = cast elt;
		var getAttr : String -> Null<String> = htmlElt.getAttribute;
		
		#end
		
		var requires = haxe.rtti.Meta.getType(cmpClass).requires;
		
		if (requires == null)
			return;
		
		for (r in requires)
		{
			if ( getAttr("data-" + Std.string(r)) == null || StringTools.trim(getAttr("data-" + Std.string(r))) == "" )
			{
				throw "ERROR: data-" + Std.string(r) + " parameter is requiredcfor "+Type.getClassName(cmpClass);
			}
		}
	}
	
	/**
	 * Determine the class tag value for a component.
	 * 
	 * @param	displayObjectClassName
	 * @param 	an Iterator of Strings containing the classnames we check against.
	 * @return	a tag class value for the given component class name that will not conflict with other components classnames / class tags.
	 */
	static public function getUnconflictedClassTag(displayObjectClassName : String , registeredComponentsClassNames:Iterator<String>) : String
	{
		var classTag = displayObjectClassName;
		
		if (classTag.indexOf(".") != -1)
			classTag = classTag.substr(classTag.lastIndexOf(".") + 1);
		
		while (registeredComponentsClassNames.hasNext())
		{
			var registeredComponentClassName = registeredComponentsClassNames.next();
			
			if (classTag == registeredComponentClassName.substr(classTag.lastIndexOf(".") + 1))
			{
				return displayObjectClassName;
			}
		}
		
		return classTag;
	}
}