package ;

import flash.display.Loader;
import flash.display.Sprite;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.events.Event;
import flash.system.ApplicationDomain;
import flash.system.SecurityDomain;

/**
 * Parent application source. Embeds both slplayer_01 and slplayer_02 using different ApplicationDomain to avoid class conflicts.
 * 
 * @author Thomas Fétiveau
 */
class Output extends Sprite
{
	var spriteA:Sprite;
	var spriteB:Sprite;
	
	public function new() 
	{
		super();
		
		spriteA = new Sprite();
		addChild(spriteA);
		var appDomainA:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
		var ldrA = new Loader(); 
		var reqA:URLRequest = new URLRequest("myEmbeddedSLPlayerApplication.swf"); 
		var ldrContextA:LoaderContext = new LoaderContext(false, appDomainA);
		ldrA.contentLoaderInfo.addEventListener(Event.INIT, completeHandlerA); 
		ldrA.load(reqA, ldrContextA);
		
		spriteB = new Sprite(); spriteB.x = 350;
		addChild(spriteB);
		var appDomainB:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
		
		var ldrB = new Loader(); 
		var reqB:URLRequest = new URLRequest("myEmbeddedSLPlayerApplication2.swf"); 
		var ldrContextB:LoaderContext = new LoaderContext(false, appDomainB);
		
		ldrContextB.allowCodeImport = true;
		
		ldrB.contentLoaderInfo.addEventListener(Event.INIT, completeHandlerB); 
		ldrB.load(reqB, ldrContextB);
	}
	
	private function completeHandlerA(event:Event) 
	{
		spriteA.addChild(event.target.content);

		trace("swf A loaded"); 
	}
	
	private function completeHandlerB(event:Event) 
	{
		spriteB.addChild(event.target.content);
		spriteB.x = 350;
		trace("swf B loaded"); 
	}
	
	public static function main()
	{
		new Output();
	}
}