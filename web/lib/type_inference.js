(function() {
  var Ti_context, Type, address_field_hash, array_field_hash, bytes_field_hash, class_prepare, config, get_list_sign, is_composite_type, is_defined_number_or_byte_type, is_not_defined_type, is_number_type, module, op, type_resolve, v, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2, _ref3, _ref4;

  config = window.config

  Type = window.Type

  

  module = this;

  this.default_var_hash_gen = function() {
    return {
      msg: (function() {
        var ret;
        ret = new Type("struct");
        ret.field_hash.sender = new Type("address");
        ret.field_hash.value = new Type("uint256");
        ret.field_hash.data = new Type("bytes");
        ret.field_hash.gas = new Type("uint256");
        ret.field_hash.sig = new Type("bytes4");
        return ret;
      })(),
      tx: (function() {
        var ret;
        ret = new Type("struct");
        ret.field_hash["origin"] = new Type("address");
        ret.field_hash["gasprice"] = new Type("uint256");
        return ret;
      })(),
      block: (function() {
        var ret;
        ret = new Type("struct");
        ret.field_hash["timestamp"] = new Type("uint256");
        ret.field_hash["coinbase"] = new Type("address");
        ret.field_hash["difficulty"] = new Type("uint256");
        ret.field_hash["gaslimit"] = new Type("uint256");
        ret.field_hash["number"] = new Type("uint256");
        return ret;
      })(),
      abi: (function() {
        var ret;
        ret = new Type("struct");
        ret.field_hash["encodePacked"] = new Type("function2_pure<function<bytes>,function<bytes>>");
        return ret;
      })(),
      now: new Type("uint256"),
      require: new Type("function2_pure<function<bool>,function<>>"),
      require2: new Type("function2_pure<function<bool, string>,function<>>"),
      assert: new Type("function2_pure<function<bool>,function<>>"),
      revert: new Type("function2_pure<function<string>,function<>>"),
      sha256: new Type("function2_pure<function<bytes>,function<bytes32>>"),
      sha3: new Type("function2_pure<function<bytes>,function<bytes32>>"),
      selfdestruct: new Type("function2_pure<function<address>,function<>>"),
      blockhash: new Type("function2_pure<function<address>,function<bytes32>>"),
      keccak256: new Type("function2_pure<function<bytes>,function<bytes32>>"),
      ripemd160: new Type("function2_pure<function<bytes>,function<bytes20>>"),
      ecrecover: new Type("function2_pure<function<bytes, uint8, bytes32, bytes32>,function<address>>"),
      "@respond": new Type("function2_pure<function<>,function<>>")
    };
  };

  array_field_hash = {
    "length": new Type("uint256"),
    "push": function(type) {
      var ret;
      ret = new Type("function2_pure<function<>,function<>>");
      ret.nest_list[0].nest_list.push(type.nest_list[0]);
      return ret;
    }
  };

  bytes_field_hash = {
    "length": new Type("uint256")
  };

  address_field_hash = {
    "send": new Type("function2_pure<function2<uint256>,function2<bool>>"),
    "transfer": new Type("function2_pure<function2<uint256>,function2<>>")
  };

  this.default_type_hash_gen = function() {
    var ret, type, _i, _j, _len, _len1, _ref, _ref1;
    ret = {
      bool: true,
      array: true,
      string: true,
      address: true
    };
    _ref = config.any_int_type_list;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      type = _ref[_i];
      ret[type] = true;
    }
    _ref1 = config.bytes_type_list;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      type = _ref1[_j];
      ret[type] = true;
    }
    return ret;
  };

  this.bin_op_ret_type_hash_list = {
    BOOL_AND: [["bool", "bool", "bool"]],
    BOOL_OR: [["bool", "bool", "bool"]],
    BOOL_GT: [["bool", "bool", "bool"]],
    BOOL_LT: [["bool", "bool", "bool"]],
    BOOL_GTE: [["bool", "bool", "bool"]],
    BOOL_LTE: [["bool", "bool", "bool"]],
    ASSIGN: []
  };

  this.un_op_ret_type_hash_list = {
    BOOL_NOT: [["bool", "bool"]],
    BIT_NOT: [],
    MINUS: []
  };

  _ref = "ADD SUB MUL DIV MOD POW".split(/\s+/g);
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    v = _ref[_i];
    this.bin_op_ret_type_hash_list[v] = [];
  }

  _ref1 = "BIT_AND BIT_OR BIT_XOR".split(/\s+/g);
  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
    v = _ref1[_j];
    this.bin_op_ret_type_hash_list[v] = [];
  }

  _ref2 = "EQ NE GT LT GTE LTE".split(/\s+/g);
  for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
    v = _ref2[_k];
    this.bin_op_ret_type_hash_list[v] = [];
  }

  _ref3 = "SHL SHR POW".split(/\s+/g);
  for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
    v = _ref3[_l];
    this.bin_op_ret_type_hash_list[v] = [];
  }

  _ref4 = "RET_INC RET_DEC INC_RET DEC_RET".split(/\s+/g);
  for (_m = 0, _len4 = _ref4.length; _m < _len4; _m++) {
    op = _ref4[_m];
    this.un_op_ret_type_hash_list[op] = [];
  }

  (function(_this) {
    return (function() {
      var idx1, idx2, list, type, type1, type2, type_index, type_main, _aa, _ab, _ac, _ad, _ae, _af, _ag, _len10, _len11, _len12, _len13, _len14, _len15, _len16, _len17, _len18, _len19, _len20, _len21, _len22, _len23, _len24, _len5, _len6, _len7, _len8, _len9, _n, _o, _p, _q, _r, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref20, _ref21, _ref22, _ref23, _ref24, _ref5, _ref6, _ref7, _ref8, _ref9, _s, _t, _u, _v, _w, _x, _y, _z;
      _ref5 = config.any_int_type_list;
      for (_n = 0, _len5 = _ref5.length; _n < _len5; _n++) {
        type = _ref5[_n];
        _this.un_op_ret_type_hash_list.BIT_NOT.push([type, type]);
      }
      _ref6 = config.int_type_list;
      for (_o = 0, _len6 = _ref6.length; _o < _len6; _o++) {
        type = _ref6[_o];
        _this.un_op_ret_type_hash_list.MINUS.push([type, type]);
      }
      _ref7 = "RET_INC RET_DEC INC_RET DEC_RET".split(/\s+/g);
      for (_p = 0, _len7 = _ref7.length; _p < _len7; _p++) {
        op = _ref7[_p];
        _ref8 = config.any_int_type_list;
        for (_q = 0, _len8 = _ref8.length; _q < _len8; _q++) {
          type = _ref8[_q];
          _this.un_op_ret_type_hash_list[op].push([type, type]);
        }
      }
      _ref9 = "ADD SUB MUL DIV MOD POW".split(/\s+/g);
      for (_r = 0, _len9 = _ref9.length; _r < _len9; _r++) {
        op = _ref9[_r];
        list = _this.bin_op_ret_type_hash_list[op];
        _ref10 = config.any_int_type_list;
        for (_s = 0, _len10 = _ref10.length; _s < _len10; _s++) {
          type = _ref10[_s];
          list.push([type, type, type]);
        }
      }
      _ref11 = "ADD SUB MUL DIV MOD POW".split(/\s+/g);
      for (_t = 0, _len11 = _ref11.length; _t < _len11; _t++) {
        op = _ref11[_t];
        list = _this.bin_op_ret_type_hash_list[op];
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
        list = _this.bin_op_ret_type_hash_list[op];
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
        list = _this.bin_op_ret_type_hash_list[op];
        _ref21 = config.any_int_type_list;
        for (_ad = 0, _len21 = _ref21.length; _ad < _len21; _ad++) {
          type = _ref21[_ad];
          list.push([type, type, "bool"]);
        }
      }
      _ref22 = "SHL SHR POW".split(/\s+/g);
      for (_ae = 0, _len22 = _ref22.length; _ae < _len22; _ae++) {
        op = _ref22[_ae];
        list = _this.bin_op_ret_type_hash_list[op];
        _ref23 = config.uint_type_list;
        for (_af = 0, _len23 = _ref23.length; _af < _len23; _af++) {
          type_main = _ref23[_af];
          _ref24 = config.uint_type_list;
          for (_ag = 0, _len24 = _ref24.length; _ag < _len24; _ag++) {
            type_index = _ref24[_ag];
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
        _this.un_op_ret_type_hash_list.BIT_NOT.push([type, type]);
      }
      _ref6 = config.bytes_type_list;
      for (_o = 0, _len6 = _ref6.length; _o < _len6; _o++) {
        type_byte = _ref6[_o];
        _ref7 = config.any_int_type_list;
        for (_p = 0, _len7 = _ref7.length; _p < _len7; _p++) {
          type_int = _ref7[_p];
          _this.bin_op_ret_type_hash_list.ASSIGN.push([type_byte, type_int, type_int]);
          _this.bin_op_ret_type_hash_list.ASSIGN.push([type_int, type_byte, type_int]);
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
            _this.bin_op_ret_type_hash_list[op].push([type_byte, type_int, "bool"]);
            _this.bin_op_ret_type_hash_list[op].push([type_int, type_byte, "bool"]);
          }
          _this.bin_op_ret_type_hash_list[op].push([type_byte, type_byte, "bool"]);
        }
      }
    });
  })(this)();

  Ti_context = (function() {
    Ti_context.prototype.parent = null;

    Ti_context.prototype.parent_fn = null;

    Ti_context.prototype.current_class = null;

    Ti_context.prototype.var_hash = {};

    Ti_context.prototype.type_hash = {};

    function Ti_context() {
      this.var_hash = module.default_var_hash_gen();
      this.type_hash = module.default_type_hash_gen();
    }

    Ti_context.prototype.mk_nest = function() {
      var ret;
      ret = new Ti_context;
      ret.parent = this;
      ret.parent_fn = this.parent_fn;
      ret.current_class = this.current_class;
      obj_set(ret.type_hash, this.type_hash);
      return ret;
    };

    Ti_context.prototype.type_proxy = function(cls) {
      var k, ret, _len5, _n, _ref5, _ref6, _ref7;
      if (cls.constructor.name === "Enum_decl") {
        ret = new Type("enum");
        _ref5 = cls.value_list;
        for (_n = 0, _len5 = _ref5.length; _n < _len5; _n++) {
          v = _ref5[_n];
          ret.field_hash[v.name] = new Type("int");
        }
        return ret;
      } else {
        ret = new Type("struct");
        _ref6 = cls._prepared_field2type;
        for (k in _ref6) {
          v = _ref6[k];
          if ((_ref7 = v.main) !== "function2" && _ref7 !== "function2_pure") {
            continue;
          }
          ret.field_hash[k] = v;
        }
        return ret;
      }
    };

    Ti_context.prototype.check_id = function(id) {
      var ret, state_class;
      if (id === "this") {
        return this.type_proxy(this.current_class);
      }
      if (this.type_hash.hasOwnProperty(id)) {
        return this.type_proxy(this.type_hash[id]);
      }
      if (this.var_hash.hasOwnProperty(id)) {
        return this.var_hash[id];
      }
      if (state_class = this.type_hash[config.storage]) {
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
      if (this.type_hash.hasOwnProperty(_type)) {
        return this.type_hash[_type];
      }
      if (this.parent) {
        return this.parent.check_type(_type);
      }
      throw new Error("can't find type '" + _type + "'");
    };

    return Ti_context;

  })();

  class_prepare = function(root, ctx) {
    var type, _len5, _n, _ref5;
    ctx.type_hash[root.name] = root;
    if (ctx.parent && ctx.current_class) {
      ctx.parent.type_hash["" + ctx.current_class.name + "." + root.name] = root;
    }
    _ref5 = root.scope.list;
    for (_n = 0, _len5 = _ref5.length; _n < _len5; _n++) {
      v = _ref5[_n];
      switch (v.constructor.name) {
        case "Var_decl":
          root._prepared_field2type[v.name] = v.type;
          break;
        case "Fn_decl_multiret":
          if (v.state_mutability === "pure") {
            type = new Type("function2_pure<function,function>");
          } else {
            type = new Type("function2<function,function>");
          }
          type.nest_list[0] = v.type_i;
          type.nest_list[1] = v.type_o;
          root._prepared_field2type[v.name] = type;
      }
    }
  };

  is_not_defined_type = function(type) {
    var _ref5;
    return !type || ((_ref5 = type.main) === "number" || _ref5 === "unsigned_number" || _ref5 === "signed_number");
  };

  is_number_type = function(type) {
    var _ref5;
    if (!type) {
      return false;
    }
    return (_ref5 = type.main) === "number" || _ref5 === "unsigned_number" || _ref5 === "signed_number";
  };

  is_composite_type = function(type) {
    var _ref5;
    return (_ref5 = type.main) === "array" || _ref5 === "tuple" || _ref5 === "map" || _ref5 === "struct";
  };

  is_defined_number_or_byte_type = function(type) {
    return config.any_int_type_hash[type.main] || config.bytes_type_hash[type.main];
  };

  type_resolve = function(type, ctx) {
    if (type && type.main !== "struct") {
      if (ctx.type_hash[type.main]) {
        type = ctx.check_id(type.main);
      }
    }
    return type;
  };

  get_list_sign = function(list) {
    var has_signed, has_unsigned, has_wtf, _len5, _n;
    has_signed = false;
    has_unsigned = false;
    has_wtf = false;
    for (_n = 0, _len5 = list.length; _n < _len5; _n++) {
      v = list[_n];
      if (config.int_type_hash.hasOwnProperty(v) || v === "signed_number") {
        has_signed = true;
      } else if (config.uint_type_hash.hasOwnProperty(v) || v === "unsigned_number") {
        has_unsigned = true;
      } else if (v === "number") {
        has_signed = true;
        has_unsigned = true;
      } else {
        has_wtf = true;
      }
    }
    if (has_wtf) {
      return null;
    }
    if (has_signed && has_unsigned) {
      return "number";
    }
    if (has_signed && !has_unsigned) {
      return "signed_number";
    }
    if (!has_signed && has_unsigned) {
      return "unsigned_number";
    }
    throw new Error("unreachable");
  };

  this.gen = function(ast_tree, opt) {
    var change_count, i, type_spread_left, walk, _n;
    change_count = 0;
    type_spread_left = function(a_type, b_type, ctx) {
      var idx, inner_a, inner_b, new_inner_a, _n, _ref5, _ref6, _ref7, _ref8;
      if (!b_type) {
        return a_type;
      }
      if (!a_type && b_type) {
        a_type = b_type.clone();
        change_count++;
      } else if (a_type.main === "number") {
        if ((_ref5 = b_type.main) === "unsigned_number" || _ref5 === "signed_number") {
          a_type = b_type.clone();
          change_count++;
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
          change_count++;
        }
      } else if (is_not_defined_type(a_type) && !is_not_defined_type(b_type)) {
        if ((_ref6 = a_type.main) === "unsigned_number" || _ref6 === "signed_number") {
          if (!is_defined_number_or_byte_type(b_type)) {
            throw new Error("can't spread '" + b_type + "' to '" + a_type + "'");
          }
        } else {
          throw new Error("unknown is_not_defined_type spread case");
        }
        a_type = b_type.clone();
        change_count++;
      } else if (!is_not_defined_type(a_type) && is_not_defined_type(b_type)) {
        if ((_ref7 = b_type.main) === "number" || _ref7 === "unsigned_number" || _ref7 === "signed_number") {
          if (!is_defined_number_or_byte_type(a_type)) {
            if (a_type.main === "address") {
              perr("CRITICAL WARNING address <-> number operation detected. We can't fix this yet. So generated code will be not compileable by LIGO");
              return a_type;
            }
            throw new Error("can't spread '" + b_type + "' to '" + a_type + "'. Reverse spread collision detected");
          }
        }
      } else {
        if (a_type.cmp(b_type)) {
          return a_type;
        }
        if (a_type.main === "bytes" && config.bytes_type_hash.hasOwnProperty(b_type.main)) {
          return a_type;
        }
        if (config.bytes_type_hash.hasOwnProperty(a_type.main) && b_type.main === "bytes") {
          return a_type;
        }
        if (a_type.main === "string" && config.bytes_type_hash.hasOwnProperty(b_type.main)) {
          return a_type;
        }
        if (config.bytes_type_hash.hasOwnProperty(a_type.main) && b_type.main === "string") {
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
            new_inner_a = type_spread_left(inner_a, inner_b, ctx);
            a_type.nest_list[idx] = new_inner_a;
          }
        } else {
          if (is_composite_type(b_type)) {
            perr("can't spread between '" + a_type + "' '" + b_type + "'. Reason: is_composite_type mismatch");
            return a_type;
          }
          if (is_number_type(a_type) && is_number_type(b_type)) {
            return a_type;
          }
          if (a_type.main === "address" && config.any_int_type_hash.hasOwnProperty(b_type)) {
            perr("CRITICAL WARNING address <-> defined number operation detected '" + a_type + "' '" + b_type + "'. We can't fix this yet. So generated code will be not compileable by LIGO");
            return a_type;
          }
          if (b_type.main === "address" && config.any_int_type_hash.hasOwnProperty(a_type)) {
            perr("CRITICAL WARNING address <-> defined number operation detected '" + a_type + "' '" + b_type + "'. We can't fix this yet. So generated code will be not compileable by LIGO");
            return a_type;
          }
          if (config.bytes_type_hash.hasOwnProperty(a_type.main) && config.bytes_type_hash.hasOwnProperty(b_type.main)) {
            perr("WARNING bytes with different sizes are in type collision '" + a_type + "' '" + b_type + "'. This can lead to runtime error.");
            return a_type;
          }
        }
      }
      return a_type;
    };
    walk = function(root, ctx) {
      var a, arg, class_decl, complex_type, ctx_nest, decl, expected, f, field_hash, field_type, i, idx, k, name, nest_list, nest_type, offset, real, root_type, t, tuple_value, type, _aa, _ab, _ac, _ad, _len10, _len11, _len12, _len13, _len14, _len15, _len16, _len17, _len18, _len19, _len20, _len21, _len5, _len6, _len7, _len8, _len9, _n, _o, _p, _q, _r, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref20, _ref21, _ref22, _ref23, _ref24, _ref25, _ref26, _ref5, _ref6, _ref7, _ref8, _ref9, _s, _t, _u, _v, _w, _x, _y, _z;
      switch (root.constructor.name) {
        case "Var":
          return root.type = type_spread_left(root.type, ctx.check_id(root.name), ctx);
        case "Const":
          return root.type;
        case "Bin_op":
          walk(root.a, ctx);
          walk(root.b, ctx);
          switch (root.op) {
            case "ASSIGN":
              root.a.type = type_spread_left(root.a.type, root.b.type, ctx);
              root.b.type = type_spread_left(root.b.type, root.a.type, ctx);
              root.type = type_spread_left(root.type, root.a.type, ctx);
              root.a.type = type_spread_left(root.a.type, root.type, ctx);
              root.b.type = type_spread_left(root.b.type, root.type, ctx);
              break;
            case "EQ":
            case "NE":
              root.type = type_spread_left(root.type, new Type("bool"), ctx);
              root.a.type = type_spread_left(root.a.type, root.b.type, ctx);
              root.b.type = type_spread_left(root.b.type, root.a.type, ctx);
              break;
            case "INDEX_ACCESS":
              switch ((_ref5 = root.a.type) != null ? _ref5.main : void 0) {
                case "string":
                  root.b.type = type_spread_left(root.b.type, new Type("uint256"), ctx);
                  root.type = type_spread_left(root.type, new Type("string"), ctx);
                  break;
                case "map":
                  root.b.type = type_spread_left(root.b.type, root.a.type.nest_list[0], ctx);
                  root.type = type_spread_left(root.type, root.a.type.nest_list[1], ctx);
                  break;
                case "array":
                  root.b.type = type_spread_left(root.b.type, new Type("uint256"), ctx);
                  root.type = type_spread_left(root.type, root.a.type.nest_list[0], ctx);
                  break;
                default:
                  if (config.bytes_type_hash.hasOwnProperty((_ref6 = root.a.type) != null ? _ref6.main : void 0)) {
                    root.b.type = type_spread_left(root.b.type, new Type("uint256"), ctx);
                    root.type = type_spread_left(root.type, new Type("bytes1"), ctx);
                  }
              }
          }
          return root.type;
        case "Un_op":
          a = walk(root.a, ctx);
          if (root.op === "DELETE") {
            if (root.a.constructor.name === "Bin_op") {
              if (root.a.op === "INDEX_ACCESS") {
                if (((_ref7 = root.a.a.type) != null ? _ref7.main : void 0) === "array") {
                  return root.type;
                }
                if (((_ref8 = root.a.a.type) != null ? _ref8.main : void 0) === "map") {
                  return root.type;
                }
              }
            }
          }
          return root.type;
        case "Field_access":
          root_type = walk(root.t, ctx);
          field_hash = {};
          if (root_type) {
            switch (root_type.main) {
              case "array":
                field_hash = array_field_hash;
                break;
              case "address":
                field_hash = address_field_hash;
                break;
              case "struct":
                field_hash = root_type.field_hash;
                break;
              case "enum":
                field_hash = root_type.field_hash;
                break;
              default:
                if (config.bytes_type_hash.hasOwnProperty(root_type.main)) {
                  field_hash = bytes_field_hash;
                } else {
                  class_decl = ctx.check_type(root_type.main);
                  field_hash = class_decl._prepared_field2type;
                }
            }
          }
          if (!field_hash.hasOwnProperty(root.name)) {
            perr("CRITICAL WARNING unknown field. '" + root.name + "' at type '" + root_type + "'. Allowed fields [" + (Object.keys(field_hash).join(', ')) + "]");
            return root.type;
          }
          field_type = field_hash[root.name];
          if (typeof field_type === "function") {
            field_type = field_type(root.t.type);
          }
          root.type = type_spread_left(root.type, field_type, ctx);
          return root.type;
        case "Fn_call":
          switch (root.fn.constructor.name) {
            case "Var":
              if (root.fn.name === "super") {
                perr("CRITICAL WARNING skip super() call");
                _ref9 = root.arg_list;
                for (_n = 0, _len5 = _ref9.length; _n < _len5; _n++) {
                  arg = _ref9[_n];
                  walk(arg, ctx);
                }
                return root.type;
              }
              break;
            case "Field_access":
              if (root.fn.t.constructor.name === "Var") {
                if (root.fn.t.name === "super") {
                  perr("CRITICAL WARNING skip super.fn call");
                  _ref10 = root.arg_list;
                  for (_o = 0, _len6 = _ref10.length; _o < _len6; _o++) {
                    arg = _ref10[_o];
                    walk(arg, ctx);
                  }
                  return root.type;
                }
              }
          }
          root_type = walk(root.fn, ctx);
          root_type = type_resolve(root_type, ctx);
          if (!root_type) {
            perr("CRITICAL WARNING can't resolve function type for Fn_call");
            return root.type;
          }
          if (root_type.main === "function2_pure") {
            offset = 0;
          } else {
            offset = 2;
          }
          _ref11 = root.arg_list;
          for (_p = 0, _len7 = _ref11.length; _p < _len7; _p++) {
            arg = _ref11[_p];
            walk(arg, ctx);
          }
          if (root_type.main === "struct") {
            if (root.arg_list.length !== 1) {
              perr("CRITICAL WARNING contract(address) call should have 1 argument. real=" + root.arg_list.length);
              return root.type;
            }
            arg = root.arg_list[0];
            arg.type = type_spread_left(arg.type, new Type("address"), ctx);
            return root.type = type_spread_left(root.type, root_type, ctx);
          } else {
            return root.type = type_spread_left(root.type, root_type.nest_list[1].nest_list[offset], ctx);
          }
          break;
        case "Struct_init":
          root_type = walk(root.fn, ctx);
          root_type = type_resolve(root_type, ctx);
          if (!root_type) {
            perr("CRITICAL WARNING can't resolve function type for Struct_init");
            return root.type;
          }
          _ref12 = root.val_list;
          for (i = _q = 0, _len8 = _ref12.length; _q < _len8; i = ++_q) {
            arg = _ref12[i];
            walk(arg, ctx);
          }
          return root.type;
        case "Comment":
          return null;
        case "Continue":
        case "Break":
          return root;
        case "Var_decl":
          if (root.assign_value) {
            root.assign_value.type = type_spread_left(root.assign_value.type, root.type, ctx);
            walk(root.assign_value, ctx);
          }
          ctx.var_hash[root.name] = root.type;
          return null;
        case "Var_decl_multi":
          if (root.assign_value) {
            root.assign_value.type = type_spread_left(root.assign_value.type, root.type, ctx);
            walk(root.assign_value, ctx);
          }
          _ref13 = root.list;
          for (_r = 0, _len9 = _ref13.length; _r < _len9; _r++) {
            decl = _ref13[_r];
            ctx.var_hash[decl.name] = decl.type;
          }
          return null;
        case "Throw":
          if (root.t) {
            walk(root.t, ctx);
          }
          return null;
        case "Scope":
          ctx_nest = ctx.mk_nest();
          _ref14 = root.list;
          for (_s = 0, _len10 = _ref14.length; _s < _len10; _s++) {
            v = _ref14[_s];
            if (v.constructor.name === "Class_decl") {
              class_prepare(v, ctx);
            }
          }
          _ref15 = root.list;
          for (_t = 0, _len11 = _ref15.length; _t < _len11; _t++) {
            v = _ref15[_t];
            walk(v, ctx_nest);
          }
          return null;
        case "Ret_multi":
          _ref16 = root.t_list;
          for (idx = _u = 0, _len12 = _ref16.length; _u < _len12; idx = ++_u) {
            v = _ref16[idx];
            v.type = type_spread_left(v.type, ctx.parent_fn.type_o.nest_list[idx], ctx);
            expected = ctx.parent_fn.type_o.nest_list[idx];
            real = v.type;
            if (!expected.cmp(real)) {
              perr(root);
              perr("fn_type=" + ctx.parent_fn.type_o);
              perr(v);
              throw new Error("Ret_multi type mismatch [" + idx + "] expected=" + expected + " real=" + real + " @fn=" + ctx.parent_fn.name);
            }
            walk(v, ctx);
          }
          return null;
        case "Class_decl":
          class_prepare(root, ctx);
          ctx_nest = ctx.mk_nest();
          ctx_nest.current_class = root;
          _ref17 = root._prepared_field2type;
          for (k in _ref17) {
            v = _ref17[k];
            ctx_nest.var_hash[k] = v;
          }
          walk(root.scope, ctx_nest);
          return root.type;
        case "Fn_decl_multiret":
          if (root.state_mutability === "pure") {
            complex_type = new Type("function2_pure");
          } else {
            complex_type = new Type("function2");
          }
          complex_type.nest_list.push(root.type_i);
          complex_type.nest_list.push(root.type_o);
          ctx.var_hash[root.name] = complex_type;
          ctx_nest = ctx.mk_nest();
          ctx_nest.parent_fn = root;
          _ref18 = root.arg_name_list;
          for (k = _v = 0, _len13 = _ref18.length; _v < _len13; k = ++_v) {
            name = _ref18[k];
            type = root.type_i.nest_list[k];
            ctx_nest.var_hash[name] = type;
          }
          walk(root.scope, ctx_nest);
          return root.type;
        case "PM_switch":
          return null;
        case "If":
          walk(root.cond, ctx);
          walk(root.t, ctx.mk_nest());
          walk(root.f, ctx.mk_nest());
          return null;
        case "While":
          walk(root.cond, ctx.mk_nest());
          walk(root.scope, ctx.mk_nest());
          return null;
        case "Enum_decl":
          ctx.type_hash[root.name] = root;
          _ref19 = root.value_list;
          for (_w = 0, _len14 = _ref19.length; _w < _len14; _w++) {
            decl = _ref19[_w];
            ctx.var_hash[decl.name] = decl.type;
          }
          return new Type("enum");
        case "Type_cast":
          walk(root.t, ctx);
          return root.type;
        case "Ternary":
          walk(root.cond, ctx);
          t = walk(root.t, ctx);
          f = walk(root.f, ctx);
          root.t.type = type_spread_left(root.t.type, root.f.type, ctx);
          root.f.type = type_spread_left(root.f.type, root.t.type, ctx);
          root.type = type_spread_left(root.type, root.t.type, ctx);
          return root.type;
        case "New":
          _ref20 = root.arg_list;
          for (_x = 0, _len15 = _ref20.length; _x < _len15; _x++) {
            arg = _ref20[_x];
            walk(arg, ctx);
          }
          return root.type;
        case "Tuple":
          _ref21 = root.list;
          for (_y = 0, _len16 = _ref21.length; _y < _len16; _y++) {
            v = _ref21[_y];
            walk(v, ctx);
          }
          nest_list = [];
          _ref22 = root.list;
          for (_z = 0, _len17 = _ref22.length; _z < _len17; _z++) {
            v = _ref22[_z];
            nest_list.push(v.type);
          }
          type = new Type("tuple<>");
          type.nest_list = nest_list;
          root.type = type_spread_left(root.type, type, ctx);
          _ref23 = root.type.nest_list;
          for (idx = _aa = 0, _len18 = _ref23.length; _aa < _len18; idx = ++_aa) {
            v = _ref23[idx];
            tuple_value = root.list[idx];
            tuple_value.type = type_spread_left(tuple_value.type, v, ctx);
          }
          return root.type;
        case "Array_init":
          _ref24 = root.list;
          for (_ab = 0, _len19 = _ref24.length; _ab < _len19; _ab++) {
            v = _ref24[_ab];
            walk(v, ctx);
          }
          nest_type = null;
          if (root.type) {
            if (root.type.main !== "array") {
              throw new Error("Array_init can have only array type");
            }
            nest_type = root.type.nest_list[0];
          }
          _ref25 = root.list;
          for (_ac = 0, _len20 = _ref25.length; _ac < _len20; _ac++) {
            v = _ref25[_ac];
            nest_type = type_spread_left(nest_type, v.type, ctx);
          }
          _ref26 = root.list;
          for (_ad = 0, _len21 = _ref26.length; _ad < _len21; _ad++) {
            v = _ref26[_ad];
            v.type = type_spread_left(v.type, nest_type, ctx);
          }
          type = new Type("array<>");
          type.nest_list[0] = nest_type;
          root.type = type_spread_left(root.type, type, ctx);
          return root.type;
        case "Event_decl":
          return null;
        default:

          /* !pragma coverage-skip-block */
          perr(root);
          throw new Error("ti phase 1 unknown node '" + root.constructor.name + "'");
      }
    };
    walk(ast_tree, new Ti_context);
    walk = function(root, ctx) {
      var a, a_type_list, arg, b, b_type_list, bruteforce_a, bruteforce_b, bruteforce_ret, class_decl, complex_type, ctx_nest, decl, expected, expected_type, f, field_hash, field_type, filter_found_list, found_list, i, idx, k, list, name, nest_list, nest_type, new_type, offset, real, ret, ret_type_list, root_type, t, tuple, tuple_value, type, _aa, _ab, _ac, _ad, _ae, _af, _ag, _ah, _ai, _aj, _ak, _al, _am, _an, _ao, _ap, _len10, _len11, _len12, _len13, _len14, _len15, _len16, _len17, _len18, _len19, _len20, _len21, _len22, _len23, _len24, _len25, _len26, _len27, _len28, _len29, _len30, _len31, _len32, _len33, _len5, _len6, _len7, _len8, _len9, _n, _o, _p, _q, _r, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref20, _ref21, _ref22, _ref23, _ref24, _ref25, _ref26, _ref27, _ref28, _ref5, _ref6, _ref7, _ref8, _ref9, _s, _t, _u, _v, _w, _x, _y, _z;
      switch (root.constructor.name) {
        case "Var":
          return root.type = type_spread_left(root.type, ctx.check_id(root.name), ctx);
        case "Const":
          return root.type;
        case "Bin_op":
          walk(root.a, ctx);
          walk(root.b, ctx);
          switch (root.op) {
            case "ASSIGN":
              root.a.type = type_spread_left(root.a.type, root.b.type, ctx);
              root.b.type = type_spread_left(root.b.type, root.a.type, ctx);
              root.type = type_spread_left(root.type, root.a.type, ctx);
              root.a.type = type_spread_left(root.a.type, root.type, ctx);
              root.b.type = type_spread_left(root.b.type, root.type, ctx);
              return root.type;
            case "EQ":
            case "NE":
            case "GT":
            case "GTE":
            case "LT":
            case "LTE":
              root.type = type_spread_left(root.type, new Type("bool"), ctx);
              root.a.type = type_spread_left(root.a.type, root.b.type, ctx);
              root.b.type = type_spread_left(root.b.type, root.a.type, ctx);
              return root.type;
            case "INDEX_ACCESS":
              switch ((_ref5 = root.a.type) != null ? _ref5.main : void 0) {
                case "string":
                  root.b.type = type_spread_left(root.b.type, new Type("uint256"), ctx);
                  root.type = type_spread_left(root.type, new Type("string"), ctx);
                  return root.type;
                case "map":
                  root.b.type = type_spread_left(root.b.type, root.a.type.nest_list[0], ctx);
                  root.type = type_spread_left(root.type, root.a.type.nest_list[1], ctx);
                  return root.type;
                case "array":
                  root.b.type = type_spread_left(root.b.type, new Type("uint256"), ctx);
                  root.type = type_spread_left(root.type, root.a.type.nest_list[0], ctx);
                  return root.type;
                default:
                  if (config.bytes_type_hash.hasOwnProperty((_ref6 = root.a.type) != null ? _ref6.main : void 0)) {
                    root.b.type = type_spread_left(root.b.type, new Type("uint256"), ctx);
                    root.type = type_spread_left(root.type, new Type("bytes1"), ctx);
                    return root.type;
                  }
              }
          }
          bruteforce_a = is_not_defined_type(root.a.type);
          bruteforce_b = is_not_defined_type(root.b.type);
          bruteforce_ret = is_not_defined_type(root.type);
          a = (root.a.type || "").toString();
          b = (root.b.type || "").toString();
          ret = (root.type || "").toString();
          if (!(list = module.bin_op_ret_type_hash_list[root.op])) {
            throw new Error("unknown bin_op " + root.op);
          }
          found_list = [];
          for (_n = 0, _len5 = list.length; _n < _len5; _n++) {
            tuple = list[_n];
            if (tuple[0] !== a && !bruteforce_a) {
              continue;
            }
            if (tuple[1] !== b && !bruteforce_b) {
              continue;
            }
            if (tuple[2] !== ret && !bruteforce_ret) {
              continue;
            }
            found_list.push(tuple);
          }
          if (is_number_type(root.a.type)) {
            filter_found_list = [];
            for (_o = 0, _len6 = found_list.length; _o < _len6; _o++) {
              tuple = found_list[_o];
              if (!config.any_int_type_hash.hasOwnProperty(tuple[0])) {
                continue;
              }
              filter_found_list.push(tuple);
            }
            found_list = filter_found_list;
          }
          if (is_number_type(root.b.type)) {
            filter_found_list = [];
            for (_p = 0, _len7 = found_list.length; _p < _len7; _p++) {
              tuple = found_list[_p];
              if (!config.any_int_type_hash.hasOwnProperty(tuple[1])) {
                continue;
              }
              filter_found_list.push(tuple);
            }
            found_list = filter_found_list;
          }
          if (is_number_type(root.type)) {
            filter_found_list = [];
            for (_q = 0, _len8 = found_list.length; _q < _len8; _q++) {
              tuple = found_list[_q];
              if (!config.any_int_type_hash.hasOwnProperty(tuple[2])) {
                continue;
              }
              filter_found_list.push(tuple);
            }
            found_list = filter_found_list;
          }
          if (found_list.length === 0) {
            throw new Error("type inference stuck bin_op " + root.op + " invalid a=" + a + " b=" + b + " ret=" + ret);
          } else if (found_list.length === 1) {
            _ref7 = found_list[0], a = _ref7[0], b = _ref7[1], ret = _ref7[2];
            root.a.type = type_spread_left(root.a.type, new Type(a), ctx);
            root.b.type = type_spread_left(root.b.type, new Type(b), ctx);
            root.type = type_spread_left(root.type, new Type(ret), ctx);
          } else {
            if (bruteforce_a) {
              a_type_list = [];
              for (_r = 0, _len9 = found_list.length; _r < _len9; _r++) {
                tuple = found_list[_r];
                a_type_list.upush(tuple[0]);
              }
              if (a_type_list.length === 0) {
                perr("bruteforce stuck bin_op " + root.op + " caused a can't be any type");
              } else if (a_type_list.length === 1) {
                root.a.type = type_spread_left(root.a.type, new Type(a_type_list[0]), ctx);
              } else {
                if (new_type = get_list_sign(a_type_list)) {
                  root.a.type = type_spread_left(root.a.type, new Type(new_type), ctx);
                }
              }
            }
            if (bruteforce_b) {
              b_type_list = [];
              for (_s = 0, _len10 = found_list.length; _s < _len10; _s++) {
                tuple = found_list[_s];
                b_type_list.upush(tuple[1]);
              }
              if (b_type_list.length === 0) {
                perr("bruteforce stuck bin_op " + root.op + " caused b can't be any type");
              } else if (b_type_list.length === 1) {
                root.b.type = type_spread_left(root.b.type, new Type(b_type_list[0]), ctx);
              } else {
                if (new_type = get_list_sign(b_type_list)) {
                  root.b.type = type_spread_left(root.b.type, new Type(new_type), ctx);
                }
              }
            }
            if (bruteforce_ret) {
              ret_type_list = [];
              for (_t = 0, _len11 = found_list.length; _t < _len11; _t++) {
                tuple = found_list[_t];
                ret_type_list.upush(tuple[2]);
              }
              if (ret_type_list.length === 0) {
                perr("bruteforce stuck bin_op " + root.op + " caused ret can't be any type");
              } else if (ret_type_list.length === 1) {
                root.type = type_spread_left(root.type, new Type(ret_type_list[0]), ctx);
              } else {
                if (new_type = get_list_sign(ret_type_list)) {
                  root.type = type_spread_left(root.type, new Type(new_type), ctx);
                }
              }
            }
          }
          return root.type;
        case "Un_op":
          walk(root.a, ctx);
          if (root.op === "DELETE") {
            if (root.a.constructor.name === "Bin_op") {
              if (root.a.op === "INDEX_ACCESS") {
                if (((_ref8 = root.a.a.type) != null ? _ref8.main : void 0) === "array") {
                  return root.type;
                }
                if (((_ref9 = root.a.a.type) != null ? _ref9.main : void 0) === "map") {
                  return root.type;
                }
              }
            }
          }
          bruteforce_a = is_not_defined_type(root.a.type);
          bruteforce_ret = is_not_defined_type(root.type);
          a = (root.a.type || "").toString();
          ret = (root.type || "").toString();
          if (!(list = module.un_op_ret_type_hash_list[root.op])) {
            throw new Error("unknown un_op " + root.op);
          }
          found_list = [];
          for (_u = 0, _len12 = list.length; _u < _len12; _u++) {
            tuple = list[_u];
            if (tuple[0] !== a && !bruteforce_a) {
              continue;
            }
            if (tuple[1] !== ret && !bruteforce_ret) {
              continue;
            }
            found_list.push(tuple);
          }
          if (is_number_type(root.a.type)) {
            filter_found_list = [];
            for (_v = 0, _len13 = found_list.length; _v < _len13; _v++) {
              tuple = found_list[_v];
              if (!config.any_int_type_hash.hasOwnProperty(tuple[0])) {
                continue;
              }
              filter_found_list.push(tuple);
            }
            found_list = filter_found_list;
          }
          if (is_number_type(root.type)) {
            filter_found_list = [];
            for (_w = 0, _len14 = found_list.length; _w < _len14; _w++) {
              tuple = found_list[_w];
              if (!config.any_int_type_hash.hasOwnProperty(tuple[1])) {
                continue;
              }
              filter_found_list.push(tuple);
            }
            found_list = filter_found_list;
          }
          if (found_list.length === 0) {
            throw new Error("type inference stuck un_op " + root.op + " invalid a=" + a + " ret=" + ret);
          } else if (found_list.length === 1) {
            _ref10 = found_list[0], a = _ref10[0], ret = _ref10[1];
            root.a.type = type_spread_left(root.a.type, new Type(a), ctx);
            root.type = type_spread_left(root.type, new Type(ret), ctx);
          } else {
            if (bruteforce_a) {
              a_type_list = [];
              for (_x = 0, _len15 = found_list.length; _x < _len15; _x++) {
                tuple = found_list[_x];
                a_type_list.upush(tuple[0]);
              }
              if (a_type_list.length === 0) {
                throw new Error("type inference bruteforce stuck un_op " + root.op + " caused a can't be any type");
              } else if (a_type_list.length === 1) {
                root.a.type = type_spread_left(root.a.type, new Type(a_type_list[0]), ctx);
              } else {
                if (new_type = get_list_sign(a_type_list)) {
                  root.a.type = type_spread_left(root.a.type, new Type(new_type), ctx);
                }
              }
            }
            if (bruteforce_ret) {
              ret_type_list = [];
              for (_y = 0, _len16 = found_list.length; _y < _len16; _y++) {
                tuple = found_list[_y];
                ret_type_list.upush(tuple[1]);
              }
              if (ret_type_list.length === 0) {
                throw new Error("type inference bruteforce stuck un_op " + root.op + " caused ret can't be any type");
              } else if (ret_type_list.length === 1) {
                root.type = type_spread_left(root.type, new Type(ret_type_list[0]), ctx);
              } else {
                if (new_type = get_list_sign(ret_type_list)) {
                  root.type = type_spread_left(root.type, new Type(new_type), ctx);
                }
              }
            }
          }
          return root.type;
        case "Field_access":
          root_type = walk(root.t, ctx);
          field_hash = {};
          if (root_type) {
            switch (root_type.main) {
              case "array":
                field_hash = array_field_hash;
                break;
              case "bytes":
                field_hash = bytes_field_hash;
                break;
              case "address":
                field_hash = address_field_hash;
                break;
              case "struct":
                field_hash = root_type.field_hash;
                break;
              case "enum":
                field_hash = root_type.field_hash;
                break;
              default:
                class_decl = ctx.check_type(root_type.main);
                field_hash = class_decl._prepared_field2type;
            }
          }
          if (!field_hash.hasOwnProperty(root.name)) {
            perr("CRITICAL WARNING unknown field. '" + root.name + "' at type '" + root_type + "'. Allowed fields [" + (Object.keys(field_hash).join(', ')) + "]");
            return root.type;
          }
          field_type = field_hash[root.name];
          if (typeof field_type === "function") {
            field_type = field_type(root.t.type);
          }
          root.type = type_spread_left(root.type, field_type, ctx);
          return root.type;
        case "Fn_call":
          switch (root.fn.constructor.name) {
            case "Var":
              if (root.fn.name === "super") {
                perr("CRITICAL WARNING skip super() call");
                _ref11 = root.arg_list;
                for (_z = 0, _len17 = _ref11.length; _z < _len17; _z++) {
                  arg = _ref11[_z];
                  walk(arg, ctx);
                }
                return root.type;
              }
              break;
            case "Field_access":
              if (root.fn.t.constructor.name === "Var") {
                if (root.fn.t.name === "super") {
                  perr("CRITICAL WARNING skip super.fn call");
                  _ref12 = root.arg_list;
                  for (_aa = 0, _len18 = _ref12.length; _aa < _len18; _aa++) {
                    arg = _ref12[_aa];
                    walk(arg, ctx);
                  }
                  return root.type;
                }
              }
          }
          root_type = walk(root.fn, ctx);
          root_type = type_resolve(root_type, ctx);
          if (!root_type) {
            perr("CRITICAL WARNING can't resolve function type for Fn_call");
            return root.type;
          }
          if (root_type.main === "function2_pure") {
            offset = 0;
          } else {
            offset = 2;
          }
          _ref13 = root.arg_list;
          for (i = _ab = 0, _len19 = _ref13.length; _ab < _len19; i = ++_ab) {
            arg = _ref13[i];
            walk(arg, ctx);
            if (root_type.main !== "struct") {
              expected_type = root_type.nest_list[0].nest_list[i + offset];
              arg.type = type_spread_left(arg.type, expected_type, ctx);
            }
          }
          if (root_type.main === "struct") {
            if (root.arg_list.length !== 1) {
              perr("CRITICAL WARNING contract(address) call should have 1 argument. real=" + root.arg_list.length);
              return root.type;
            }
            arg = root.arg_list[0];
            arg.type = type_spread_left(arg.type, new Type("address"), ctx);
            return root.type = type_spread_left(root.type, root_type, ctx);
          } else {
            return root.type = type_spread_left(root.type, root_type.nest_list[1].nest_list[offset], ctx);
          }
          break;
        case "Struct_init":
          root_type = walk(root.fn, ctx);
          root_type = type_resolve(root_type, ctx);
          if (!root_type) {
            perr("CRITICAL WARNING can't resolve function type for Struct_init");
            return root.type;
          }
          _ref14 = root.val_list;
          for (i = _ac = 0, _len20 = _ref14.length; _ac < _len20; i = ++_ac) {
            arg = _ref14[i];
            walk(arg, ctx);
          }
          return root.type;
        case "Comment":
          return null;
        case "Continue":
        case "Break":
          return root;
        case "Var_decl":
          if (root.assign_value) {
            root.assign_value.type = type_spread_left(root.assign_value.type, root.type, ctx);
            walk(root.assign_value, ctx);
          }
          ctx.var_hash[root.name] = root.type;
          return null;
        case "Var_decl_multi":
          if (root.assign_value) {
            root.assign_value.type = type_spread_left(root.assign_value.type, root.type, ctx);
            walk(root.assign_value, ctx);
          }
          _ref15 = root.list;
          for (_ad = 0, _len21 = _ref15.length; _ad < _len21; _ad++) {
            decl = _ref15[_ad];
            ctx.var_hash[decl.name] = decl.type;
          }
          return null;
        case "Throw":
          if (root.t) {
            walk(root.t, ctx);
          }
          return null;
        case "Scope":
          ctx_nest = ctx.mk_nest();
          _ref16 = root.list;
          for (_ae = 0, _len22 = _ref16.length; _ae < _len22; _ae++) {
            v = _ref16[_ae];
            if (v.constructor.name === "Class_decl") {
              class_prepare(v, ctx);
            }
          }
          _ref17 = root.list;
          for (_af = 0, _len23 = _ref17.length; _af < _len23; _af++) {
            v = _ref17[_af];
            walk(v, ctx_nest);
          }
          return null;
        case "Ret_multi":
          _ref18 = root.t_list;
          for (idx = _ag = 0, _len24 = _ref18.length; _ag < _len24; idx = ++_ag) {
            v = _ref18[idx];
            v.type = type_spread_left(v.type, ctx.parent_fn.type_o.nest_list[idx], ctx);
            expected = ctx.parent_fn.type_o.nest_list[idx];
            real = v.type;
            if (!expected.cmp(real)) {
              perr(root);
              perr("fn_type=" + ctx.parent_fn.type_o);
              perr(v);
              throw new Error("Ret_multi type mismatch [" + idx + "] expected=" + expected + " real=" + real + " @fn=" + ctx.parent_fn.name);
            }
            walk(v, ctx);
          }
          return null;
        case "Class_decl":
          class_prepare(root, ctx);
          ctx_nest = ctx.mk_nest();
          ctx_nest.current_class = root;
          _ref19 = root._prepared_field2type;
          for (k in _ref19) {
            v = _ref19[k];
            ctx_nest.var_hash[k] = v;
          }
          walk(root.scope, ctx_nest);
          return root.type;
        case "Fn_decl_multiret":
          if (root.state_mutability === "pure") {
            complex_type = new Type("function2_pure");
          } else {
            complex_type = new Type("function2");
          }
          complex_type.nest_list.push(root.type_i);
          complex_type.nest_list.push(root.type_o);
          ctx.var_hash[root.name] = complex_type;
          ctx_nest = ctx.mk_nest();
          ctx_nest.parent_fn = root;
          _ref20 = root.arg_name_list;
          for (k = _ah = 0, _len25 = _ref20.length; _ah < _len25; k = ++_ah) {
            name = _ref20[k];
            type = root.type_i.nest_list[k];
            ctx_nest.var_hash[name] = type;
          }
          walk(root.scope, ctx_nest);
          return root.type;
        case "PM_switch":
          return null;
        case "If":
          walk(root.cond, ctx);
          walk(root.t, ctx.mk_nest());
          walk(root.f, ctx.mk_nest());
          return null;
        case "While":
          walk(root.cond, ctx.mk_nest());
          walk(root.scope, ctx.mk_nest());
          return null;
        case "Enum_decl":
          ctx.type_hash[root.name] = root;
          _ref21 = root.value_list;
          for (_ai = 0, _len26 = _ref21.length; _ai < _len26; _ai++) {
            decl = _ref21[_ai];
            ctx.var_hash[decl.name] = decl.type;
          }
          return new Type("enum");
        case "Type_cast":
          walk(root.t, ctx);
          return root.type;
        case "Ternary":
          walk(root.cond, ctx);
          t = walk(root.t, ctx);
          f = walk(root.f, ctx);
          root.t.type = type_spread_left(root.t.type, root.f.type, ctx);
          root.f.type = type_spread_left(root.f.type, root.t.type, ctx);
          root.type = type_spread_left(root.type, root.t.type, ctx);
          return root.type;
        case "New":
          _ref22 = root.arg_list;
          for (_aj = 0, _len27 = _ref22.length; _aj < _len27; _aj++) {
            arg = _ref22[_aj];
            walk(arg, ctx);
          }
          return root.type;
        case "Tuple":
          _ref23 = root.list;
          for (_ak = 0, _len28 = _ref23.length; _ak < _len28; _ak++) {
            v = _ref23[_ak];
            walk(v, ctx);
          }
          nest_list = [];
          _ref24 = root.list;
          for (_al = 0, _len29 = _ref24.length; _al < _len29; _al++) {
            v = _ref24[_al];
            nest_list.push(v.type);
          }
          type = new Type("tuple<>");
          type.nest_list = nest_list;
          root.type = type_spread_left(root.type, type, ctx);
          _ref25 = root.type.nest_list;
          for (idx = _am = 0, _len30 = _ref25.length; _am < _len30; idx = ++_am) {
            v = _ref25[idx];
            tuple_value = root.list[idx];
            tuple_value.type = type_spread_left(tuple_value.type, v, ctx);
          }
          return root.type;
        case "Array_init":
          _ref26 = root.list;
          for (_an = 0, _len31 = _ref26.length; _an < _len31; _an++) {
            v = _ref26[_an];
            walk(v, ctx);
          }
          nest_type = null;
          if (root.type) {
            if (root.type.main !== "array") {
              throw new Error("Array_init can have only array type");
            }
            nest_type = root.type.nest_list[0];
          }
          _ref27 = root.list;
          for (_ao = 0, _len32 = _ref27.length; _ao < _len32; _ao++) {
            v = _ref27[_ao];
            nest_type = type_spread_left(nest_type, v.type, ctx);
          }
          _ref28 = root.list;
          for (_ap = 0, _len33 = _ref28.length; _ap < _len33; _ap++) {
            v = _ref28[_ap];
            v.type = type_spread_left(v.type, nest_type, ctx);
          }
          type = new Type("array<" + nest_type + ">");
          root.type = type_spread_left(root.type, type, ctx);
          return root.type;
        case "Event_decl":
          return null;
        default:

          /* !pragma coverage-skip-block */
          perr(root);
          throw new Error("ti phase 2 unknown node '" + root.constructor.name + "'");
      }
    };
    change_count = 0;
    for (i = _n = 0; _n < 100; i = ++_n) {
      walk(ast_tree, new Ti_context);
      if (change_count === 0) {
        break;
      }
      change_count = 0;
    }
    return ast_tree;
  };

}).call(window.type_inference = {});
