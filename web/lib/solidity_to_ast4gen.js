(function() {
  var Context, Type, ast, bin_op_map, config, ensure_scope, is_complex_assign_op, parse_line_pos, prev_root, type_generalize, un_op_map, un_op_post_map, un_op_pre_map, unpack_id_type, walk, walk_param, walk_type;

  

  config = require("./config");

  Type = window.Type;

  ast = require("./ast");

  type_generalize = require("./type_generalize").type_generalize;

  bin_op_map = {
    "+": "ADD",
    "-": "SUB",
    "*": "MUL",
    "/": "DIV",
    "%": "MOD",
    "**": "POW",
    ">>": "SHR",
    "<<": "SHL",
    "&": "BIT_AND",
    "|": "BIT_OR",
    "^": "BIT_XOR",
    "&&": "BOOL_AND",
    "||": "BOOL_OR",
    "==": "EQ",
    "!=": "NE",
    ">": "GT",
    "<": "LT",
    ">=": "GTE",
    "<=": "LTE",
    "=": "ASSIGN",
    "+=": "ASS_ADD",
    "-=": "ASS_SUB",
    "*=": "ASS_MUL",
    "/=": "ASS_DIV",
    "%=": "ASS_MOD",
    ">>=": "ASS_SHR",
    "<<=": "ASS_SHL",
    "&=": "ASS_BIT_AND",
    "|=": "ASS_BIT_OR",
    "^=": "ASS_BIT_XOR"
  };

  is_complex_assign_op = {
    "ASS_ADD": true,
    "ASS_SUB": true,
    "ASS_MUL": true,
    "ASS_DIV": true
  };

  un_op_map = {
    "-": "MINUS",
    "+": "PLUS",
    "~": "BIT_NOT",
    "!": "BOOL_NOT",
    "delete": "DELETE"
  };

  un_op_pre_map = {
    "++": "INC_RET",
    "--": "DEC_RET"
  };

  un_op_post_map = {
    "++": "RET_INC",
    "--": "RET_DEC"
  };

  walk_type = function(root, ctx) {
    var ret, _ref, _ref1;
    if (typeof root === "string") {
      return new Type(root);
    }
    switch (root.nodeType) {
      case "ElementaryTypeName":
        switch (root.name) {
          case "uint":
            return new Type("uint256");
          case "int":
            return new Type("int256");
          default:
            return new Type(root.name);
        }
        break;
      case "UserDefinedTypeName":
        return new Type(root.name);
      case "ArrayTypeName":
        ret = new Type("array");
        ret.nest_list.push(walk_type(root.baseType, ctx));
        _ref = parse_line_pos(root.src), ret.pos = _ref[0], ret.line = _ref[1];
        ret.file = ctx.file_stack.last();
        return ret;
      case "Mapping":
        ret = new Type("map");
        ret.nest_list.push(walk_type(root.keyType, ctx));
        ret.nest_list.push(walk_type(root.valueType, ctx));
        _ref1 = parse_line_pos(root.src), ret.pos = _ref1[0], ret.line = _ref1[1];
        ret.file = ctx.file_stack.last();
        return ret;
      default:
        perr(root);
        throw new Error("walk_type unknown nodeType '" + root.nodeType + "'");
    }
  };

  unpack_id_type = function(root, ctx) {
    var type_string;
    type_string = root.typeString;
    if (/\smemory$/.test(type_string)) {
      type_string = type_string.replace(/\smemory$/, "");
    }
    if (/\sstorage$/.test(type_string)) {
      type_string = type_string.replace(/\sstorage$/, "");
    }
    switch (type_string) {
      case "bool":
        return new Type("bool");
      case "uint":
        return new Type("uint256");
      case "int":
        return new Type("int256");
      case "byte":
        return new Type("bytes1");
      case "bytes":
        return new Type("bytes");
      case "address":
        return new Type("address");
      case "string":
        return new Type("string");
      case "msg":
        return null;
      case "block":
        return null;
      case "tx":
        return null;
      default:
        if (config.bytes_type_map.hasOwnProperty(type_string)) {
          return new Type(root.typeString);
        } else if (config.uint_type_map.hasOwnProperty(type_string)) {
          return new Type(root.typeString);
        } else if (config.int_type_map.hasOwnProperty(type_string)) {
          return new Type(root.typeString);
        } else {
          throw new Error("unpack_id_type unknown typeString '" + root.typeString + "'");
        }
    }
  };

  parse_line_pos = function(str) {
    return str.split(":", 2);
  };

  walk_param = function(root, ctx) {
    var ret, t, v, _i, _len, _ref;
    switch (root.nodeType) {
      case "ParameterList":
        ret = [];
        _ref = root.parameters;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          v = _ref[_i];
          ret.append(walk_param(v, ctx));
        }
        return ret;
      case "VariableDeclaration":
        if (root.value) {
          throw new Error("root.value not implemented");
        }
        ret = [];
        t = walk_type(root.typeName, ctx);
        t._name = root.name;
        ret.push(t);
        return ret;
      default:
        perr(root);
        throw new Error("walk_param unknown nodeType '" + root.nodeType + "'");
    }
  };

  ensure_scope = function(t) {
    var ret;
    if (t.constructor.name === "Scope") {
      return t;
    }
    ret = new ast.Scope;
    ret.list.push(t);
    return ret;
  };

  Context = (function() {
    Context.prototype.contract = null;

    Context.prototype.contract_name = "";

    Context.prototype.contract_type = "";

    Context.prototype.file_stack = [];

    Context.prototype.need_prevent_deploy = false;

    function Context() {}

    return Context;

  })();

  prev_root = null;

  walk = function(root, ctx) {
    var arg, arg_list, arg_names, args, ast_mod, comment, decl, err, exp, failwith, failwith_msg, fn, list, member, modifier, mult, name, node, parameter, result, ret, ret_multi, scope_prepend_list, tuple, type, type_list, v, var_decl, _var;
    if (!root) {
      perr(prev_root);
      throw new Error("!root");
    }
    prev_root = root;
    result = (function() {
      var _base, _i, _j, _k, _l, _len, _len1, _len10, _len11, _len12, _len13, _len14, _len15, _len2, _len3, _len4, _len5, _len6, _len7, _len8, _len9, _m, _n, _o, _p, _q, _r, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref2, _ref20, _ref21, _ref22, _ref23, _ref24, _ref25, _ref26, _ref27, _ref28, _ref29, _ref3, _ref30, _ref31, _ref32, _ref33, _ref34, _ref35, _ref36, _ref37, _ref38, _ref39, _ref4, _ref40, _ref41, _ref42, _ref43, _ref44, _ref45, _ref46, _ref47, _ref48, _ref5, _ref6, _ref7, _ref8, _ref9, _s, _t, _u, _v, _w, _x;
      switch (root.nodeType) {
        case "SourceUnit":
          ret = new ast.Scope;
          ret.original_node_type = root.nodeType;
          _ref = root.nodes;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            node = _ref[_i];
            ret.list.push(walk(node, ctx));
          }
          _ref1 = parse_line_pos(root.src), ret.pos = _ref1[0], ret.line = _ref1[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "ContractDefinition":
          if (root.name.startsWith("ImportPlaceholderStart")) {
            ctx.file_stack.push(root.nodes[0].value.value);
            ret = new ast.Comment;
            ret.text = "#include \"" + (ctx.file_stack.last()) + "\"";
            ret.can_skip = true;
            return ret;
          } else if (root.name.startsWith("ImportPlaceholderEnd")) {
            ret = new ast.Comment;
            ret.text = "end of include " + (ctx.file_stack.last());
            ret.can_skip = true;
            ctx.file_stack.pop();
            return ret;
          } else {
            ret = new ast.Class_decl;
            switch (root.contractKind) {
              case "contract":
                ret.is_contract = true;
                break;
              case "library":
                ret.is_library = true;
                break;
              case "interface":
                ret.is_interface = true;
                break;
              default:
                throw new Error("unknown contractKind " + root.contractKind);
            }
            ret.inheritance_list = [];
            ret.name = root.name;
            ctx.contract = ret;
            ctx.contract_name = root.name;
            ctx.contract_type = root.contractKind;
            _ref2 = root.baseContracts;
            for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
              v = _ref2[_j];
              arg_list = [];
              if (v["arguments"]) {
                _ref3 = v["arguments"];
                for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
                  arg = _ref3[_k];
                  arg_list.push(walk(arg, ctx));
                }
              }
              ret.inheritance_list.push({
                name: v.baseName.name,
                arg_list: arg_list
              });
            }
            _ref4 = root.nodes;
            for (_l = 0, _len3 = _ref4.length; _l < _len3; _l++) {
              node = _ref4[_l];
              ret.scope.list.push(walk(node, ctx));
            }
            _ref5 = parse_line_pos(root.src), ret.pos = _ref5[0], ret.line = _ref5[1];
            ret.file = ctx.file_stack.last();
            return ret;
          }
          break;
        case "PragmaDirective":
          ret = new ast.Comment;
          ret.text = "PragmaDirective " + (root.literals.join(' '));
          ret.can_skip = true;
          return ret;
        case "UsingForDirective":
          ret = new ast.Comment;
          ret.text = "UsingForDirective";
          _ref6 = parse_line_pos(root.src), ret.pos = _ref6[0], ret.line = _ref6[1];
          ret.file = ctx.file_stack.last();
          if (root.typeName === null) {
            type = "*";
          } else {
            type = type_generalize(root.typeName.name);
          }
          if ((_base = ctx.contract.using_map)[type] == null) {
            _base[type] = [];
          }
          ctx.contract.using_map[type].push(root.libraryName.name);
          return ret;
        case "StructDefinition":
          ret = new ast.Class_decl;
          ret.name = root.name;
          ret.is_struct = true;
          _ref7 = root.members;
          for (_m = 0, _len4 = _ref7.length; _m < _len4; _m++) {
            v = _ref7[_m];
            ret.scope.list.push(walk(v, ctx));
          }
          _ref8 = parse_line_pos(root.src), ret.pos = _ref8[0], ret.line = _ref8[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "InlineAssembly":
          perr("WARNING (AST gen). InlineAssembly is not supported. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#inline-assembler");
          failwith_msg = new ast.Const;
          failwith_msg.val = "Unsupported InlineAssembly";
          failwith_msg.type = new Type("string");
          failwith = new ast.Throw;
          failwith.t = failwith_msg;
          comment = new ast.Comment;
          comment.text = "InlineAssembly " + root.operations;
          ret = new ast.Scope;
          ret.need_nest = false;
          ret.list.push(failwith);
          ret.list.push(comment);
          _ref9 = parse_line_pos(root.src), ret.pos = _ref9[0], ret.line = _ref9[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "EventDefinition":
          perr("WARNING (AST gen). EventDefinition is not supported. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#solidity-events");
          ret = new ast.Event_decl;
          ret.name = root.name;
          ret.arg_list = walk_param(root.parameters, ctx);
          _ref10 = parse_line_pos(root.src), ret.pos = _ref10[0], ret.line = _ref10[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "EmitStatement":
          perr("WARNING (AST gen). EmitStatement is not supported. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#solidity-events");
          ret = new ast.Comment;
          args = [];
          name = ((_ref11 = root.fn) != null ? _ref11.name : void 0) || root.eventCall.name || root.eventCall.expression.name;
          args = root.arg_list || root.eventCall["arguments"];
          arg_names = args.map(function(arg) {
            return arg.name;
          });
          ret.text = "EmitStatement " + name + "(" + (arg_names.join(", ")) + ")";
          _ref12 = parse_line_pos(root.src), ret.pos = _ref12[0], ret.line = _ref12[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "PlaceholderStatement":
          ret = new ast.Comment;
          ret.text = "COMPILER MSG PlaceholderStatement";
          _ref13 = parse_line_pos(root.src), ret.pos = _ref13[0], ret.line = _ref13[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "Identifier":
          ret = new ast.Var;
          ret.name = root.name;
          try {
            ret.type = unpack_id_type(root.typeDescriptions, ctx);
          } catch (_error) {
            err = _error;
            perr("WARNING (AST gen). Can't resolve type " + err);
          }
          _ref14 = parse_line_pos(root.src), ret.pos = _ref14[0], ret.line = _ref14[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "Literal":
          ret = new ast.Const;
          ret.type = new Type(root.kind);
          ret.val = root.value;
          _ref15 = parse_line_pos(root.src), ret.pos = _ref15[0], ret.line = _ref15[1];
          ret.file = ctx.file_stack.last();
          switch (root.subdenomination) {
            case "seconds":
              return ret;
            case "minutes":
              mult = new ast.Const;
              mult.type = new Type(root.kind);
              mult.val = 60;
              exp = new ast.Bin_op;
              exp.op = bin_op_map["*"];
              exp.a = ret;
              exp.b = mult;
              return exp;
            case "hours":
              mult = new ast.Const;
              mult.type = new Type(root.kind);
              mult.val = 3600;
              exp = new ast.Bin_op;
              exp.op = bin_op_map["*"];
              exp.a = ret;
              exp.b = mult;
              return exp;
            case "days":
              mult = new ast.Const;
              mult.type = new Type(root.kind);
              mult.val = 86400;
              exp = new ast.Bin_op;
              exp.op = bin_op_map["*"];
              exp.a = ret;
              exp.b = mult;
              return exp;
            case "weeks":
              mult = new ast.Const;
              mult.type = new Type(root.kind);
              mult.val = 604800;
              exp = new ast.Bin_op;
              exp.op = bin_op_map["*"];
              exp.a = ret;
              exp.b = mult;
              return exp;
            case "szabo":
              return ret;
            case "finney":
              mult = new ast.Const;
              mult.type = new Type(root.kind);
              mult.val = 1000;
              exp = new ast.Bin_op;
              exp.op = bin_op_map["*"];
              exp.a = ret;
              exp.b = mult;
              return exp;
            case "ether":
              mult = new ast.Const;
              mult.type = new Type(root.kind);
              mult.val = 1000000;
              exp = new ast.Bin_op;
              exp.op = bin_op_map["*"];
              exp.a = ret;
              exp.b = mult;
              return exp;
            default:
              return ret;
          }
          break;
        case "VariableDeclaration":
          ret = new ast.Var_decl;
          ret.is_const = root.constant;
          ret.name = root.name;
          ret.contract_name = ctx.contract_name;
          ret.contract_type = ctx.contract_type;
          ret.type = walk_type(root.typeName, ctx);
          if (root.value) {
            ret.assign_value = walk(root.value, ctx);
          }
          _ref16 = parse_line_pos(root.src), ret.pos = _ref16[0], ret.line = _ref16[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "Assignment":
          ret = new ast.Bin_op;
          ret.op = bin_op_map[root.operator];
          if (!ret.op) {
            throw new Error("unknown bin_op " + root.operator);
          }
          ret.a = walk(root.leftHandSide, ctx);
          ret.b = walk(root.rightHandSide, ctx);
          _ref17 = parse_line_pos(root.src), ret.pos = _ref17[0], ret.line = _ref17[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "BinaryOperation":
          ret = new ast.Bin_op;
          ret.op = bin_op_map[root.operator];
          if (!ret.op) {
            throw new Error("unknown bin_op " + root.operator);
          }
          ret.a = walk(root.leftExpression, ctx);
          ret.b = walk(root.rightExpression, ctx);
          _ref18 = parse_line_pos(root.src), ret.pos = _ref18[0], ret.line = _ref18[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "MemberAccess":
          ret = new ast.Field_access;
          ret.t = walk(root.expression, ctx);
          ret.name = root.memberName;
          _ref19 = parse_line_pos(root.src), ret.pos = _ref19[0], ret.line = _ref19[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "IndexAccess":
          ret = new ast.Bin_op;
          ret.op = "INDEX_ACCESS";
          ret.a = walk(root.baseExpression, ctx);
          ret.b = walk(root.indexExpression, ctx);
          _ref20 = parse_line_pos(root.src), ret.pos = _ref20[0], ret.line = _ref20[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "UnaryOperation":
          ret = new ast.Un_op;
          ret.op = un_op_map[root.operator];
          if (!ret.op) {
            if (root.prefix) {
              ret.op = un_op_pre_map[root.operator];
            } else {
              ret.op = un_op_post_map[root.operator];
            }
          }
          if (!ret.op) {
            perr(root);
            throw new Error("unknown un_op " + root.operator);
          }
          ret.a = walk(root.subExpression, ctx);
          _ref21 = parse_line_pos(root.src), ret.pos = _ref21[0], ret.line = _ref21[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "FunctionCall":
          fn = walk(root.expression, ctx);
          arg_list = [];
          _ref22 = root["arguments"];
          for (_n = 0, _len5 = _ref22.length; _n < _len5; _n++) {
            v = _ref22[_n];
            arg_list.push(walk(v, ctx));
          }
          switch (fn.constructor.name) {
            case "New":
              ret = fn;
              ret.arg_list = arg_list;
              break;
            case "Type_cast":
              if (arg_list.length !== 1) {
                perr(arg_list);
                throw new Error("arg_list.length != 1");
              }
              ret = fn;
              ret.t = arg_list[0];
              break;
            default:
              if (root.kind === "structConstructorCall") {
                ret = new ast.Struct_init;
                ret.fn = fn;
                ret.val_list = arg_list;
                if (root.names) {
                  ret.arg_names = root.names;
                }
              } else {
                ret = new ast.Fn_call;
                ret.fn = fn;
                ret.arg_list = arg_list;
              }
          }
          _ref23 = parse_line_pos(root.src), ret.pos = _ref23[0], ret.line = _ref23[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "TupleExpression":
          if (root.isInlineArray) {
            ret = new ast.Array_init;
          } else {
            ret = new ast.Tuple;
          }
          _ref24 = root.components;
          for (_o = 0, _len6 = _ref24.length; _o < _len6; _o++) {
            v = _ref24[_o];
            if (v != null) {
              ret.list.push(walk(v, ctx));
            } else {
              ret.list.push(null);
            }
          }
          if (ret.constructor.name === "Tuple") {
            if (ret.list.length === 1) {
              ret = ret.list[0];
            }
          }
          _ref25 = parse_line_pos(root.src), ret.pos = _ref25[0], ret.line = _ref25[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "NewExpression":
          ret = new ast.New;
          ret.cls = walk_type(root.typeName, ctx);
          _ref26 = parse_line_pos(root.src), ret.pos = _ref26[0], ret.line = _ref26[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "ElementaryTypeNameExpression":
          ret = new ast.Type_cast;
          ret.target_type = walk_type(root.typeName, ctx);
          _ref27 = parse_line_pos(root.src), ret.pos = _ref27[0], ret.line = _ref27[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "Conditional":
          ret = new ast.Ternary;
          ret.cond = walk(root.condition, ctx);
          ret.t = walk(root.trueExpression, ctx);
          ret.f = walk(root.falseExpression, ctx);
          _ref28 = parse_line_pos(root.src), ret.pos = _ref28[0], ret.line = _ref28[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "ExpressionStatement":
          return walk(root.expression, ctx);
        case "VariableDeclarationStatement":
          if (root.declarations.length !== 1) {
            ret = new ast.Var_decl_multi;
            _ref29 = root.declarations;
            for (_p = 0, _len7 = _ref29.length; _p < _len7; _p++) {
              decl = _ref29[_p];
              if (decl == null) {
                ret.list.push({
                  skip: true
                });
                continue;
              }
              if (decl.typeName) {
                ret.list.push({
                  name: decl.name,
                  type: walk_type(decl.typeName, ctx)
                });
              } else {
                try {
                  type = unpack_id_type(decl.typeDescriptions, ctx);
                } catch (_error) {
                  err = _error;
                  perr("WARNING (AST gen). Can't resolve type " + err);
                }
                ret.list.push({
                  name: decl.name,
                  type: type
                });
              }
            }
            if (root.initialValue) {
              ret.assign_value = walk(root.initialValue, ctx);
            }
            type_list = [];
            _ref30 = ret.list;
            for (_q = 0, _len8 = _ref30.length; _q < _len8; _q++) {
              v = _ref30[_q];
              type_list.push(v.type);
            }
            ret.type = new Type("tuple<>");
            ret.type.nest_list = type_list;
            _ref31 = parse_line_pos(root.src), ret.pos = _ref31[0], ret.line = _ref31[1];
            ret.file = ctx.file_stack.last();
            return ret;
          } else {
            decl = root.declarations[0];
            if (decl.value) {
              throw new Error("decl.value not implemented");
            }
            ret = new ast.Var_decl;
            ret.name = decl.name;
            if (decl.typeName) {
              ret.type = walk_type(decl.typeName, ctx);
            } else {
              ret.type = unpack_id_type(decl.typeDescriptions, ctx);
            }
            if (root.initialValue) {
              ret.assign_value = walk(root.initialValue, ctx);
            }
            _ref32 = parse_line_pos(root.src), ret.pos = _ref32[0], ret.line = _ref32[1];
            ret.file = ctx.file_stack.last();
            return ret;
          }
          break;
        case "Block":
          ret = new ast.Scope;
          _ref33 = root.statements;
          for (_r = 0, _len9 = _ref33.length; _r < _len9; _r++) {
            node = _ref33[_r];
            ret.list.push(walk(node, ctx));
          }
          _ref34 = parse_line_pos(root.src), ret.pos = _ref34[0], ret.line = _ref34[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "IfStatement":
          ret = new ast.If;
          ret.cond = walk(root.condition, ctx);
          ret.t = ensure_scope(walk(root.trueBody, ctx));
          if (root.falseBody) {
            ret.f = ensure_scope(walk(root.falseBody, ctx));
          }
          _ref35 = parse_line_pos(root.src), ret.pos = _ref35[0], ret.line = _ref35[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "WhileStatement":
          ret = new ast.While;
          ret.cond = walk(root.condition, ctx);
          ret.scope = ensure_scope(walk(root.body, ctx));
          _ref36 = parse_line_pos(root.src), ret.pos = _ref36[0], ret.line = _ref36[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "ForStatement":
          ret = new ast.For3;
          if (root.initializationExpression) {
            ret.init = walk(root.initializationExpression, ctx);
          }
          if (root.condition) {
            ret.cond = walk(root.condition, ctx);
          }
          if (root.loopExpression) {
            ret.iter = walk(root.loopExpression, ctx);
          }
          ret.scope = ensure_scope(walk(root.body, ctx));
          _ref37 = parse_line_pos(root.src), ret.pos = _ref37[0], ret.line = _ref37[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "Return":
          ret = new ast.Ret_multi;
          if (root.expression) {
            ret.t_list.push(walk(root.expression, ctx));
          }
          _ref38 = parse_line_pos(root.src), ret.pos = _ref38[0], ret.line = _ref38[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "Continue":
          perr("WARNING (AST gen). 'continue' is not supported by LIGO. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#continue--break");
          ctx.need_prevent_deploy = true;
          ret = new ast.Continue;
          _ref39 = parse_line_pos(root.src), ret.pos = _ref39[0], ret.line = _ref39[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "Break":
          perr("WARNING (AST gen). 'break' is not supported by LIGO. Read more: https://github.com/madfish-solutions/sol2ligo/wiki/Known-issues#continue--break");
          ctx.need_prevent_deploy = true;
          ret = new ast.Break;
          _ref40 = parse_line_pos(root.src), ret.pos = _ref40[0], ret.line = _ref40[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "Throw":
          ret = new ast.Throw;
          _ref41 = parse_line_pos(root.src), ret.pos = _ref41[0], ret.line = _ref41[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "FunctionDefinition":
        case "ModifierDefinition":
          ret = ctx.current_function = new ast.Fn_decl_multiret;
          ret.is_modifier = root.nodeType === "ModifierDefinition";
          ret.is_constructor = root.isConstructor || root.kind === "constructor";
          ret.name = root.name || "fallback";
          if (ret.is_constructor) {
            ret.name = "constructor";
          }
          ret.contract_name = ctx.contract_name;
          ret.contract_type = ctx.contract_type;
          ret.type_i = new Type("function");
          ret.type_o = new Type("function");
          ret.visibility = root.visibility;
          ret.state_mutability = root.stateMutability;
          ret.type_i.nest_list = walk_param(root.parameters, ctx);
          if (!ret.is_modifier) {
            list = walk_param(root.returnParameters, ctx);
            if (list.length <= 1) {
              ret.type_o.nest_list = list;
            } else {
              tuple = new Type("tuple<>");
              tuple.nest_list = list;
              ret.type_o.nest_list.push(tuple);
            }
          }
          scope_prepend_list = [];
          if (root.returnParameters) {
            _ref42 = root.returnParameters.parameters;
            for (_s = 0, _len10 = _ref42.length; _s < _len10; _s++) {
              parameter = _ref42[_s];
              if (!parameter.name) {
                continue;
              }
              scope_prepend_list.push(var_decl = new ast.Var_decl);
              var_decl.name = parameter.name;
              var_decl.type = walk_type(parameter.typeName, ctx);
            }
          }
          _ref43 = ret.type_i.nest_list;
          for (_t = 0, _len11 = _ref43.length; _t < _len11; _t++) {
            v = _ref43[_t];
            ret.arg_name_list.push(v._name);
          }
          if (!ret.is_modifier) {
            _ref44 = root.modifiers;
            for (_u = 0, _len12 = _ref44.length; _u < _len12; _u++) {
              modifier = _ref44[_u];
              ast_mod = new ast.Fn_call;
              ast_mod.fn = walk(modifier.modifierName, ctx);
              if (modifier["arguments"]) {
                _ref45 = modifier["arguments"];
                for (_v = 0, _len13 = _ref45.length; _v < _len13; _v++) {
                  v = _ref45[_v];
                  ast_mod.arg_list.push(walk(v, ctx));
                }
              }
              ret.modifier_list.push(ast_mod);
            }
          }
          if (root.body) {
            ret.scope = walk(root.body, ctx);
          } else {
            ret.scope = new ast.Scope;
          }
          if (scope_prepend_list.length) {
            ret.scope.list = arr_merge(scope_prepend_list, ret.scope.list);
            if (ret.scope.list.last().constructor.name !== "Ret_multi") {
              ret.scope.list.push(ret_multi = new ast.Ret_multi);
              switch (scope_prepend_list.length) {
                case 0:
                  "nothing";
                  break;
                case 1:
                  v = scope_prepend_list[0];
                  ret_multi.t_list.push(_var = new ast.Var);
                  _var.name = v.name;
                  break;
                default:
                  tuple = new ast.Tuple;
                  for (_w = 0, _len14 = scope_prepend_list.length; _w < _len14; _w++) {
                    v = scope_prepend_list[_w];
                    tuple.list.push(_var = new ast.Var);
                    _var.name = v.name;
                  }
                  ret_multi.t_list.push(tuple);
              }
            }
          }
          _ref46 = parse_line_pos(root.src), ret.pos = _ref46[0], ret.line = _ref46[1];
          ret.file = ctx.file_stack.last();
          return ret;
        case "EnumDefinition":
          ret = new ast.Enum_decl;
          ret.name = root.name;
          _ref47 = root.members;
          for (_x = 0, _len15 = _ref47.length; _x < _len15; _x++) {
            member = _ref47[_x];
            ret.value_list.push(decl = new ast.Var_decl);
            decl.name = member.name;
          }
          _ref48 = parse_line_pos(root.src), ret.pos = _ref48[0], ret.line = _ref48[1];
          ret.file = ctx.file_stack.last();
          return ret;
        default:
          perr(root);
          throw new Error("walk unknown nodeType '" + root.nodeType + "'");
      }
    })();
    if (ctx.need_prevent_deploy) {
      result.need_prevent_deploy = true;
    }
    return result;
  };

  this.gen = function(root) {
    return walk(root, new Context);
  };

}).call(window.require_register("./solidity_to_ast4gen"));
