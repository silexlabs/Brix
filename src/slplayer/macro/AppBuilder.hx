package slplayer.macro;

import sys.FileSystem;

import haxe.macro.Expr;

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
	static inline public var SLP_USE_ATTR_NAME = "slp-use";
	/**
	 * The path to the application HTML source page.
	 */
	static public var htmlSourcePage = "index.html";
	
	
	/**
	 * The js exposed name.
	 */
	static private var jsExposedName : String;
	/**
	 * The expressions array of the initMetaParameters() method.
	 */
	static private var initMetaParametersExprs;
	/**
	 * The expressions array of the registerComponentsforInit() method.
	 */
	static private var registerComponentsforInitExprs;
	/**
	 * The expressions array of the main() method.
	 */
	static private var mainExprs;
	/**
	 * The expressions array of the init() method.
	 */
	static private var initExprs;
	/**
	 * The expressions array of the initHtmlRootElementContent() method.
	 */
	static private var initHtmlRootElementContentExprs;
	/**
	 * TODO comment
	 */
	static private var registeredComponents : Hash<Iterable<String>> = new Hash();
	
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
	static private function discoverSLPlayerMethods(fields : Array<Field>)
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
		//Initial check
		if (!FileSystem.exists(htmlSourcePage))
			throw htmlSourcePage + " not found !";
		
		//read the source page
		var rowHtmlContent = neko.io.File.getContent(htmlSourcePage);
		
		//source HTML content parsing
		var htmlContent : Xml = haxe.xml.Parser.parse(rowHtmlContent);
		
		var pos;
		
		var fields = haxe.macro.Context.getBuildFields();
		
		//parse the SLPlayer class fields to find the methods to fill in
		discoverSLPlayerMethods(fields);

		for ( elt in htmlContent.firstElement().elements() )
		{
			switch(elt.nodeName.toLowerCase())
			{
				case "head":
					
					for (headElt in elt.elements())
					{
						switch(headElt.nodeName.toLowerCase())
						{
							case "script":
								
								var cmpClassName = headElt.get("data-"+SLP_USE_ATTR_NAME);
								
								if (cmpClassName == null)
									continue;
								
								#if slp-debug
									trace("component found => "+cmpClassName);
								#end
								
								var initArgsElts:Iterable<String> = { iterator : headElt.attributes };
								
								registeredComponents.set(cmpClassName, initArgsElts);
								
								pos = haxe.macro.Context.currentPos();
								
								//generate import
								registerComponentsforInitExprs.push(generateImport(cmpClassName));
								
								if (Lambda.exists(initArgsElts, function(atName:String) { return StringTools.startsWith( atName , "data-" ) && atName != "data-"+SLP_USE_ATTR_NAME; } )) //case the component initialization takes arguments (other than src or type)
								{
									var argsArrayName = StringTools.replace( cmpClassName , ".", "" ) + "Args";
									registerComponentsforInitExprs.push( { expr : EVars([ { expr : { expr : ENew( { name : "Hash", pack : [], params : [], sub : null }, []), pos : pos }, name : argsArrayName, type : TPath( { name : "Hash", pack : [], params : [TPType(TPath( { name : "String", pack : [], params : [], sub : null } ))], sub : null } ) } ]), pos : pos } );
									
									for (initArgElt in initArgsElts)
									{
										if (StringTools.startsWith( initArgElt , "data-" ) && initArgElt != "data-"+SLP_USE_ATTR_NAME)
											registerComponentsforInitExprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent(argsArrayName)), pos : pos }, "set"), pos : pos }, [ { expr : EConst(CString(initArgElt)), pos : pos }, { expr : EConst(CString(headElt.get(initArgElt))), pos : pos } ]), pos : pos } );
									}
									
									//generate call to registerComponent with additionnal arguments
									registerComponentsforInitExprs.push( { expr : ECall( { expr : EConst(CIdent("registerComponent")), pos : pos }, [ { expr : EConst(CString(cmpClassName)), pos : pos }, { expr : EConst(CIdent(argsArrayName)), pos : pos } ]), pos : pos } );
								}
								else
								{
									//generate call to registerComponent with no additionnal arguments
									registerComponentsforInitExprs.push( { expr : ECall( { expr : EConst(CIdent("registerComponent")), pos : pos }, [ { expr : EConst(CString(cmpClassName)), pos : pos } ] ) , pos : pos } );
								}
								
								#if slp-debug
									trace("added call to registerComponent("+cmpClassName+")");
								#end
								
								if (headElt.get("src") == null)
								{
									//remove the element as it won't be useful at runtime
									elt.removeChild(headElt);
								}
								else
								{
									//remove the "data-"+SLP_USE_ATTR_NAME attribute but leave the tag as there is a src attr
									elt.remove("data-" + SLP_USE_ATTR_NAME);
								}
							
							case "meta":
								
								if (headElt.get("name") == null)
									continue;
								
								pos = haxe.macro.Context.currentPos();
								
								#if slp-debug
									trace("found meta parameter : "+headElt.get("name")+" => "+headElt.get("content"));
								#end
								
								//interpret meta parameter
								var compilerFlags = ["noAutoStart", "embedHtml"];
		
								if ( Lambda.exists(compilerFlags, function(s:String) { return s == headElt.get("name"); } ) && headElt.get("content") == "true" )
								{
									//we define the tag for the compilation
									haxe.macro.Compiler.define(headElt.get("name"));
									//and remove the meta tag from the HTML (no need at runtime)
									elt.removeChild(headElt);
									continue;
								}
								
								if (headElt.get("name") == "jsExposedName")
								{
									if (StringTools.replace(headElt.get("content"), " ", "") == "")
									{
										haxe.macro.Context.warning("Invalid jsExposedName value, use default one instead.", pos);
									}
									else
									{
										jsExposedName = headElt.get("content");
									}
									//no need of that at runtime, remove it from HTML
									elt.removeChild(headElt);
									continue;
								}
								
								//then it's a custom meta param (or a HTML one => manage this case ?) potentially needed at runtime
								initMetaParametersExprs.push(  { expr : ECall( { expr : EField( { expr : EConst(CIdent( "metaParameters" )), pos : pos }, "set"), pos : pos }, [ { expr : EConst(CString( headElt.get("name") )), pos : pos }, { expr : EConst(CString( headElt.get("content") )), pos : pos } ]), pos : pos }  );
								
							default:
								//trace("Application configuration node "+headElt.nodeName+" ignored.");
						}
					}
					
				case "body":
					
					if (!haxe.macro.Context.defined('js') || haxe.macro.Context.defined('embedHtml'))
					{
						//Add the _htmlBody static var to the SLPlayer class
						pos = haxe.macro.Context.currentPos();
						
						var bodyInnerHtml = haxe.Serializer.run("");
						
						if (elt.toString() != null)
						{
							bodyInnerHtml = haxe.Serializer.run(elt.toString());
						}
						
						var htmlBodyFieldValue = { expr : ECall({ expr : EField({ expr : EType({ expr : EConst(CIdent("haxe")), pos : pos }, "Unserializer"), pos : pos }, "run"), pos : pos },[{ expr : EConst(CString(bodyInnerHtml)), pos : pos }]), pos : pos };
						
						fields.push( { name : "_htmlBody", doc : null, meta : [], access : [APrivate, AStatic], kind : FVar(null, htmlBodyFieldValue), pos : pos } );
							
						#if slp-debug
							trace("bodyInnerHtml extracted and set on SLPlayer with a length of "+bodyInnerHtml.length);
						#end
						
						//Add initalization expr of htmlRootElement.innerHTML to _htmlBody
						initHtmlRootElementContentExprs.push({ expr : EBinop(OpAssign, { expr : EField( { expr : EConst(CIdent("htmlRootElement")), pos : pos }, "innerHTML"), pos : pos }, { expr : EConst(CIdent("_htmlBody")), pos : pos } ), pos : pos });
					}
					
				default:
					
					#if slp-debug
						trace("Main application node " + elt.nodeName + " ignored.");
					#end
			}
		}
		
		if (haxe.macro.Context.defined('js'))
		{
			packForJs(htmlContent.toString());
		}
		
		if (!haxe.macro.Context.defined('noAutoStart'))
		{
			//if the noAutoStart method is not set, then add a call to init() in the SLPlayer main method.
			mainExprs.push({ expr : ECall( { expr : EConst(CIdent("init")), pos : pos }, [ ] ) , pos : pos });
		}
		
		if (haxe.macro.Context.defined('js') && !haxe.macro.Context.defined('embedHtml'))
		{
			//Add this call in init() method :  Lib.window.onload = function (e:Event) 	{ newInstance.launch(appendTo); };
			initExprs.push( { expr : EBinop(OpAssign, { expr : EField( { expr : EField( { expr : EConst(CType("Lib")), pos : pos }, "window"), pos : pos }, "onload"), pos : pos }, { expr : EFunction(null, { args : [ { name : "e", type : TPath( { name: "Event", pack : [], params : [], sub : null } ), opt : false, value : null } ], expr : { expr : EBlock([ { expr : ECall( { expr : EField( { expr : EConst(CIdent("newInstance")), pos : pos }, "launch"), pos : pos }, [ { expr : EConst(CIdent("appendTo")), pos : pos } ]), pos : pos } ]), pos : pos }, params : [], ret : null } ), pos : pos } ), pos : pos } );
		}
		else
		{
			//Add this call in init method : newInstance.launch(appendTo);
			initExprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent("newInstance")), pos : pos }, "launch"), pos : pos }, [ { expr : EConst(CIdent("appendTo")), pos : pos } ]), pos : pos } );
		}
		
		return fields;
	}
	
	/**
	 * TODO
	 */
	static function checkComponents() : Void
	{
		/*
		for (rc in { iterator : registeredComponents.keys } )
		{
			var cmpClass = Type.resolveClass(rc);
			
			if (cmpClass != null)
			{
				if (slplayer.core.SLPlayerComponentTools.isDisplayObject(cmpClass))
				{
					var unconflictedClassName = slplayer.core.SLPlayerComponentTools.getUnconflictedClassTag(cmpClass);
					
					
					
						//compile time check on required tag name if DisplayObject
						slplayer.core.SLPlayerComponentTools.checkFilterOnElt(cmpClass, );
						
						//compile time check on required parameters
						slplayer.core.SLPlayerComponentTools.checkRequiredParameters(cmpClass, );
					
				}
				else
				{
					compile time check on required parameters on all other components
					TODO
				}
			}
		}
		*/
	}
	
	/**
	 * Performs the js-specific compile config and output generating tasks.
	 */
	static function packForJs(compiledHTML:String) : Void
	{
		var pos = haxe.macro.Context.currentPos();
		
		var output = haxe.macro.Compiler.getOutput();
		
		//the compiled SLPlayer application filename
		var outputFileName = output;
		
		if (output.indexOf('/') != -1)
		{
			outputFileName = output.substr(output.lastIndexOf('/') + 1, (( output.lastIndexOf('.') > -1 ) ? output.lastIndexOf('.') : output.length) - output.lastIndexOf('/') - 1);
		}
		
		//Set the js-modern mode
		if (!haxe.macro.Context.defined('js-modern'))
		{
			#if slp-debug
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
			#if slp-debug
				trace("Setting @:expose meta tag on SLPlayer class.");
			#end
			
			if (jsExposedName == null)
			{
				jsExposedName = outputFileName;
			}
			
			haxe.macro.Context.getLocalClass().get().meta.add( ":expose", [{ expr : EConst(CString(jsExposedName)), pos : pos }], pos);
		}
		
		if (!haxe.macro.Context.defined('embedHtml'))
		{
			var outputDirectory = "./";
			
			if (output.lastIndexOf('/') != null)
				outputDirectory = output.substr( 0 , output.lastIndexOf('/') + 1 );
			
			#if slp-debug
				trace("Saving "+outputDirectory + outputFileName+".html");
			#end
			
			//generates the "compiled" HTML file if not embed
			sys.io.File.saveContent( outputDirectory + outputFileName+".html" , compiledHTML );
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