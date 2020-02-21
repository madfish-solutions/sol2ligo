var solidity_compile_wrap = cwrap('solidity_compile', 'string', ['string', 'number']);
window.ast_gen = function(code){
  input = {
    language: 'Solidity',
    sources: {
        'test.sol': {
            content: code
        }
    },
    settings: {
        
        outputSelection: {
            '*': {
                '*': [ '*' ],
                '' : ['ast']
            }
        }
    }
  }
  var output = JSON.parse(solidity_compile_wrap(JSON.stringify(input)));
  
  var error, is_ok, res, _i, _len, _ref;

  is_ok = true;

  _ref = output.errors || [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    error = _ref[_i];
    if (error.type === 'Warning') {
      console.log("WARNING", error);
      continue;
    }
    is_ok = false;
    perr(error);
  }

  if (!is_ok) {
    throw Error("solc compiler error");
  }

  res = output.sources['test.sol'].ast;

  if (!res) {
    throw Error("!res");
  }

  return res;
}