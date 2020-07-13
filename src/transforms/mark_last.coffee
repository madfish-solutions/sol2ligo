@mark_last = (root, opt)-> 
  last_contract = null
  for v in root.list
    continue if v.constructor.name != "Class_decl"
    continue if !v.is_contract
    last_contract = v
  
  if last_contract
    last_contract.is_last = true
  
  root