(function () { "use strict";
var $hxClasses = {},$estr = function() { return js.Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function inherit() {}; inherit.prototype = from; var proto = new inherit();
	for (var name in fields) proto[name] = fields[name];
	return proto;
}
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
$hxClasses["EReg"] = EReg;
EReg.__name__ = ["EReg"];
EReg.prototype = {
	customReplace: function(s,f) {
		var buf = new StringBuf();
		while(true) {
			if(!this.match(s)) break;
			buf.b += Std.string(this.matchedLeft());
			buf.b += Std.string(f(this));
			s = this.matchedRight();
		}
		buf.b += Std.string(s);
		return buf.b;
	}
	,replace: function(s,by) {
		return s.replace(this.r,by);
	}
	,split: function(s) {
		var d = "#__delim__#";
		return s.replace(this.r,d).split(d);
	}
	,matchedPos: function() {
		if(this.r.m == null) throw "No string matched";
		return { pos : this.r.m.index, len : this.r.m[0].length};
	}
	,matchedRight: function() {
		if(this.r.m == null) throw "No string matched";
		var sz = this.r.m.index + this.r.m[0].length;
		return this.r.s.substr(sz,this.r.s.length - sz);
	}
	,matchedLeft: function() {
		if(this.r.m == null) throw "No string matched";
		return this.r.s.substr(0,this.r.m.index);
	}
	,matched: function(n) {
		return this.r.m != null && n >= 0 && n < this.r.m.length?this.r.m[n]:(function($this) {
			var $r;
			throw "EReg::matched";
			return $r;
		}(this));
	}
	,match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,r: null
	,__class__: EReg
}
var Hash = function() {
	this.h = { };
};
$hxClasses["Hash"] = Hash;
Hash.__name__ = ["Hash"];
Hash.prototype = {
	toString: function() {
		var s = new StringBuf();
		s.b += Std.string("{");
		var it = this.keys();
		while( it.hasNext() ) {
			var i = it.next();
			s.b += Std.string(i);
			s.b += Std.string(" => ");
			s.b += Std.string(Std.string(this.get(i)));
			if(it.hasNext()) s.b += Std.string(", ");
		}
		s.b += Std.string("}");
		return s.b;
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref["$" + i];
		}};
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return HxOverrides.iter(a);
	}
	,remove: function(key) {
		key = "$" + key;
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,exists: function(key) {
		return this.h.hasOwnProperty("$" + key);
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,set: function(key,value) {
		this.h["$" + key] = value;
	}
	,h: null
	,__class__: Hash
}
var HxOverrides = function() { }
$hxClasses["HxOverrides"] = HxOverrides;
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.dateStr = function(date) {
	var m = date.getMonth() + 1;
	var d = date.getDate();
	var h = date.getHours();
	var mi = date.getMinutes();
	var s = date.getSeconds();
	return date.getFullYear() + "-" + (m < 10?"0" + m:"" + m) + "-" + (d < 10?"0" + d:"" + d) + " " + (h < 10?"0" + h:"" + h) + ":" + (mi < 10?"0" + mi:"" + mi) + ":" + (s < 10?"0" + s:"" + s);
}
HxOverrides.strDate = function(s) {
	switch(s.length) {
	case 8:
		var k = s.split(":");
		var d = new Date();
		d.setTime(0);
		d.setUTCHours(k[0]);
		d.setUTCMinutes(k[1]);
		d.setUTCSeconds(k[2]);
		return d;
	case 10:
		var k = s.split("-");
		return new Date(k[0],k[1] - 1,k[2],0,0,0);
	case 19:
		var k = s.split(" ");
		var y = k[0].split("-");
		var t = k[1].split(":");
		return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
	default:
		throw "Invalid date format : " + s;
	}
}
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
}
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
}
HxOverrides.remove = function(a,obj) {
	var i = 0;
	var l = a.length;
	while(i < l) {
		if(a[i] == obj) {
			a.splice(i,1);
			return true;
		}
		i++;
	}
	return false;
}
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
}
var IntIter = function(min,max) {
	this.min = min;
	this.max = max;
};
$hxClasses["IntIter"] = IntIter;
IntIter.__name__ = ["IntIter"];
IntIter.prototype = {
	next: function() {
		return this.min++;
	}
	,hasNext: function() {
		return this.min < this.max;
	}
	,max: null
	,min: null
	,__class__: IntIter
}
var Lambda = function() { }
$hxClasses["Lambda"] = Lambda;
Lambda.__name__ = ["Lambda"];
Lambda.array = function(it) {
	var a = new Array();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		a.push(i);
	}
	return a;
}
Lambda.list = function(it) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		l.add(i);
	}
	return l;
}
Lambda.map = function(it,f) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(f(x));
	}
	return l;
}
Lambda.mapi = function(it,f) {
	var l = new List();
	var i = 0;
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(f(i++,x));
	}
	return l;
}
Lambda.has = function(it,elt,cmp) {
	if(cmp == null) {
		var $it0 = $iterator(it)();
		while( $it0.hasNext() ) {
			var x = $it0.next();
			if(x == elt) return true;
		}
	} else {
		var $it1 = $iterator(it)();
		while( $it1.hasNext() ) {
			var x = $it1.next();
			if(cmp(x,elt)) return true;
		}
	}
	return false;
}
Lambda.exists = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) return true;
	}
	return false;
}
Lambda.foreach = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(!f(x)) return false;
	}
	return true;
}
Lambda.iter = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		f(x);
	}
}
Lambda.filter = function(it,f) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) l.add(x);
	}
	return l;
}
Lambda.fold = function(it,f,first) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		first = f(x,first);
	}
	return first;
}
Lambda.count = function(it,pred) {
	var n = 0;
	if(pred == null) {
		var $it0 = $iterator(it)();
		while( $it0.hasNext() ) {
			var _ = $it0.next();
			n++;
		}
	} else {
		var $it1 = $iterator(it)();
		while( $it1.hasNext() ) {
			var x = $it1.next();
			if(pred(x)) n++;
		}
	}
	return n;
}
Lambda.empty = function(it) {
	return !$iterator(it)().hasNext();
}
Lambda.indexOf = function(it,v) {
	var i = 0;
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var v2 = $it0.next();
		if(v == v2) return i;
		i++;
	}
	return -1;
}
Lambda.concat = function(a,b) {
	var l = new List();
	var $it0 = $iterator(a)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(x);
	}
	var $it1 = $iterator(b)();
	while( $it1.hasNext() ) {
		var x = $it1.next();
		l.add(x);
	}
	return l;
}
var List = function() {
	this.length = 0;
};
$hxClasses["List"] = List;
List.__name__ = ["List"];
List.prototype = {
	map: function(f) {
		var b = new List();
		var l = this.h;
		while(l != null) {
			var v = l[0];
			l = l[1];
			b.add(f(v));
		}
		return b;
	}
	,filter: function(f) {
		var l2 = new List();
		var l = this.h;
		while(l != null) {
			var v = l[0];
			l = l[1];
			if(f(v)) l2.add(v);
		}
		return l2;
	}
	,join: function(sep) {
		var s = new StringBuf();
		var first = true;
		var l = this.h;
		while(l != null) {
			if(first) first = false; else s.b += Std.string(sep);
			s.b += Std.string(l[0]);
			l = l[1];
		}
		return s.b;
	}
	,toString: function() {
		var s = new StringBuf();
		var first = true;
		var l = this.h;
		s.b += Std.string("{");
		while(l != null) {
			if(first) first = false; else s.b += Std.string(", ");
			s.b += Std.string(Std.string(l[0]));
			l = l[1];
		}
		s.b += Std.string("}");
		return s.b;
	}
	,iterator: function() {
		return { h : this.h, hasNext : function() {
			return this.h != null;
		}, next : function() {
			if(this.h == null) return null;
			var x = this.h[0];
			this.h = this.h[1];
			return x;
		}};
	}
	,remove: function(v) {
		var prev = null;
		var l = this.h;
		while(l != null) {
			if(l[0] == v) {
				if(prev == null) this.h = l[1]; else prev[1] = l[1];
				if(this.q == l) this.q = prev;
				this.length--;
				return true;
			}
			prev = l;
			l = l[1];
		}
		return false;
	}
	,clear: function() {
		this.h = null;
		this.q = null;
		this.length = 0;
	}
	,isEmpty: function() {
		return this.h == null;
	}
	,pop: function() {
		if(this.h == null) return null;
		var x = this.h[0];
		this.h = this.h[1];
		if(this.h == null) this.q = null;
		this.length--;
		return x;
	}
	,last: function() {
		return this.q == null?null:this.q[0];
	}
	,first: function() {
		return this.h == null?null:this.h[0];
	}
	,push: function(item) {
		var x = [item,this.h];
		this.h = x;
		if(this.q == null) this.q = x;
		this.length++;
	}
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,length: null
	,q: null
	,h: null
	,__class__: List
}
var Reflect = function() { }
$hxClasses["Reflect"] = Reflect;
Reflect.__name__ = ["Reflect"];
Reflect.hasField = function(o,field) {
	return Object.prototype.hasOwnProperty.call(o,field);
}
Reflect.field = function(o,field) {
	var v = null;
	try {
		v = o[field];
	} catch( e ) {
	}
	return v;
}
Reflect.setField = function(o,field,value) {
	o[field] = value;
}
Reflect.getProperty = function(o,field) {
	var tmp;
	return o == null?null:o.__properties__ && (tmp = o.__properties__["get_" + field])?o[tmp]():o[field];
}
Reflect.setProperty = function(o,field,value) {
	var tmp;
	if(o.__properties__ && (tmp = o.__properties__["set_" + field])) o[tmp](value); else o[field] = value;
}
Reflect.callMethod = function(o,func,args) {
	return func.apply(o,args);
}
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
}
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
}
Reflect.compare = function(a,b) {
	return a == b?0:a > b?1:-1;
}
Reflect.compareMethods = function(f1,f2) {
	if(f1 == f2) return true;
	if(!Reflect.isFunction(f1) || !Reflect.isFunction(f2)) return false;
	return f1.scope == f2.scope && f1.method == f2.method && f1.method != null;
}
Reflect.isObject = function(v) {
	if(v == null) return false;
	var t = typeof(v);
	return t == "string" || t == "object" && !v.__enum__ || t == "function" && (v.__name__ || v.__ename__);
}
Reflect.deleteField = function(o,f) {
	if(!Reflect.hasField(o,f)) return false;
	delete(o[f]);
	return true;
}
Reflect.copy = function(o) {
	var o2 = { };
	var _g = 0, _g1 = Reflect.fields(o);
	while(_g < _g1.length) {
		var f = _g1[_g];
		++_g;
		o2[f] = Reflect.field(o,f);
	}
	return o2;
}
Reflect.makeVarArgs = function(f) {
	return function() {
		var a = Array.prototype.slice.call(arguments);
		return f(a);
	};
}
var Std = function() { }
$hxClasses["Std"] = Std;
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
}
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std["int"] = function(x) {
	return x | 0;
}
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
Std.random = function(x) {
	return Math.floor(Math.random() * x);
}
var StringBuf = function() {
	this.b = "";
};
$hxClasses["StringBuf"] = StringBuf;
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype = {
	toString: function() {
		return this.b;
	}
	,addSub: function(s,pos,len) {
		this.b += HxOverrides.substr(s,pos,len);
	}
	,addChar: function(c) {
		this.b += String.fromCharCode(c);
	}
	,add: function(x) {
		this.b += Std.string(x);
	}
	,b: null
	,__class__: StringBuf
}
var StringTools = function() { }
$hxClasses["StringTools"] = StringTools;
StringTools.__name__ = ["StringTools"];
StringTools.urlEncode = function(s) {
	return encodeURIComponent(s);
}
StringTools.urlDecode = function(s) {
	return decodeURIComponent(s.split("+").join(" "));
}
StringTools.htmlEscape = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
StringTools.htmlUnescape = function(s) {
	return s.split("&gt;").join(">").split("&lt;").join("<").split("&amp;").join("&");
}
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && HxOverrides.substr(s,0,start.length) == start;
}
StringTools.endsWith = function(s,end) {
	var elen = end.length;
	var slen = s.length;
	return slen >= elen && HxOverrides.substr(s,slen - elen,elen) == end;
}
StringTools.isSpace = function(s,pos) {
	var c = HxOverrides.cca(s,pos);
	return c >= 9 && c <= 13 || c == 32;
}
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) return HxOverrides.substr(s,r,l - r); else return s;
}
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
	if(r > 0) return HxOverrides.substr(s,0,l - r); else return s;
}
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
}
StringTools.rpad = function(s,c,l) {
	var sl = s.length;
	var cl = c.length;
	while(sl < l) if(l - sl < cl) {
		s += HxOverrides.substr(c,0,l - sl);
		sl = l;
	} else {
		s += c;
		sl += cl;
	}
	return s;
}
StringTools.lpad = function(s,c,l) {
	var ns = "";
	var sl = s.length;
	if(sl >= l) return s;
	var cl = c.length;
	while(sl < l) if(l - sl < cl) {
		ns += HxOverrides.substr(c,0,l - sl);
		sl = l;
	} else {
		ns += c;
		sl += cl;
	}
	return ns + s;
}
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
}
StringTools.hex = function(n,digits) {
	var s = "";
	var hexChars = "0123456789ABCDEF";
	do {
		s = hexChars.charAt(n & 15) + s;
		n >>>= 4;
	} while(n > 0);
	if(digits != null) while(s.length < digits) s = "0" + s;
	return s;
}
StringTools.fastCodeAt = function(s,index) {
	return s.charCodeAt(index);
}
StringTools.isEOF = function(c) {
	return c != c;
}
var ValueType = $hxClasses["ValueType"] = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] }
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
var Type = function() { }
$hxClasses["Type"] = Type;
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null;
	return o.__class__;
}
Type.getEnum = function(o) {
	if(o == null) return null;
	return o.__enum__;
}
Type.getSuperClass = function(c) {
	return c.__super__;
}
Type.getClassName = function(c) {
	var a = c.__name__;
	return a.join(".");
}
Type.getEnumName = function(e) {
	var a = e.__ename__;
	return a.join(".");
}
Type.resolveClass = function(name) {
	var cl = $hxClasses[name];
	if(cl == null || !cl.__name__) return null;
	return cl;
}
Type.resolveEnum = function(name) {
	var e = $hxClasses[name];
	if(e == null || !e.__ename__) return null;
	return e;
}
Type.createInstance = function(cl,args) {
	switch(args.length) {
	case 0:
		return new cl();
	case 1:
		return new cl(args[0]);
	case 2:
		return new cl(args[0],args[1]);
	case 3:
		return new cl(args[0],args[1],args[2]);
	case 4:
		return new cl(args[0],args[1],args[2],args[3]);
	case 5:
		return new cl(args[0],args[1],args[2],args[3],args[4]);
	case 6:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5]);
	case 7:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
	case 8:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
	default:
		throw "Too many arguments";
	}
	return null;
}
Type.createEmptyInstance = function(cl) {
	function empty() {}; empty.prototype = cl.prototype;
	return new empty();
}
Type.createEnum = function(e,constr,params) {
	var f = Reflect.field(e,constr);
	if(f == null) throw "No such constructor " + constr;
	if(Reflect.isFunction(f)) {
		if(params == null) throw "Constructor " + constr + " need parameters";
		return f.apply(e,params);
	}
	if(params != null && params.length != 0) throw "Constructor " + constr + " does not need parameters";
	return f;
}
Type.createEnumIndex = function(e,index,params) {
	var c = e.__constructs__[index];
	if(c == null) throw index + " is not a valid enum constructor index";
	return Type.createEnum(e,c,params);
}
Type.getInstanceFields = function(c) {
	var a = [];
	for(var i in c.prototype) a.push(i);
	HxOverrides.remove(a,"__class__");
	HxOverrides.remove(a,"__properties__");
	return a;
}
Type.getClassFields = function(c) {
	var a = Reflect.fields(c);
	HxOverrides.remove(a,"__name__");
	HxOverrides.remove(a,"__interfaces__");
	HxOverrides.remove(a,"__properties__");
	HxOverrides.remove(a,"__super__");
	HxOverrides.remove(a,"prototype");
	return a;
}
Type.getEnumConstructs = function(e) {
	var a = e.__constructs__;
	return a.slice();
}
Type["typeof"] = function(v) {
	switch(typeof(v)) {
	case "boolean":
		return ValueType.TBool;
	case "string":
		return ValueType.TClass(String);
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	case "object":
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = v.__class__;
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	case "function":
		if(v.__name__ || v.__ename__) return ValueType.TObject;
		return ValueType.TFunction;
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
}
Type.enumEq = function(a,b) {
	if(a == b) return true;
	try {
		if(a[0] != b[0]) return false;
		var _g1 = 2, _g = a.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(!Type.enumEq(a[i],b[i])) return false;
		}
		var e = a.__enum__;
		if(e != b.__enum__ || e == null) return false;
	} catch( e ) {
		return false;
	}
	return true;
}
Type.enumConstructor = function(e) {
	return e[0];
}
Type.enumParameters = function(e) {
	return e.slice(2);
}
Type.enumIndex = function(e) {
	return e[1];
}
Type.allEnums = function(e) {
	var all = [];
	var cst = e.__constructs__;
	var _g = 0;
	while(_g < cst.length) {
		var c = cst[_g];
		++_g;
		var v = Reflect.field(e,c);
		if(!Reflect.isFunction(v)) all.push(v);
	}
	return all;
}
var haxe = {}
haxe.Log = function() { }
$hxClasses["haxe.Log"] = haxe.Log;
haxe.Log.__name__ = ["haxe","Log"];
haxe.Log.trace = function(v,infos) {
	js.Boot.__trace(v,infos);
}
haxe.Log.clear = function() {
	js.Boot.__clear_trace();
}
haxe._Template = {}
haxe._Template.TemplateExpr = $hxClasses["haxe._Template.TemplateExpr"] = { __ename__ : ["haxe","_Template","TemplateExpr"], __constructs__ : ["OpVar","OpExpr","OpIf","OpStr","OpBlock","OpForeach","OpMacro"] }
haxe._Template.TemplateExpr.OpVar = function(v) { var $x = ["OpVar",0,v]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpExpr = function(expr) { var $x = ["OpExpr",1,expr]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpIf = function(expr,eif,eelse) { var $x = ["OpIf",2,expr,eif,eelse]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpStr = function(str) { var $x = ["OpStr",3,str]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpBlock = function(l) { var $x = ["OpBlock",4,l]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpForeach = function(expr,loop) { var $x = ["OpForeach",5,expr,loop]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpMacro = function(name,params) { var $x = ["OpMacro",6,name,params]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe.Template = function(str) {
	var tokens = this.parseTokens(str);
	this.expr = this.parseBlock(tokens);
	if(!tokens.isEmpty()) throw "Unexpected '" + Std.string(tokens.first().s) + "'";
};
$hxClasses["haxe.Template"] = haxe.Template;
haxe.Template.__name__ = ["haxe","Template"];
haxe.Template.prototype = {
	run: function(e) {
		var $e = (e);
		switch( $e[1] ) {
		case 0:
			var v = $e[2];
			this.buf.b += Std.string(Std.string(this.resolve(v)));
			break;
		case 1:
			var e1 = $e[2];
			this.buf.b += Std.string(Std.string(e1()));
			break;
		case 2:
			var eelse = $e[4], eif = $e[3], e1 = $e[2];
			var v = e1();
			if(v == null || v == false) {
				if(eelse != null) this.run(eelse);
			} else this.run(eif);
			break;
		case 3:
			var str = $e[2];
			this.buf.b += Std.string(str);
			break;
		case 4:
			var l = $e[2];
			var $it0 = l.iterator();
			while( $it0.hasNext() ) {
				var e1 = $it0.next();
				this.run(e1);
			}
			break;
		case 5:
			var loop = $e[3], e1 = $e[2];
			var v = e1();
			try {
				var x = $iterator(v)();
				if(x.hasNext == null) throw null;
				v = x;
			} catch( e2 ) {
				try {
					if(v.hasNext == null) throw null;
				} catch( e3 ) {
					throw "Cannot iter on " + Std.string(v);
				}
			}
			this.stack.push(this.context);
			var v1 = v;
			while( v1.hasNext() ) {
				var ctx = v1.next();
				this.context = ctx;
				this.run(loop);
			}
			this.context = this.stack.pop();
			break;
		case 6:
			var params = $e[3], m = $e[2];
			var v = Reflect.field(this.macros,m);
			var pl = new Array();
			var old = this.buf;
			pl.push($bind(this,this.resolve));
			var $it1 = params.iterator();
			while( $it1.hasNext() ) {
				var p = $it1.next();
				var $e = (p);
				switch( $e[1] ) {
				case 0:
					var v1 = $e[2];
					pl.push(this.resolve(v1));
					break;
				default:
					this.buf = new StringBuf();
					this.run(p);
					pl.push(this.buf.b);
				}
			}
			this.buf = old;
			try {
				this.buf.b += Std.string(Std.string(v.apply(this.macros,pl)));
			} catch( e1 ) {
				var plstr = (function($this) {
					var $r;
					try {
						$r = pl.join(",");
					} catch( e2 ) {
						$r = "???";
					}
					return $r;
				}(this));
				var msg = "Macro call " + m + "(" + plstr + ") failed (" + Std.string(e1) + ")";
				throw msg;
			}
			break;
		}
	}
	,makeExpr2: function(l) {
		var p = l.pop();
		if(p == null) throw "<eof>";
		if(p.s) return this.makeConst(p.p);
		switch(p.p) {
		case "(":
			var e1 = this.makeExpr(l);
			var p1 = l.pop();
			if(p1 == null || p1.s) throw p1.p;
			if(p1.p == ")") return e1;
			var e2 = this.makeExpr(l);
			var p2 = l.pop();
			if(p2 == null || p2.p != ")") throw p2.p;
			return (function($this) {
				var $r;
				switch(p1.p) {
				case "+":
					$r = function() {
						return e1() + e2();
					};
					break;
				case "-":
					$r = function() {
						return e1() - e2();
					};
					break;
				case "*":
					$r = function() {
						return e1() * e2();
					};
					break;
				case "/":
					$r = function() {
						return e1() / e2();
					};
					break;
				case ">":
					$r = function() {
						return e1() > e2();
					};
					break;
				case "<":
					$r = function() {
						return e1() < e2();
					};
					break;
				case ">=":
					$r = function() {
						return e1() >= e2();
					};
					break;
				case "<=":
					$r = function() {
						return e1() <= e2();
					};
					break;
				case "==":
					$r = function() {
						return e1() == e2();
					};
					break;
				case "!=":
					$r = function() {
						return e1() != e2();
					};
					break;
				case "&&":
					$r = function() {
						return e1() && e2();
					};
					break;
				case "||":
					$r = function() {
						return e1() || e2();
					};
					break;
				default:
					$r = (function($this) {
						var $r;
						throw "Unknown operation " + p1.p;
						return $r;
					}($this));
				}
				return $r;
			}(this));
		case "!":
			var e = this.makeExpr(l);
			return function() {
				var v = e();
				return v == null || v == false;
			};
		case "-":
			var e = this.makeExpr(l);
			return function() {
				return -e();
			};
		}
		throw p.p;
	}
	,makeExpr: function(l) {
		return this.makePath(this.makeExpr2(l),l);
	}
	,makePath: function(e,l) {
		var p = l.first();
		if(p == null || p.p != ".") return e;
		l.pop();
		var field = l.pop();
		if(field == null || !field.s) throw field.p;
		var f = field.p;
		haxe.Template.expr_trim.match(f);
		f = haxe.Template.expr_trim.matched(1);
		return this.makePath(function() {
			return Reflect.field(e(),f);
		},l);
	}
	,makeConst: function(v) {
		haxe.Template.expr_trim.match(v);
		v = haxe.Template.expr_trim.matched(1);
		if(HxOverrides.cca(v,0) == 34) {
			var str = HxOverrides.substr(v,1,v.length - 2);
			return function() {
				return str;
			};
		}
		if(haxe.Template.expr_int.match(v)) {
			var i = Std.parseInt(v);
			return function() {
				return i;
			};
		}
		if(haxe.Template.expr_float.match(v)) {
			var f = Std.parseFloat(v);
			return function() {
				return f;
			};
		}
		var me = this;
		return function() {
			return me.resolve(v);
		};
	}
	,parseExpr: function(data) {
		var l = new List();
		var expr = data;
		while(haxe.Template.expr_splitter.match(data)) {
			var p = haxe.Template.expr_splitter.matchedPos();
			var k = p.pos + p.len;
			if(p.pos != 0) l.add({ p : HxOverrides.substr(data,0,p.pos), s : true});
			var p1 = haxe.Template.expr_splitter.matched(0);
			l.add({ p : p1, s : p1.indexOf("\"") >= 0});
			data = haxe.Template.expr_splitter.matchedRight();
		}
		if(data.length != 0) l.add({ p : data, s : true});
		var e;
		try {
			e = this.makeExpr(l);
			if(!l.isEmpty()) throw l.first().p;
		} catch( s ) {
			if( js.Boot.__instanceof(s,String) ) {
				throw "Unexpected '" + s + "' in " + expr;
			} else throw(s);
		}
		return function() {
			try {
				return e();
			} catch( exc ) {
				throw "Error : " + Std.string(exc) + " in " + expr;
			}
		};
	}
	,parse: function(tokens) {
		var t = tokens.pop();
		var p = t.p;
		if(t.s) return haxe._Template.TemplateExpr.OpStr(p);
		if(t.l != null) {
			var pe = new List();
			var _g = 0, _g1 = t.l;
			while(_g < _g1.length) {
				var p1 = _g1[_g];
				++_g;
				pe.add(this.parseBlock(this.parseTokens(p1)));
			}
			return haxe._Template.TemplateExpr.OpMacro(p,pe);
		}
		if(HxOverrides.substr(p,0,3) == "if ") {
			p = HxOverrides.substr(p,3,p.length - 3);
			var e = this.parseExpr(p);
			var eif = this.parseBlock(tokens);
			var t1 = tokens.first();
			var eelse;
			if(t1 == null) throw "Unclosed 'if'";
			if(t1.p == "end") {
				tokens.pop();
				eelse = null;
			} else if(t1.p == "else") {
				tokens.pop();
				eelse = this.parseBlock(tokens);
				t1 = tokens.pop();
				if(t1 == null || t1.p != "end") throw "Unclosed 'else'";
			} else {
				t1.p = HxOverrides.substr(t1.p,4,t1.p.length - 4);
				eelse = this.parse(tokens);
			}
			return haxe._Template.TemplateExpr.OpIf(e,eif,eelse);
		}
		if(HxOverrides.substr(p,0,8) == "foreach ") {
			p = HxOverrides.substr(p,8,p.length - 8);
			var e = this.parseExpr(p);
			var efor = this.parseBlock(tokens);
			var t1 = tokens.pop();
			if(t1 == null || t1.p != "end") throw "Unclosed 'foreach'";
			return haxe._Template.TemplateExpr.OpForeach(e,efor);
		}
		if(haxe.Template.expr_splitter.match(p)) return haxe._Template.TemplateExpr.OpExpr(this.parseExpr(p));
		return haxe._Template.TemplateExpr.OpVar(p);
	}
	,parseBlock: function(tokens) {
		var l = new List();
		while(true) {
			var t = tokens.first();
			if(t == null) break;
			if(!t.s && (t.p == "end" || t.p == "else" || HxOverrides.substr(t.p,0,7) == "elseif ")) break;
			l.add(this.parse(tokens));
		}
		if(l.length == 1) return l.first();
		return haxe._Template.TemplateExpr.OpBlock(l);
	}
	,parseTokens: function(data) {
		var tokens = new List();
		while(haxe.Template.splitter.match(data)) {
			var p = haxe.Template.splitter.matchedPos();
			if(p.pos > 0) tokens.add({ p : HxOverrides.substr(data,0,p.pos), s : true, l : null});
			if(HxOverrides.cca(data,p.pos) == 58) {
				tokens.add({ p : HxOverrides.substr(data,p.pos + 2,p.len - 4), s : false, l : null});
				data = haxe.Template.splitter.matchedRight();
				continue;
			}
			var parp = p.pos + p.len;
			var npar = 1;
			while(npar > 0) {
				var c = HxOverrides.cca(data,parp);
				if(c == 40) npar++; else if(c == 41) npar--; else if(c == null) throw "Unclosed macro parenthesis";
				parp++;
			}
			var params = HxOverrides.substr(data,p.pos + p.len,parp - (p.pos + p.len) - 1).split(",");
			tokens.add({ p : haxe.Template.splitter.matched(2), s : false, l : params});
			data = HxOverrides.substr(data,parp,data.length - parp);
		}
		if(data.length > 0) tokens.add({ p : data, s : true, l : null});
		return tokens;
	}
	,resolve: function(v) {
		if(Reflect.hasField(this.context,v)) return Reflect.field(this.context,v);
		var $it0 = this.stack.iterator();
		while( $it0.hasNext() ) {
			var ctx = $it0.next();
			if(Reflect.hasField(ctx,v)) return Reflect.field(ctx,v);
		}
		if(v == "__current__") return this.context;
		return Reflect.field(haxe.Template.globals,v);
	}
	,execute: function(context,macros) {
		this.macros = macros == null?{ }:macros;
		this.context = context;
		this.stack = new List();
		this.buf = new StringBuf();
		this.run(this.expr);
		return this.buf.b;
	}
	,buf: null
	,stack: null
	,macros: null
	,context: null
	,expr: null
	,__class__: haxe.Template
}
haxe.Timer = function(time_ms) {
	var me = this;
	this.id = window.setInterval(function() {
		me.run();
	},time_ms);
};
$hxClasses["haxe.Timer"] = haxe.Timer;
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.delay = function(f,time_ms) {
	var t = new haxe.Timer(time_ms);
	t.run = function() {
		t.stop();
		f();
	};
	return t;
}
haxe.Timer.measure = function(f,pos) {
	var t0 = haxe.Timer.stamp();
	var r = f();
	haxe.Log.trace(haxe.Timer.stamp() - t0 + "s",pos);
	return r;
}
haxe.Timer.stamp = function() {
	return new Date().getTime() / 1000;
}
haxe.Timer.prototype = {
	run: function() {
	}
	,stop: function() {
		if(this.id == null) return;
		window.clearInterval(this.id);
		this.id = null;
	}
	,id: null
	,__class__: haxe.Timer
}
haxe.rtti = {}
haxe.rtti.Meta = function() { }
$hxClasses["haxe.rtti.Meta"] = haxe.rtti.Meta;
haxe.rtti.Meta.__name__ = ["haxe","rtti","Meta"];
haxe.rtti.Meta.getType = function(t) {
	var meta = t.__meta__;
	return meta == null || meta.obj == null?{ }:meta.obj;
}
haxe.rtti.Meta.getStatics = function(t) {
	var meta = t.__meta__;
	return meta == null || meta.statics == null?{ }:meta.statics;
}
haxe.rtti.Meta.getFields = function(t) {
	var meta = t.__meta__;
	return meta == null || meta.fields == null?{ }:meta.fields;
}
var js = {}
js.Boot = function() { }
$hxClasses["js.Boot"] = js.Boot;
js.Boot.__name__ = ["js","Boot"];
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = i != null?i.fileName + ":" + i.lineNumber + ": ":"";
	msg += js.Boot.__string_rec(v,"");
	var d;
	if(typeof(document) != "undefined" && (d = document.getElementById("haxe:trace")) != null) d.innerHTML += js.Boot.__unhtml(msg) + "<br/>"; else if(typeof(console) != "undefined" && console.log != null) console.log(msg);
}
js.Boot.__clear_trace = function() {
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
}
js.Boot.isClass = function(o) {
	return o.__name__;
}
js.Boot.isEnum = function(e) {
	return e.__ename__;
}
js.Boot.getClass = function(o) {
	return o.__class__;
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	try {
		if(o instanceof cl) {
			if(cl == Array) return o.__enum__ == null;
			return true;
		}
		if(js.Boot.__interfLoop(o.__class__,cl)) return true;
	} catch( e ) {
		if(cl == null) return false;
	}
	switch(cl) {
	case Int:
		return Math.ceil(o%2147483648.0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return o === true || o === false;
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o == null) return false;
		if(cl == Class && o.__name__ != null) return true; else null;
		if(cl == Enum && o.__ename__ != null) return true; else null;
		return o.__enum__ == cl;
	}
}
js.Boot.__cast = function(o,t) {
	if(js.Boot.__instanceof(o,t)) return o; else throw "Cannot cast " + Std.string(o) + " to " + Std.string(t);
}
js.Lib = function() { }
$hxClasses["js.Lib"] = js.Lib;
js.Lib.__name__ = ["js","Lib"];
js.Lib.document = null;
js.Lib.window = null;
js.Lib.debug = function() {
	debugger;
}
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
}
js.Lib["eval"] = function(code) {
	return eval(code);
}
js.Lib.setErrorHandler = function(f) {
	js.Lib.onerror = f;
}
var org = {}
org.slplayer = {}
org.slplayer.component = {}
org.slplayer.component.ISLPlayerComponent = function() { }
$hxClasses["org.slplayer.component.ISLPlayerComponent"] = org.slplayer.component.ISLPlayerComponent;
org.slplayer.component.ISLPlayerComponent.__name__ = ["org","slplayer","component","ISLPlayerComponent"];
org.slplayer.component.ISLPlayerComponent.prototype = {
	getSLPlayer: null
	,SLPlayerInstanceId: null
	,__class__: org.slplayer.component.ISLPlayerComponent
}
org.slplayer.component.SLPlayerComponent = function() { }
$hxClasses["org.slplayer.component.SLPlayerComponent"] = org.slplayer.component.SLPlayerComponent;
org.slplayer.component.SLPlayerComponent.__name__ = ["org","slplayer","component","SLPlayerComponent"];
org.slplayer.component.SLPlayerComponent.initSLPlayerComponent = function(component,SLPlayerInstanceId) {
	component.SLPlayerInstanceId = SLPlayerInstanceId;
}
org.slplayer.component.SLPlayerComponent.getSLPlayer = function(component) {
	return org.slplayer.core.Application.get(component.SLPlayerInstanceId);
}
org.slplayer.component.SLPlayerComponent.checkRequiredParameters = function(cmpClass,elt) {
	var requires = haxe.rtti.Meta.getType(cmpClass).requires;
	if(requires == null) return;
	var _g = 0;
	while(_g < requires.length) {
		var r = requires[_g];
		++_g;
		if(elt.getAttribute(Std.string(r)) == null || StringTools.trim(elt.getAttribute(Std.string(r))) == "") throw Std.string(r) + " parameter is required for " + Type.getClassName(cmpClass);
	}
}
org.slplayer.component.ui = {}
org.slplayer.component.ui.IDisplayObject = function() { }
$hxClasses["org.slplayer.component.ui.IDisplayObject"] = org.slplayer.component.ui.IDisplayObject;
org.slplayer.component.ui.IDisplayObject.__name__ = ["org","slplayer","component","ui","IDisplayObject"];
org.slplayer.component.ui.IDisplayObject.__interfaces__ = [org.slplayer.component.ISLPlayerComponent];
org.slplayer.component.ui.IDisplayObject.prototype = {
	rootElement: null
	,__class__: org.slplayer.component.ui.IDisplayObject
}
org.slplayer.component.ui.DisplayObject = function(rootElement,SLPId) {
	this.rootElement = rootElement;
	org.slplayer.component.SLPlayerComponent.initSLPlayerComponent(this,SLPId);
	org.slplayer.core.Application.get(this.SLPlayerInstanceId).addAssociatedComponent(rootElement,this);
};
$hxClasses["org.slplayer.component.ui.DisplayObject"] = org.slplayer.component.ui.DisplayObject;
org.slplayer.component.ui.DisplayObject.__name__ = ["org","slplayer","component","ui","DisplayObject"];
org.slplayer.component.ui.DisplayObject.__interfaces__ = [org.slplayer.component.ui.IDisplayObject];
org.slplayer.component.ui.DisplayObject.isDisplayObject = function(cmpClass) {
	if(cmpClass == Type.resolveClass("org.slplayer.component.ui.DisplayObject")) return true;
	if(Type.getSuperClass(cmpClass) != null) return org.slplayer.component.ui.DisplayObject.isDisplayObject(Type.getSuperClass(cmpClass));
	return false;
}
org.slplayer.component.ui.DisplayObject.checkFilterOnElt = function(cmpClass,elt) {
	if(elt.nodeType != js.Lib.document.body.nodeType) throw "cannot instantiate " + Type.getClassName(cmpClass) + " on a non element node.";
	var tagFilter = haxe.rtti.Meta.getType(cmpClass) != null?haxe.rtti.Meta.getType(cmpClass).tagNameFilter:null;
	if(tagFilter == null) return;
	if(Lambda.exists(tagFilter,function(s) {
		return elt.nodeName.toLowerCase() == Std.string(s).toLowerCase();
	})) return;
	throw "cannot instantiate " + Type.getClassName(cmpClass) + " on this type of HTML element: " + elt.nodeName.toLowerCase();
}
org.slplayer.component.ui.DisplayObject.prototype = {
	init: function() {
	}
	,getSLPlayer: function() {
		return org.slplayer.component.SLPlayerComponent.getSLPlayer(this);
	}
	,rootElement: null
	,SLPlayerInstanceId: null
	,__class__: org.slplayer.component.ui.DisplayObject
}
org.slplayer.component.group = {}
org.slplayer.component.group.Group = function(rootElement,SLPId) {
	org.slplayer.component.ui.DisplayObject.call(this,rootElement,SLPId);
};
$hxClasses["org.slplayer.component.group.Group"] = org.slplayer.component.group.Group;
org.slplayer.component.group.Group.__name__ = ["org","slplayer","component","group","Group"];
org.slplayer.component.group.Group.__super__ = org.slplayer.component.ui.DisplayObject;
org.slplayer.component.group.Group.prototype = $extend(org.slplayer.component.ui.DisplayObject.prototype,{
	__class__: org.slplayer.component.group.Group
});
org.slplayer.component.group.IGroupable = function() { }
$hxClasses["org.slplayer.component.group.IGroupable"] = org.slplayer.component.group.IGroupable;
org.slplayer.component.group.IGroupable.__name__ = ["org","slplayer","component","group","IGroupable"];
org.slplayer.component.group.IGroupable.__interfaces__ = [org.slplayer.component.ui.IDisplayObject];
org.slplayer.component.group.IGroupable.prototype = {
	groupElement: null
	,__class__: org.slplayer.component.group.IGroupable
}
org.slplayer.component.group.Groupable = function() { }
$hxClasses["org.slplayer.component.group.Groupable"] = org.slplayer.component.group.Groupable;
org.slplayer.component.group.Groupable.__name__ = ["org","slplayer","component","group","Groupable"];
org.slplayer.component.group.Groupable.startGroupable = function(groupable) {
	var groupId = groupable.rootElement.getAttribute("data-group-id");
	if(groupId == null) return;
	var groupElements = js.Lib.document.getElementsByClassName(groupId);
	if(groupElements.length < 1) {
		haxe.Log.trace("WARNING: could not find the group component " + groupId,{ fileName : "IGroupable.hx", lineNumber : 57, className : "org.slplayer.component.group.Groupable", methodName : "startGroupable"});
		return;
	}
	if(groupElements.length > 1) throw "ERROR " + groupElements.length + " Group components are declared with the same group id " + groupId;
	groupable.groupElement = groupElements[0];
}
org.slplayer.component.navigation = {}
org.slplayer.component.navigation.LayerStatus = $hxClasses["org.slplayer.component.navigation.LayerStatus"] = { __ename__ : ["org","slplayer","component","navigation","LayerStatus"], __constructs__ : ["showTransition","hideTransition","visible","hidden","notInit"] }
org.slplayer.component.navigation.LayerStatus.showTransition = ["showTransition",0];
org.slplayer.component.navigation.LayerStatus.showTransition.toString = $estr;
org.slplayer.component.navigation.LayerStatus.showTransition.__enum__ = org.slplayer.component.navigation.LayerStatus;
org.slplayer.component.navigation.LayerStatus.hideTransition = ["hideTransition",1];
org.slplayer.component.navigation.LayerStatus.hideTransition.toString = $estr;
org.slplayer.component.navigation.LayerStatus.hideTransition.__enum__ = org.slplayer.component.navigation.LayerStatus;
org.slplayer.component.navigation.LayerStatus.visible = ["visible",2];
org.slplayer.component.navigation.LayerStatus.visible.toString = $estr;
org.slplayer.component.navigation.LayerStatus.visible.__enum__ = org.slplayer.component.navigation.LayerStatus;
org.slplayer.component.navigation.LayerStatus.hidden = ["hidden",3];
org.slplayer.component.navigation.LayerStatus.hidden.toString = $estr;
org.slplayer.component.navigation.LayerStatus.hidden.__enum__ = org.slplayer.component.navigation.LayerStatus;
org.slplayer.component.navigation.LayerStatus.notInit = ["notInit",4];
org.slplayer.component.navigation.LayerStatus.notInit.toString = $estr;
org.slplayer.component.navigation.LayerStatus.notInit.__enum__ = org.slplayer.component.navigation.LayerStatus;
org.slplayer.component.navigation.Layer = function(rootElement,SLPId) {
	this.hasTransitionStarted = false;
	org.slplayer.component.ui.DisplayObject.call(this,rootElement,SLPId);
	this.childrenArray = new Array();
	this.status = org.slplayer.component.navigation.LayerStatus.notInit;
	this.styleAttrDisplay = rootElement.style.display;
};
$hxClasses["org.slplayer.component.navigation.Layer"] = org.slplayer.component.navigation.Layer;
org.slplayer.component.navigation.Layer.__name__ = ["org","slplayer","component","navigation","Layer"];
org.slplayer.component.navigation.Layer.__super__ = org.slplayer.component.ui.DisplayObject;
org.slplayer.component.navigation.Layer.prototype = $extend(org.slplayer.component.ui.DisplayObject.prototype,{
	doHide: function(transitionData,preventTransitions,e) {
		haxe.Log.trace("doHide " + Std.string(preventTransitions),{ fileName : "Layer.hx", lineNumber : 364, className : "org.slplayer.component.navigation.Layer", methodName : "doHide"});
		haxe.Log.trace("remove " + this.rootElement.childNodes.length + " children ---",{ fileName : "Layer.hx", lineNumber : 365, className : "org.slplayer.component.navigation.Layer", methodName : "doHide"});
		if(e != null && e.target != this.rootElement) {
			haxe.Log.trace("End transition event from another html element",{ fileName : "Layer.hx", lineNumber : 367, className : "org.slplayer.component.navigation.Layer", methodName : "doHide"});
			return;
		}
		if(preventTransitions == false && this.doHideCallback == null) {
			haxe.Log.trace("Warning: end transition callback already called",{ fileName : "Layer.hx", lineNumber : 371, className : "org.slplayer.component.navigation.Layer", methodName : "doHide"});
			return;
		}
		if(preventTransitions == false) {
			this.endTransition(org.slplayer.component.navigation.transition.TransitionType.hide,transitionData,this.doHideCallback);
			this.doHideCallback = null;
		}
		this.status = org.slplayer.component.navigation.LayerStatus.hidden;
		try {
			var event = js.Lib.document.createEvent("CustomEvent");
			event.initCustomEvent("onLayerHide",false,false,{ transitionData : transitionData, target : this.rootElement, layer : this});
			this.rootElement.dispatchEvent(event);
		} catch( e1 ) {
			haxe.Log.trace("Error: could not dispatch event " + Std.string(e1),{ fileName : "Layer.hx", lineNumber : 394, className : "org.slplayer.component.navigation.Layer", methodName : "doHide"});
		}
		while(this.rootElement.childNodes.length > 0) {
			var element = this.rootElement.childNodes[0];
			this.rootElement.removeChild(element);
			this.childrenArray.push(element);
			if(element.tagName != null && (element.tagName.toLowerCase() == "audio" || element.tagName.toLowerCase() == "video")) try {
				element.pause();
				element.currentTime = 0;
			} catch( e1 ) {
				haxe.Log.trace("Layer error: could not access audio or video element",{ fileName : "Layer.hx", lineNumber : 415, className : "org.slplayer.component.navigation.Layer", methodName : "doHide"});
			}
		}
		this.rootElement.style.display = "none";
	}
	,hide: function(transitionData,preventTransitions) {
		if(this.status != org.slplayer.component.navigation.LayerStatus.visible && this.status != org.slplayer.component.navigation.LayerStatus.notInit) return;
		if(this.status == org.slplayer.component.navigation.LayerStatus.hideTransition) {
			haxe.Log.trace("Warning: hide break previous transition hide",{ fileName : "Layer.hx", lineNumber : 335, className : "org.slplayer.component.navigation.Layer", methodName : "hide"});
			this.doHideCallback(null);
			this.removeTransitionEvent(this.doHideCallback);
		} else if(this.status == org.slplayer.component.navigation.LayerStatus.showTransition) {
			haxe.Log.trace("Warning: hide break previous transition show",{ fileName : "Layer.hx", lineNumber : 341, className : "org.slplayer.component.navigation.Layer", methodName : "hide"});
			this.doShowCallback(null);
			this.removeTransitionEvent(this.doShowCallback);
		}
		this.status = org.slplayer.component.navigation.LayerStatus.hideTransition;
		if(preventTransitions == false) {
			this.doHideCallback = (function(f,a1,a2) {
				return function(e) {
					return f(a1,a2,e);
				};
			})($bind(this,this.doHide),transitionData,preventTransitions);
			this.startTransition(org.slplayer.component.navigation.transition.TransitionType.hide,transitionData,this.doHideCallback);
		} else this.doHide(transitionData,preventTransitions,null);
	}
	,doShow: function(transitionData,preventTransitions,e) {
		haxe.Log.trace("doShow",{ fileName : "Layer.hx", lineNumber : 303, className : "org.slplayer.component.navigation.Layer", methodName : "doShow"});
		if(e != null && e.target != this.rootElement) {
			haxe.Log.trace("End transition event from another html element",{ fileName : "Layer.hx", lineNumber : 305, className : "org.slplayer.component.navigation.Layer", methodName : "doShow"});
			return;
		}
		if(preventTransitions == false && this.doShowCallback == null) {
			haxe.Log.trace("Warning: end transition callback already called",{ fileName : "Layer.hx", lineNumber : 309, className : "org.slplayer.component.navigation.Layer", methodName : "doShow"});
			return;
		}
		if(preventTransitions == false) this.endTransition(org.slplayer.component.navigation.transition.TransitionType.show,transitionData,this.doShowCallback);
		this.doShowCallback = null;
		this.status = org.slplayer.component.navigation.LayerStatus.visible;
	}
	,show: function(transitionData,preventTransitions) {
		if(preventTransitions == null) preventTransitions = false;
		if(this.status != org.slplayer.component.navigation.LayerStatus.hidden && this.status != org.slplayer.component.navigation.LayerStatus.notInit) {
			haxe.Log.trace("Warning: can not show the layer, since it has the status '" + Std.string(this.status) + "'",{ fileName : "Layer.hx", lineNumber : 227, className : "org.slplayer.component.navigation.Layer", methodName : "show"});
			return;
		}
		if(this.status == org.slplayer.component.navigation.LayerStatus.hideTransition) {
			haxe.Log.trace("Warning: hide break previous transition hide",{ fileName : "Layer.hx", lineNumber : 232, className : "org.slplayer.component.navigation.Layer", methodName : "show"});
			this.doHideCallback(null);
			this.removeTransitionEvent(this.doHideCallback);
		} else if(this.status == org.slplayer.component.navigation.LayerStatus.showTransition) {
			haxe.Log.trace("Warning: hide break previous transition show",{ fileName : "Layer.hx", lineNumber : 238, className : "org.slplayer.component.navigation.Layer", methodName : "show"});
			this.doShowCallback(null);
			this.removeTransitionEvent(this.doShowCallback);
		}
		this.status = org.slplayer.component.navigation.LayerStatus.showTransition;
		while(this.childrenArray.length > 0) {
			var element = this.childrenArray.shift();
			this.rootElement.appendChild(element);
			if(element.tagName != null && (element.tagName.toLowerCase() == "audio" || element.tagName.toLowerCase() == "video")) try {
				if(element.autoplay == true) {
					element.currentTime = 0;
					element.play();
				}
				element.muted = org.slplayer.component.sound.SoundOn.isMuted;
			} catch( e ) {
				haxe.Log.trace("Layer error: could not access audio or video element",{ fileName : "Layer.hx", lineNumber : 266, className : "org.slplayer.component.navigation.Layer", methodName : "show"});
			}
		}
		try {
			var event = js.Lib.document.createEvent("CustomEvent");
			event.initCustomEvent("onLayerShow",false,false,{ transitionData : transitionData, target : this.rootElement, layer : this});
			this.rootElement.dispatchEvent(event);
		} catch( e ) {
			haxe.Log.trace("Error: could not dispatch event " + Std.string(e),{ fileName : "Layer.hx", lineNumber : 282, className : "org.slplayer.component.navigation.Layer", methodName : "show"});
		}
		if(preventTransitions == false) {
			this.doShowCallback = (function(f,a1,a2) {
				return function(e) {
					return f(a1,a2,e);
				};
			})($bind(this,this.doShow),transitionData,preventTransitions);
			this.startTransition(org.slplayer.component.navigation.transition.TransitionType.show,transitionData,this.doShowCallback);
		} else this.doShow(transitionData,preventTransitions,null);
		this.rootElement.style.display = this.styleAttrDisplay;
	}
	,removeTransitionEvent: function(onEndCallback) {
		this.rootElement.removeEventListener("transitionend",onEndCallback,false);
		this.rootElement.removeEventListener("transitionEnd",onEndCallback,false);
		this.rootElement.removeEventListener("webkitTransitionEnd",onEndCallback,false);
		this.rootElement.removeEventListener("oTransitionEnd",onEndCallback,false);
		this.rootElement.removeEventListener("MSTransitionEnd",onEndCallback,false);
	}
	,addTransitionEvent: function(onEndCallback) {
		this.rootElement.addEventListener("transitionend",onEndCallback,false);
		this.rootElement.addEventListener("transitionEnd",onEndCallback,false);
		this.rootElement.addEventListener("webkitTransitionEnd",onEndCallback,false);
		this.rootElement.addEventListener("oTransitionEnd",onEndCallback,false);
		this.rootElement.addEventListener("MSTransitionEnd",onEndCallback,false);
	}
	,endTransition: function(type,transitionData,onComplete) {
		this.removeTransitionEvent(onComplete);
		if(transitionData != null) org.slplayer.util.DomTools.removeClass(this.rootElement,transitionData.endStyleName);
		var transitionData2 = org.slplayer.component.navigation.transition.TransitionTools.getTransitionData(this.rootElement,type);
		if(transitionData2 != null) org.slplayer.util.DomTools.removeClass(this.rootElement,transitionData2.endStyleName);
	}
	,doStartTransition: function(sumOfTransitions,onComplete) {
		var _g = 0;
		while(_g < sumOfTransitions.length) {
			var transition = sumOfTransitions[_g];
			++_g;
			org.slplayer.util.DomTools.removeClass(this.rootElement,transition.startStyleName);
		}
		if(onComplete != null) this.addTransitionEvent(onComplete);
		org.slplayer.component.navigation.transition.TransitionTools.setTransitionProperty(this.rootElement,"transitionDuration",null);
		var _g = 0;
		while(_g < sumOfTransitions.length) {
			var transition = sumOfTransitions[_g];
			++_g;
			org.slplayer.util.DomTools.addClass(this.rootElement,transition.endStyleName);
		}
	}
	,startTransition: function(type,transitionData,onComplete) {
		var transitionData2 = org.slplayer.component.navigation.transition.TransitionTools.getTransitionData(this.rootElement,type);
		var sumOfTransitions = new Array();
		if(transitionData != null) sumOfTransitions.push(transitionData);
		if(transitionData2 != null) sumOfTransitions.push(transitionData2);
		if(sumOfTransitions.length == 0) {
			if(onComplete != null) onComplete(null);
		} else {
			this.hasTransitionStarted = true;
			org.slplayer.component.navigation.transition.TransitionTools.setTransitionProperty(this.rootElement,"transitionDuration","0");
			var _g = 0;
			while(_g < sumOfTransitions.length) {
				var transition = sumOfTransitions[_g];
				++_g;
				org.slplayer.util.DomTools.addClass(this.rootElement,transition.startStyleName);
			}
			org.slplayer.util.DomTools.doLater((function(f,a1,a2) {
				return function() {
					return f(a1,a2);
				};
			})($bind(this,this.doStartTransition),sumOfTransitions,onComplete));
		}
	}
	,doHideCallback: null
	,doShowCallback: null
	,styleAttrDisplay: null
	,hasTransitionStarted: null
	,status: null
	,childrenArray: null
	,__class__: org.slplayer.component.navigation.Layer
});
org.slplayer.component.navigation.Page = function(rootElement,SLPId) {
	org.slplayer.component.ui.DisplayObject.call(this,rootElement,SLPId);
	org.slplayer.component.group.Groupable.startGroupable(this);
	this.name = rootElement.getAttribute("name");
	if(this.name == null || this.name == "") throw "Pages have to have a 'name' attribute";
};
$hxClasses["org.slplayer.component.navigation.Page"] = org.slplayer.component.navigation.Page;
org.slplayer.component.navigation.Page.__name__ = ["org","slplayer","component","navigation","Page"];
org.slplayer.component.navigation.Page.__interfaces__ = [org.slplayer.component.group.IGroupable];
org.slplayer.component.navigation.Page.openPage = function(pageName,isPopup,transitionDataShow,transitionDataHide,slPlayerId,root) {
	var document = root;
	if(root == null) document = js.Lib.document;
	var page = org.slplayer.component.navigation.Page.getPageByName(pageName,slPlayerId,document);
	if(page == null) throw "Error, could not find a page with name " + pageName;
	page.open(transitionDataShow,transitionDataHide,!isPopup);
}
org.slplayer.component.navigation.Page.closePage = function(pageName,transitionData,slPlayerId,root) {
	var document = root;
	if(root == null) document = js.Lib.document;
	var page = org.slplayer.component.navigation.Page.getPageByName(pageName,slPlayerId,document);
	if(page == null) throw "Error, could not find a page with name " + pageName;
	page.close(transitionData);
}
org.slplayer.component.navigation.Page.getPageNodes = function(slPlayerId,root) {
	var document = root;
	if(root == null) document = js.Lib.document;
	return document.getElementsByClassName("Page");
}
org.slplayer.component.navigation.Page.getLayerNodes = function(pageName,slPlayerId,root) {
	var document = root;
	if(root == null) document = js.Lib.document;
	return document.getElementsByClassName(pageName);
}
org.slplayer.component.navigation.Page.getPageByName = function(pageName,slPlayerId,root) {
	var document = root;
	if(root == null) document = js.Lib.document;
	var pages = org.slplayer.component.navigation.Page.getPageNodes(slPlayerId,document);
	var _g1 = 0, _g = pages.length;
	while(_g1 < _g) {
		var pageIdx = _g1++;
		if(pages[pageIdx].getAttribute("name") == pageName) {
			var pageInstances = org.slplayer.core.Application.get(slPlayerId).getAssociatedComponents(pages[pageIdx],org.slplayer.component.navigation.Page);
			var $it0 = pageInstances.iterator();
			while( $it0.hasNext() ) {
				var page = $it0.next();
				return page;
			}
			return null;
		}
	}
	return null;
}
org.slplayer.component.navigation.Page.__super__ = org.slplayer.component.ui.DisplayObject;
org.slplayer.component.navigation.Page.prototype = $extend(org.slplayer.component.ui.DisplayObject.prototype,{
	close: function(transitionData,preventCloseByClassName,preventTransitions) {
		if(preventTransitions == null) preventTransitions = false;
		haxe.Log.trace("close " + Std.string(transitionData) + ", " + this.name + " - " + Std.string(preventTransitions),{ fileName : "Page.hx", lineNumber : 245, className : "org.slplayer.component.navigation.Page", methodName : "close"});
		if(preventCloseByClassName == null) preventCloseByClassName = new Array();
		var nodes = org.slplayer.component.navigation.Page.getLayerNodes(this.name,this.SLPlayerInstanceId,this.groupElement);
		var _g1 = 0, _g = nodes.length;
		while(_g1 < _g) {
			var idxLayerNode = _g1++;
			var layerNode = nodes[idxLayerNode];
			var hasForbiddenClass = false;
			var _g2 = 0;
			while(_g2 < preventCloseByClassName.length) {
				var className = preventCloseByClassName[_g2];
				++_g2;
				if(org.slplayer.util.DomTools.hasClass(layerNode,className)) {
					hasForbiddenClass = true;
					break;
				}
			}
			if(!hasForbiddenClass) {
				var layerInstances = this.getSLPlayer().getAssociatedComponents(layerNode,org.slplayer.component.navigation.Layer);
				var $it0 = layerInstances.iterator();
				while( $it0.hasNext() ) {
					var layerInstance = $it0.next();
					(js.Boot.__cast(layerInstance , org.slplayer.component.navigation.Layer)).hide(transitionData,preventTransitions);
				}
			}
		}
	}
	,doOpen: function(transitionData,preventTransitions) {
		if(preventTransitions == null) preventTransitions = false;
		haxe.Log.trace("doOpen " + Std.string(transitionData) + ", " + this.name + " - " + Std.string(preventTransitions),{ fileName : "Page.hx", lineNumber : 223, className : "org.slplayer.component.navigation.Page", methodName : "doOpen"});
		var nodes = org.slplayer.component.navigation.Page.getLayerNodes(this.name,this.SLPlayerInstanceId,this.groupElement);
		var _g1 = 0, _g = nodes.length;
		while(_g1 < _g) {
			var idxLayerNode = _g1++;
			var layerNode = nodes[idxLayerNode];
			var layerInstances = this.getSLPlayer().getAssociatedComponents(layerNode,org.slplayer.component.navigation.Layer);
			var $it0 = layerInstances.iterator();
			while( $it0.hasNext() ) {
				var layerInstance = $it0.next();
				layerInstance.show(transitionData,preventTransitions);
			}
		}
	}
	,closeOthers: function(transitionData,preventTransitions) {
		if(preventTransitions == null) preventTransitions = false;
		haxe.Log.trace("closeOthers(" + Std.string(transitionData) + ") - " + Std.string(preventTransitions),{ fileName : "Page.hx", lineNumber : 203, className : "org.slplayer.component.navigation.Page", methodName : "closeOthers"});
		var nodes = org.slplayer.component.navigation.Page.getPageNodes(this.SLPlayerInstanceId,this.groupElement);
		var _g1 = 0, _g = nodes.length;
		while(_g1 < _g) {
			var idxPageNode = _g1++;
			var pageNode = nodes[idxPageNode];
			var pageInstances = this.getSLPlayer().getAssociatedComponents(pageNode,org.slplayer.component.navigation.Page);
			var $it0 = pageInstances.iterator();
			while( $it0.hasNext() ) {
				var pageInstance = $it0.next();
				if(pageInstance != this) pageInstance.close(transitionData,[this.name],preventTransitions);
			}
		}
	}
	,open: function(transitionDataShow,transitionDataHide,doCloseOthers,preventTransitions) {
		if(preventTransitions == null) preventTransitions = false;
		if(doCloseOthers == null) doCloseOthers = true;
		haxe.Log.trace("open - " + Std.string(doCloseOthers) + " - name=" + this.name + " - " + Std.string(preventTransitions),{ fileName : "Page.hx", lineNumber : 192, className : "org.slplayer.component.navigation.Page", methodName : "open"});
		if(doCloseOthers) this.closeOthers(transitionDataHide,preventTransitions);
		this.doOpen(transitionDataShow,preventTransitions);
	}
	,init: function() {
		org.slplayer.component.ui.DisplayObject.prototype.init.call(this);
		if(org.slplayer.util.DomTools.getMeta("initialPageName") == this.name || this.groupElement != null && this.groupElement.getAttribute("data-initial-page-name") == this.name) this.open(null,null,true,true);
	}
	,groupElement: null
	,name: null
	,__class__: org.slplayer.component.navigation.Page
});
org.slplayer.component.navigation.link = {}
org.slplayer.component.navigation.link.LinkBase = function(rootElement,SLPId) {
	org.slplayer.component.ui.DisplayObject.call(this,rootElement,SLPId);
	org.slplayer.component.group.Groupable.startGroupable(this);
	rootElement.addEventListener("click",$bind(this,this.onClick),false);
	if(rootElement.getAttribute("href") != null) {
		this.linkName = StringTools.trim(rootElement.getAttribute("href"));
		this.linkName = HxOverrides.substr(this.linkName,this.linkName.indexOf("#") + 1,null);
	} else haxe.Log.trace("Warning: the link has no href atribute (" + Std.string(rootElement) + ")",{ fileName : "LinkBase.hx", lineNumber : 93, className : "org.slplayer.component.navigation.link.LinkBase", methodName : "new"});
	if(rootElement.getAttribute("target") != null && StringTools.trim(rootElement.getAttribute("target")) != "") this.targetAttr = StringTools.trim(rootElement.getAttribute("target"));
};
$hxClasses["org.slplayer.component.navigation.link.LinkBase"] = org.slplayer.component.navigation.link.LinkBase;
org.slplayer.component.navigation.link.LinkBase.__name__ = ["org","slplayer","component","navigation","link","LinkBase"];
org.slplayer.component.navigation.link.LinkBase.__interfaces__ = [org.slplayer.component.group.IGroupable];
org.slplayer.component.navigation.link.LinkBase.__super__ = org.slplayer.component.ui.DisplayObject;
org.slplayer.component.navigation.link.LinkBase.prototype = $extend(org.slplayer.component.ui.DisplayObject.prototype,{
	onClick: function(e) {
		e.preventDefault();
		this.transitionDataShow = org.slplayer.component.navigation.transition.TransitionTools.getTransitionData(this.rootElement,org.slplayer.component.navigation.transition.TransitionType.show);
		this.transitionDataHide = org.slplayer.component.navigation.transition.TransitionTools.getTransitionData(this.rootElement,org.slplayer.component.navigation.transition.TransitionType.hide);
	}
	,transitionDataHide: null
	,transitionDataShow: null
	,targetAttr: null
	,linkName: null
	,groupElement: null
	,__class__: org.slplayer.component.navigation.link.LinkBase
});
org.slplayer.component.navigation.link.LinkToPage = function(rootElement,SLPId) {
	org.slplayer.component.navigation.link.LinkBase.call(this,rootElement,SLPId);
};
$hxClasses["org.slplayer.component.navigation.link.LinkToPage"] = org.slplayer.component.navigation.link.LinkToPage;
org.slplayer.component.navigation.link.LinkToPage.__name__ = ["org","slplayer","component","navigation","link","LinkToPage"];
org.slplayer.component.navigation.link.LinkToPage.__super__ = org.slplayer.component.navigation.link.LinkBase;
org.slplayer.component.navigation.link.LinkToPage.prototype = $extend(org.slplayer.component.navigation.link.LinkBase.prototype,{
	onClick: function(e) {
		org.slplayer.component.navigation.link.LinkBase.prototype.onClick.call(this,e);
		org.slplayer.component.navigation.Page.openPage(this.linkName,this.targetAttr == "_top",this.transitionDataShow,this.transitionDataHide,this.SLPlayerInstanceId,this.groupElement);
	}
	,__class__: org.slplayer.component.navigation.link.LinkToPage
});
org.slplayer.component.navigation.link.TouchType = $hxClasses["org.slplayer.component.navigation.link.TouchType"] = { __ename__ : ["org","slplayer","component","navigation","link","TouchType"], __constructs__ : ["swipeLeft","swipeRight","swipeUp","swipeDown","pinchOpen","pinchClose"] }
org.slplayer.component.navigation.link.TouchType.swipeLeft = ["swipeLeft",0];
org.slplayer.component.navigation.link.TouchType.swipeLeft.toString = $estr;
org.slplayer.component.navigation.link.TouchType.swipeLeft.__enum__ = org.slplayer.component.navigation.link.TouchType;
org.slplayer.component.navigation.link.TouchType.swipeRight = ["swipeRight",1];
org.slplayer.component.navigation.link.TouchType.swipeRight.toString = $estr;
org.slplayer.component.navigation.link.TouchType.swipeRight.__enum__ = org.slplayer.component.navigation.link.TouchType;
org.slplayer.component.navigation.link.TouchType.swipeUp = ["swipeUp",2];
org.slplayer.component.navigation.link.TouchType.swipeUp.toString = $estr;
org.slplayer.component.navigation.link.TouchType.swipeUp.__enum__ = org.slplayer.component.navigation.link.TouchType;
org.slplayer.component.navigation.link.TouchType.swipeDown = ["swipeDown",3];
org.slplayer.component.navigation.link.TouchType.swipeDown.toString = $estr;
org.slplayer.component.navigation.link.TouchType.swipeDown.__enum__ = org.slplayer.component.navigation.link.TouchType;
org.slplayer.component.navigation.link.TouchType.pinchOpen = ["pinchOpen",4];
org.slplayer.component.navigation.link.TouchType.pinchOpen.toString = $estr;
org.slplayer.component.navigation.link.TouchType.pinchOpen.__enum__ = org.slplayer.component.navigation.link.TouchType;
org.slplayer.component.navigation.link.TouchType.pinchClose = ["pinchClose",5];
org.slplayer.component.navigation.link.TouchType.pinchClose.toString = $estr;
org.slplayer.component.navigation.link.TouchType.pinchClose.__enum__ = org.slplayer.component.navigation.link.TouchType;
org.slplayer.component.navigation.link.TouchLink = function(rootElement,SLPId) {
	org.slplayer.component.ui.DisplayObject.call(this,rootElement,SLPId);
	org.slplayer.component.group.Groupable.startGroupable(this);
	var element;
	if(this.groupElement != null) element = this.groupElement; else element = js.Lib.document.body;
	var attrStr = rootElement.getAttribute("data-touch-detection-distance");
	if(attrStr == null || attrStr == "") this.detectDistance = 200; else this.detectDistance = Std.parseInt(attrStr);
	element.addEventListener("touchmove",$bind(this,this.onTouchMove),false);
	element.addEventListener("touchstart",$bind(this,this.onTouchStart),false);
	element.addEventListener("touchend",$bind(this,this.onTouchEnd),false);
	switch(rootElement.getAttribute("data-touch-type")) {
	case "left":
		this.touchType = org.slplayer.component.navigation.link.TouchType.swipeLeft;
		break;
	case "right":
		this.touchType = org.slplayer.component.navigation.link.TouchType.swipeRight;
		break;
	case "up":
		this.touchType = org.slplayer.component.navigation.link.TouchType.swipeUp;
		break;
	case "down":
		this.touchType = org.slplayer.component.navigation.link.TouchType.swipeDown;
		break;
	case "open":
		this.touchType = org.slplayer.component.navigation.link.TouchType.pinchOpen;
		throw "not implemented";
		break;
	case "close":
		this.touchType = org.slplayer.component.navigation.link.TouchType.pinchClose;
		throw "not implemented";
		break;
	default:
		throw "Error in param " + "data-touch-type" + " for touch event type (requires left, right, up, down, in, out)";
	}
};
$hxClasses["org.slplayer.component.navigation.link.TouchLink"] = org.slplayer.component.navigation.link.TouchLink;
org.slplayer.component.navigation.link.TouchLink.__name__ = ["org","slplayer","component","navigation","link","TouchLink"];
org.slplayer.component.navigation.link.TouchLink.__interfaces__ = [org.slplayer.component.group.IGroupable];
org.slplayer.component.navigation.link.TouchLink.__super__ = org.slplayer.component.ui.DisplayObject;
org.slplayer.component.navigation.link.TouchLink.prototype = $extend(org.slplayer.component.ui.DisplayObject.prototype,{
	dispatchClick: function() {
		var evt = js.Lib.document.createEvent("MouseEvents");
		evt.initEvent("click",true,true);
		this.rootElement.dispatchEvent(evt);
	}
	,onTouchEnd: function(e) {
		var event = e;
		this.touchStart = null;
	}
	,onTouchMove: function(e) {
		var event = e;
		if(this.touchStart == null) return;
		var xOffset = event.touches.item(0).screenX - this.touchStart.x;
		var yOffset = event.touches.item(0).screenY - this.touchStart.y;
		if(Math.abs(xOffset) > 200) {
			this.touchStart = null;
			if(xOffset > 0) {
				if(this.touchType == org.slplayer.component.navigation.link.TouchType.swipeLeft) this.dispatchClick();
			} else if(this.touchType == org.slplayer.component.navigation.link.TouchType.swipeRight) this.dispatchClick();
		} else if(Math.abs(yOffset) > this.detectDistance) {
			this.touchStart = null;
			if(yOffset > 0) {
				if(this.touchType == org.slplayer.component.navigation.link.TouchType.swipeUp) this.dispatchClick();
			} else if(this.touchType == org.slplayer.component.navigation.link.TouchType.swipeDown) this.dispatchClick();
		}
	}
	,onClick: function(e) {
		haxe.Log.trace("CLICK ",{ fileName : "TouchLink.hx", lineNumber : 123, className : "org.slplayer.component.navigation.link.TouchLink", methodName : "onClick"});
	}
	,onTouchStart: function(e) {
		var event = e;
		this.touchStart = { x : event.touches.item(0).screenX, y : event.touches.item(0).screenY};
	}
	,touchStart: null
	,touchType: null
	,detectDistance: null
	,groupElement: null
	,__class__: org.slplayer.component.navigation.link.TouchLink
});
org.slplayer.component.navigation.transition = {}
org.slplayer.component.navigation.transition.TransitionType = $hxClasses["org.slplayer.component.navigation.transition.TransitionType"] = { __ename__ : ["org","slplayer","component","navigation","transition","TransitionType"], __constructs__ : ["show","hide"] }
org.slplayer.component.navigation.transition.TransitionType.show = ["show",0];
org.slplayer.component.navigation.transition.TransitionType.show.toString = $estr;
org.slplayer.component.navigation.transition.TransitionType.show.__enum__ = org.slplayer.component.navigation.transition.TransitionType;
org.slplayer.component.navigation.transition.TransitionType.hide = ["hide",1];
org.slplayer.component.navigation.transition.TransitionType.hide.toString = $estr;
org.slplayer.component.navigation.transition.TransitionType.hide.__enum__ = org.slplayer.component.navigation.transition.TransitionType;
org.slplayer.component.navigation.transition.TransitionTools = function() { }
$hxClasses["org.slplayer.component.navigation.transition.TransitionTools"] = org.slplayer.component.navigation.transition.TransitionTools;
org.slplayer.component.navigation.transition.TransitionTools.__name__ = ["org","slplayer","component","navigation","transition","TransitionTools"];
org.slplayer.component.navigation.transition.TransitionTools.getTransitionData = function(rootElement,type) {
	var res = null;
	if(type == org.slplayer.component.navigation.transition.TransitionType.show) {
		var start = rootElement.getAttribute("data-show-start-style");
		var end = rootElement.getAttribute("data-show-end-style");
		if(start != null && end != null) res = { startStyleName : start, endStyleName : end};
	} else {
		var start = rootElement.getAttribute("data-hide-start-style");
		var end = rootElement.getAttribute("data-hide-end-style");
		if(start != null && end != null) res = { startStyleName : start, endStyleName : end};
	}
	return res;
}
org.slplayer.component.navigation.transition.TransitionTools.setTransitionProperty = function(rootElement,name,value) {
	rootElement.style[name] = value;
	var prefixed = "MozT" + HxOverrides.substr(name,1,null);
	rootElement.style[prefixed] = value;
	var prefixed1 = "webkitT" + HxOverrides.substr(name,1,null);
	rootElement.style[prefixed1] = value;
	var prefixed2 = "oT" + HxOverrides.substr(name,1,null);
	rootElement.style[prefixed2] = value;
}
org.slplayer.component.sound = {}
org.slplayer.component.sound.SoundOn = function(rootElement,SLPId) {
	org.slplayer.component.ui.DisplayObject.call(this,rootElement,SLPId);
	rootElement.onclick = $bind(this,this.onClick);
};
$hxClasses["org.slplayer.component.sound.SoundOn"] = org.slplayer.component.sound.SoundOn;
org.slplayer.component.sound.SoundOn.__name__ = ["org","slplayer","component","sound","SoundOn"];
org.slplayer.component.sound.SoundOn.mute = function(doMute) {
	haxe.Log.trace("Sound mute " + Std.string(doMute),{ fileName : "SoundOn.hx", lineNumber : 54, className : "org.slplayer.component.sound.SoundOn", methodName : "mute"});
	var audioTags = js.Lib.document.getElementsByTagName("audio");
	var _g1 = 0, _g = audioTags.length;
	while(_g1 < _g) {
		var idx = _g1++;
		audioTags[idx].muted = doMute;
	}
	org.slplayer.component.sound.SoundOn.isMuted = doMute;
	var soundOffButtons = js.Lib.document.getElementsByClassName("SoundOff");
	var soundOnButtons = js.Lib.document.getElementsByClassName("SoundOn");
	var _g1 = 0, _g = soundOffButtons.length;
	while(_g1 < _g) {
		var idx = _g1++;
		if(doMute) soundOffButtons[idx].style.visibility = "hidden"; else soundOffButtons[idx].style.visibility = "visible";
	}
	var _g1 = 0, _g = soundOnButtons.length;
	while(_g1 < _g) {
		var idx = _g1++;
		if(!doMute) soundOnButtons[idx].style.visibility = "hidden"; else soundOnButtons[idx].style.visibility = "visible";
	}
}
org.slplayer.component.sound.SoundOn.__super__ = org.slplayer.component.ui.DisplayObject;
org.slplayer.component.sound.SoundOn.prototype = $extend(org.slplayer.component.ui.DisplayObject.prototype,{
	onClick: function(e) {
		org.slplayer.component.sound.SoundOn.mute(false);
	}
	,init: function() {
		org.slplayer.component.sound.SoundOn.mute(false);
	}
	,__class__: org.slplayer.component.sound.SoundOn
});
org.slplayer.component.sound.SoundOff = function(rootElement,SLPId) {
	org.slplayer.component.sound.SoundOn.call(this,rootElement,SLPId);
};
$hxClasses["org.slplayer.component.sound.SoundOff"] = org.slplayer.component.sound.SoundOff;
org.slplayer.component.sound.SoundOff.__name__ = ["org","slplayer","component","sound","SoundOff"];
org.slplayer.component.sound.SoundOff.__super__ = org.slplayer.component.sound.SoundOn;
org.slplayer.component.sound.SoundOff.prototype = $extend(org.slplayer.component.sound.SoundOn.prototype,{
	onClick: function(e) {
		haxe.Log.trace("Sound onClick",{ fileName : "SoundOff.hx", lineNumber : 23, className : "org.slplayer.component.sound.SoundOff", methodName : "onClick"});
		org.slplayer.component.sound.SoundOn.mute(true);
	}
	,__class__: org.slplayer.component.sound.SoundOff
});
org.slplayer.core = {}
org.slplayer.core.Application = function(id,args) {
	this.dataObject = args;
	this.id = id;
	this.nodesIdSequence = 0;
	this.registeredComponents = new Array();
	this.nodeToCmpInstances = new Hash();
	this.metaParameters = new Hash();
};
$hxClasses["org.slplayer.core.Application"] = org.slplayer.core.Application;
$hxExpose(org.slplayer.core.Application, "touch");
org.slplayer.core.Application.__name__ = ["org","slplayer","core","Application"];
org.slplayer.core.Application.get = function(SLPId) {
	return org.slplayer.core.Application.instances.get(SLPId);
}
org.slplayer.core.Application.main = function() {
	var newApp = org.slplayer.core.Application.createApplication();
	js.Lib.window.onload = function(e) {
		newApp.init();
	};
}
org.slplayer.core.Application.createApplication = function(args) {
	var newId = org.slplayer.core.Application.generateUniqueId();
	var newInstance = new org.slplayer.core.Application(newId,args);
	org.slplayer.core.Application.instances.set(newId,newInstance);
	return newInstance;
}
org.slplayer.core.Application.generateUniqueId = function() {
	return Std.string(Math.round(Math.random() * 10000));
}
org.slplayer.core.Application.prototype = {
	getUnconflictedClassTag: function(displayObjectClassName) {
		var classTag = displayObjectClassName;
		if(classTag.indexOf(".") != -1) classTag = HxOverrides.substr(classTag,classTag.lastIndexOf(".") + 1,null);
		var _g = 0, _g1 = this.registeredComponents;
		while(_g < _g1.length) {
			var rc = _g1[_g];
			++_g;
			if(rc.classname != displayObjectClassName && classTag == HxOverrides.substr(rc.classname,classTag.lastIndexOf(".") + 1,null)) return displayObjectClassName;
		}
		return classTag;
	}
	,getAssociatedComponents: function(node,typeFilter) {
		var nodeId = node.getAttribute("data-" + "slpid");
		if(nodeId != null) {
			var l = new List();
			if(this.nodeToCmpInstances.exists(nodeId)) {
				var $it0 = this.nodeToCmpInstances.get(nodeId).iterator();
				while( $it0.hasNext() ) {
					var i = $it0.next();
					if(js.Boot.__instanceof(i,typeFilter)) {
						var inst = i;
						l.add(inst);
					}
				}
			}
			return l;
		}
		return new List();
	}
	,addAssociatedComponent: function(node,cmp) {
		var nodeId = node.getAttribute("data-" + "slpid");
		var associatedCmps;
		if(nodeId != null) associatedCmps = this.nodeToCmpInstances.get(nodeId); else {
			this.nodesIdSequence++;
			nodeId = Std.string(this.nodesIdSequence);
			node.setAttribute("data-" + "slpid",nodeId);
			associatedCmps = new List();
		}
		associatedCmps.add(cmp);
		this.nodeToCmpInstances.set(nodeId,associatedCmps);
	}
	,callInitOnComponents: function() {
		var $it0 = this.nodeToCmpInstances.iterator();
		while( $it0.hasNext() ) {
			var l = $it0.next();
			var $it1 = l.iterator();
			while( $it1.hasNext() ) {
				var c = $it1.next();
				c.init();
			}
		}
	}
	,createComponentsOfType: function(componentClassName,args) {
		var componentClass = Type.resolveClass(componentClassName);
		if(componentClass == null) {
			var rslErrMsg = "ERROR cannot resolve " + componentClassName;
			throw rslErrMsg;
			return;
		}
		if(org.slplayer.component.ui.DisplayObject.isDisplayObject(componentClass)) {
			var classTag = this.getUnconflictedClassTag(componentClassName);
			var taggedNodes = new Array();
			var taggedNodesCollection = this.htmlRootElement.getElementsByClassName(classTag);
			var _g1 = 0, _g = taggedNodesCollection.length;
			while(_g1 < _g) {
				var nodeCnt = _g1++;
				taggedNodes.push(taggedNodesCollection[nodeCnt]);
			}
			if(componentClassName != classTag) {
				taggedNodesCollection = this.htmlRootElement.getElementsByClassName(componentClassName);
				var _g1 = 0, _g = taggedNodesCollection.length;
				while(_g1 < _g) {
					var nodeCnt = _g1++;
					taggedNodes.push(taggedNodesCollection[nodeCnt]);
				}
			}
			var _g = 0;
			while(_g < taggedNodes.length) {
				var node = taggedNodes[_g];
				++_g;
				var newDisplayObject;
				newDisplayObject = Type.createInstance(componentClass,[node,this.id]);
			}
		} else {
			var cmpInstance = null;
			if(args != null) cmpInstance = Type.createInstance(componentClass,[args]); else cmpInstance = Type.createInstance(componentClass,[]);
			if(cmpInstance != null && js.Boot.__instanceof(cmpInstance,org.slplayer.component.ISLPlayerComponent)) cmpInstance.initSLPlayerComponent(this.id);
		}
	}
	,initComponents: function() {
		var _g = 0, _g1 = this.registeredComponents;
		while(_g < _g1.length) {
			var rc = _g1[_g];
			++_g;
			this.createComponentsOfType(rc.classname,rc.args);
		}
		this.callInitOnComponents();
	}
	,registerComponent: function(componentClassName,args) {
		this.registeredComponents.push({ classname : componentClassName, args : args});
	}
	,registerComponentsforInit: function() {
		org.slplayer.component.group.Group;
		this.registerComponent("org.slplayer.component.group.Group");
		org.slplayer.component.navigation.link.TouchLink;
		this.registerComponent("org.slplayer.component.navigation.link.TouchLink");
		org.slplayer.component.navigation.Page;
		this.registerComponent("org.slplayer.component.navigation.Page");
		org.slplayer.component.navigation.Layer;
		this.registerComponent("org.slplayer.component.navigation.Layer");
		org.slplayer.component.navigation.link.LinkToPage;
		this.registerComponent("org.slplayer.component.navigation.link.LinkToPage");
	}
	,initMetaParameters: function() {
		this.metaParameters.set("initialPageName","welcome");
	}
	,init: function(appendTo) {
		this.htmlRootElement = appendTo;
		if(this.htmlRootElement == null || this.htmlRootElement.nodeType != js.Lib.document.body.nodeType) this.htmlRootElement = js.Lib.document.body;
		if(this.htmlRootElement == null) {
			haxe.Log.trace("ERROR Lib.document.body is null => You are trying to start your application while the document loading is probably not complete yet." + " To fix that, add the noAutoStart option to your slplayer application and control the application startup with: window.onload = function() { myApplication.init() };",{ fileName : "Application.hx", lineNumber : 184, className : "org.slplayer.core.Application", methodName : "init"});
			return;
		}
		this.initMetaParameters();
		this.registerComponentsforInit();
		this.initComponents();
	}
	,getMetaParameter: function(metaParamKey) {
		return this.metaParameters.get(metaParamKey);
	}
	,metaParameters: null
	,registeredComponents: null
	,dataObject: null
	,htmlRootElement: null
	,nodeToCmpInstances: null
	,nodesIdSequence: null
	,id: null
	,__class__: org.slplayer.core.Application
}
org.slplayer.util = {}
org.slplayer.util.DomTools = function() { }
$hxClasses["org.slplayer.util.DomTools"] = org.slplayer.util.DomTools;
org.slplayer.util.DomTools.__name__ = ["org","slplayer","util","DomTools"];
org.slplayer.util.DomTools.doLater = function(callbackFunction,nFrames) {
	if(nFrames == null) nFrames = 1;
	haxe.Timer.delay(callbackFunction,Math.round(200 * nFrames));
}
org.slplayer.util.DomTools.getElementsByAttribute = function(elt,attr,value) {
	var childElts = elt.getElementsByTagName("*");
	var filteredChildElts = new Array();
	var _g1 = 0, _g = childElts.length;
	while(_g1 < _g) {
		var cCount = _g1++;
		if(childElts[cCount].getAttribute(attr) != null && (value == "*" || childElts[cCount].getAttribute(attr) == value)) filteredChildElts.push(childElts[cCount]);
	}
	return filteredChildElts;
}
org.slplayer.util.DomTools.getSingleElement = function(rootElement,className,required) {
	if(required == null) required = true;
	var domElements = rootElement.getElementsByClassName(className);
	if(domElements != null && domElements.length == 1) return domElements[0]; else {
		if(required) throw "Error: search for the element with class name \"" + className + "\" gave " + domElements.length + " results";
		return null;
	}
}
org.slplayer.util.DomTools.getElementBoundingBox = function(htmlDom) {
	var halfBorderH = 0;
	var halfBorderV = 0;
	return { x : Math.floor(htmlDom.offsetLeft - halfBorderH), y : Math.floor(htmlDom.offsetTop - halfBorderV), w : Math.floor(htmlDom.offsetWidth - halfBorderH), h : Math.floor(htmlDom.offsetHeight - halfBorderV)};
}
org.slplayer.util.DomTools.inspectTrace = function(obj,callingClass) {
	haxe.Log.trace("-- " + callingClass + " inspecting element --",{ fileName : "DomTools.hx", lineNumber : 104, className : "org.slplayer.util.DomTools", methodName : "inspectTrace"});
	var _g = 0, _g1 = Reflect.fields(obj);
	while(_g < _g1.length) {
		var prop = _g1[_g];
		++_g;
		haxe.Log.trace("- " + prop + " = " + Std.string(Reflect.field(obj,prop)),{ fileName : "DomTools.hx", lineNumber : 107, className : "org.slplayer.util.DomTools", methodName : "inspectTrace"});
	}
	haxe.Log.trace("-- --",{ fileName : "DomTools.hx", lineNumber : 109, className : "org.slplayer.util.DomTools", methodName : "inspectTrace"});
}
org.slplayer.util.DomTools.toggleClass = function(element,className) {
	if(org.slplayer.util.DomTools.hasClass(element,className)) org.slplayer.util.DomTools.removeClass(element,className); else org.slplayer.util.DomTools.addClass(element,className);
}
org.slplayer.util.DomTools.addClass = function(element,className) {
	if(element.className == null) element.className = "";
	if(!org.slplayer.util.DomTools.hasClass(element,className)) element.className += " " + className;
}
org.slplayer.util.DomTools.removeClass = function(element,className) {
	if(element.className == null) return;
	if(org.slplayer.util.DomTools.hasClass(element,className)) element.className = StringTools.replace(element.className,className,"");
}
org.slplayer.util.DomTools.hasClass = function(element,className) {
	if(element.className == null) return false;
	return element.className.indexOf(className) > -1;
}
org.slplayer.util.DomTools.setMeta = function(metaName,metaValue,attributeName) {
	if(attributeName == null) attributeName = "content";
	var res = new Hash();
	var metaTags = js.Lib.document.getElementsByTagName("META");
	var found = false;
	var _g1 = 0, _g = metaTags.length;
	while(_g1 < _g) {
		var idxNode = _g1++;
		var node = metaTags[idxNode];
		var configName = node.getAttribute("name");
		var configValue = node.getAttribute(attributeName);
		if(configName != null && configValue != null) {
			if(configName == metaName) {
				configValue = metaValue;
				node.setAttribute(attributeName,metaValue);
				found = true;
			}
			res.set(configName,configValue);
		}
	}
	if(!found) {
		var node = js.Lib.document.createElement("meta");
		node.setAttribute("name",metaName);
		node.setAttribute("content",metaValue);
		var head = js.Lib.document.getElementsByTagName("head")[0];
		head.appendChild(node);
		res.set(metaName,metaValue);
	}
	return res;
}
org.slplayer.util.DomTools.getMeta = function(name,attributeName,head) {
	if(attributeName == null) attributeName = "content";
	if(head == null) head = js.Lib.document.documentElement.getElementsByTagName("head")[0];
	var metaTags = head.getElementsByTagName("meta");
	var _g1 = 0, _g = metaTags.length;
	while(_g1 < _g) {
		var idxNode = _g1++;
		var node = metaTags[idxNode];
		var configName = node.getAttribute("name");
		var configValue = node.getAttribute(attributeName);
		if(configName == name) return configValue;
	}
	return null;
}
org.slplayer.util.DomTools.addCssRules = function(css,head) {
	if(head == null) head = js.Lib.document.documentElement.getElementsByTagName("head")[0];
	var node = js.Lib.document.createElement("style");
	node.setAttribute("type","text/css");
	node.appendChild(js.Lib.document.createTextNode(css));
	head.appendChild(node);
	return node;
}
org.slplayer.util.DomTools.embedScript = function(src) {
	var head = js.Lib.document.getElementsByTagName("head")[0];
	var scriptNodes = js.Lib.document.getElementsByTagName("script");
	var _g1 = 0, _g = scriptNodes.length;
	while(_g1 < _g) {
		var idxNode = _g1++;
		var node = scriptNodes[idxNode];
		if(node.getAttribute("src") == src) return node;
	}
	var node = js.Lib.document.createElement("script");
	node.setAttribute("src",src);
	head.appendChild(node);
	return node;
}
org.slplayer.util.DomTools.getBaseTag = function() {
	var head = js.Lib.document.getElementsByTagName("head")[0];
	var baseNodes = js.Lib.document.getElementsByTagName("base");
	if(baseNodes.length > 0) return baseNodes[0].getAttribute("href"); else return null;
}
org.slplayer.util.DomTools.setBaseTag = function(href) {
	var head = js.Lib.document.getElementsByTagName("head")[0];
	var baseNodes = js.Lib.document.getElementsByTagName("base");
	if(baseNodes.length > 0) {
		haxe.Log.trace("Warning: base tag already set in the head section. Current value (\"" + baseNodes[0].getAttribute("href") + "\") will be replaced by \"" + href + "\"",{ fileName : "DomTools.hx", lineNumber : 279, className : "org.slplayer.util.DomTools", methodName : "setBaseTag"});
		baseNodes[0].setAttribute("href",href);
	} else {
		var node = js.Lib.document.createElement("base");
		node.setAttribute("href",href);
		node.setAttribute("target","_self");
		if(head.childNodes.length > 0) head.insertBefore(node,head.childNodes[0]); else head.appendChild(node);
	}
}
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; };
var $_;
function $bind(o,m) { var f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; return f; };
if(Array.prototype.indexOf) HxOverrides.remove = function(a,o) {
	var i = a.indexOf(o);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
}; else null;
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
$hxClasses.Math = Math;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.prototype.__class__ = $hxClasses.String = String;
String.__name__ = ["String"];
Array.prototype.__class__ = $hxClasses.Array = Array;
Array.__name__ = ["Array"];
Date.prototype.__class__ = $hxClasses.Date = Date;
Date.__name__ = ["Date"];
var Int = $hxClasses.Int = { __name__ : ["Int"]};
var Dynamic = $hxClasses.Dynamic = { __name__ : ["Dynamic"]};
var Float = $hxClasses.Float = Number;
Float.__name__ = ["Float"];
var Bool = $hxClasses.Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = $hxClasses.Class = { __name__ : ["Class"]};
var Enum = { };
var Void = $hxClasses.Void = { __ename__ : ["Void"]};
if(typeof document != "undefined") js.Lib.document = document;
if(typeof window != "undefined") {
	js.Lib.window = window;
	js.Lib.window.onerror = function(msg,url,line) {
		var f = js.Lib.onerror;
		if(f == null) return false;
		return f(msg,[url + ":" + line]);
	};
}
haxe.Template.splitter = new EReg("(::[A-Za-z0-9_ ()&|!+=/><*.\"-]+::|\\$\\$([A-Za-z0-9_-]+)\\()","");
haxe.Template.expr_splitter = new EReg("(\\(|\\)|[ \r\n\t]*\"[^\"]*\"[ \r\n\t]*|[!+=/><*.&|-]+)","");
haxe.Template.expr_trim = new EReg("^[ ]*([^ ]+)[ ]*$","");
haxe.Template.expr_int = new EReg("^[0-9]+$","");
haxe.Template.expr_float = new EReg("^([+-]?)(?=\\d|,\\d)\\d*(,\\d*)?([Ee]([+-]?\\d+))?$","");
haxe.Template.globals = { };
js.Lib.onerror = null;
org.slplayer.component.navigation.Layer.EVENT_TYPE_SHOW = "onLayerShow";
org.slplayer.component.navigation.Layer.EVENT_TYPE_HIDE = "onLayerHide";
org.slplayer.component.navigation.Page.CLASS_NAME = "Page";
org.slplayer.component.navigation.Page.CONFIG_NAME_ATTR = "name";
org.slplayer.component.navigation.Page.CONFIG_INITIAL_PAGE_NAME = "initialPageName";
org.slplayer.component.navigation.Page.ATTRIBUTE_INITIAL_PAGE_NAME = "data-initial-page-name";
org.slplayer.component.navigation.link.LinkBase.__meta__ = { obj : { tagNameFilter : ["a"]}};
org.slplayer.component.navigation.link.LinkBase.CONFIG_PAGE_NAME_ATTR = "href";
org.slplayer.component.navigation.link.LinkBase.CONFIG_TARGET_ATTR = "target";
org.slplayer.component.navigation.link.LinkBase.CONFIG_TARGET_IS_POPUP = "_top";
org.slplayer.component.navigation.link.LinkToPage.__meta__ = { obj : { tagNameFilter : ["a"]}};
org.slplayer.component.navigation.link.TouchLink.ATTR_TOUCH_TYPE = "data-touch-type";
org.slplayer.component.navigation.link.TouchLink.ATTR_TOUCH_DETECT_DISTANCE = "data-touch-detection-distance";
org.slplayer.component.navigation.link.TouchLink.DEFAULT_DETECT_DISTANCE = 200;
org.slplayer.component.navigation.transition.TransitionTools.SHOW_START_STYLE_ATTR_NAME = "data-show-start-style";
org.slplayer.component.navigation.transition.TransitionTools.SHOW_END_STYLE_ATTR_NAME = "data-show-end-style";
org.slplayer.component.navigation.transition.TransitionTools.HIDE_START_STYLE_ATTR_NAME = "data-hide-start-style";
org.slplayer.component.navigation.transition.TransitionTools.HIDE_END_STYLE_ATTR_NAME = "data-hide-end-style";
org.slplayer.component.navigation.transition.TransitionTools.EVENT_TYPE_REQUEST = "transitionEventTypeRequest";
org.slplayer.component.navigation.transition.TransitionTools.EVENT_TYPE_STARTED = "transitionEventTypeStarted";
org.slplayer.component.navigation.transition.TransitionTools.EVENT_TYPE_ENDED = "transitionEventTypeEnded";
org.slplayer.component.sound.SoundOn.__meta__ = { obj : { tagNameFilter : ["a"]}};
org.slplayer.component.sound.SoundOn.CLASS_NAME = "SoundOn";
org.slplayer.component.sound.SoundOn.isMuted = false;
org.slplayer.component.sound.SoundOff.__meta__ = { obj : { tagNameFilter : ["a"]}};
org.slplayer.component.sound.SoundOff.CLASS_NAME = "SoundOff";
org.slplayer.core.Application.SLPID_ATTR_NAME = "slpid";
org.slplayer.core.Application.instances = new Hash();
org.slplayer.core.Application.main();
function $hxExpose(src, path) {
	var o = window;
	var parts = path.split(".");
	for(var ii = 0; ii < parts.length-1; ++ii) {
		var p = parts[ii];
		if(typeof o[p] == "undefined") o[p] = {};
		o = o[p];
	}
	o[parts[parts.length-1]] = src;
}
})();

//@ sourceMappingURL=touch.js.map