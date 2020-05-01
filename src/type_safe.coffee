Type = require "type"

Type.prototype.clone = ()->
  ret = new Type
  ret.main = @main
  for v in @nest_list
    if !v?
      ret.nest_list.push v
    else
      ret.nest_list.push v.clone()
  for k,v of @field_map
    if !v?
      ret.field_map[k] = v
    else
      ret.field_map[k] = v.clone()
  ret

null_str = "\x1E"

Type.prototype.toString = ()->
  ret = @main
  if @nest_list.length
    jl = []
    for v in @nest_list
      if !v?
        jl.push null_str
      else
        jl.push v.toString()
    ret += "<#{jl.join ', '}>"
  
  jl = []
  for k,v of @field_map
    if !v?
      jl.push "#{k}: #{null_str}"
    else
      jl.push "#{k}: #{v.toString()}"
  if jl.length
    ret += "{#{jl.join ', '}}"
  
  ret

Type.prototype.cmp = (t)->
  return false if @main != t?.main
  return false if @nest_list.length != t.nest_list.length
  for v,k in @nest_list
    tv = t.nest_list[k]
    continue if tv == v
    return false if !tv?.cmp v
  for k,v of @field_map
    continue if t.field_map[k] == v
    return false if !t.field_map.hasOwnProperty k
    tv = t.field_map[k]
    return false if !tv?.cmp v
  for k,v of t.field_map
    return false if !@field_map.hasOwnProperty k
    tv = @field_map[k]
    # return false if !tv.cmp v
  true
