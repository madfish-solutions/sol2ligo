(function() {
  var execSync, fs, setupMethods, shellEscape, solc_map;

  

  fs = require("fs");

  setupMethods = require("solc/wrapper");

  execSync = require("child_process").execSync;

  shellEscape = require("shell-escape");

  solc_map = {};

  module.exports = function(code, opt) {
    var allow_download, auto_version, debug, err, error, header, input, is_ok, output, path, pick_version, reg_ret, release_map, res, solc, solc_full_name, solc_version, str, strings, suggest_solc_version, target_dir, _i, _j, _len, _len1, _ref;
    if (opt == null) {
      opt = {};
    }
    solc_version = opt.solc_version, suggest_solc_version = opt.suggest_solc_version, auto_version = opt.auto_version, debug = opt.debug, allow_download = opt.allow_download;
    if (allow_download == null) {
      allow_download = true;
    }
    target_dir = "" + __dirname + "/../solc-bin/bin";
    if (allow_download && !fs.existsSync("" + target_dir + "/list.js")) {
      perr("download solc catalog");
      execSync(shellEscape(["mkdir", "-p", target_dir]));
      execSync(shellEscape(["curl", "https://raw.githubusercontent.com/ethereum/solc-bin/gh-pages/bin/list.js", "--output", "" + target_dir + "/list.js"]));
    }
    release_map = require("../solc-bin/bin/list.js").releases;
    solc_full_name = null;
    if (auto_version == null) {
      auto_version = true;
    }
    pick_version = function(candidate_version) {
      var full_name;
      if (debug) {
        perr("try pick_version " + candidate_version);
      }
      if (full_name = release_map[candidate_version]) {
        return solc_full_name = full_name;
      } else {
        return perr("unknown release version of solc " + candidate_version + "; will take latest");
      }
    };
    if (auto_version && (solc_version == null)) {
      strings = code.trim().split("\n");
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
    } else if (solc_version) {
      pick_version(solc_version);
    }
    if (!solc_full_name && suggest_solc_version) {
      pick_version(suggest_solc_version);
    }
    if (solc_full_name == null) {
      solc_full_name = "soljson-latest.js";
    }
    if ((solc = solc_map[solc_full_name]) == null) {
      path = "" + target_dir + "/" + solc_full_name;
      if (allow_download && !fs.existsSync(path)) {
        perr("download " + solc_full_name);
        execSync(shellEscape(["curl", "https://raw.githubusercontent.com/ethereum/solc-bin/gh-pages/bin/" + solc_full_name, "--output", "" + target_dir + "/" + solc_full_name]));
      }
      perr("loading solc " + solc_full_name);
      solc_map[solc_full_name] = solc = setupMethods(require(path));
    }
    if (debug) {
      perr("use " + solc_full_name);
    }
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
    output = JSON.parse(solc.compile(JSON.stringify(input)));
    is_ok = true;
    _ref = output.errors || [];
    for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
      error = _ref[_j];
      if (error.type === "Warning") {
        if (!opt.quiet) {
          perr("WARNING (Solidity compiler).", error.formattedMessage);
        }
        continue;
      }
      is_ok = false;
      perr(error);
    }
    if (!is_ok) {
      err = new Error("solc compiler error");
      err.__inject_error_list = output.errors;
      throw err;
    }
    res = output.sources["test.sol"].ast;
    if (!res) {

      /* !pragma coverage-skip-block */
      throw new Error("!res");
    }
    return res;
  };

}).call(window.require_register("./ast_gen"));
