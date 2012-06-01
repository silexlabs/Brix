package slplayer.macro;

import sys.FileSystem;

import haxe.macro.Expr;

/**
 * The Builder macro of any SLPlayer application.
 * What this macro do is basically : parse the application HTML file, add the necessary components import and init calls,
 * cut the body part of the page and set it as the application contents.
 * 
 * @author Thomas Fétiveau
 */
class AppBuilder 
{
	/**
	 * The data- attribute set by the slplayer on the HTML elements associated with one or more component.
	 */
	static public var SLP_USE_ATTR_NAME = "slp-use";
	/**
	 * The path to the application HTML source page.
	 */
	static public var htmlSourcePage = "index.html";
	
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
	 * Builds an SLPlayer application from an HTML file.
	 * Splits the input HTML file in two parts: the header part and the body.
	 * The header part is used to configure the application. It also includes the components which may be used by the application.
	 * The body part is the content and layout of the application.
	 * @return	the updated SLPlayer class fields 
	 */
	@:macro static function buildFromHtml() :  Array<Field>
	{
		var pos = haxe.macro.Context.currentPos();
		
		var output = haxe.macro.Compiler.getOutput();
		
		//Sets the SLPlayer exposed name for js version
		if (haxe.macro.Context.defined('js'))
		{
			var outputFileName = output.substr(output.lastIndexOf('/') + 1, output.lastIndexOf('.') - output.lastIndexOf('/') - 1);
			
			if (!haxe.macro.Context.defined('js-modern'))
			{
				#if debug
					trace("Setting js-modern mode.");
				#end
				haxe.macro.Compiler.define("js-modern");
			}
			
			//FIXME add a compile tag and a meta tag to set the expose name to something else than the default value which is the .js file name
			
			if ( haxe.macro.Context.getLocalClass().get().meta.has(":expose"))
			{
				haxe.macro.Context.warning( "You should not set manually the @:expose meta tag on SLPlayer class. SLPlayer sets it automatically to the name of your .js file." , pos );
			}
			else
			{
				haxe.macro.Context.getLocalClass().get().meta.add( ":expose", [{ expr : EConst(CString(outputFileName)), pos : pos }], pos);
			}
		}
		
		var fields = haxe.macro.Context.getBuildFields();
		
		//First read the HTML file
		if (!FileSystem.exists(htmlSourcePage))
			throw htmlSourcePage + " not found !";
		
		var rowHtmlContent = neko.io.File.getContent(htmlSourcePage);
		
		//HTML content parsing
		var htmlContent : Xml = haxe.xml.Parser.parse(rowHtmlContent);

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
								{
									continue;
								}
								
								#if debug
									trace("component found => "+cmpClassName);
								#end
								
								var initArgsElts:Iterable<String> = { iterator : headElt.attributes };
								
								for (fc in 0...fields.length)
								{
									switch (fields[fc].kind)
									{
										case FFun(f) :
											
											if (fields[fc].name != "registerComponentsforInit")
											{
												continue;
											}
											
											switch (f.expr.expr)
											{
												case EBlock(exprs):
													
													pos = haxe.macro.Context.currentPos();
													
													//exprs.push({ expr : ENew( { name : cmpClassName, pack : [], params : [], sub : null }, []) , pos : pos });
													//trace("added new "+cmpClassName+"() call");
													
													//exprs.push({ expr : ECall( { expr : EField( { expr : EConst(CType(cmpClassName)), pos : pos }, "initAll"), pos : pos }, [] ) , pos : pos });
													//trace("added call to "+cmpClassName+".main()");
													
													//generate import
													exprs.push(generateImport(cmpClassName));
													
													if (Lambda.exists(initArgsElts, function(atName:String) { return StringTools.startsWith( atName , "data-" ) && atName != "data-"+SLP_USE_ATTR_NAME; } )) //case the component initialization takes arguments (other than src or type)
													{
														//FIXME we may encode cmpClassName+"Args" in MD5 for more security (conflicts)
														var shortCmpClassName = cmpClassName.split('.').pop();
														exprs.push( { expr : EVars([ { expr : { expr : ENew( { name : "Hash", pack : [], params : [], sub : null }, []), pos : pos }, name : shortCmpClassName + "Args", type : TPath( { name : "Hash", pack : [], params : [TPType(TPath( { name : "String", pack : [], params : [], sub : null } ))], sub : null } ) } ]), pos : pos } );
														
														for (initArgElt in initArgsElts)
														{
															if (StringTools.startsWith( initArgElt , "data-" ) && initArgElt != "data-"+SLP_USE_ATTR_NAME)
																exprs.push( { expr : ECall( { expr : EField( { expr : EConst(CIdent(shortCmpClassName + "Args")), pos : pos }, "set"), pos : pos }, [ { expr : EConst(CString(initArgElt)), pos : pos }, { expr : EConst(CString(headElt.get(initArgElt))), pos : pos } ]), pos : pos } );
														}
														
														//generate call to registerComponent with additionnal arguments
														exprs.push( { expr : ECall( { expr : EConst(CIdent("registerComponent")), pos : pos }, [ { expr : EConst(CString(cmpClassName)), pos : pos }, { expr : EConst(CIdent(shortCmpClassName+"Args")), pos : pos } ]), pos : pos } );
													}
													else
													{
														//generate call to registerComponent with no additionnal arguments
														exprs.push( { expr : ECall( { expr : EConst(CIdent("registerComponent")), pos : pos }, [ { expr : EConst(CString(cmpClassName)), pos : pos } ] ) , pos : pos } );
													}
													
													#if debug
														trace("added call to registerComponent("+cmpClassName+")");
													#end
													
													break;
													
												default :
													//trace("expr type ignored for field initDisplayObjects.");
											}
										
										default :
											//trace("field "+fields[fc].name+" ignored.");
									}
								}
								
							//case "meta":
								//TODO
								
							default:
								//trace("Application configuration node "+headElt.nodeName+" ignored.");
						}
					}
					
				case "body":
					
					if (!haxe.macro.Context.defined('js') || haxe.macro.Context.defined('embedHtml')) //embed HTML only if not js except if we want to
					{
						//Add the _htmlBody static var to the SLPlayer class
						pos = haxe.macro.Context.currentPos();
						
						var htmlBodyFieldType = TPath( { pack : [], name : "String", params : [], sub : null } );
						
						var bodyInnerHtml = "";
						
						if (elt.toString() != null)
						{
							bodyInnerHtml = haxe.Serializer.run(elt.toString());
							
							//#if debug
								//trace("bodyInnerHtml = "+bodyInnerHtml);
							//#end
						}
						
						var htmlBodyFieldValue = { expr : EConst(CString(bodyInnerHtml)) , pos : pos };
						
						fields.push( { name : "_htmlBody", doc : null, meta : [], access : [AStatic], kind : FVar(htmlBodyFieldType, htmlBodyFieldValue), pos : pos } );
							
						#if debug
							trace("bodyInnerHtml extracted and set on SLPlayer with a length of "+bodyInnerHtml.length);
						#end
					}
					
				default:
					
					#if debug
						trace("Main application node " + elt.nodeName + " ignored.");
					#end
			}
		}
		return fields;
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