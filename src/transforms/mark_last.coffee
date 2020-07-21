@mark_last = (root, opt)->
  last_contract = null
  seek_contract = null
  for v in root.list
    continue if v.constructor.name != "Class_decl"
    continue if !v.is_contract
    last_contract = v
    if opt.contract?
      seek_contract = v if v.name == opt.contract
  
  if last_contract
    last_contract.is_last = true
  
  if opt.contract?
    if !seek_contract
      if opt.contract
        perr "WARNING Can't find contract '#{opt.contract}' I will use last contract '#{last_contract?.name}'"
    else
      if last_contract
        last_contract.is_last = false
      seek_contract.is_last = true
  
  root