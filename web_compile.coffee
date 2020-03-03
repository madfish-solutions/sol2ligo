#!/usr/bin/env iced
### !pragma coverage-skip-block ###
require "fy"
fs = require "fs"
iced_compiler = require "iced-coffee-script"

code = iced_compiler.compile fs.readFileSync "src/ast.coffee", "utf-8"
code = code.replace 'ast = require("ast4gen");', 'ast = window.ast4gen;'
code = code.replace '}).call(this);', '}).call(window.mod_ast = {});'
fs.writeFileSync "web/lib/ast.js", code

code = iced_compiler.compile fs.readFileSync "src/ast_transform.coffee", "utf-8"
code = code.replace 'Type = require("type");', 'Type = window.Type'
code = code.replace 'config = require("./config");', 'config = window.config'
code = code.replace 'ast = require("./ast");', 'ast = window.mod_ast;'
code = code.replace 'translate_var_name = require("./translate_var_name").translate_var_name;', 'translate_var_name = window.translate_var_name.translate_var_name;'
code = code.replace 'translate_type = require("./translate_ligo").translate_type;', 'translate_type = window.translate_ligo.translate_type;'
code = code.replace '}).call(this);', '}).call(window.ast_transform = {});'
fs.writeFileSync "web/lib/ast_transform.js", code

code = iced_compiler.compile fs.readFileSync "src/config.coffee", "utf-8"
code = code.replace 'require("fy");', ''
code = code.replace '}).call(this);', '}).call(window.config = {});'
fs.writeFileSync "web/lib/config.js", code

code = iced_compiler.compile fs.readFileSync "src/solidity_to_ast4gen.coffee", "utf-8"
code = code.replace 'config = require("./config");', 'config = window.config'
code = code.replace 'Type = require("type");', 'Type = window.Type'
code = code.replace 'ast = require("./ast");', 'ast = window.mod_ast;'
code = code.replace '}).call(this);', '}).call(window.solidity_to_ast4gen = {});'
fs.writeFileSync "web/lib/solidity_to_ast4gen.js", code


code = iced_compiler.compile fs.readFileSync "src/translate_ligo.coffee", "utf-8"
code = code.replace 'require("fy/codegen");', ''
code = code.replace 'config = require("./config");', 'config = window.config'
code = code.replace 'translate_var_name = require("./translate_var_name").translate_var_name;', 'translate_var_name = window.translate_var_name.translate_var_name;'
code = code.replace '}).call(this);', '}).call(window.translate_ligo = {});'
fs.writeFileSync "web/lib/translate_ligo.js", code

code = iced_compiler.compile fs.readFileSync "src/translate_ligo_default_state.coffee", "utf-8"
code = code.replace 'require("fy/codegen");', ''
code = code.replace 'config = require("./config");', 'config = window.config'
code = code.replace 'Type = require("type");', 'Type = window.Type'
code = code.replace '_ref = require("./translate_ligo"), translate_type = _ref.translate_type, type2default_value = _ref.type2default_value;', '_ref = translate_ligo, translate_type = _ref.translate_type, type2default_value = _ref.type2default_value;'
code = code.replace '}).call(this);', '}).call(window.translate_ligo_default_state = {});'
fs.writeFileSync "web/lib/translate_ligo_default_state.js", code

code = iced_compiler.compile fs.readFileSync "src/translate_var_name.coffee", "utf-8"
code = code.replace 'config = require("./config");', 'config = window.config'
code = code.replace '}).call(this);', '}).call(window.translate_var_name = {});'
fs.writeFileSync "web/lib/translate_var_name.js", code

code = iced_compiler.compile fs.readFileSync "src/type_inference.coffee", "utf-8"
code = code.replace 'require("./type_safe");', ''
code = code.replace 'config = require("./config");', 'config = window.config'
code = code.replace 'Type = require("type");', 'Type = window.Type'
code = code.replace '}).call(this);', '}).call(window.type_inference = {});'
fs.writeFileSync "web/lib/type_inference.js", code

code = iced_compiler.compile fs.readFileSync "src/type_safe.coffee", "utf-8"
code = code.replace 'Type = require("type");', 'Type = window.Type'
fs.writeFileSync "web/lib/type_safe.js", code

code = iced_compiler.compile fs.readFileSync "web/example_list.coffee", "utf-8"
fs.writeFileSync "web/example_list.js", code

