return if !process.env.EMULATOR
fs = require "fs"
assert = require "assert"
{execSync} = require "child_process"
{
  translate_ligo
  tez_account_list
} = require("./util")
shellEscape = require "shell-escape"

describe "emulator section", ()->
  it "Test_contract.add", (on_end)->
    @timeout 30000
    sol_code = """
      pragma solidity >=0.4.21 <0.6.0;
      
      contract Test_contract {
        int ret;
        function add(int a, int b) public {
          ret = a + b;
        }
        function getRet() public view returns (int ret_val) {
          ret_val = ret;
        }
      }
      """
    ligo_code = translate_ligo sol_code
    
    await test_get_contract "Test_contract", sol_code, defer(err, contract); return on_end err if err
    
    await contract.add(1, 2).cb defer(err, result); return on_end err if err
    await contract.getRet.call().cb defer(err, result); return on_end err if err
    
    assert.strictEqual result.toNumber(), 3
    
    fs.writeFileSync "test.ligo", ligo_code
    res = execSync shellEscape [
      "ligo", "dry-run", "test.ligo",
      "--sender", tez_account_list[0],
      "--syntax", "pascaligo",
      "main", # router name
      "Add(record a=1;b=2 end)",
      "record ret = 100; end"
    ]
    reg_ret = /ret -> (\d+)/.exec res
    return on_end new Error "!reg_ret #{res}" if !reg_ret
    [_skip, value] = reg_ret
    
    assert.strictEqual +value, 3
    
    on_end()
