module = @
fs = require 'fs'

@walk = (src_path, cb)->
  list = fs.readdirSync src_path
  for v in list
    src = "#{src_path}/#{v}"
    if fs.lstatSync(src).isDirectory()
      module.walk src, cb
      continue
    
    cb src
  return

  
@walk2 = (src_path, dst_path, cb)->
  list = fs.readdirSync src_path
  for v in list
    src = "#{src_path}/#{v}"
    dst = "#{dst_path}/#{v}"
    if fs.lstatSync(src).isDirectory()
      module.walk2 src, "#{dst_path}/#{v}", cb
      continue
    
    cb src, dst
  return
