package slplayer.ui.list;

import js.Lib;
import js.Dom;
import slplayer.ui.list.List;
import slplayer.util.DomTools;

/**
 * list component with XML as an input
 * takes the XML in the attributes o the node
 * convert the XML into an object tree in the data provider
 */
class XmlList extends List<Xml>{
	static inline var ATTR_ITEMS:String = "data-items";
	/**
	 * constructor
	 */
	public function new(rootElement:HtmlDom, SLPId:String) {
		super(rootElement, SLPId);
		var attr = rootElement.getAttribute(ATTR_ITEMS);
		var xmlData:Xml = Xml.parse(StringTools.htmlUnescape(attr));
		dataProvider = [];
		for(item in xmlData.elements()){
			dataProvider.push(xmlToObj(item));
			DomTools.inspectTrace(xmlToObj(item));
		}
	}
	private function xmlToObj(xml:Xml):Dynamic{
		var res:Dynamic = {};
		for(item in xml.iterator()){
			if (item.nodeType == Xml.PCData 
				|| item.nodeType == Xml.CData
				|| item.nodeType == Xml.Prolog
				){
				return item.nodeValue;
			}
			else
				Reflect.setField(res, item.nodeName, xmlToObj(item));
		}
		return res;
	}
}