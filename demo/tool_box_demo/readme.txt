TODO LIST

With Zabojad
- templates with the 2nd "method"? and retrieve content of the dataprovider in the list
  => un mixin qui permet d'init une liste avec des données qui viennent d'une de ces sources
     1- name.html en resource haxe
     2- data-name sur le noeud
     3- dans un container "name-data" avec la template dans "name-template"
     3- dans le corps de la liste direct
  => Dragable on list items / templates??
  => comment on met a jour le dataProvider? Redraw sur le parent? Redrawable? Movable?
- functional tests?
- revue du code de lexa
- pull request / ou on met tout ca?
	----
- tu trouves que DataConsumer est un bon nom? Plugable? DataPlugable?
- DataConnetor<Xml> => List<Xml>
  . modif DataConsumer<ElementType> 
  . modif DataProvider<ElementType> 
  . Lists doivent etre DataConsumer


Dragable: 
- use computed style of rootElement instead of absolute values ---- window.getComputedStyle ---- currentStyle ----- in initPhantomStyle ----- http://www.javascriptkit.com/dhtmltutors/dhtmlcascade4.shtml et http://javascript.gakaa.com/window-getcomputedstyle-4-0-5-.aspx
- tests: position absolute, horizontal/vertical...
- functional tests 

PannelLayout
- slplayer.ui.layout.Pannel
- dispatch redraw events on the nodes
- functional tests

List
- slplayer.ui.lists.List et slplayer.ui.lists.XmlList
- Lists doivent etre DataConsumer
- multiple selection

next comps
- Redrawable
  . slplayer.ui.interaction.Redrawable
  . Redrawable.hx
  . class de mixin Redrawable avec init() qui écoute l'event "redraw" => appel de redraw()
    . initRedrawable ( cmp : IRedrawable , nodes : Array<HtmlDom> )
    . préciser plusieurs noeuds dans le cas ou un mec utilise des groupes par exemple et qu'il voudrait etre redrawable sur tout son groupe
    . un evenment custom est defin, cf data provider et consumer, customEvent est dans javascript
  . interface IRedrawable avec juste redraw()
  . le constructeur de PannelLayout appelle Redrawable::init()
  . Resizeable emet "redraw sur son noeud"
- Resizable
- Tree
