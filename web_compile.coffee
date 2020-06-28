#!/usr/bin/env iced
### !pragma coverage-skip-block ###
require "fy"
fs = require "fs"
iced_compiler = require "iced-coffee-script"
path = require "path"

# ###################################################################################################
#    source code
# ###################################################################################################

# recursively walk through folder
walk = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    if err
      return done(err)
    i = 0
    next = () ->
      file = list[i++]
      if !file
        return done(null, results)
      # file = path.resolve(dir, file)
      file = dir + "/" + file
      fs.stat file, (err, stat) ->
        if stat and stat.isDirectory()
          walk file, (err, res) ->
            results = results.concat(res)
            next()
        else
          results.push file
          next()
    next()

dirname = "src"

walk dirname, (err, paths) ->
  if err
    throw err
  for filename in paths
    p filename
    code = fs.readFileSync filename, "utf-8"
    code = iced_compiler.compile code

    filepath = filename.replace(dirname, "").substr(1) # remove "src/"
    parsed_path = path.parse(filepath)

    if parsed_path.ext != ".coffee"
      p "skipping ", filepath
      continue
    fs.mkdirSync "web/lib/#{parsed_path.dir}", recursive: true
    
    code = code.replace 'require("fy");', ''
    code = code.replace 'require("fy/codegen");', ''
    code = code.replace 'Type = require("type");', 'Type = window.Type;'
    code = code.replace 'ast = require("ast4gen");', 'ast = window.ast4gen;'
    
    require_path = "./"+filepath.replace /\.coffee$/, ''
    # code = code.replace '}).call(this);', "}).call(window._require_hash[#{JSON.stringify require_path}] = {});"
    code = code.replace '}).call(this);', "}).call(window.require_register(#{JSON.stringify require_path}));"
    
    fs.writeFileSync "web/lib/#{parsed_path.dir}/#{parsed_path.name}.js", code
    


# ###################################################################################################
#    examples
# ###################################################################################################
code = iced_compiler.compile fs.readFileSync "web/example_list.coffee", "utf-8"
fs.writeFileSync "web/example_list.js", code
# ###################################################################################################
#    solc
# ###################################################################################################
solc_patch_code = (code, name)->
  """
  (function(){
  #{code}
  window._solc[#{JSON.stringify name}] = Module
  })()
  """

solc_process = (file_name, name)->
  code = fs.readFileSync "solc-bin/bin/#{file_name}", "utf-8"
  code = solc_patch_code code, name
  fs.writeFileSync "web/solc/#{file_name}", code

solc_process "soljson-v0.4.26+commit.4563c3fc.js", "soljson-v0.4.26"
solc_process "soljson-v0.5.11+commit.c082d0b4.js", "soljson-v0.5.11"
