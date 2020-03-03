var solidity_compile_wrap_0_4 = window._solc["soljson-v0.4.26"].cwrap("compileStandard", "string", [
  "string",
  "number"
]);
var solidity_compile_wrap_0_5 = window._solc["soljson-v0.5.11"].cwrap("solidity_compile", "string", [
  "string",
  "number"
]);
window.ast_gen = function(code) {
  input = {
    language: "Solidity",
    sources: {
      "test.sol": {
        content: code
      }
    },
    settings: {
      outputSelection: {
        "*": {
          "*": ["*"],
          "": ["ast"]
        }
      }
    }
  };
  var solidity_compile_wrap = solidity_compile_wrap_0_5;
  var solc_full_name = null;
  pick_version = function(candidate_version) {
    // very hacky for front-end
    if (/0\.4/.test(candidate_version)) {
      solidity_compile_wrap = solidity_compile_wrap_0_4;
    }
  };
  var _i, _len, header, reg_ret;
  var strings = code.trim().split("\n");
  for (_i = 0, _len = strings.length; _i < _len; _i++) {
    str = strings[_i];
    header = str.trim();
    if (reg_ret = /^pragma solidity \^?([.0-9]+);/.exec(header)) {
      pick_version(reg_ret[1]);
      break;
    } else if (reg_ret = /^pragma solidity >=([.0-9]+)/.exec(header)) {
      pick_version(reg_ret[1]);
      break;
    }
  }
  
  var output = JSON.parse(solidity_compile_wrap(JSON.stringify(input)));

  var error, is_ok, res, _i, _len, _ref;

  is_ok = true;

  _ref = output.errors || [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    error = _ref[_i];
    if (error.type === "Warning") {
      perr("WARNING", error);
      continue;
    }
    is_ok = false;
    perr(error);
  }

  if (!is_ok) {
    throw Error("solc compiler error");
  }

  res = output.sources["test.sol"].ast;

  if (!res) {
    throw Error("!res");
  }

  return res;
};
