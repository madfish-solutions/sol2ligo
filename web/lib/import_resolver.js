(function() {
  var execSync, fs, get_folder, import_placeholder_count, m_path, shellEscape, url_resolve;

  m_path = require("path");

  fs = require("fs");

  execSync = require("child_process").execSync;

  shellEscape = require("shell-escape");

  import_placeholder_count = 0;

  get_folder = function(path) {
    var folder, list;
    list = path.split("/");
    list.pop();
    return folder = list.join("/");
  };

  url_resolve = function(url) {
    var code, folder, path, path_list, pseudo_path, reg_ret, repo, user, _ref, _skip;
    if (reg_ret = /^https?:\/\/github.com\/([^\/]+)\/([^\/]+)\/(.*)$/.exec(url)) {
      _skip = reg_ret[0], user = reg_ret[1], repo = reg_ret[2], path = reg_ret[3];
      path_list = path.split("/");
      if (path_list[0] === "blob") {
        path_list.shift();
      } else {
        path_list.unshift("master");
      }
      path = path_list.join("/");
      url = "https://raw.githubusercontent.com/" + user + "/" + repo + "/" + path;
    }
    _ref = /^https?:\/\/(.*)/.exec(url), _skip = _ref[0], pseudo_path = _ref[1];
    pseudo_path = "import_url_cache/" + pseudo_path;
    if (!fs.existsSync(pseudo_path)) {
      folder = get_folder(pseudo_path);
      execSync(shellEscape(["mkdir", "-p", folder]));
      execSync("" + (shellEscape(["curl", url])) + " > " + (shellEscape([pseudo_path])));
    }
    code = fs.readFileSync(pseudo_path, "utf-8");
    if (/^404: Not Found/.test(code)) {
      throw new Error("404. failed to load " + url);
    }
    return code;
  };

  module.exports = function(path, import_cache) {
    var code, filter_line_list, folder, idx, is_root, is_url, key, line, line_list, mk_import, orig_file, pragma_map, reg_ret, val, _i, _j, _len, _len1, _skip;
    is_root = import_cache == null;
    if (import_cache == null) {
      import_cache = {};
    }
    is_url = /^https?:\/\/(.*)/.test(path);
    if (!is_url) {
      path = m_path.resolve(path);
    }
    if ((val = import_cache[path]) != null) {
      return val;
    }
    folder = get_folder(path);
    if (is_url) {
      code = url_resolve(path);
    } else {
      code = fs.readFileSync(path, "utf-8");
    }
    mk_import = function(orig_file) {
      var file, file_like, folder_like, path_like, protocol, _ref;
      if (/^https?:\/\/(.*)/.test(orig_file)) {
        file = orig_file;
      } else if (is_url) {
        _ref = path.split("://"), protocol = _ref[0], path_like = _ref[1];
        folder_like = get_folder(path_like);
        file_like = folder_like + "/" + orig_file;
        file = "" + protocol + "://" + file_like;
      } else {
        file = m_path.resolve(folder + "/" + orig_file);
      }
      if (import_cache[file]) {
        return "// IMPORT RESOLVE " + orig_file + "\n// IMPORT SKIP";
      } else {
        code = module.exports(file, import_cache);
        import_placeholder_count += 1;
        return "contract ImportPlaceholderStart" + import_placeholder_count + " { string name = \"" + orig_file + "\"; }\n" + code + "\ncontract ImportPlaceholderEnd" + import_placeholder_count + " { string name = \"" + orig_file + "\"; }";
      }
    };
    line_list = code.split("\n");
    for (idx = _i = 0, _len = line_list.length; _i < _len; idx = ++_i) {
      line = line_list[idx];
      line = line.trim();
      if (reg_ret = /^import\s+\{.*\}\s+from\s+\"(.+)\";?$/.exec(line)) {
        _skip = reg_ret[0], orig_file = reg_ret[1];
        line_list[idx] = mk_import(orig_file);
      } else if (reg_ret = /^import\s+\"(.+)\";?$/.exec(line)) {
        _skip = reg_ret[0], orig_file = reg_ret[1];
        line_list[idx] = mk_import(orig_file);
      } else if (reg_ret = /^import\s+\'(.+)\';?$/.exec(line)) {
        _skip = reg_ret[0], orig_file = reg_ret[1];
        line_list[idx] = mk_import(orig_file);
      }
    }
    code = line_list.join("\n");
    line_list = code.split("\n");
    pragma_map = {};
    filter_line_list = [];
    for (_j = 0, _len1 = line_list.length; _j < _len1; _j++) {
      line = line_list[_j];
      key = line.trim();
      if (/^pragma/.test(key)) {
        if (pragma_map.hasOwnProperty(key)) {
          continue;
        }
        pragma_map[key] = true;
      }
      filter_line_list.push(line);
    }
    code = filter_line_list.join("\n");
    code = code.replace(/pragma experimental "v0.5.0";?/g, "");
    code = code.replace(/^\/\/ SPDX-License-Identifier.*/g, "");
    if (is_root) {
      code = "// SPDX-License-Identifier: MIT\n" + code;
    }
    return import_cache[path] = code;
  };

}).call(window.require_register("./import_resolver"));
