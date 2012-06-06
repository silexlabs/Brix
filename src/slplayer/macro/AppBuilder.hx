package slplayer.macro;

import haxe.macro.Expr;

import haxe.macro.Type;

/**
 * The Builder macro of any SLPlayer application.
 * This is the central point of the SLPlayer workflow. SLPlayer builds the application from a single HTML file thanks to this macro.
 * 
 * @author Thomas Fétiveau
 */
class AppBuilder 
{
	/**
	 * The data- attribute set by the slplayer on the HTML elements associated with one or more component.
	 */
	static inline public var SLP_USE_ATTR_NAME : String = "slp-use";
	/**
	 * The path to the application HTML source page.
	 */
	static public var htmlSourcePage : String = "index.html";
	
	
	/**
	 * The js exposed name.
	 */
	static private var jsExposedName : String;
	/**
	 * The expressions array of the initMetaParameters() method.
	 */
	static private var initMetaParametersExprs : Array<haxe.macro.Expr>;
	/**
	 * The expressions array of the registerComponentsforInit() method.
	 */
	static private var registerComponentsforInitExprs : Array<haxe.macro.Expr>;
	/**
	 * The expressions array of the main() method.
	 */
	static private var mainExprs : Array<haxe.macro.Expr>;
	/**
	 * The expressions array of the init() method.
	 */
	static private var initExprs : Array<haxe.macro.Expr>;
	/**
	 * The expressions array of the initHtmlRootElementContent() method.
	 */
	static private var initHtmlRootElementContentExprs : Array<haxe.macro.Expr>;
	/**
	 * The expressions array of the init() method.
	 */
	static private var fields : Array<haxe.macro.Field>;
	/**
	 * A Collection of the components declared in the application (ie: in the HTML source) along 
	 * with their static params (any data-... attribute set on the <script> tag). Looks like :
	 * [ <ComponentClassName> => [ <data-attribute-Name> => <data-attribute-Value>, ... ], ... ]
	 */
	static private var registeredComponents : Hash<Hash<String>> = new Hash();
	
	/**
	 * Sets the html page from the compile command line.
	 * @param	key
	 * @param	value
	 */
	@:macro static public function setHtmlSourcePage(value:String)
	{
        htmlSourcePage = value;
        return null;
    }
	
	/**
	 * Parse the SLPlayer fields to create references to the methods to implement.
	 * @param	fields, array of SLPlayer fields
	 */
	static private function discoverSLPlayerMethods()
	{
		for (fc in 0...fields.length)
		{
			switch (fields[fc].kind)
			{
				case FFun(f) :
					
					switch (f.expr.expr)
					{
						case EBlock(exprs):
							
							if (fields[fc].name == "initMetaParameters")
								initMetaParametersExprs = exprs;
							
							if (fields[fc].name == "registerComponentsforInit")
								registerComponentsforInitExprs = exprs;
							
							if (fields[fc].name == "main")
								mainExprs = exprs;
							
							if (fields[fc].name == "init")
								initExprs = exprs;
							
							if (fields[fc].name == "initHtmlRootElementContent")
								initHtmlRootElementContentExprs = exprs;
						
						default : 
					}
					
				default : 
			}
		}
	}
	
	/**
	 * Builds an SLPlayer application from an HTML file.
	 * Splits the input HTML file in two parts: the header part and the body.
	 * The header part is used to configure the application. It also includes the components which may be used by the application.
	 * The body part is the content and layout of the application.
	 * @return	the updated SLPlayer class fields 
	 */
	@:macro static function buildFromHtml() :  Array<Field>
	{
		try
		{
			//Initial check
			if (!sys.FileSystem.exists(htmlSourcePage))
				throw htmlSourcePage + " not found !";
			
			//source HTML content reading
			cocktail.Lib.document.documentElement.innerHTML = neko.io.File.getContent(htmlSourcePage);
			
			//init fields var
			fields = haxe.macro.Context.getBuildFields();
			
			//parse the SLPlayer class fields to find the methods to fill in
			discoverSLPlayerMethods();
			
			//parse <script> elements
			parseScripts();
			
			//parse <meta> elements
			parseMetas();
			
			//parse the <body> element
			parseBody();
			
			//pack the application (interpret or set compiler flags, generate compiled HTML file...)
			pack();
		}
		catch (unknown : Dynamic) { neko.Lib.println("\nERROR : "+Std.string(unknown)); }
		
		return fields;
	}
	
	/**
	 * Parse and interpret the <body> element
	 */
	static function parseBody()
	{
		if (!haxe.macro.Context.defined('js') || haxe.macro.Context.defined('embedHtml'))
		{
			var pos = haxe.macro.Context.currentPos();
			
			//Add the _htmlBody static var to the SLPlayer class
			var bodyInnerHtml = haxe.Serializer.run("");
			
			if (cocktail.Lib.document.body.innerHTML != null)
			{
				bodyInnerHtml = haxe.Serializer.run(cocktail.Lib.document.body.innerHTML);
			}
			
			var htmlBodyFieldValue = { expr : ECall({ expr : EField({ expr : EType({ expr : EConst(CIdent("haxe")), pos : pos }, "Unserializer"), pos : pos }, "run"), pos : pos },[{ expr : EConst(CString(bodyInnerHtml)), pos : pos }]), pos : pos };
			
			fields.push( { name : "_htmlBody", doc : null, meta : [], access : [APrivate, AStatic], kind : FVar(null, htmlBodyFieldValue), pos : pos } );
				
			#if slpdebug
				trace("bodyInnerHtml extracted and set on SLPlayer with a size of "+bodyInnerHtml.length);
			#end
			
			//Add initalization expr of htmlRootElement.innerHTML to _htmlBody
			initHtmlRootElementContentExprs.push({ expr : EBinop(OpAssign, { expr : EField( { expr : EConst(CIdent("htmlRootElement")), pos : pos }, "innerHTML"), pos : pos }, { expr : EConst(CIdent("_htmlBody")), pos : pos } ), pos : pos });
		}
	}
	
	/**
	 * Parse and interpret the <meta> elements
	 */
	static function parseMetas()
	{
		var pos;
		
		var metaElts = cocktail.Lib.document.getElementsByTagName("meta");
		
		for (metaElt in metaElts)
		{
			if (metaElt.getAttribute("name") == null)
				continue;
			
			pos = haxe.macro.Context.currentPos();
			
			#if slpdebug
				trace("found meta parameter : "+metaElt.getAttribute("name")+" => "+metaElt.getAttribute("content"));
			#end
			
			//interpret the meta parameter
			var compilerFlags = ["noAutoStart", "embedHtml"]; //FIXME should this be a static var ?
			
			if ( Lambda.exists(compilerFlags, function(s:String) { return s == metaElt.getAttribute("name"); } ) && metaElt.getAttribute("content") == "true" )
			{
				//we define the tag for the compilation
				haxe.macro.Compiler.define(metaElt.getAttribute("name"));
				//and remove the meta tag from the HTML (no need at runtime)
				metaElt.parentNode.removeChild(metaElt);
				continue;
			}
			
			if (metaElt.getAttribute("name") == "jsExposedName")
			{
				if (metaElt.getAttribute("content") == null || StringTools.replace(metaElt.getAttribute("content"), " ", "") == "")
				{
					haxe.macro.Context.warning("Invalid jsExposedName value specified, will use default one instead.", pos);
				}
				else
				{
					jsExposedName = metaElt.getAttribute("content");
				}
				//no need of that at runtime, remove it from HTML
				metaElt.parentNode.removeChild(metaElt);
				continue;
			}
			
			//then it's a custom meta param (or a HTML one => manage this case ?) potentially needed at runtime
			initMetaParametersExprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent( "metaParameters" )), pos : pos }, "set"), pos : pos }, [ { expr : EConst(CString( metaElt.getAttribute("name") )), pos : pos }, { expr : EConst(CString( metaElt.getAttribute("content") )), pos : pos } ]), pos : pos } );
		}
	}
	
	/**
	 * Parse and interpret the <script> elements
	 */
	static function parseScripts()
	{
		var pos;
		
		var scriptElts = cocktail.Lib.document.getElementsByTagName("script");
		
		for (scriptElt in scriptElts)
		{
			var cmpDeclarations = scriptElt.getAttribute("data-"+SLP_USE_ATTR_NAME);
			
			if (cmpDeclarations == null || StringTools.trim(cmpDeclarations) == "" )
				continue;
			
			//Extract data- attributes
			var scriptEltAttrs : Hash<String> = new Hash();
			
			for (itCnt in 0...scriptElt.attributes.length)
			{
				if ( StringTools.startsWith( scriptElt.attributes.item(itCnt).nodeName , "data-" ) && scriptElt.attributes.item(itCnt).nodeName != "data-" + SLP_USE_ATTR_NAME )
				{
					scriptEltAttrs.set( scriptElt.attributes.item(itCnt).nodeName , scriptElt.attributes.item(itCnt).nodeValue );
				}
			}
			
			//include declared components into application
			var cmpClassNames = cmpDeclarations.split(" ");
			
			for (cmpClassName in cmpClassNames)
			{
				#if slpdebug
					trace("component found => "+cmpClassName);
				#end
				
				registeredComponents.set(cmpClassName, scriptEltAttrs);
				
				pos = haxe.macro.Context.currentPos();
				
				//generate import
				registerComponentsforInitExprs.push(generateImport(cmpClassName));
				
				if ( !Lambda.empty(scriptEltAttrs) )
				{
					//case the component has data-arguments on its script tag
					var argsArrayName = StringTools.replace( cmpClassName , ".", "_" ) + "Args";
					registerComponentsforInitExprs.push( { expr : EVars([ { expr : { expr : ENew( { name : "Hash", pack : [], params : [], sub : null }, []), pos : pos }, name : argsArrayName, type : TPath( { name : "Hash", pack : [], params : [TPType(TPath( { name : "String", pack : [], params : [], sub : null } ))], sub : null } ) } ]), pos : pos } );
					
					for ( scriptEltAttrName in {iterator : scriptEltAttrs.keys})
					{
						if (StringTools.startsWith( scriptEltAttrName , "data-" ) && scriptEltAttrName != "data-"+SLP_USE_ATTR_NAME)
							registerComponentsforInitExprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent(argsArrayName)), pos : pos }, "set"), pos : pos }, [ { expr : EConst(CString(scriptEltAttrName)), pos : pos }, { expr : EConst(CString(scriptElt.getAttribute(scriptEltAttrName))), pos : pos } ]), pos : pos } );
					}
					
					//generate call to registerComponent with additionnal arguments
					registerComponentsforInitExprs.push( { expr : ECall( { expr : EConst(CIdent("registerComponent")), pos : pos }, [ { expr : EConst(CString(cmpClassName)), pos : pos }, { expr : EConst(CIdent(argsArrayName)), pos : pos } ]), pos : pos } );
				}
				else
				{
					//generate call to registerComponent with no additionnal arguments
					registerComponentsforInitExprs.push( { expr : ECall( { expr : EConst(CIdent("registerComponent")), pos : pos }, [ { expr : EConst(CString(cmpClassName)), pos : pos } ] ) , pos : pos } );
				}
				
				#if slpdebug
					trace("added call to registerComponent("+cmpClassName+")");
				#end
			}
			
			//TODO FIXME #3 forbid the javascript inline code for flash
			
			//TODO #4 add the src="" if necessary (js) and if not found and forbid for other targets (flash)
			
			if (scriptElt.getAttribute("src") == null)
			{
				//remove the element as it won't be useful at runtime
				scriptElt.parentNode.removeChild(scriptElt);
			}
			else
			{
				//remove the "data-"+SLP_USE_ATTR_NAME attribute but leave the tag as there is a src attr
				scriptElt.removeAttribute("data-" + SLP_USE_ATTR_NAME);
			}
		}
		
		//check the registered components
		checkComponents();
	}
	
	/**
	 * 
	 * @param	type
	 * @return
	 */
	static function isDisplayObject( classType : haxe.macro.ClassType ) : Bool
	{
		if ( classType.name == "DisplayObject" && classType.pack.length == 2 && classType.pack[0] == "slplayer" && classType.pack[1] == "ui" ) // FIXME cleaner way to do that
		{
			return true;
		}
		if ( classType.superClass != null )
		{
			return isDisplayObject(classType.superClass.t.get());
		}
		return false;
	}
	
	/**
	 * Checks if the declared components can be found in the classpath and if their use 
	 * complies with their potential restriction (on html tags or attribute settings).
	 * 
	 * FIXME There is certainly some cleanup / better implementation to find...
	 */
	static function checkComponents() : Void
	{
		for (cmpClassName in { iterator : registeredComponents.keys })
		{
			var cmpType = haxe.macro.Context.getType(cmpClassName);
			
			if (cmpType == null)
			{
				throw "cannot resolve " + cmpClassName + ", ensure this class is in your application classpath.";
			}
			
			switch( cmpType ) 
			{
				case TInst( classRef , params ):
					
					var metaData = classRef.get().meta.get();
					
					if ( isDisplayObject( classRef.get() ) )
					{
						var unconflictedClassName = slplayer.core.SLPlayerComponentTools.getUnconflictedClassTag(cmpClassName, registeredComponents.keys());
						
						var tagsToSearchFor = [unconflictedClassName];
						
						if (unconflictedClassName != cmpClassName)
							tagsToSearchFor.push(cmpClassName);
						
						var taggedElts : Array<cocktail.Dom.HtmlDom> = new Array();
						
						for (tagToSearchFor in tagsToSearchFor)
						{
							taggedElts = taggedElts.concat(cocktail.Lib.document.body.getElementsByClassName(tagToSearchFor));
						}
						
						for (metaDataTag in metaData)
						{
							switch (metaDataTag.name)
							{
								case "requires":
									
									for (taggedElt in taggedElts)
									{
										var missingAttr:String = null;
										for (metaParam in metaDataTag.params)
										{
											switch (metaParam.expr) {
												case EConst(c) :
													switch(c) {
														case CString(s) :
															if ( taggedElt.getAttribute(s) == null || StringTools.trim(taggedElt.getAttribute(s)) == "" )
															{
																missingAttr = s;
																break;
															}
														default :
													}
												default :
											}
										}
										if (missingAttr != null)
										{
											throw missingAttr+" not set on "+taggedElt.nodeName+" while it's required by "+cmpClassName;
										}
									}
									
								case "tagNameFilter":
									
									for (taggedElt in taggedElts)
									{
										var requirePassed = false;
										var requiresList : Array<String> = new Array();
										for (metaParam in metaDataTag.params)
										{
											switch (metaParam.expr) {
												case EConst(c) :
													switch(c) {
														case CString(s) :
															if ( taggedElt.nodeName == s )
															{
																requirePassed = true;
																break;
															}
															else
															{
																requiresList.push(s);
															}
														default :
													}
												default :
											}
										}
										if (!requirePassed)
										{
											throw taggedElt.nodeName+" is not allowed to be a "+cmpClassName;
										}
									}
									
								default :
									
							}
						}
					}
					else
					{
						for (metaDataTag in metaData)
						{
							switch (metaDataTag.name)
							{
								case "requires":
									var missingAttr:String = null;
									for (metaParam in metaDataTag.params)
									{
										switch (metaParam.expr) {
											case EConst(c) :
												switch(c) {
													case CString(s) :
														if ( registeredComponents.get("cmpClassName").get(s) == null || StringTools.trim(registeredComponents.get("cmpClassName").get(s)) == "" )
														{
															missingAttr = s;
															break;
														}
													default :
												}
											default :
										}
									}
									if (missingAttr != null)
									{
										throw missingAttr+" not set on "+cmpClassName+" <script> declaration while it's required by the component";
									}
									
								default :
							}
						}
					}
					
				default: 
			}
		}
	}
	
	/**
	 * Pack the application : set specific compiler flags, generate HTML file, ...
	 */
	static function pack() : Void
	{
		var pos;
		
		//specific js-target application packaging
		if (haxe.macro.Context.defined('js'))
		{
			packForJs();
		}
		
		//launch method call
		if (haxe.macro.Context.defined('js') && !haxe.macro.Context.defined('embedHtml'))
		{
			pos = haxe.macro.Context.currentPos();
			
			//add this call in init() method :  Lib.window.onload = function (e:Event) 	{ newInstance.launch(appendTo); };
			initExprs.push( { expr : EBinop(OpAssign, { expr : EField( { expr : EField( { expr : EConst(CType("Lib")), pos : pos }, "window"), pos : pos }, "onload"), pos : pos }, { expr : EFunction(null, { args : [ { name : "e", type : TPath( { name: "Event", pack : [], params : [], sub : null } ), opt : false, value : null } ], expr : { expr : EBlock([ { expr : ECall( { expr : EField( { expr : EConst(CIdent("newInstance")), pos : pos }, "launch"), pos : pos }, [ { expr : EConst(CIdent("appendTo")), pos : pos } ]), pos : pos } ]), pos : pos }, params : [], ret : null } ), pos : pos } ), pos : pos } );
		}
		else
		{
			pos = haxe.macro.Context.currentPos();
			
			//Add this call in init method : newInstance.launch(appendTo);
			initExprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent("newInstance")), pos : pos }, "launch"), pos : pos }, [ { expr : EConst(CIdent("appendTo")), pos : pos } ]), pos : pos } );
		}
		
		//manage the auto start mode
		if (!haxe.macro.Context.defined('noAutoStart'))
		{
			pos = haxe.macro.Context.currentPos();
			
			//if the noAutoStart method is not set, then add a call to init() in the SLPlayer main method.
			mainExprs.push({ expr : ECall( { expr : EConst(CIdent("init")), pos : pos }, [ ] ) , pos : pos });
		}
	}
	
	/**
	 * Performs the js-specific compile config and output generating tasks.
	 */
	static function packForJs() : Void
	{
		var pos = haxe.macro.Context.currentPos();
		
		var output = haxe.macro.Compiler.getOutput();
		
		//the compiled SLPlayer application filename
		var outputFileName = output;
		
		var outputFileNameBegin = (output.indexOf('/') > -1) ? output.lastIndexOf('/') + 1 : 0 ;
		
		outputFileName = output.substr( outputFileNameBegin, (( output.lastIndexOf('.') > outputFileNameBegin ) ? output.lastIndexOf('.') : output.length) - outputFileNameBegin );
		
		
		//Set the js-modern mode
		if (!haxe.macro.Context.defined('js-modern'))
		{
			#if slpdebug
				trace("Setting js-modern mode.");
			#end
			haxe.macro.Compiler.define("js-modern");
		}
		
		//Set the SLPlayer Class exposed name for js version
		if ( haxe.macro.Context.getLocalClass().get().meta.has(":expose"))
		{
			haxe.macro.Context.warning( "You should not set manually the @:expose meta tag on SLPlayer class. SLPlayer sets it automatically to the name of your .js file." , pos );
		}
		else
		{
			if (jsExposedName == null)
			{
				jsExposedName = outputFileName;
			}
			
			#if slpdebug
				trace("Setting @:expose("+jsExposedName+") meta tag on SLPlayer class.");
			#end
			
			haxe.macro.Context.getLocalClass().get().meta.add( ":expose", [{ expr : EConst(CString(jsExposedName)), pos : pos }], pos);
		}
		
		
		if (!haxe.macro.Context.defined('embedHtml'))
		{
			//generates the "compiled" HTML file if not embed
			var outputDirectory = "./";
			
			if (output.lastIndexOf('/') != null)
				outputDirectory = output.substr( 0 , output.lastIndexOf('/') + 1 );
			
			#if slpdebug
				trace("Saving "+outputDirectory + outputFileName+".html");
			#end
			
			sys.io.File.saveContent( outputDirectory + outputFileName + ".html" , cocktail.Lib.document.documentElement.innerHTML );
		}
	}
	
	/**
	 * Generate an import expression for a given class.
	 * @param	full classname (with packages)
	 * @return	an import Expr
	 */
	static function generateImport(classname : String) : Expr
	{
		var splitedClassName = classname.split(".");
		var realClassName = splitedClassName.pop();
		
		if (splitedClassName.length > 0)
		{
			return { expr : EType( generateImportPackagePath(splitedClassName) , realClassName), pos : haxe.macro.Context.currentPos() };
		}
		return { expr : EConst(CType(classname)), pos : haxe.macro.Context.currentPos() };
	}
	
	/**
	 * Generates the package part of an import Expr.
	 * @param	path
	 * @return	an part of an import Expr
	 */
	static function generateImportPackagePath(path : Array<String>) : Expr
	{
		if (path.length > 1)
		{
			var lastPathElt = path.pop();
			return { expr : EField( generateImportPackagePath(path), lastPathElt), pos : haxe.macro.Context.currentPos() };
		}
		return { expr : EConst(CIdent(path[0])), pos : haxe.macro.Context.currentPos() };
	}
}
