package slplayer.macro;

import sys.FileSystem;
import haxe.macro.Expr;

/**
 * ...
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
								if (cmpClassName != null && StringTools.endsWith(cmpClassName.toLowerCase(), ".js"))
								{
									cmpClassName = cmpClassName.substr(0, cmpClassName.length - 3);
									trace("found cmpClassName="+cmpClassName);
									//add a new cmpClassName() in SLPlayer constructor
									for (fc in 0...fields.length)
									{
										//trace("\n"+fields[f]+"\n");
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
														//var newCmpExpr = { expr : ENew( { name : cmpClassName, pack : [], params : [], sub : null }, []) , pos : pos };
														//trace("added new "+cmpClassName+"() call");

														//var newCmpExpr = { expr : ECall( { expr : EField( { expr : EConst(CType(cmpClassName)), pos : pos }, "initAll"), pos : pos }, [] ) , pos : pos };
														//trace("added call to "+cmpClassName+".main()");

														var newCmpExpr = { expr : ECall( { expr : EConst(CIdent("initDisplayObjectsOfType")), pos : pos }, [{ expr : EConst(CString(cmpClassName)), pos : pos}] ) , pos : pos };
														trace("added call to initDisplayObjectsOfType("+cmpClassName+")");
														
														exprs.push(newCmpExpr);
														break;
													
													default :
														trace("expr type ignored for field initDisplayObjects.");
												}
												
											
											default :
												trace("field "+fields[fc].name+" ignored.");
										}
									}
									
									//add import cmpClassName in SLPlayer class
									//TODO
									
									
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
}