translate_ligo = require "../src/translate_ligo"

describe "finalize", ()->
  it "warning_counter", ()->
    puts "warning_counter = #{translate_ligo.warning_counter}"