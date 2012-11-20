package brix.test.unit.component;

import utest.Assert;
import utest.Runner;
import utest.ui.Report;

import js.Dom;
import js.Lib;

import brix.core.Application;
import brix.util.DomTools;

/**
 * Unit test the Group component.
 * 
 * @author Thomas Fétiveau
 */
class GroupTests 
{
	public static function main()
	{	
		var runner = new Runner();
		runner.addCase(new GroupTests());
		Report.create(runner);
		runner.run();
	}

	public function new() { }

	/**
	 * Here, we test the Group component when it's added at runtime.
	 */
	public function testRuntime()
	{
		// the html content that will be added at runtime
		var htmlBoot:String = "<div class=\"Group\">"+
									"<a class=\"LinkToPage\">o</a>"+
									"<a class=\"LinkToPage\">o</a>"+
									"<div class=\"Group\">"+
										"<a class=\"LinkToPage\">i</a>"+
										"<a class=\"LinkToPage\">i</a>"+
									"</div>"+
								"</div>";

		// we create a root node for our application
		var appNode:HtmlDom = Lib.document.createElement("div");
		Lib.document.body.appendChild(appNode);

		// we create and initialize our application on this root node
		var newApp:Application = Application.createApplication();
		newApp.initDom(appNode); 
		newApp.initComponents();

		// we check the expected html content (should be empty)
		Assert.equals(appNode.innerHTML, "");

		// here we add our html content
		appNode.innerHTML = htmlBoot;
		// that we initialize
		newApp.initNode(appNode);

		// we can now test that the components have been correctly initilized, especially the Group component and its Groupable peers.
		Assert.equals(appNode.innerHTML, "<div data-brix-id=\"1\" class=\"Group1r\">"+
												"<a data-brix-id=\"2\" data-group-id=\"Group1r\" class=\"LinkToPage\">o</a>"+
												"<a data-brix-id=\"3\" data-group-id=\"Group1r\" class=\"LinkToPage\">o</a>"+
													"<div data-brix-id=\"4\" class=\"Group2r\">"+
														"<a data-brix-id=\"5\" data-group-id=\"Group2r\" class=\"LinkToPage\">i</a>"+
														"<a data-brix-id=\"6\" data-group-id=\"Group2r\" class=\"LinkToPage\">i</a>"+
													"</div>"+
											"</div>");
	}
}