package slplayer.prototype.ui;

import js.Lib;
import js.Dom;

import haxe.Template;

import org.slplayer.component.ui.DisplayObject;

import org.slplayer.component.data.IDataConsumer;
using org.slplayer.component.data.IDataConsumer.DataConsumer;
import org.slplayer.component.data.IDataProvider;

/**
 * The TemplateRenderer is a simple DataConsumer component that renders a template against 
 * the data it consumes.
 * @author Thomas Fétiveau
 */
class TemplateRenderer extends DisplayObject, implements IDataConsumer
{
	/**
	 * The Template object used to render the template syntax.
	 */
	var tpl : Template;
	/**
	 * This variable may contain data from different sources and/or DataProviders.
	 */
	var dataProviders(default,null) : Hash<Array<Dynamic>>;
	
	override public function init():Void 
	{
		dataProviders = new Hash();
		
		tpl = untyped new Template(rootElement.innerHTML);
		rootElement.innerHTML = "";
		
		updateView();
		
		startConsuming(rootElement);
	}
	
	/**
	 * The redraw function of the component.
	 */
	function updateView():Void
	{		
		//consolidate data from providers
		var providersData : Array<Dynamic> = new Array();
		for (pvdData in dataProviders)
		{
			providersData = providersData.concat(pvdData);
		}
		
		//execute template
		rootElement.innerHTML = tpl.execute({data:providersData});
	}
	
	public function onData(dataObj:DataObject):Void
	{
		if (dataObj != null)
		{
			dataProviders.set(dataObj.src,dataObj.data);
			updateView();
		}
	}
	
	/**
	 * Callback invoked when a new data provider is showing up.
	 */
	public function onNewDataProvider( dataProvider : IDataProvider ):Void
	{
		dataProvider.onNewDataConsumer(this);
	}
}