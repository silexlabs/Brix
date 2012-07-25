package slplayer.prototype.ui;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

/**
 * 
 * 
 * @author Thomas Fétiveau
 */
@:macro class CodeViewerBuilder 
{
	static public function build() : Array<haxe.macro.Field>
	{
		var codeViewerFullClassName = Context.getLocalClass().get().pack.join(".") + "." + Context.getLocalClass().get().name;
		
		var codeViewerClassNames = org.slplayer.core.Builder.getUnconflictedClassTags( codeViewerFullClassName );
		
		var shortestClassName = codeViewerClassNames.first();
		
		for ( scn in codeViewerClassNames ) { if (scn.length < shortestClassName.length) shortestClassName = scn; }
		
		for ( codeViewerClass in codeViewerClassNames )
		{
			for ( codeViewerElt in cocktail.Lib.document.body.getElementsByClassName(codeViewerClass) )
			{
				var associatedEltId = codeViewerElt.getAttribute("data-code-viewer-id").trim();
				
				if ( associatedEltId == null || associatedEltId.trim() == "" )
					continue;
				
				var associatedElt = cocktail.Lib.document.getElementById(associatedEltId);
				
				if ( associatedElt == null )
					continue;
				
				codeViewerElt.innerHTML = associatedElt.innerHTML.htmlEscape().replace( "	" , "&nbsp;&nbsp;").replace("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;","");
			}
		}
		return haxe.macro.Context.getBuildFields();
	}
}