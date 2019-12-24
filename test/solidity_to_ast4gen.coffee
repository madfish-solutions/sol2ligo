assert = require 'assert'
solidity_to_ast4gen = require '../src/solidity_to_ast4gen'
describe 'solidity_to_ast4gen section', ()->
  describe 'solidity samples', ()->
    for path, ast of global.solidity_source_to_ast_hash
      # NOTE ignore ast until previous test are done
      do (path)->
        it "#{path}", ()->
          if !ast = global.solidity_source_to_ast_hash[path]
            puts "NOT AVAILABLE"
            return
          solidity_to_ast4gen ast
  