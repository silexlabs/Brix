/*
 * Brix, Rich UI application framework
 * https://github.com/silexlabs/Brix
 *
 * Copyright (c) Silex Labs
 * Brix is available under the MIT license
 * http://www.silexlabs.org/labs/brix-licensing/
 */
package brix.core;

import js.Lib;
import js.Dom;

import brix.core.Application;

/**
 * 
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
	 * A collection of the <script> declared global components with the optionnal data- args passed on the <script> tag.
	 * A global component is a component that doesn't inharit from brix.component.ui.DisplayObject.
	 * Ideally, a global component class should implement brix.component.IBrixComponent if it needs to know its brix Application instance.
	 */
	public var registeredGlobalComponents(default,null) : Array<RegisteredComponent>;
	
	public function new() 
	{
		registeredUIComponents = new Array();
		
		registeredGlobalComponents = new Array();
		
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
	 * registeredUIComponents and registeredGlobalComponents collections.
	 */
	private function registerComponentsforInit() { }
	
	//static public function getEmbeddedHtml():String
	//{
		//return "";//FIXME _htmlDocumentElement;
	//}
}