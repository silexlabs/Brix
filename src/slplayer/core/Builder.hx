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
package slplayer.core;

import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

using slplayer.util.MacroTools;

using StringTools;

/**
 * Implements the pre-compile and compile logic of SLPlayer.
 * 
 * @author Thomas Fétiveau
 */
class Builder 
{
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// CONSTANTS
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * The data- attribute set by the slplayer on the HTML elements associated with one or more components.
	 */
	static inline public var SLP_USE_ATTR_NAME : String = "slp-use";
	/**
	 * The SLPlayer-reserved flags which should be set as compiler flags
	 */
	static inline public var SLP_COMPILER_FLAGS = ["noAutoStart", "disableEmbedHtml", "disableFastInit"];
	/**
	 * The value (<meta name=key content=value />) to give a meta tag to make it a compiler flag
	 */
	static inline public var CUSTOM_COMPILER_FLAG_VALUE = "compile-flag";
	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// VARIABLES
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//////////////////////////
	// SET AT PRE-COMPILE TIME
	//////////////////////////
	/**
	 * Keep a reference to the path of the HTML source file.
	 */
	static private var sourceFilePath : String;
	/**
	 * A collection of custom name => content <meta> header parameters from the source HTML page.
	 */
	static private var metaParameters : Hash<String> = new Hash();
	/**
	 * A [<component name> => <component args>, ...] Hash containing the components declared in the application.
	 * FIXME find a way to expose in read only mode
	 */
	static public var declaredComponents : Hash<Hash<String>> = new Hash();
	/**
	 * The js exposed name.
	 */
	static private var jsExposedName : String;
	
	//////////////////////
	// SET AT COMPILE TIME
	//////////////////////
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
	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// MACROS
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Main entry point for the compilation of an SLPlayer application. Parses the HTML source file and presets
	 * data and flags that will be used during the compilation of the application. Also performs some initial 
	 * checking on the HTML document content, the use of the components...
	 * 
	 * @param	htmlSourcePath	The path to the application HTML source page. By default "./index.html".
	 */
	@:macro static public function create(?htmlSourcePath:String="index.html") : Void
	{
		try
		{
			sourceFilePath = htmlSourcePath;
			
			//Initial check
			if (!sys.FileSystem.exists(sourceFilePath))
				throw sourceFilePath + " not found !";
			
			//source HTML content reading
			cocktail.Lib.document.documentElement.innerHTML = sys.io.File.getContent(sourceFilePath);
			
			//parse <meta> elements
			parseMetas();
			
			//parse <script> elements
			parseScripts();
			
			//parse the <body> element
			parseBody();
		}
		catch (unknown : Dynamic) 
		{
			neko.Lib.println("\nERROR : " + Std.string(unknown));
			
			Sys.exit(1);
		}
	}
	
	/**
	 * Actually builds the SLPlayer application from what has been extracted from the HTML source.
	 * 
	 * @return Array<Field>	the fields of the application main class.
	 */
	@:macro static public function build() : Array<Field>
	{
		//init fields var
		var fields = haxe.macro.Context.getBuildFields();
		
		try
		{
			//parse the SLPlayer class fields to find the methods to fill in
			discoverSLPlayerMethods(fields);
			
			var pos = Context.currentPos();
			
			//set the metaParameters var
			for ( metaName in { iterator : metaParameters.keys } )
			{
				initMetaParametersExprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent( "metaParameters" )), pos : pos }, "set"), pos : pos }, [ { expr : EConst(CString( metaName )), pos : pos }, { expr : EConst(CString( metaParameters.get(metaName) )), pos : pos } ]), pos : pos } );
			}
			
			//add the import and init() calls for the declared components in the application
			includeComponents();
			
			//check the components restrictions (needs to be done after includeComponents() 'cause it wouldn't resolve the component classes otherwise)
			checkComponents();
			
			//embeds the html (body) within the application
			embedHTML(fields);
			
			//finalize the application compilation
			pack();
		}
		catch (unknown : Dynamic)
		{
			neko.Lib.println("\nERROR : " + Std.string(unknown));
		
			Sys.exit(1);
		}
		
		return fields;
	}
	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// HELPERS
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Parse and interpret the <meta> elements.
	 */
	static private function parseMetas() : Void
	{
		var metaElts = cocktail.Lib.document.getElementsByTagName("meta");
		
		for (metaElt in metaElts)
		{
			//do not interprete http-equiv or charset meta tags
			if (metaElt.getAttribute("name") == null)
				continue;
			
			var metaKey = metaElt.getAttribute("name");
			
			var metaValue = metaElt.getAttribute("content");
			
			#if slpdebug
				trace("Found meta parameter "+metaKey+" => "+metaValue);
			#end
			
			if ( Lambda.exists( SLP_COMPILER_FLAGS , function(s:String) { return s == metaKey; } ) && metaValue == "true" || metaValue == CUSTOM_COMPILER_FLAG_VALUE )
			{
				#if slpdebug
					trace("Setting flag " + metaKey);
				#end
				
				//define the tag for the compilation
				haxe.macro.Compiler.define(metaKey);
				
				//and remove the meta tag from the HTML (no need at runtime)
				metaElt.parentNode.removeChild(metaElt);
				
				continue;
			}
			
			if (haxe.macro.Context.defined('js') && metaKey == "jsExposedName")
			{
				if (metaValue == null || metaValue.replace( " ", "" ) == "" )
				{
					neko.Lib.println(sourceFilePath+" line "+metaElt.getLineNumber()+": Invalid jsExposedName value specified, will use default one instead.");
				}
				else
				{
					jsExposedName = metaValue;
				}
				
				//no need of that at runtime, remove it from HTML
				metaElt.parentNode.removeChild(metaElt);
				
				continue;
			}
			
			//then it's a custom meta param (or a HTML one => TODO manage this case ?) potentialy needed at runtime
			metaParameters.set( metaKey , metaValue );
		}
	}
	
	/**
	 * Parse and interpret the <script> elements.
	 */
	static private function parseScripts() : Void
	{
		var scriptElts = cocktail.Lib.document.getElementsByTagName("script");
		
		//flag telling if we've found the inclusion script tag for the application (js target with no embedHtml only)
		var appScriptInclusionFound = false;

		var applicationFileName = Compiler.getOutput();
		applicationFileName = applicationFileName.substr( (applicationFileName.indexOf('/') > -1) ? applicationFileName.lastIndexOf('/') + 1 : 0 );
		
		for (scriptElt in scriptElts)
		{
			//search for components declarations
			var cmpDeclarations = scriptElt.getAttribute("data-"+SLP_USE_ATTR_NAME);
			
			if (cmpDeclarations != null && cmpDeclarations.trim() != "" )
			{
				//extract data- attributes
				var scriptEltAttrs : Hash<String> = new Hash();
				
				for (itCnt in 0...scriptElt.attributes.length)
				{
					var scriptEltAttr = scriptElt.attributes.item(itCnt);
					
					if ( scriptEltAttr.nodeName.startsWith( "data-" ) && scriptEltAttr.nodeName != "data-" + SLP_USE_ATTR_NAME )
					{
						scriptEltAttrs.set( scriptEltAttr.nodeName , scriptEltAttr.nodeValue );
					}
				}
				
				//include declared components into application
				var cmpClassNames = cmpDeclarations.split(" ");
				
				for (cmpClassName in cmpClassNames)
				{
					#if slpdebug
						trace("component found => "+cmpClassName);
					#end
					
					declaredComponents.set( cmpClassName, scriptEltAttrs);
				}
			}
			
			//clean the <script> tag
			if ( scriptElt.getAttribute("src") == null && scriptElt.innerHTML.trim() == "" )
			{
				//remove the element as it won't be useful at runtime
				scriptElt.parentNode.removeChild(scriptElt);
			}
			else
			{
				if ( Context.defined('js') && scriptElt.getAttribute("src") != null && 
						Context.defined('disableEmbedHtml') && scriptElt.getAttribute("src").endsWith(applicationFileName) )
				{
					appScriptInclusionFound = true;
					
					#if slpdebug
						trace("Found application script inclusion ");
					#end
				}
				
				neko.Lib.println( sourceFilePath+" line "+scriptElt.getLineNumber()+": WARNING You should not include nor put any script in your HTML source file as it's not cross platform.\n" );
				
				//just remove the declare part but leave it as there may be an associated script.
				scriptElt.removeAttribute( "data-" + SLP_USE_ATTR_NAME );
			}
		}
		
		if ( Context.defined('js') && Context.defined('disableEmbedHtml') && !appScriptInclusionFound )
		{
			//Add the <script src="<application .js file>" /> in js/disableEmbedHtml mode.
			var appScriptInclusionTag = cocktail.Lib.document.createElement("script");
			appScriptInclusionTag.setAttribute( "src" , applicationFileName );
			cocktail.Lib.document.getElementsByTagName("head")[0].appendChild(appScriptInclusionTag);
			
			#if slpdebug
				trace("Adding <script src='"+applicationFileName+"'></script>");
			#end
		}
	}
	
	/**
	 * Parse and interpret the <body> element.
	 */
	static private function parseBody() : Void { }
	
	/**
	 * Checks if the declared components can be found in the classpath and if their use 
	 * complies with their potential restrictions (on html tags or attribute settings).
	 */
	static function checkComponents() : Void
	{
		for ( cmpClassName in { iterator : declaredComponents.keys } )
		{
			var cmpType;
			
			try
			{
				cmpType = Context.getType(cmpClassName);
			}
			catch (unknown:Dynamic)
			{	
				throw "cannot resolve " + cmpClassName + ", ensure this class is in your application classpath and that it compiles correctly. Cause: "+Std.string(unknown);
			}
			
			switch( cmpType ) 
			{
				case TInst( classRef , params ):
					
					var metaData = classRef.get().meta.get();
					
					if ( classRef.get().is("slplayer.ui.DisplayObject") )
					{
						var tagsToSearchFor = getUnconflictedClassTags(cmpClassName);
						
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
															if ( taggedElt.getAttribute(s) == null || taggedElt.getAttribute(s).trim() == "" )
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
											throw sourceFilePath+" line "+taggedElt.getLineNumber()+": "+missingAttr+" not set on "+taggedElt.nodeName+" while it's required by "+cmpClassName;
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
											throw sourceFilePath+" line "+taggedElt.getLineNumber()+": "+taggedElt.nodeName+" is not allowed to be a "+cmpClassName;
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
														if ( declaredComponents.get("cmpClassName").get(s) == null || declaredComponents.get("cmpClassName").get(s).trim() == "" )
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
										throw missingAttr+" not set on "+cmpClassName+" <script> declaration while it's required by the component"; //FIXME need to be able to give the line number
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
	 * Parse the SLPlayer fields to create references to the methods to implement.
	 * 
	 * @param	fields, array of SLPlayer fields
	 */
	static private function discoverSLPlayerMethods( fields : Array<Field> ) : Void
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
	 * Embeds the HTML content in the application main class.
	 */
	static public function embedHTML(fields:Array<Field>) : Void
	{
		var pos = Context.currentPos();
		
		if (!Context.defined('disableEmbedHtml'))
		{
			//add the _htmlBody static var to the SLPlayer class
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
			
			//add initalization expr of htmlRootElement.innerHTML to _htmlBody
			initHtmlRootElementContentExprs.push({ expr : EBinop(OpAssign, { expr : EField( { expr : EConst(CIdent("htmlRootElement")), pos : pos }, "innerHTML"), pos : pos }, { expr : EConst(CIdent("_htmlBody")), pos : pos } ), pos : pos });
		}
	}
	
	/**
	 * Add import and init calls for components.
	 */
	static private function includeComponents() : Void
	{
		var pos = Context.currentPos();
		
		for ( cmpClassName in { iterator : declaredComponents.keys } )
		{
			//generate import
			registerComponentsforInitExprs.push(generateImport(cmpClassName));
			
			var cmpArgs = declaredComponents.get(cmpClassName);
			
			var cmpClassType = switch( Context.getType(cmpClassName) ) { case TInst( classRef , params ): classRef.get(); default: };
			
			//TODO wouldn't it be better to initialize the components knowing that they are DisplayObjects or not, right from here
			if ( !Lambda.empty(cmpArgs) && cmpClassType.is("slplayer.ui.DisplayObject") )
			{
				//case the component has data-arguments on its script tag
				var argsArrayName = cmpClassName.replace( "." , "_" ) + "Args";
				registerComponentsforInitExprs.push( { expr : EVars([ { expr : { expr : ENew( { name : "Hash", pack : [], params : [], sub : null }, []), pos : pos }, name : argsArrayName, type : TPath( { name : "Hash", pack : [], params : [TPType(TPath( { name : "String", pack : [], params : [], sub : null } ))], sub : null } ) } ]), pos : pos } );
				
				for ( cmpArg in {iterator : cmpArgs.keys})
				{
					if (cmpArg.startsWith( "data-" ) && cmpArg != "data-"+SLP_USE_ATTR_NAME)
						registerComponentsforInitExprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent(argsArrayName)), pos : pos }, "set"), pos : pos }, [ { expr : EConst(CString(cmpArg)), pos : pos }, { expr : EConst(CString(cmpArgs.get(cmpArg))), pos : pos } ]), pos : pos } );
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
	}
	
	/**
	 * Pack the application : set specific compiler flags, generate HTML file, ...
	 */
	static function pack() : Void
	{
		var pos;
		
		//specific js-target application packaging
		if (Context.defined('js'))
		{
			packForJs();
		}
		
		//launch method call
		//FIXME it may not work with already loaded pages
		if (Context.defined('js') && Context.defined('disableEmbedHtml')) //the application is included in an existing HTML page
		{
			pos = Context.currentPos();
			
			//add this call in init() method :  Lib.window.onload = function (e:Event) 	{ newInstance.launch(appendTo); };
			initExprs.push( { expr : EBinop(OpAssign, { expr : EField( { expr : EField( { expr : EConst(CType("Lib")), pos : pos }, "window"), pos : pos }, "onload"), pos : pos }, { expr : EFunction(null, { args : [ { name : "e", type : TPath( { name: "Event", pack : [], params : [], sub : null } ), opt : false, value : null } ], expr : { expr : EBlock([ { expr : ECall( { expr : EField( { expr : EConst(CIdent("newInstance")), pos : pos }, "launch"), pos : pos }, [ { expr : EConst(CIdent("appendTo")), pos : pos } ]), pos : pos } ]), pos : pos }, params : [], ret : null } ), pos : pos } ), pos : pos } );
		}
		else
		{
			pos = Context.currentPos();
			
			//add this call in init method : newInstance.launch(appendTo);
			initExprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent("newInstance")), pos : pos }, "launch"), pos : pos }, [ { expr : EConst(CIdent("appendTo")), pos : pos } ]), pos : pos } );
		}
	}
	
	/**
	 * Performs the js-specific compile config and output generating tasks.
	 */
	static function packForJs() : Void
	{
		var pos = Context.currentPos();
		
		var output = Compiler.getOutput();
		
		//the compiled SLPlayer application filename
		var outputFileName = output;
		
		var outputFileNameBegin = (output.indexOf('/') > -1) ? output.lastIndexOf('/') + 1 : 0 ;
		
		outputFileName = output.substr( outputFileNameBegin, (( output.lastIndexOf('.') > outputFileNameBegin ) ? output.lastIndexOf('.') : output.length) - outputFileNameBegin );
		
		
		//set the js-modern mode
		if (!Context.defined('js-modern'))
		{
			#if slpdebug
				trace("Setting js-modern mode.");
			#end
			haxe.macro.Compiler.define("js-modern");
		}
		
		//set the SLPlayer Class exposed name for js version
		if ( Context.getLocalClass().get().meta.has(":expose"))
		{
			neko.Lib.println( "\nWARNING you should not set manually the @:expose meta tag on SLPlayer class. SLPlayer sets it automatically to the name of your .js file." );
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
			
			Context.getLocalClass().get().meta.add( ":expose", [{ expr : EConst(CString(jsExposedName)), pos : pos }], pos);
		}
		
		
		if (Context.defined('disableEmbedHtml'))
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
	 * 
	 * @param	full classname (with packages)
	 * @return	an import Expr
	 */
	static function generateImport(classname : String) : Expr
	{
		var splitedClassName = classname.split(".");
		var realClassName = splitedClassName.pop();
		
		if (splitedClassName.length > 0)
		{
			return { expr : EType( generateImportPackagePath(splitedClassName) , realClassName), pos : Context.currentPos() };
		}
		return { expr : EConst(CType(classname)), pos : Context.currentPos() };
	}
	
	/**
	 * Generates the package part of an import Expr.
	 * 
	 * @param	path
	 * @return	an part of an import Expr
	 */
	static function generateImportPackagePath(path : Array<String>) : Expr
	{
		if (path.length > 1)
		{
			var lastPathElt = path.pop();
			return { expr : EField( generateImportPackagePath(path), lastPathElt), pos : Context.currentPos() };
		}
		return { expr : EConst(CIdent(path[0])), pos : Context.currentPos() };
	}
	
	/**
	 * Determine a class tag value for a component that won't be conflicting with other declared components.
	 * 
	 * @param	className
	 * @return	a tag class value for the given component class name that will not conflict with other components classnames / class tags.
	 */
	static public function getUnconflictedClassTags( className : String ) : List<String>
	{
		if ( Lambda.empty(declaredComponents) )
			throw "There has been no declared components so far. You thus cannot use getUnconflictedClassTag().";
		
		var classTags : List<String> = new List();
		
		classTags.add(className);
		
		var classTag = className;
		
		if (classTag.indexOf(".") != -1)
			classTag = classTag.substr(classTag.lastIndexOf(".") + 1);
		
		var declaredCmpsClassNames = declaredComponents.keys();
		
		while (declaredCmpsClassNames.hasNext())
		{
			var declaredComponentClassName = declaredCmpsClassNames.next();
			
			if ( declaredComponentClassName != className && classTag == declaredComponentClassName.substr(classTag.lastIndexOf(".") + 1) )
			{
				return classTags;
			}
		}
		
		classTags.add(classTag);
		
		return classTags;
	}
	
	/**
	 * Gets the declared components class names that could have the given class tag. Having more than one result 
	 * in the list means the given class tag is not valid for your application (as it leads to conflicts).
	 * 
	 * @return a List of classnames.
	 */
	static public function getClassNameFromClassTag( classTag : String ) : List<String>
	{
		var classNames : List<String> = new List();
		
		for ( className in { iterator : declaredComponents.keys } )
		{
			if ( className.endsWith( classTag ) )
				classNames.add( className );
		}
		
		return classNames;
	}
}