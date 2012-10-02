package util;

/*
import utest.Assert;
import utest.Runner;
import utest.ui.Report;
*/
import js.Lib;
import js.Dom;

import org.slplayer.util.DomTools;

class UtilTest {

	/**
	 * Main entry point for the tests
	 * Add new tests here
	 */
	public static function main(){
/*        var runner = new Runner();
		runner.addCase(new UtilTest());
        Report.create(runner);
        runner.run();
*/
		new UtilTest();
	}
	public function new(){
		haxe.Timer.delay(testBoundingBox, 200);
	}
	public function testBoundingBox(){

		doTestBoundingBox(Lib.document.getElementById("rootNode"));
	}
	public function doTestBoundingBox(element:HtmlDom){
		trace(element.tagName);
		var bb = DomTools.getElementBoundingBox(element);
		//var bb = Lib.getBoundingClientRect(element);
		drawBox(bb);

		for (idx in 0...element.childNodes.length){
			doTestBoundingBox(element.childNodes[idx]);
		}
	}
	var canvas:HtmlDom;
	var idxColor:Int = 0;
	public function drawBox(bb:BoundingBox){
		if (bb == null) return;
		//trace("drawBox "+bb.left+", "+bb.top+", "+bb.width+", "+bb.height);
		trace("drawBox "+bb.x+", "+bb.y+", "+bb.w+", "+bb.h+ " - "+StringTools.hex(idxColor, 6));
/*		var ctx=cast(canvas).getContext("2d");
		ctx.fillStyle="#"+StringTools.hex(idxColor);
		idxColor += 2;
		ctx.fillRect(bb.x,bb.y,bb.w,bb.h);
		//ctx.fillRect(bb.left,bb.top,bb.width,bb.height);		
*/

		var element = Lib.document.body;
		canvas = Lib.document.createElement("div");
		canvas.style.display = "static";
		canvas.style.position = "absolute";
		canvas.style.margin = "0";
		canvas.style.padding = "0";
		canvas.style.left = bb.x+"px";
		canvas.style.top = bb.y+"px";
		canvas.style.width = bb.w+"px";
		canvas.style.height = bb.h+"px";
		canvas.style.opacity = "0.1";
		canvas.style.zIndex = -1000;
		canvas.style.backgroundColor = "#"+StringTools.hex(idxColor,6);
		element.appendChild(canvas);

		idxColor += 10;
	}
}