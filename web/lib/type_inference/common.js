(function() {
  var Type, config, is_composite_type, is_defined_number_or_byte_type, module, op, translate_var_name, type_resolve, v, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2, _ref3, _ref4;

  module = this;

  translate_var_name = require("../translate_var_name").translate_var_name;

  config = require("../config");

  Type = window.Type;

  this.default_var_map_gen = function() {
    return {
      msg: (function() {
        var ret;
        ret = new Type("struct");
        ret.field_map.sender = new Type("address");
        ret.field_map.value = new Type("uint256");
        ret.field_map.data = new Type("bytes");
        ret.field_map.gas = new Type("uint256");
        ret.field_map.sig = new Type("bytes4");
        return ret;
      })(),
      tx: (function() {
        var ret;
        ret = new Type("struct");
        ret.field_map["origin"] = new Type("address");
        ret.field_map["gasprice"] = new Type("uint256");
        return ret;
      })(),
      block: (function() {
        var ret;
        ret = new Type("struct");
        ret.field_map["timestamp"] = new Type("uint256");
        ret.field_map["coinbase"] = new Type("address");
        ret.field_map["difficulty"] = new Type("uint256");
        ret.field_map["gaslimit"] = new Type("uint256");
        ret.field_map["number"] = new Type("uint256");
        return ret;
      })(),
      abi: (function() {
        var ret;
        ret = new Type("struct");
        ret.field_map["encodePacked"] = new Type("function2<function<bytes>,function<bytes>>");
        return ret;
      })(),
      now: new Type("uint256"),
      require: new Type("function2<function<bool>,function<>>"),
      require2: new Type("function2<function<bool, string>,function<>>"),
      assert: new Type("function2<function<bool>,function<>>"),
      revert: new Type("function2<function<string>,function<>>"),
      sha256: new Type("function2<function<bytes>,function<bytes32>>"),
      sha3: new Type("function2<function<bytes>,function<bytes32>>"),
      blockhash: new Type("function2<function<uint256>,function<bytes32>>"),
      selfdestruct: new Type("function2<function<address>,function<>>"),
      blockmap: new Type("function2<function<address>,function<bytes32>>"),
      keccak256: new Type("function2<function<bytes>,function<bytes32>>"),
      ripemd160: new Type("function2<function<bytes>,function<bytes20>>"),
      ecrecover: new Type("function2<function<bytes, uint8, bytes32, bytes32>,function<address>>")
    };
  };

  this.array_field_map = {
    "length": new Type("uint256"),
    "push": function(type) {
      var ret;
      ret = new Type("function2<function<>,function<>>");
      ret.nest_list[0].nest_list.push(type.nest_list[0]);
      return ret;
    }
  };

  this.bytes_field_map = {
    "length": new Type("uint256")
  };

  this.address_field_map = {
    "send": new Type("function2<function2<uint256>,function2<bool>>"),
    "transfer": new Type("function2<function2<uint256>,function2<>>")
  };

  this.is_not_defined_type = function(type) {
    var _ref;
    return !type || ((_ref = type.main) === "number" || _ref === "unsigned_number" || _ref === "signed_number");
  };

  this.is_number_type = function(type) {
    var _ref;
    if (!type) {
      return false;
    }
    return (_ref = type.main) === "number" || _ref === "unsigned_number" || _ref === "signed_number";
  };

  is_composite_type = function(type) {
    var _ref;
    return (_ref = type.main) === "array" || _ref === "tuple" || _ref === "map" || _ref === "struct";
  };

  is_defined_number_or_byte_type = function(type) {
    return config.any_int_type_map[type.main] || config.bytes_type_map[type.main];
  };

  type_resolve = function(type, ctx) {
    if (type && type.main !== "struct") {
      if (ctx.type_map[type.main]) {
        type = ctx.check_id(type.main);
      }
    }
    return type;
  };

  this.default_type_map_gen = function() {
    var ret, type, _i, _j, _len, _len1, _ref, _ref1;
    ret = {
      bool: new Type("struct"),
      array: new Type("struct"),
      string: new Type("struct"),
      address: new Type("struct")
    };
    _ref = config.any_int_type_list;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      type = _ref[_i];
      ret[type] = new Type("struct");
    }
    _ref1 = config.bytes_type_list;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      type = _ref1[_j];
      ret[type] = new Type("struct");
    }
    return ret;
  };

  this.bin_op_ret_type_map_list = {
    BOOL_AND: [["bool", "bool", "bool"]],
    BOOL_OR: [["bool", "bool", "bool"]],
    BOOL_GT: [["bool", "bool", "bool"]],
    BOOL_LT: [["bool", "bool", "bool"]],
    BOOL_GTE: [["bool", "bool", "bool"]],
    BOOL_LTE: [["bool", "bool", "bool"]],
    ASSIGN: []
  };

  this.un_op_ret_type_map_list = {
    BOOL_NOT: [["bool", "bool"]],
    BIT_NOT: [],
    MINUS: []
  };

  _ref = "ADD SUB MUL DIV MOD POW".split(/\s+/g);
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    v = _ref[_i];
    this.bin_op_ret_type_map_list[v] = [];
  }

  _ref1 = "BIT_AND BIT_OR BIT_XOR".split(/\s+/g);
  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
    v = _ref1[_j];
    this.bin_op_ret_type_map_list[v] = [];
  }

  _ref2 = "EQ NE GT LT GTE LTE".split(/\s+/g);
  for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
    v = _ref2[_k];
    this.bin_op_ret_type_map_list[v] = [];
  }

  _ref3 = "SHL SHR POW".split(/\s+/g);
  for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
    v = _ref3[_l];
    this.bin_op_ret_type_map_list[v] = [];
  }

  _ref4 = "RET_INC RET_DEC INC_RET DEC_RET".split(/\s+/g);
  for (_m = 0, _len4 = _ref4.length; _m < _len4; _m++) {
    op = _ref4[_m];
    this.un_op_ret_type_map_list[op] = [];
  }

  (function(_this) {
    return (function() {
      var idx1, idx2, list, type, type1, type2, type_index, type_main, _aa, _ab, _ac, _ad, _ae, _af, _ag, _ah, _ai, _len10, _len11, _len12, _len13, _len14, _len15, _len16, _len17, _len18, _len19, _len20, _len21, _len22, _len23, _len24, _len25, _len26, _len5, _len6, _len7, _len8, _len9, _n, _o, _p, _q, _r, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref20, _ref21, _ref22, _ref23, _ref24, _ref25, _ref26, _ref5, _ref6, _ref7, _ref8, _ref9, _s, _t, _u, _v, _w, _x, _y, _z;
      _ref5 = config.any_int_type_list;
      for (_n = 0, _len5 = _ref5.length; _n < _len5; _n++) {
        type = _ref5[_n];
        _this.un_op_ret_type_map_list.BIT_NOT.push([type, type]);
      }
      _ref6 = config.int_type_list;
      for (_o = 0, _len6 = _ref6.length; _o < _len6; _o++) {
        type = _ref6[_o];
        _this.un_op_ret_type_map_list.MINUS.push([type, type]);
      }
      _ref7 = "RET_INC RET_DEC INC_RET DEC_RET".split(/\s+/g);
      for (_p = 0, _len7 = _ref7.length; _p < _len7; _p++) {
        op = _ref7[_p];
        _ref8 = config.any_int_type_list;
        for (_q = 0, _len8 = _ref8.length; _q < _len8; _q++) {
          type = _ref8[_q];
          _this.un_op_ret_type_map_list[op].push([type, type]);
        }
      }
      _ref9 = "ADD SUB MUL DIV MOD POW".split(/\s+/g);
      for (_r = 0, _len9 = _ref9.length; _r < _len9; _r++) {
        op = _ref9[_r];
        list = _this.bin_op_ret_type_map_list[op];
        _ref10 = config.any_int_type_list;
        for (_s = 0, _len10 = _ref10.length; _s < _len10; _s++) {
          type = _ref10[_s];
          list.push([type, type, type]);
        }
      }
      _ref11 = "ADD SUB MUL DIV MOD POW".split(/\s+/g);
      for (_t = 0, _len11 = _ref11.length; _t < _len11; _t++) {
        op = _ref11[_t];
        list = _this.bin_op_ret_type_map_list[op];
        _ref12 = config.int_type_list;
        for (idx1 = _u = 0, _len12 = _ref12.length; _u < _len12; idx1 = ++_u) {
          type1 = _ref12[idx1];
          _ref13 = config.int_type_list;
          for (idx2 = _v = 0, _len13 = _ref13.length; _v < _len13; idx2 = ++_v) {
            type2 = _ref13[idx2];
            if (idx1 >= idx2) {
              continue;
            }
            list.push([type1, type2, type2]);
            list.push([type2, type1, type2]);
          }
        }
        _ref14 = config.uint_type_list;
        for (idx1 = _w = 0, _len14 = _ref14.length; _w < _len14; idx1 = ++_w) {
          type1 = _ref14[idx1];
          _ref15 = config.uint_type_list;
          for (idx2 = _x = 0, _len15 = _ref15.length; _x < _len15; idx2 = ++_x) {
            type2 = _ref15[idx2];
            if (idx1 >= idx2) {
              continue;
            }
            list.push([type1, type2, type2]);
            list.push([type2, type1, type2]);
          }
        }
      }
      _ref16 = "BIT_AND BIT_OR BIT_XOR".split(/\s+/g);
      for (_y = 0, _len16 = _ref16.length; _y < _len16; _y++) {
        op = _ref16[_y];
        list = _this.bin_op_ret_type_map_list[op];
        _ref17 = config.uint_type_list;
        for (_z = 0, _len17 = _ref17.length; _z < _len17; _z++) {
          type = _ref17[_z];
          list.push([type, type, type]);
        }
        _ref18 = config.int_type_list;
        for (_aa = 0, _len18 = _ref18.length; _aa < _len18; _aa++) {
          type = _ref18[_aa];
          list.push([type, type, type]);
        }
        _ref19 = config.bytes_type_list;
        for (_ab = 0, _len19 = _ref19.length; _ab < _len19; _ab++) {
          type = _ref19[_ab];
          list.push([type, type, type]);
        }
      }
      _ref20 = "EQ NE GT LT GTE LTE".split(/\s+/g);
      for (_ac = 0, _len20 = _ref20.length; _ac < _len20; _ac++) {
        op = _ref20[_ac];
        list = _this.bin_op_ret_type_map_list[op];
        _ref21 = config.any_int_type_list;
        for (_ad = 0, _len21 = _ref21.length; _ad < _len21; _ad++) {
          type = _ref21[_ad];
          list.push([type, type, "bool"]);
        }
      }
      _ref22 = "SHL SHR POW".split(/\s+/g);
      for (_ae = 0, _len22 = _ref22.length; _ae < _len22; _ae++) {
        op = _ref22[_ae];
        list = _this.bin_op_ret_type_map_list[op];
        _ref23 = config.uint_type_list;
        for (_af = 0, _len23 = _ref23.length; _af < _len23; _af++) {
          type_main = _ref23[_af];
          _ref24 = config.uint_type_list;
          for (_ag = 0, _len24 = _ref24.length; _ag < _len24; _ag++) {
            type_index = _ref24[_ag];
            list.push([type_main, type_index, type_main]);
          }
        }
        _ref25 = config.int_type_list;
        for (_ah = 0, _len25 = _ref25.length; _ah < _len25; _ah++) {
          type_main = _ref25[_ah];
          _ref26 = config.int_type_list;
          for (_ai = 0, _len26 = _ref26.length; _ai < _len26; _ai++) {
            type_index = _ref26[_ai];
            list.push([type_main, type_index, type_main]);
          }
        }
      }
    });
  })(this)();

  (function(_this) {
    return (function() {
      var type, type_byte, type_int, _len10, _len5, _len6, _len7, _len8, _len9, _n, _o, _p, _q, _r, _ref10, _ref5, _ref6, _ref7, _ref8, _ref9, _s;
      _ref5 = config.bytes_type_list;
      for (_n = 0, _len5 = _ref5.length; _n < _len5; _n++) {
        type = _ref5[_n];
        _this.un_op_ret_type_map_list.BIT_NOT.push([type, type]);
      }
      _ref6 = config.bytes_type_list;
      for (_o = 0, _len6 = _ref6.length; _o < _len6; _o++) {
        type_byte = _ref6[_o];
        _ref7 = config.any_int_type_list;
        for (_p = 0, _len7 = _ref7.length; _p < _len7; _p++) {
          type_int = _ref7[_p];
          _this.bin_op_ret_type_map_list.ASSIGN.push([type_byte, type_int, type_int]);
          _this.bin_op_ret_type_map_list.ASSIGN.push([type_int, type_byte, type_int]);
        }
      }
      _ref8 = "EQ NE GT LT GTE LTE".split(/\s+/g);
      for (_q = 0, _len8 = _ref8.length; _q < _len8; _q++) {
        op = _ref8[_q];
        _ref9 = config.bytes_type_list;
        for (_r = 0, _len9 = _ref9.length; _r < _len9; _r++) {
          type_byte = _ref9[_r];
          _ref10 = config.any_int_type_list;
          for (_s = 0, _len10 = _ref10.length; _s < _len10; _s++) {
            type_int = _ref10[_s];
            _this.bin_op_ret_type_map_list[op].push([type_byte, type_int, "bool"]);
            _this.bin_op_ret_type_map_list[op].push([type_int, type_byte, "bool"]);
          }
          _this.bin_op_ret_type_map_list[op].push([type_byte, type_byte, "bool"]);
        }
      }
    });
  })(this)();

  this.Ti_context = (function() {
    Ti_context.prototype.parent = null;

    Ti_context.prototype.parent_fn = null;

    Ti_context.prototype.current_class = null;

    Ti_context.prototype.var_map = {};

    Ti_context.prototype.type_map = {};

    Ti_context.prototype.library_map = {};

    Ti_context.prototype.walk = null;

    Ti_context.prototype.first_stage_walk = null;

    Ti_context.prototype.change_count = 0;

    function Ti_context() {
      this.var_map = module.default_var_map_gen();
      this.type_map = module.default_type_map_gen();
      this.library_map = {};
    }

    Ti_context.prototype.mk_nest = function() {
      var ret;
      ret = new Ti_context;
      ret.parent = this;
      ret.parent_fn = this.parent_fn;
      ret.current_class = this.current_class;
      ret.first_stage_walk = this.first_stage_walk;
      ret.walk = this.walk;
      obj_set(ret.type_map, this.type_map);
      ret.library_map = this.library_map;
      return ret;
    };

    Ti_context.prototype.type_proxy = function(cls) {
      var k, ret, _len5, _n, _ref5, _ref6;
      if (cls.constructor.name === "Enum_decl") {
        ret = new Type("enum");
        _ref5 = cls.value_list;
        for (_n = 0, _len5 = _ref5.length; _n < _len5; _n++) {
          v = _ref5[_n];
          ret.field_map[v.name] = new Type("int");
        }
        return ret;
      } else {
        ret = new Type("struct");
        _ref6 = cls._prepared_field2type;
        for (k in _ref6) {
          v = _ref6[k];
          if (v.main !== "function2") {
            continue;
          }
          ret.field_map[k] = v;
        }
        return ret;
      }
    };

    Ti_context.prototype.check_id = function(id) {
      var ret, state_class;
      if (id === "this") {
        return this.type_proxy(this.current_class);
      }
      if (this.type_map.hasOwnProperty(id)) {
        return this.type_proxy(this.type_map[id]);
      }
      if (this.var_map.hasOwnProperty(id)) {
        return this.var_map[id];
      }
      if (state_class = this.type_map[config.storage]) {
        if (ret = state_class._prepared_field2type[id]) {
          return ret;
        }
      }
      if (this.parent) {
        return this.parent.check_id(id);
      }
      throw new Error("can't find decl for id '" + id + "'");
    };

    Ti_context.prototype.check_type = function(_type) {
      if (this.type_map.hasOwnProperty(_type)) {
        return this.type_map[_type];
      }
      if (this.parent) {
        return this.parent.check_type(_type);
      }
      throw new Error("can't find type '" + _type + "'");
    };

    return Ti_context;

  })();

  this.class_prepare = function(root, ctx) {
    var type, _len5, _n, _ref5;
    ctx.type_map[root.name] = root;
    if (ctx.parent && ctx.current_class) {
      ctx.parent.type_map["" + ctx.current_class.name + "." + root.name] = root;
    }
    _ref5 = root.scope.list;
    for (_n = 0, _len5 = _ref5.length; _n < _len5; _n++) {
      v = _ref5[_n];
      switch (v.constructor.name) {
        case "Var_decl":
          root._prepared_field2type[v.name] = v.type;
          break;
        case "Fn_decl_multiret":
          type = new Type("function2<function,function>");
          type.nest_list[0] = v.type_i;
          type.nest_list[1] = v.type_o;
          root._prepared_field2type[v.name] = type;
      }
    }
  };

  this.type_resolve = function(type, ctx) {
    if (type && type.main !== "struct") {
      if (ctx.type_map[type.main]) {
        type = ctx.check_id(type.main);
      }
    }
    return type;
  };

  this.type_spread_left = function(a_type, b_type, ctx) {
    var idx, inner_a, inner_b, new_inner_a, _n, _ref5, _ref6, _ref7, _ref8;
    if (!b_type) {
      return a_type;
    }
    if (!a_type && b_type) {
      a_type = b_type.clone();
      ctx.change_count++;
    } else if (a_type.main === "number") {
      if ((_ref5 = b_type.main) === "unsigned_number" || _ref5 === "signed_number") {
        a_type = b_type.clone();
        ctx.change_count++;
      } else if (b_type.main === "number") {
        "nothing";
      } else {
        if (b_type.main === "address") {
          perr("NOTE address to number type cast is not supported in LIGO");
          return a_type;
        }
        if (!is_defined_number_or_byte_type(b_type)) {
          throw new Error("can't spread '" + b_type + "' to '" + a_type + "'");
        }
        a_type = b_type.clone();
        ctx.change_count++;
      }
    } else if (this.is_not_defined_type(a_type) && !this.is_not_defined_type(b_type)) {
      if ((_ref6 = a_type.main) === "unsigned_number" || _ref6 === "signed_number") {
        if (!is_defined_number_or_byte_type(b_type)) {
          throw new Error("can't spread '" + b_type + "' to '" + a_type + "'");
        }
      } else {
        throw new Error("unknown is_not_defined_type spread case");
      }
      a_type = b_type.clone();
      ctx.change_count++;
    } else if (!this.is_not_defined_type(a_type) && this.is_not_defined_type(b_type)) {
      if ((_ref7 = b_type.main) === "number" || _ref7 === "unsigned_number" || _ref7 === "signed_number") {
        if (!is_defined_number_or_byte_type(a_type)) {
          if (a_type.main === "address") {
            perr("WARNING (Type inference). address <-> number operation detected. Generated code will be not compilable by LIGO");
            return a_type;
          }
          throw new Error("can't spread '" + b_type + "' to '" + a_type + "'. Reverse spread collision detected");
        }
      }
    } else {
      if (a_type.cmp(b_type)) {
        return a_type;
      }
      if (a_type.main === "bytes" && config.bytes_type_map.hasOwnProperty(b_type.main)) {
        return a_type;
      }
      if (config.bytes_type_map.hasOwnProperty(a_type.main) && b_type.main === "bytes") {
        return a_type;
      }
      if (a_type.main === "string" && config.bytes_type_map.hasOwnProperty(b_type.main)) {
        return a_type;
      }
      if (config.bytes_type_map.hasOwnProperty(a_type.main) && b_type.main === "string") {
        return a_type;
      }
      if (a_type.main !== "struct" && b_type.main === "struct") {
        a_type = type_resolve(a_type, ctx);
      }
      if (a_type.main === "struct" && b_type.main !== "struct") {
        b_type = type_resolve(b_type, ctx);
      }
      if (is_composite_type(a_type)) {
        if (!is_composite_type(b_type)) {
          perr("can't spread between '" + a_type + "' '" + b_type + "'. Reason: is_composite_type mismatch");
          return a_type;
        }
        if (a_type.main !== b_type.main) {
          throw new Error("spread composite collision '" + a_type + "' '" + b_type + "'. Reason: composite container mismatch");
        }
        if (a_type.nest_list.length !== b_type.nest_list.length) {
          throw new Error("spread composite collision '" + a_type + "' '" + b_type + "'. Reason: nest_list length mismatch");
        }
        for (idx = _n = 0, _ref8 = a_type.nest_list.length; 0 <= _ref8 ? _n < _ref8 : _n > _ref8; idx = 0 <= _ref8 ? ++_n : --_n) {
          inner_a = a_type.nest_list[idx];
          inner_b = b_type.nest_list[idx];
          new_inner_a = this.type_spread_left(inner_a, inner_b, ctx);
          a_type.nest_list[idx] = new_inner_a;
        }
      } else {
        if (is_composite_type(b_type)) {
          perr("can't spread between '" + a_type + "' '" + b_type + "'. Reason: is_composite_type mismatch");
          return a_type;
        }
        if (this.is_number_type(a_type) && this.is_number_type(b_type)) {
          return a_type;
        }
        if (a_type.main === "address" && config.any_int_type_map.hasOwnProperty(b_type)) {
          perr("WARNING (Type inference). address <-> number operation detected. Generated code will be not compilable by LIGO");
          return a_type;
        }
        if (b_type.main === "address" && config.any_int_type_map.hasOwnProperty(a_type)) {
          perr("WARNING (Type inference). address <-> number operation detected. Generated code will be not compilable by LIGO");
          return a_type;
        }
        if (config.bytes_type_map.hasOwnProperty(a_type.main) && config.bytes_type_map.hasOwnProperty(b_type.main)) {
          perr("WARNING (Type inference). Bytes with different sizes are in type collision '" + a_type + "' '" + b_type + "'. This can lead to runtime error.");
          return a_type;
        }
      }
    }
    return a_type;
  };

}).call(window.require_register("./type_inference/common"));
