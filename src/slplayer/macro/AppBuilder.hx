package slplayer.macro;

import sys.FileSystem;
import haxe.macro.Expr;

/**
 * 
	  une macro split la page html en deux : body et head

		. prend le contenu de <body> comme une chaine de caractère et génère 
		js.Lib.document.body.innerHTML = "... la chaine ..."; 

		. parse puis interprete le contenu de <head> comme la config de l'appli SLPlayer (par exemple taille de l'appli dans la balise meta viewport)

		. interprete <script src="classes/Galery.js" /> comme ceci :
		génère un "import classes.Galery;" (le dev doit avoir ajouté le bon class path pour qu on le trouve)
		génère un "new Galery();" pour qu il soit executé dès le lancement de l appli
	 
 * @author Thomas Fétiveau
 */

class AppBuilder 
{
	/**
	 * Builds an SLPlayer application from an HTML file.
	 * Splits the input HTML file in two parts: the header part and the body.
	 * The header part is used to configure the application. It also includes the components which may be used by the application.
	 * The body part is the content and layout of the application.
	 * @param	fileName
	 * @return
	 */
	@:macro static function buildFromHtml( fileName : String ) :  Array<Field>
	{
		var fields = haxe.macro.Context.getBuildFields();
		var pos;

		//First read the HTML file
		if (!FileSystem.exists(fileName))
			throw fileName + " not found !";

		var rowHtmlContent = neko.io.File.getContent(fileName);

		//ignore first line if <!DOCTYPE html>
		//TODO
		
		//HTML content parsing
		var htmlContent : Xml = Xml.parse(rowHtmlContent);

		for ( elt in htmlContent.firstChild().elements() )
		{
			switch(elt.nodeName.toLowerCase())
			{
				case "head":
//trace("head content: "+elt.toString());
					for (headElt in elt.elements())
					{
						switch(headElt.nodeName.toLowerCase())
						{
							case "script":
								var cmpClassName = headElt.get("src");
								
								//FIXME
								if (cmpClassName == "SLPlayer.js")
									continue;
								
								if (cmpClassName != null && StringTools.endsWith(cmpClassName.toLowerCase(), ".js"))
								{
									cmpClassName = cmpClassName.substr(0, cmpClassName.length - 3);
									cmpClassName = StringTools.replace( cmpClassName, "/", "." );
trace("found cmpClassName="+cmpClassName);
									
									for (fc in 0...fields.length)
									{
//trace("\n"+fields[fc]+"\n");
										switch (fields[fc].kind)
										{
											case FFun(f) :
												if (fields[fc].name != "initDisplayObjects")
												{
													continue;
												}
//trace(fields[fc]);
												
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
														
														//generate call to
														exprs.push({ expr : ECall( { expr : EConst(CIdent("initDisplayObjectsOfType")), pos : pos }, [{ expr : EConst(CString(cmpClassName)), pos : pos}] ) , pos : pos });
//trace("added call to initDisplayObjectsOfType("+cmpClassName+")");
														break;
													
													default :
														trace("expr type ignored for field initDisplayObjects.");
												}
												
											
											default :
												trace("field "+fields[fc].name+" ignored.");
										}
									}
								}
								
							//case "meta":
								//TODO
								
							default:
								trace("Application configuration node "+headElt.nodeName+" ignored.");
						}
					}

				case "body":
					//Add the _htmlBody static var to the SLPlayer class
					pos = haxe.macro.Context.currentPos();
					var htmlBodyFieldType = TPath( { pack : [], name : "String", params : [], sub : null } );
					var htmlBodyFieldValue = { expr : EConst(CString(elt.firstChild().toString())) , pos : pos };
					fields.push({ name : "_htmlBody", doc : null, meta : [], access : [AStatic], kind : FVar(htmlBodyFieldType, htmlBodyFieldValue), pos : pos });

				default:
					trace("Main application node "+elt.nodeName+" ignored.");
			}
		}
		return fields;
	}
	
	/*
	{ expr => EType({ expr => EConst(CIdent(debug)), pos  : pos },DebugNodes), pos  : pos }
	{ expr => EType({ expr => EField({ expr => EConst(CIdent(silexlabs)), pos : pos },slplayer), pos : pos },DebugNodes), pos : pos }
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