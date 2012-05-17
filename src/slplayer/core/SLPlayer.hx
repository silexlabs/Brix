package slplayer.core;

import js.Lib;
import js.Dom;

import slplayer.ui.DisplayObject;

import Gallery;

/**
 * ...
 * @author Thomas Fétiveau
 */
@:build(slplayer.macro.AppBuilder.buildFromHtml('gallery.html')) class SLPlayer 
{
	//static var _htmlBody:String = "toto";
	/*
	 * une macro split la page html en deux : body et head

		. prend le contenu de <body> comme une chaine de caractère et génère 
		js.Lib.document.body.innerHTML = "... la chaine ..."; 

		. parse puis interprete le contenu de <head> comme la config de l'appli SLPlayer (par exemple taille de l'appli dans la balise meta viewport)

		. interprete <script src="classes/Galery.js" /> comme ceci :
		génère un "import classes.Galery;" (le dev doit avoir ajouté le bon class path pour qu on le trouve)
		génère un "new Galery();" pour qu il soit executé dès le lancement de l appli
	 */

	public function new() 
	{
		//Set the body HTML content if not js
		#if !js
		trace("body set");
		Lib.document.body.innerHTML = _htmlBody;
		#end
	}

	public static function main()
	{
		var mySLPlayerApp = new SLPlayer();
		#if js
			Lib.window.onload = callback(mySLPlayerApp.initDisplayObjects);
		#else
			mySLPlayerApp.initDisplayObjects(null);
		#end
	}

	private function initDisplayObjects(e : Event) { }
	
	/**
	 * TODO determine if it wouldn't be better to pass directly the Class. I've tried before but I don't get the generic <> thing...
	 * TODO Also, need to ask the mailing list if I have to use Reflect to access a Class static field.
	 * @param	displayObjectClassName
	 */
	private function initDisplayObjectsOfType(displayObjectClassName : String)
	{
trace("initDisplayObjectsOfType called with displayObjectClassName="+displayObjectClassName);
		
		var displayObjectClass = Type.resolveClass(displayObjectClassName);
		
		if (displayObjectClass != null)
		{
			var tagClassName = Reflect.field(displayObjectClass, "className");
trace(displayObjectClassName+" class resolved and its tag classname is "+tagClassName);
			
			if (tagClassName != null)
			{
				var taggedNodes : Array<HtmlDom> = untyped Lib.document.getElementsByClassName(tagClassName);
trace("taggedNodes = "+taggedNodes.length);
				for (nodeCnt in 0...taggedNodes.length)
				{
					var newDisplayObject = Type.createInstance( displayObjectClass, [taggedNodes[nodeCnt]] ); trace(displayObjectClassName+" instance created");
					newDisplayObject.init(null);
				}
			}
		}
	}
}