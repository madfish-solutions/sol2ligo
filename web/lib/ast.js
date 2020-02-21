// Generated by IcedCoffeeScript 108.0.13
(function() {
  var ast, k, module, v;

  module = this;

  ast = window.ast4gen;

  for (k in ast) {
    v = ast[k];
    this[k] = v;
  }

  this.Class_decl = (function() {
    Class_decl.prototype.name = "";

    Class_decl.prototype.namespace_name = true;

    Class_decl.prototype.is_contract = false;

    Class_decl.prototype.is_library = false;

    Class_decl.prototype.is_interface = false;

    Class_decl.prototype.need_skip = false;

    Class_decl.prototype.scope = null;

    Class_decl.prototype._prepared_field2type = {};

    Class_decl.prototype.inheritance_list = [];

    Class_decl.prototype.line = 0;

    Class_decl.prototype.pos = 0;

    function Class_decl() {
      this.scope = new module.Scope;
      this._prepared_field2type = {};
      this.inheritance_list = [];
    }

    Class_decl.prototype.clone = function() {
      var arg, arg_list, ret, _i, _j, _len, _len1, _ref, _ref1, _ref2;
      ret = new module.Class_decl;
      ret.name = this.name;
      ret.namespace_name = this.namespace_name;
      ret.is_contract = this.is_contract;
      ret.is_library = this.is_library;
      ret.is_interface = this.is_interface;
      ret.need_skip = this.need_skip;
      ret.scope = this.scope.clone();
      _ref = this._prepared_field2type;
      for (k in _ref) {
        v = _ref[k];
        ret._prepared_field2type[k] = v.clone();
      }
      _ref1 = this.inheritance_list;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        v = _ref1[_i];
        arg_list = [];
        _ref2 = v.arg_list;
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          arg = _ref2[_j];
          arg_list.push(arg.clone());
        }
        ret.inheritance_list.push({
          name: v.name,
          arg_list: arg_list
        });
      }
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Class_decl;

  })();

  this.Var = (function() {
    function Var() {}

    Var.prototype.name = "";

    Var.prototype.name_translate = true;

    Var.prototype.type = null;

    Var.prototype.line = 0;

    Var.prototype.pos = 0;

    Var.prototype.clone = function() {
      var ret;
      ret = new module.Var;
      ret.name = this.name;
      if (this.type) {
        ret.type = this.type.clone();
      }
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Var;

  })();

  this.Var_decl = (function() {
    function Var_decl() {}

    Var_decl.prototype.name = "";

    Var_decl.prototype.name_translate = true;

    Var_decl.prototype.type = null;

    Var_decl.prototype.size = null;

    Var_decl.prototype.assign_value = null;

    Var_decl.prototype.assign_value_list = null;

    Var_decl.prototype.line = 0;

    Var_decl.prototype.pos = 0;

    Var_decl.prototype.clone = function() {
      var ret, _i, _len, _ref;
      ret = new module.Var_decl;
      ret.name = this.name;
      ret.name_translate = this.name_translate;
      if (this.type) {
        ret.type = this.type.clone();
      }
      ret.size = this.size;
      if (this.assign_value) {
        ret.assign_value = this.assign_value.clone();
      }
      if (this.assign_value_list) {
        ret.assign_value_list = [];
        _ref = this.assign_value_list;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          v = _ref[_i];
          ret.assign_value_list.push(v.clone());
        }
      }
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Var_decl;

  })();

  this.Fn_decl_multiret = (function() {
    Fn_decl_multiret.prototype.is_closure = false;

    Fn_decl_multiret.prototype.name = "";

    Fn_decl_multiret.prototype.type_i = null;

    Fn_decl_multiret.prototype.type_o = null;

    Fn_decl_multiret.prototype.arg_name_list = [];

    Fn_decl_multiret.prototype.scope = null;

    Fn_decl_multiret.prototype.line = 0;

    Fn_decl_multiret.prototype.pos = 0;

    Fn_decl_multiret.prototype.visibility = "";

    Fn_decl_multiret.prototype.state_mutability = "";

    Fn_decl_multiret.prototype.is_modifier = false;

    Fn_decl_multiret.prototype.modifier_list = [];

    function Fn_decl_multiret() {
      this.arg_name_list = [];
      this.scope = new ast.Scope;
      this.modifier_list = [];
    }

    Fn_decl_multiret.prototype.clone = function() {
      var ret, _i, _len, _ref;
      ret = new module.Fn_decl_multiret;
      ret.is_closure = this.is_closure;
      ret.name = this.name;
      ret.type_i = this.type_i.clone();
      ret.type_o = this.type_o.clone();
      ret.arg_name_list = this.arg_name_list.clone();
      ret.scope = this.scope.clone();
      ret.line = this.line;
      ret.pos = this.pos;
      ret.visibility = this.visibility;
      ret.state_mutability = this.state_mutability;
      _ref = this.modifier_list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        ret.modifier_list.push(v.clone());
      }
      return ret;
    };

    return Fn_decl_multiret;

  })();

  this.Ret_multi = (function() {
    Ret_multi.prototype.t_list = [];

    Ret_multi.prototype.line = 0;

    Ret_multi.prototype.pos = 0;

    function Ret_multi() {
      this.t_list = [];
    }

    Ret_multi.prototype.clone = function() {
      var ret, _i, _len, _ref;
      ret = new module.Ret_multi;
      _ref = this.t_list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        ret.t_list.push(v.clone());
      }
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Ret_multi;

  })();

  this.Comment = (function() {
    function Comment() {}

    Comment.prototype.text = "";

    Comment.prototype.line = 0;

    Comment.prototype.pos = 0;

    Comment.prototype.clone = function() {
      var ret;
      ret = new module.Comment;
      ret.text = this.text;
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Comment;

  })();

  this.Tuple = (function() {
    Tuple.prototype.list = [];

    Tuple.prototype.type = null;

    Tuple.prototype.line = 0;

    Tuple.prototype.pos = 0;

    function Tuple() {
      this.list = [];
    }

    Tuple.prototype.clone = function() {
      var ret, _i, _len, _ref;
      ret = new module.Tuple;
      _ref = this.list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        ret.list.push(v.clone());
      }
      if (this.type) {
        ret.type = this.type.clone();
      }
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Tuple;

  })();

  this.Var_decl_multi = (function() {
    Var_decl_multi.prototype.list = [];

    Var_decl_multi.prototype.assign_value = null;

    Var_decl_multi.prototype.type = null;

    Var_decl_multi.prototype.line = 0;

    Var_decl_multi.prototype.pos = 0;

    function Var_decl_multi() {
      this.list = [];
    }

    Var_decl_multi.prototype.clone = function() {
      var ret, _i, _len, _ref;
      ret = new module.Var_decl_multi;
      _ref = this.list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        ret.list.push({
          name: v.name,
          type: v.type.clone()
        });
      }
      ret.assign_value = this.assign_value.clone();
      if (this.type) {
        ret.type = this.type.clone();
      }
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Var_decl_multi;

  })();

  this.Ternary = (function() {
    function Ternary() {}

    Ternary.prototype.cond = null;

    Ternary.prototype.t = null;

    Ternary.prototype.f = null;

    Ternary.prototype.line = 0;

    Ternary.prototype.pos = 0;

    Ternary.prototype.clone = function() {
      var ret;
      ret = new module.Ternary;
      ret.cond = this.cond.clone();
      ret.t = this.t.clone();
      ret.f = this.f.clone();
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Ternary;

  })();

  this.New = (function() {
    New.prototype.cls = null;

    New.prototype.arg_list = [];

    New.prototype.line = 0;

    New.prototype.pos = 0;

    function New() {
      this.arg_list = [];
    }

    New.prototype.clone = function() {
      var ret, _i, _len, _ref;
      ret = new module.New;
      ret.cls = this.cls;
      _ref = this.arg_list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        ret.arg_list.push(v.clone());
      }
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return New;

  })();

  this.Type_cast = (function() {
    function Type_cast() {}

    Type_cast.prototype.target_type = null;

    Type_cast.prototype.t = null;

    Type_cast.prototype.line = 0;

    Type_cast.prototype.pos = 0;

    Type_cast.prototype.clone = function() {
      var ret;
      ret = new module.Type_cast;
      ret.target_type = this.target_type.clone();
      ret.t = this.t.clone();
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Type_cast;

  })();

  this.For3 = (function() {
    For3.prototype.init = null;

    For3.prototype.cond = null;

    For3.prototype.iter = null;

    For3.prototype.scope = null;

    For3.prototype.line = 0;

    For3.prototype.pos = 0;

    function For3() {
      this.scope = new ast.Scope;
    }

    For3.prototype.clone = function() {
      var ret;
      ret = new module.For3;
      if (this.init) {
        ret.init = this.init.clone();
      }
      if (this.cond) {
        ret.cond = this.cond.clone();
      }
      if (this.init) {
        ret.iter = this.iter.clone();
      }
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return For3;

  })();

  this.PM_switch = (function() {
    PM_switch.prototype.cond = null;

    PM_switch.prototype.scope = null;

    PM_switch.prototype.line = 0;

    PM_switch.prototype.pos = 0;

    function PM_switch() {
      this.scope = new ast.Scope;
    }

    PM_switch.prototype.clone = function() {
      var ret;
      ret = new module.PM_switch;
      ret.cond = this.cond.clone();
      ret.scope = this.scope.clone();
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return PM_switch;

  })();

  this.PM_case = (function() {
    PM_case.prototype.struct_name = "";

    PM_case.prototype.var_decl = null;

    PM_case.prototype.scope = null;

    PM_case.prototype.line = 0;

    PM_case.prototype.pos = 0;

    function PM_case() {
      this.var_decl = new ast.Var_decl;
      this.scope = new ast.Scope;
    }

    PM_case.prototype.clone = function() {
      var ret;
      ret = new module.PM_case;
      ret.struct_name = this.struct_name;
      ret.var_decl = this.var_decl.clone();
      ret.scope = this.scope.clone();
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return PM_case;

  })();

  this.Enum_decl = (function() {
    Enum_decl.prototype.name = "";

    Enum_decl.prototype.value_list = [];

    Enum_decl.prototype.line = 0;

    Enum_decl.prototype.pos = 0;

    function Enum_decl() {
      this.value_list = [];
    }

    Enum_decl.prototype.clone = function() {
      var ret, _i, _len, _ref;
      ret = new module.Enum_decl;
      ret.name = this.name;
      _ref = this.value_list;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        ret.value_list.push(v.clone());
      }
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Enum_decl;

  })();

  this.Event_decl = (function() {
    function Event_decl() {}

    Event_decl.prototype.name = "";

    Event_decl.prototype.line = 0;

    Event_decl.prototype.pos = 0;

    Event_decl.prototype.clone = function() {
      var ret;
      ret = new module.Event_decl;
      ret.name = this.name;
      ret.line = this.line;
      ret.pos = this.pos;
      return ret;
    };

    return Event_decl;

  })();

}).call(window.mod_ast = {});
