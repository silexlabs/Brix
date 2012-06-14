/*
 * This file is part of SLPlayer http://www.silexlabs.org/groups/labs/slplayer/
 * 
 * This project is © 2011-2012 Silex Labs and is released under the GPL License:
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms 
 * of the GNU General Public License (GPL) as published by the Free Software Foundation; 
 * either version 2 of the License, or (at your option) any later version. 
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU General Public License for more details.
 * 
 * To read the license please visit http://www.gnu.org/copyleft/gpl.html
 */
package slplayer.core;

/**
 * The interface each SLPlayer component should implement to be able to standardly retreive their SLPlayer Application instance.
 * 
 * @author Thomas Fétiveau
 */
//@:autoBuild(slplayer.core.SLPlayerComponentBuilder.build())
interface ISLPlayerComponent
{
	/**
	 * the CLPlayer Application instance id.
	 */
	public var SLPlayerInstanceId : String;
	
	/**
	 * a method to get transparently the associated Application instance.
	 */
	public function getSLPlayer() : Application;
}

/**
 * The common code to all SLPlayer components.
 */
class SLPlayerComponent 
{
	static public function initSLPlayerComponent(component : ISLPlayerComponent, SLPlayerInstanceId : String):Void
	{
		component.SLPlayerInstanceId = SLPlayerInstanceId;
	}
	
	static public function getSLPlayer(component : ISLPlayerComponent):Application
	{
		return Application.get(component.SLPlayerInstanceId);
	}
}

/**
 * The macro code adding the common pieces of code to all implementations of ISLPlayerComponent.
 */
//@:macro class SLPlayerComponentBuilder
//{
	///**
	 //* Automatically adds the initialization call of an ISLPlayerComponent component at the first line of the constructors 
	 //* of your ISLPlayerComponent components.
	 //*/
	//static public function build() : Array<Field>
	//{
		//var fields = Context.getBuildFields();
		//
		//if ( Context.getLocalClass().get().isInterface )
			//return fields;
		//
		////
		//Disable the cumulative behavior of @:autoBuild ( @see https://groups.google.com/forum/?hl=fr&fromgroups#!topic/haxelang/5KxTAO3BrHw ).
		//TODO find a way to generalize this
		//if ( Context.getLocalClass().get().meta.has( "slplayer.core.ISLPlayerComponent" ) )
			//return fields;
		//
		//var pos = Context.currentPos();
		//
		//Context.getLocalClass().get().meta.add( "slplayer.core.ISLPlayerComponent" , [] , pos);
		////
		//
		//#if slpdebug
			//trace("Executing SLPlayerComponentBuilder on : "+Context.getLocalClass().get().name);
		//#end
		//
		//discover new or create it
		//var newExprs : Array<Expr> = null;
		//
		//tells if a getSLPlayer method already exists
		//var getSLPlayerFound = false;
		//
		//TODO FIXME throw an error if already existing getSLPlayer() method ?
		//for (fc in 0...fields.length) { 
			//switch (fields[fc].kind) { case FFun(f) : switch (f.expr.expr) { case EBlock(exprs): 
				//if (fields[fc].name == "new") { newExprs = exprs; } 
				//if (fields[fc].name == "getSLPlayer") { getSLPlayerFound = true; } 
			//default : } default : } 
		//}
				//
		//append groupElement initialization as first expr of new method
		// TODO FIXME search for any contructor in any potential parent class and get the constructor signature
		//if ( newExprs == null ) newExprs = new Array();
		///*{
			//case new() hasn't been overriden
			//newExprs = new Array();
			//
			//newExprs.push( { expr : ECall({ expr : EConst(CIdent("super")), pos : pos },[{ expr : EConst(CIdent("rootElement")), pos : pos }, { expr : EConst(CType("SLPId")), pos : pos }]), pos : pos } );
			//
			//fields.push( { kind : FFun( { args : [ { name : "rootElement", type : TPath( { name : "HtmlDom", pack : [], params : [], sub : null } ), opt : false, value : null },
							//{ name : "SLPId", type : TPath( { name : "String", pack : [], params : [], sub : null } ), opt : false, value : null } ], expr : { expr : EBlock( newExprs ), pos : pos },
								//params : [], ret : null }), meta : [], name : "new" , doc : null, pos : pos , access : [APrivate, AOverride] } );
		//}
		//*/
		//
		//Add the SLPlayerComponent initialization call in component constructor
		//newExprs.insert( 0 , { expr : ECall( { expr : EField( { expr : EType( { expr : EType( { expr : EField( { expr : EConst(CIdent("slplayer")), pos : pos }, "core"), pos : pos }, "ISLPlayerComponent"), pos : pos }, "SLPlayerComponent"), pos : pos }, "initSLPlayerComponent"), pos : pos } , [{ expr : EConst(CIdent("this")), pos : pos }, { expr : EConst(CType("SLPId")) , pos : pos }]) , pos : pos } );
		//
		//Add in the components fields the getSLPlayer() method which returns the running SLPlayer Application instance of the component.
		//if ( getSLPlayerFound )
		//{
			//fields.push( { kind : FFun( { args : [], expr : { expr : EBlock( [ { expr : ECall( { expr : EField( { expr : EType( { expr : EType( { expr : EField( { expr : EConst(CIdent("slplayer")), pos : pos },
				//"core"), pos : pos }, "ISLPlayerComponent"), pos : pos }, "SLPlayerComponent"), pos : pos }, "getSLPlayer"), pos : pos } , [{ expr : EConst(CIdent("this")), pos : pos }]) , pos : pos } ] ), pos : pos },
					//params : [], ret : null } ), meta : [], name : "getSLPlayer" , doc : null, pos : pos , access : [APublic] } );
		//}
		//
		//return fields;
	//}
//}