(function() {
  var Type, null_str;

  Type = window.Type;

  Type.prototype.clone = function() {
    var k, ret, v, _i, _len, _ref, _ref1;
    ret = new Type;
    ret.main = this.main;
    _ref = this.nest_list;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      v = _ref[_i];
      if (v == null) {
        ret.nest_list.push(v);
      } else {
        ret.nest_list.push(v.clone());
      }
    }
    _ref1 = this.field_map;
    for (k in _ref1) {
      v = _ref1[k];
      if (v == null) {
        ret.field_map[k] = v;
      } else {
        ret.field_map[k] = v.clone();
      }
    }
    return ret;
  };

  null_str = "\x1E";

  Type.prototype.toString = function() {
    var jl, k, ret, v, _i, _len, _ref, _ref1;
    ret = this.main;
    if (this.nest_list.length) {
      jl = [];
      _ref = this.nest_list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        if (v == null) {
          jl.push(null_str);
        } else {
          jl.push(v.toString());
        }
      }
      ret += "<" + (jl.join(', ')) + ">";
    }
    jl = [];
    _ref1 = this.field_map;
    for (k in _ref1) {
      v = _ref1[k];
      if (v == null) {
        jl.push("" + k + ": " + null_str);
      } else {
        jl.push("" + k + ": " + (v.toString()));
      }
    }
    if (jl.length) {
      ret += "{" + (jl.join(', ')) + "}";
    }
    return ret;
  };

  Type.prototype.cmp = function(t) {
    var k, tv, v, _i, _len, _ref, _ref1, _ref2;
    if (this.main !== (t != null ? t.main : void 0)) {
      return false;
    }
    if (this.nest_list.length !== t.nest_list.length) {
      return false;
    }
    _ref = this.nest_list;
    for (k = _i = 0, _len = _ref.length; _i < _len; k = ++_i) {
      v = _ref[k];
      tv = t.nest_list[k];
      if (tv === v) {
        continue;
      }
      if (!(tv != null ? tv.cmp(v) : void 0)) {
        return false;
      }
    }
    _ref1 = this.field_map;
    for (k in _ref1) {
      v = _ref1[k];
      if (t.field_map[k] === v) {
        continue;
      }
      if (!t.field_map.hasOwnProperty(k)) {
        return false;
      }
      tv = t.field_map[k];
      if (!(tv != null ? tv.cmp(v) : void 0)) {
        return false;
      }
    }
    _ref2 = t.field_map;
    for (k in _ref2) {
      v = _ref2[k];
      if (!this.field_map.hasOwnProperty(k)) {
        return false;
      }
      tv = this.field_map[k];
    }
    return true;
  };

}).call(window.require_register("./type_safe"));
