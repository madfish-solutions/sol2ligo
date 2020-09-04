(function() {
  this.mark_last = function(root, opt) {
    var last_contract, seek_contract, v, _i, _len, _ref;
    last_contract = null;
    seek_contract = null;
    _ref = root.list;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      v = _ref[_i];
      if (v.constructor.name !== "Class_decl") {
        continue;
      }
      if (!v.is_contract) {
        continue;
      }
      last_contract = v;
      if (opt.contract != null) {
        if (v.name === opt.contract) {
          seek_contract = v;
        }
      }
    }
    if (last_contract) {
      last_contract.is_last = true;
    }
    if (opt.contract != null) {
      if (!seek_contract) {
        if (opt.contract) {
          perr("WARNING (AST transform). Can't find contract '" + opt.contract + "' . Using last contract named '" + (last_contract != null ? last_contract.name : void 0) + "' instead");
        }
      } else {
        if (last_contract) {
          last_contract.is_last = false;
        }
        seek_contract.is_last = true;
      }
    }
    return root;
  };

}).call(window.require_register("./transforms/mark_last"));
