return if !process.env.EMULATOR
require "fy"
fs = require "fs"
{
  spawn
  exec
  execSync
} = require "child_process"

truffle_config      = require "@truffle/config"
truffle_environment = require "@truffle/environment"
truffle_artifactor  = require "@truffle/artifactor"
truffle_resolver    = require "@truffle/resolver"

Promise.prototype.cb = (cb)->
  @catch (err)=>cb err
  @then (res)=>cb null, res

uid = 0
global.test_get_contract = (name, code, cb)->
  # we should use unique name equal to file name, so we patch code. Yes it can break code
  anon_name = "Test#{uid++}"
  code = code.split(name).join anon_name
  fs.writeFileSync "contracts/#{anon_name}.sol", code
  
  fs.writeFileSync "migrations/2_#{anon_name}.js", """
    var contract = artifacts.require(#{JSON.stringify anon_name})
    
    module.exports = function(deployer) {
      deployer.deploy(contract);
    }
    """
  
  await exec "./node_modules/.bin/truffle migrate", defer(err, stdout, stderr); return cb err if err
  p "stdout", stdout
  p "stderr", stderr
  
  config = truffle_config.default()
  await truffle_environment.Environment.detect(config).cb defer(err); return cb err if err
  config.artifactor = new truffle_artifactor("build")
  config.resolver   = new truffle_resolver config
  
  wrap_contract = config.resolver.require anon_name, config.contracts_build_directory
  await wrap_contract.deployed().cb defer(err, contract); return cb err if err
  cb null, contract

describe "emulator section", ()->
  it "init", (done)->
    @timeout 30000
    # https://developer.kyber.network/docs/Reserves-Ganache/
    execSync "rm -rf build"
    execSync "rm -rf db"
    execSync "rm -rf contracts/Test*.sol"
    execSync "rm -rf migrations/*Test*.js"
    global.__sandbox_proc = spawn "./node_modules/.bin/ganache-cli", [
      "--db", "db"
      "--accounts", "10"
      "--defaultBalanceEther", "1000",
      "--mnemonic", "gesture rather obey video awake genuine patient base soon parrot upset lounge"
      "--networkId", "5777"
      "--port", "7545"
      "--debug"
    ]
    stdout = []
    ready = false
    global.__sandbox_proc.stdout.on "data", (data)->
      return if ready
      stdout.push data
      str = stdout.join ""
      if -1 != str.indexOf "Listening on 127.0.0.1:7545"
        ready = true
        puts "ganache is ready"
    
    puts "waiting until ganache would up"
    for i in [0 ... 300] # 300*100 = 30000 = 30 sec
      await setTimeout defer(), 100
      break if ready
    
    done()
  
  it "migrations", (on_end)->
    @timeout 30000
    await exec "./node_modules/.bin/truffle migrate", defer(err, stdout, stderr)
    p "stdout", stdout
    p "stderr", stderr
    
    on_end(err)
  