return if !process.env.EMULATOR
assert = require "assert"

describe "emulator section", ()->
  it "Test_contract.add", (on_end)->
    @timeout 30000
    await test_get_contract "Test_contract", defer(err, contract); return on_end err if err
    
    await contract.add.call(1, 2).cb defer(err, result); return on_end err if err
    assert.strictEqual result.toNumber(), 3
    
    on_end()
