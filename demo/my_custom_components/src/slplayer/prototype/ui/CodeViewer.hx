package slplayer.prototype.ui;

/**
 * This component "extends" the behavior of the <pre> element by reducing the default tab size (a
 * standard css3 property may appear one day: http://dev.w3.org/csswg/css3-text/#tab-size) and optionaly
 * reading its content from another component.
 * 
 * @author Thomas Fétiveau
 */
@tagNameFilter("pre")
@:build(slplayer.prototype.ui.CodeViewerBuilder.build())
class CodeViewer extends org.slplayer.component.ui.DisplayObject
{
	/**
	 * The data- optional attribute used to specify with HTML element we're viewing.
	 */
	static inline var CODE_VIEW_ID_TAG = "code-viewer-id";
}