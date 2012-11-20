package brix.core;

import js.Lib;
import js.Dom;

import brix.core.Application;

/**
 * ...
 * @author Thomas Fétiveau
 */
@:build(brix.core.Builder.build()) class ApplicationContext 
{
	/**
	 * A collection of the <script> declared UI components with the optionnal data- args passed on the <script> tag.
	 * A UI component class is a child class of brix.component.ui.DisplayObject
	 */
	public var registeredUIComponents(default,null) : Array<RegisteredComponent>;
	/**
	 * A collection of the <script> declared Non UI components with the optionnal data- args passed on the <script> tag.
	 * Ideally, a component class should at least implement brix.component.IBrixComponent.
	 */
	public var registeredNonUIComponents(default,null) : Array<RegisteredComponent>;
	
	public function new() 
	{
		registeredUIComponents = new Array();
		
		registeredNonUIComponents = new Array();
		
		//initMetaParameters();
		
		registerComponentsforInit();
	}
	
	/**
	 * This function is implemented by the AppBuilder macro.
	 */
	//private function initMetaParameters() { }
	
	/**
	 * This function is implemented by the AppBuilder macro.
	 * It simply pushes each component class declared in the headers of the HTML source file in the
	 * registeredUIComponents and registeredNonUIComponents collections.
	 */
	private function registerComponentsforInit() { }
	
	//static public function getEmbeddedHtml():String
	//{
		//return "";//FIXME _htmlDocumentElement;
	//}
}