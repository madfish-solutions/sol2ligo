(function() {
  var config, module;

  module = this;

  config = require("./config");

  this.type_generalize = function(type) {
    if (config.uint_type_list.has(type)) {
      type = "uint";
    }
    if (config.int_type_list.has(type)) {
      type = "int";
    }
    if (config.bytes_type_list.has(type)) {
      type = "bytes";
    }
    return type;
  };

}).call(window.require_register("./type_generalize"));
