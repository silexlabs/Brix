/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.core;

import haxe.macro.Compiler;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

using brix.util.MacroTools;

import cocktail.Dom;
import cocktail.Lib;

using StringTools;
using Lambda;

/**
 * Implements the pre-compile and compile logic of Brix.
 * 
 * @author Thomas Fétiveau
 */
class Builder 
{
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// CONSTANTS
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * The data- attribute set by the brix on the HTML elements associated with one or more components.
	 */
	static inline public var BRIX_USE_ATTR_NAME : String = "data-brix-use";
	/**
	 * The Brix-reserved flags which should be set as compiler flags
	 */
	static inline public var BRIX_COMPILER_FLAGS = ["noAutoStart", "disableEmbedHtml", "disableFastInit", 
	"keepComments", "minimizeHtml"];
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
	 * Keep a reference to the path of the HTML output file.
	 */
	static private var outputFilePath : String;
	/**
	 * Keep a copy of the original HTML Source.
	 */
	static private var sourceHTMLDocument : Document;
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
	 * TODO add comments
	 */
	//static public var macroApplication : Application;// = Application.createApplication();
	
	/**
	 * The js exposed name.
	 */
	static private var jsExposedName : String;
	/**
	 * The list of HTML nodes to remove before packing.
	 */
	static private var nodesToRemove : List<HtmlDom> = new List();
	
	//////////////////////
	// SET AT COMPILE TIME
	//////////////////////
	/**
	 * The expressions array of the initMetaParameters() method.
	 */
	//static private var initMetaParametersExprs : Array<haxe.macro.Expr>;
	/**
	 * The expressions array of the registerComponentsforInit() method.
	 */
	static private var registerComponentsforInitExprs : Array<haxe.macro.Expr>;
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// MACROS
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Main entry point for the compilation of an Brix application. Parses the HTML source file and presets
	 * data and flags that will be used during the compilation of the application. Also performs some initial 
	 * checking on the HTML document content, the use of the components...
	 * 
	 * @param	htmlSourcePath	The path to the application HTML source page. By default "./index.html".
	 * @param	htmlOutputPath	The path to the generated output HTML file when using the disableEmbedHtml 
	 * option. By default, will be the same as the js/swf/... output file but with the .html extension.
	 */
	@:macro static public function create(?htmlSourcePath:String="index.html", ?htmlOutputPath:Null<String>) : Void
	{
		//try
		//{
		//TODO debug error catching: why some errors in component are catch and other not ?
			sourceFilePath = htmlSourcePath;
			outputFilePath = htmlOutputPath;
			
			//Initial check
			if (!sys.FileSystem.exists(sourceFilePath))
				throw sourceFilePath + " not found !";
			
			var htmlSource : String = sys.io.File.getContent(sourceFilePath);
			//var htmlSource : String = '<html>	<head>		<script data-brix-use="org.silex.components.Page"></script>		<script data-brix-use="org.silex.components.Layer"></script>		<script data-brix-use="org.silex.components.LinkToPage"></script>		<script data-brix-use="org.silex.components.LinkClosePage"></script>		<script data-brix-use="org.silex.components.SoundOn"></script>		<script data-brix-use="org.silex.components.SoundOff"></script>		<script data-brix-use="org.silex.components.EmailForm"></script>		<script data-brix-use="org.silex.components.SWFImport"></script>		<link rel="stylesheet" type="text/css" href="app.css" />		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 		<meta name="HomePage" content="page1"/>	</head>	<body>		<div class="main-container">			<!-- POP UPs -->			<div class="popup-container">				<a name="popup1" class="Page">Popup 1</a>				<div class="Layer popup1">					<p>Test of a popup. <br/><a href="http://itunes.apple.com/fr/artist/europa-apps/id481656283?uo=4" target="_blank">Voir les applis sur l app store</a>					</p>					<a href="#popup1" class="LinkClosePage">						<img src="assets/close.png" class="illustration" />					</a>					<div class="EmailForm" data-service-url="http://www.europa-apps.com/wpsb-opt-in.webservice.php">						<input type="text" class="email-form-text-input" />						<input type="submit" value="Submit" class="email-form-submit-button" />						<p class="email-form-messages-zone email-form-error-message email-form-success-message" />					</div>				</div>			</div>			<!-- PAGES -->			<div class="pages-container">				<!-- INTERFACE -->				<img src="assets/son-on-off.png" class="SoundOn" />				<img src="assets/son-on-off.png" class="SoundOff" />				<a href="#popup1" target="_top" class="LinkToPage">					<img src="assets/open_pop-up01.png" />				</a>				<!-- SEQ 1 -->				<a name="page1" class="Page">Page 1</a>				<div class="Layer page1">					<!-- PERSO -->					<!-- BACKGROUND -->					<object class="SWFImport" 						data="illustrations/seq1.swf">					</object>					<!-- SOUND -->					<audio autoplay="autoplay">						<source src="sounds/page1-txt.mp3" type="audio/mp3" />					</audio>					<audio autoplay="autoplay" loop="loop">						<source src="sounds/page1-bg.mp3" type="audio/mp3" />					</audio>					<!-- INTERFACE -->					<a href="#page2" class="LinkToPage next">						<img src="assets/next.png" />					</a>				</div>				<!-- SEQ 2 -->				<a name="page2" class="Page">Page 2</a>				<div class="Layer page2">					<!-- BACKGROUND -->					<object class="SWFImport"						data="illustrations/seq2.swf">					</object>					<!-- SOUND -->					<audio autoplay="autoplay">						<source src="sounds/page2-txt.mp3" type="audio/mp3" />					</audio>					<audio autoplay="autoplay" loop="loop">						<source src="sounds/page2-bg.mp3" type="audio/mp3" />					</audio>					<!-- INTERFACE -->					<a href="#page1" class="LinkToPage previous">						<img src="assets/previous.png" />					</a>					<a href="#page3" class="LinkToPage next">						<img src="assets/next.png" />					</a>				</div>				<!-- PAGE 3 -->				<a name="page3" class="Page">Page 3</a>				<div class="Layer page3">					<!-- BACKGROUND -->					<object class="SWFImport"						data="illustrations/seq3.swf">					</object>					<!-- SOUND -->					<audio autoplay="autoplay">						<source src="sounds/page3-txt.mp3" type="audio/mp3" />					</audio>					<!-- INTERFACE -->					<a href="#page2" class="LinkToPage previous">						<img src="assets/previous.png" />					</a>				</div>				<div class="Layer page2 page3 page2-3">					<p>TEST SUR 2 PAGES, PAGE 2 et 3</p>				</div>			</div>		</div>	</body></html>';
			
			//init the DOM tree from source HTML file content
			cocktail.Lib.document.innerHTML = htmlSource;
			
			//init a copy of the source DOM tree
			sourceHTMLDocument = new Document();
			sourceHTMLDocument.innerHTML = htmlSource;
			
			//parse <meta> elements
			parseMetas();
			
			//parse <script> elements
			parseScripts();
			
			//parse the <body> element
			parseBody();
		//}
		//catch (unknown : Dynamic) 
		//{
			//neko.Lib.println("\nERROR " + Std.string(unknown));
			//neko.Lib.println( haxe.Stack.toString(haxe.Stack.exceptionStack()) );
			//Sys.exit(1);
		//}
	}
	
	/**
	 * Actually builds the Brix application from what has been extracted from the HTML source.
	 * 
	 * @return Array<Field>	the fields of the application main class.
	 */
	@:macro static public function build() : Array<Field>
	{
		//init fields var
		var fields = haxe.macro.Context.getBuildFields();
		
		//try
		//{
		//TODO debug error catching: why some errors in component are catch and other not ?
			//parse the Application class fields to find the methods to fill in
			discoverApplicationContextMethods(fields);

			var pos = Context.currentPos();

			//set the metaParameters var
			//for ( metaName in { iterator : metaParameters.keys } )
			//{
				//initMetaParametersExprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent( "metaParameters" )), pos : pos }, "set"), pos : pos }, [ { expr : EConst(CString( metaName )), pos : pos }, { expr : EConst(CString( metaParameters.get(metaName) )), pos : pos } ]), pos : pos } );
			//}

			//add the import and init() calls for the declared components in the application
			includeComponents();

			//check the components restrictions (needs to be done after includeComponents() 'cause it wouldn't resolve the component classes otherwise)
			checkComponents();
			//runMacroApplication(); // temporarly commented because of http://code.google.com/p/haxe/issues/detail?id=924 but will replace checkComponents() eventually.

			//finalize the application compilation
			pack();

			//embeds the html (body) within the application
			embedHTML(fields);
		//}
		//catch (unknown : Dynamic)
		//{
			//if (unknown.message != null)
			//{
				//neko.Lib.println("\nERROR " + Std.string(unknown.message));
				//neko.Lib.println("at " + Std.string(unknown.pos).substr( 5 , Std.string(unknown.pos).length-6 ) );
			//}
			//else
			//{
				//neko.Lib.println("\nERROR " + Std.string(unknown));
				//neko.Lib.println( haxe.Stack.toString( haxe.Stack.exceptionStack() ) );
			//}
			//Sys.exit(1);
		//}
		
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
			
			#if brixdebug
				neko.Lib.println("Found meta parameter "+metaKey+" => "+metaValue);
			#end
			
			if ( Lambda.exists( BRIX_COMPILER_FLAGS , function(s:String) { return s == metaKey; } ) && metaValue == "true" || metaValue == CUSTOM_COMPILER_FLAG_VALUE )
			{
				#if brixdebug
					neko.Lib.println("Setting flag " + metaKey);
				#end
				
				//define the tag for the compilation
				haxe.macro.Compiler.define(metaKey);
				
				//and remove the meta tag from the HTML (no need at runtime)
				nodesToRemove.add(metaElt);
				
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
				nodesToRemove.add(metaElt);
				
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
			var cmpDeclarations = scriptElt.getAttribute(BRIX_USE_ATTR_NAME);
			
			if (cmpDeclarations != null && cmpDeclarations.trim() != "" )
			{
				//extract data- attributes
				var scriptEltAttrs : Hash<String> = new Hash();
				
				for (itCnt in 0...scriptElt.attributes.length)
				{
					var scriptEltAttr = scriptElt.attributes.item(itCnt);
					
					if ( scriptEltAttr.nodeName.startsWith( "data-" ) && scriptEltAttr.nodeName != BRIX_USE_ATTR_NAME )
					{
						scriptEltAttrs.set( scriptEltAttr.nodeName , scriptEltAttr.nodeValue );
					}
				}
				
				//include declared components into application
				var cmpClassNames = cmpDeclarations.split(" ");
				
				for (cmpClassName in cmpClassNames)
				{
					#if brixdebug
						neko.Lib.println("component found => "+cmpClassName);
					#end
					
					declaredComponents.set( cmpClassName, scriptEltAttrs);
				}
			}
			
			//clean the <script> tag
			if ( scriptElt.getAttribute("src") == null && scriptElt.innerHTML.trim() == "" )
			{
				//remove the element as it won't be useful at runtime
				nodesToRemove.add(scriptElt);
			}
			else
			{
				if ( Context.defined('js') && scriptElt.getAttribute("src") != null && 
						Context.defined('disableEmbedHtml') && scriptElt.getAttribute("src").endsWith(applicationFileName) )
				{
					appScriptInclusionFound = true;
					
					#if brixdebug
						neko.Lib.println("Found application script inclusion ");
					#end
				}
				
				//neko.Lib.println( sourceFilePath+" line "+scriptElt.getLineNumber()+": WARNING You should not include nor put any script in your HTML source file as it's not cross platform.\n" );
				
				//just remove the declare part but leave it as there may be an associated script.
				scriptElt.removeAttribute( BRIX_USE_ATTR_NAME );
			}
		}
		
		if ( Context.defined('js') && Context.defined('disableEmbedHtml') && !appScriptInclusionFound )
		{
			//Add the <script src="<application .js file>" /> in js/disableEmbedHtml mode.
			var appScriptInclusionTag = cocktail.Lib.document.createElement("script");
			appScriptInclusionTag.setAttribute( "src" , applicationFileName );
			cocktail.Lib.document.getElementsByTagName("head")[0].appendChild(appScriptInclusionTag);
			
			#if brixdebug
				neko.Lib.println("Adding <script src='"+applicationFileName+"'></script>");
			#end
		}
	}
	
	/**
	 * Parse and interpret the <body> element.
	 */
	static private function parseBody() : Void { }
	
	/**
	 * Run the application (and its component instances) at macro time.
	 * This allows components to run macro time logic on their DOM node as
	 * well as performing constraints checking against the component and its
	 * DOM node.
	 */
	//static function runMacroApplication():Void
	//{
		//macroApplication.initDom();
		//macroApplication.initComponents();
	//}
	
	/**
	 * Checks if the declared components can be found in the classpath and if their use 
	 * complies with their potential restrictions (on html tags or attribute settings).
	 */
	static function checkComponents() : Void
	{
		for ( cmpClassName in { iterator : declaredComponents.keys } )
		{
			var cmpType;
			
			//try
			//{
			//TODO debug error catching: why some errors in component are catch and other not ?
				cmpType = Context.getType(cmpClassName);
			//}
			//catch (unknown:Dynamic)
			//{	
				//throw "cannot resolve " + cmpClassName + ", ensure this class is in your application classpath and that it compiles correctly. Cause: "+Std.string(unknown);
			//}
			
			switch( cmpType ) 
			{
				case TInst( classRef , params ):
					
					var metaData = classRef.get().meta.get();
					
					if ( classRef.get().is("brix.component.ui.DisplayObject") )
					{
						var tagsToSearchFor = getUnconflictedClassTags(cmpClassName);
						
						var taggedElts : Array<cocktail.Dom.HtmlDom> = new Array();
						
						for (tagToSearchFor in tagsToSearchFor)
						{
							taggedElts = taggedElts.concat(cocktail.Lib.document.body.getElementsByClassName(tagToSearchFor));
							taggedElts = taggedElts.concat(sourceHTMLDocument.body.getElementsByClassName(tagToSearchFor));
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
															if ( taggedElt.nodeName.toLowerCase() == s.toLowerCase() )
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
										throw missingAttr+" not set on "+cmpClassName+" <script> declaration while it's required by the component";
										//FIXME need to be able to give the line number
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
	 * Parse the ApplicationContext class fields to create references to the methods to implement.
	 * 
	 * @param	fields, array of ApplicationContext fields
	 */
	static private function discoverApplicationContextMethods( fields : Array<Field> ) : Void
	{
		for (fc in 0...fields.length)
		{
			switch (fields[fc].kind)
			{
				case FFun(f) :

					switch (f.expr.expr)
					{
						case EBlock(exprs):

							//if (fields[fc].name == "initMetaParameters")
								//initMetaParametersExprs = exprs;

							if (fields[fc].name == "registerComponentsforInit")
								registerComponentsforInitExprs = exprs;

						default : 
					}

				default : 
			}
		}
	}

	
	/**
	 * Embeds the HTML content in the ApplicationContext class.
	 */
	static public function embedHTML(fields:Array<Field>) : Void
	{
		if (Context.defined('disableEmbedHtml'))
		{
			return;
		}
		var pos = Context.currentPos();
	
		//add the _htmlDocumentElement static var to ApplicationContext
		var documentInnerHtml = haxe.Serializer.run("");

		var innerHtml:String = cocktail.Lib.document.innerHTML;
		if (innerHtml != null)
		{
			documentInnerHtml = haxe.Serializer.run(innerHtml);
		}

		var htmlDocumentElementFieldValue = { expr : ECall({ expr : EField({ expr : EType({ expr : EConst(CIdent("haxe")), pos : pos }, "Unserializer"), pos : pos }, "run"), pos : pos },[{ expr : EConst(CString(documentInnerHtml)), pos : pos }]), pos : pos };

		fields.push( { name : "htmlDocumentElement", doc : null, meta : [], access : [APublic, AStatic], kind : FVar(null, htmlDocumentElementFieldValue), pos : pos } );

		#if brixdebug
			neko.Lib.println("document innerHtml extracted and set on ApplicationContext with a size of "+documentInnerHtml.length);
		#end
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
			
			var argsExpr = macro null;
			
			if ( !Lambda.empty(cmpArgs) )
			{
				//case the component has data-arguments on its script tag
				var argsArrayName = cmpClassName.replace( "." , "_" ) + "Args";
				
				registerComponentsforInitExprs.push( { expr : EVars([ { expr : { expr : ENew( { name : "Hash", pack : [], params : [], sub : null }, []), pos : pos }, name : argsArrayName, type : TPath( { name : "Hash", pack : [], params : [TPType(TPath( { name : "String", pack : [], params : [], sub : null } ))], sub : null } ) } ]), pos : pos } );
				
				argsExpr = { expr : EConst(CIdent(argsArrayName)), pos : pos };
				
				for ( cmpArg in {iterator : cmpArgs.keys})
				{
					if (cmpArg.startsWith( "data-" ) && cmpArg != BRIX_USE_ATTR_NAME)
						registerComponentsforInitExprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent(argsArrayName)), pos : pos }, "set"), pos : pos }, [ { expr : EConst(CString(cmpArg)), pos : pos }, { expr : EConst(CString(cmpArgs.get(cmpArg))), pos : pos } ]), pos : pos } );
				}
			}
			var cmpClassNameExpr = { expr:EConst(CString(cmpClassName)), pos:pos };
			var unconflictedClassTagExpr = { expr:EConst(CString(getUnconflictedClassTag(cmpClassName))), pos:pos };
			var registerCompExpr;
			
			if ( cmpClassType.is("brix.component.ui.DisplayObject") )
			{
				registerCompExpr = macro registeredUIComponents.push( { classname:$cmpClassNameExpr, args:$argsExpr, unconflictedClassTag:$unconflictedClassTagExpr } );
				//macroApplication.getRegisteredUIComponents().push( { classname:cmpClassName, args:null } ); // FIXME pass the args

				#if brixdebug
					neko.Lib.println("added to registeredUIComponents: "+cmpClassName+"");
				#end
			}
			else
			{
				registerCompExpr = macro registeredGlobalComponents.push({classname:$cmpClassNameExpr, args:$argsExpr, unconflictedClassTag:$unconflictedClassTagExpr});
				//macroApplication.getRegisteredNonUIComponents().push( { classname:cmpClassName, args:null } ); // FIXME pass the args

				#if brixdebug
					neko.Lib.println("added to registeredGlobalComponents: "+cmpClassName+"");
				#end
			}
			registerComponentsforInitExprs.push(registerCompExpr);
		}
	}
	
	/**
	 * Pack the application : set specific compiler flags, generate HTML file, ...
	 */
	static function pack() : Void
	{
		var pos;
		
		// keepComments option
		if ( !Context.defined('keepComments') )
		{
			removeComments(Lib.document.documentElement);
		}
		
		// minimizeHtml option
		if ( Context.defined('minimizeHtml') )
		{
			minimizeHtml(Lib.document.documentElement);
		}
		
		// clean DOM by removing useless nodes
		for (n in nodesToRemove)
		{
			if (n.parentNode != null)
			{
				var parent : HtmlDom = n.parentNode;
				
				parent.removeChild(n);
			}
		}

		if (Context.defined('disableEmbedHtml'))
		{
			var output = Compiler.getOutput();

			//the compiled Brix application filename
			var outputFileName = output;

			var outputFileNameBegin = (output.indexOf('/') > -1) ? output.lastIndexOf('/') + 1 : 0 ;

			outputFileName = output.substr( outputFileNameBegin, (( output.lastIndexOf('.') > outputFileNameBegin ) ? output.lastIndexOf('.') : output.length) - outputFileNameBegin );

			//generates the "compiled" HTML file if not embed
			if (outputFilePath == null)
			{
				var outputDirectory = "./";

				if (output.lastIndexOf('/') != null)
					outputDirectory = output.substr( 0 , output.lastIndexOf('/') + 1 );

				outputFilePath = outputDirectory + outputFileName + ".html";
			}

			#if brixdebug
				neko.Lib.println("Saving "+outputFilePath);
			#end

			sys.io.File.saveContent( outputFilePath , "<!DOCTYPE HTML>\n" + cocktail.Lib.document.innerHTML );
		}
		
		// specific js-target application packaging
		if (Context.defined('js'))
		{
			packForJs();
		}
	}
	
	/**
	 * Performs the js-specific compile config and output generating tasks.
	 */
	static function packForJs() : Void
	{
		var pos = Context.currentPos();

		var output = Compiler.getOutput();

		//the compiled Brix application filename
		var outputFileName = output;

		var outputFileNameBegin = (output.indexOf('/') > -1) ? output.lastIndexOf('/') + 1 : 0 ;

		outputFileName = output.substr( outputFileNameBegin, (( output.lastIndexOf('.') > outputFileNameBegin ) ? output.lastIndexOf('.') : output.length) - outputFileNameBegin );

		//set the js-modern mode
		if (!Context.defined('js-modern'))
		{
			#if brixdebug
				neko.Lib.println("Setting js-modern mode.");
			#end
			haxe.macro.Compiler.define("js-modern");
		}

		//set the Brix Class exposed name for js version
		//if ( Context.getLocalClass().get().meta.has(":expose"))
		var applicationClassType:haxe.macro.Ref<haxe.macro.ClassType> = switch(Context.getType("brix.core.Application")) { case TInst(classRef, params): classRef; default: null; } ;
		if ( applicationClassType.get().meta.has(":expose"))
		{
			neko.Lib.println( "\nWARNING you should not set manually the @:expose meta tag on Application class as Brix sets it automatically." );
		}
		else
		{
			if (jsExposedName == null)
			{
				jsExposedName = outputFileName;
			}
			
			#if brixdebug
				neko.Lib.println("Setting @:expose("+jsExposedName+") meta tag on Application class.");
			#end

			//Context.getLocalClass().get().meta.add( ":expose", [{ expr : EConst(CString(jsExposedName)), pos : pos }], pos);
			applicationClassType.get().meta.add( ":expose", [{ expr : EConst(CString(jsExposedName)), pos : pos }], pos);
		}
	}
	
	/**
	 * Adds to the nodes-to-remove-list the comments in the content of an HtmlDom.
	 * 
	 * @param	the HtmlDom to parse for comments removing
	 */
	static function removeComments(elt:HtmlDom) : Void
	{
		for (nc in elt.childNodes)
		{
			switch (nc.nodeType)
			{
				//FIXME use constants (add to Dom.hx?)
				case 8:	//Node.COMMENT_NODE
					elt.removeChild(nc);
				case 1:	//Node.ELEMENT_NODE:
					removeComments(nc);
				default:
			}
		}
	}
	
	/**
	 * Recursively adds the white spaces, tabulations and line breaks to the nodes-to-remove-list 
	 * so that they will be removed just before packing.
	 * 
	 * @param	the HtmlDom to minimize.
	 */
	static function minimizeHtml(elt:HtmlDom) : Void
	{
		for (nc in elt.childNodes)
		{
			switch (nc.nodeType)
			{
				//FIXME use constants
				case 3:		//Node.TEXT_NODE
					
					switch (elt.style.whiteSpace)
					{
						case "normal", "nowrap": // both lines and spaces
							
							var er1 : EReg = ~/[ \t]+/;
							var er2 : EReg = ~/  +/;
							
							nc.nodeValue = er2.replace( er1.replace( nc.nodeValue , " " ) , " " );
						
						case "pre-line": // spaces
							
							var er1 : EReg = ~/ *$^ */m;
							var er2 : EReg = ~/[ \t]+/;
							
							nc.nodeValue = er2.replace( er1.replace( nc.nodeValue , "\n" ) , " " );
						
						default:
					}
					
					if (nc.nodeValue == "" || nc.nodeValue.trim() == "")
					{
						elt.removeChild(nc);
					}
					
				case 1:		//Node.ELEMENT_NODE
					
					minimizeHtml(nc);
					
				default:
			}
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
	 * Determine a class tag value for a component that won't be conflicting with other components.
	 * 
	 * NOTE : fix by Yannick, this method now called at macro time, could probably reuse "getUnconflictedClassTags"
	 * instead of this one, but I didn't fully understood it
	 */
	static private function getUnconflictedClassTag(className : String) : String
	{
		var classTag = className;

		if (classTag.indexOf(".") != -1)
			classTag = classTag.substr(classTag.lastIndexOf(".") + 1);
			
		var declaredCmpsClassNames = declaredComponents.keys();
		
		while (declaredCmpsClassNames.hasNext())
		{
			var declaredComponentClassName = declaredCmpsClassNames.next();
			
			if ( declaredComponentClassName != className && classTag == declaredComponentClassName.substr(classTag.lastIndexOf(".") + 1) )
			{
				return className;
			}
		}

		return classTag;
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
			var a = className.split(".");
			if (a[a.length-1] == classTag)
				classNames.add( className );
		}
		
		return classNames;
	}
}