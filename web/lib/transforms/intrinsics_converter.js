(function() {
  var Type, ast, default_walk, module, timestamp_node;

  default_walk = require("./default_walk").default_walk;

  ast = require("../ast");

  Type = window.Type;

  module = this;

  timestamp_node = function() {
    var timestamp;
    timestamp = new ast.Bin_op;
    timestamp.op = "SUB";
    timestamp.a = new ast.Var;
    timestamp.a.name = "@now";
    timestamp.a.name_translate = false;
    timestamp.b = new ast.Type_cast;
    timestamp.b.target_type = new Type("timestamp");
    timestamp.b.t = new ast.Const;
    timestamp.b.t.type = new Type("string");
    timestamp.b.t.val = "1970-01-01T00:00:00Z";
    timestamp.a.type = new Type("uint");
    timestamp.b.type = new Type("uint");
    return timestamp;
  };

  (function(_this) {
    return (function() {
      var walk;
      walk = function(root, ctx) {
        var ret;
        walk = ctx.walk;
        switch (root.constructor.name) {
          case "Var":
            if (root.name === "now") {
              return timestamp_node();
            }
            return ctx.next_gen(root, ctx);
          case "Field_access":
            switch (root.t.name) {
              case "block":
                if (root.name === "timestamp") {
                  return timestamp_node();
                }
                break;
              case "msg":
                switch (root.name) {
                  case "sender":
                    root.t.name = "@Tezos";
                    root.name = "@sender";
                    break;
                  case "value":
                    ret = new ast.Bin_op;
                    ret.op = "DIV";
                    ret.a = new ast.Var;
                    ret.a.name = "@amount";
                    ret.a.type = new Type("uint");
                    ret.b = new ast.Const;
                    ret.b.val = 1;
                    ret.b.type = new Type("mutez");
                    return ctx.next_gen(ret, ctx);
                }
                break;
              case "tx":
                if (root.name === "origin") {
                  root.t.name = "@Tezos";
                  root.name = "@source";
                }
            }
            return ctx.next_gen(root, ctx);
          default:
            return ctx.next_gen(root, ctx);
        }
      };
      return _this.intrinsics_converter = function(root) {
        return walk(root, {
          walk: walk,
          next_gen: default_walk
        });
      };
    });
  })(this)();

}).call(window.require_register("./transforms/intrinsics_converter"));
