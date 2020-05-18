return if !process.env.EMULATOR
describe "emulator section", ()->
  @timeout 10000
  it "free", (done)->
    global.__sandbox_proc.kill()
    done()
  
