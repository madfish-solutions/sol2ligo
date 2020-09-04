(function() {
  var i, v, _i, _j, _k, _l, _len, _len1, _len2, _len3, _m, _n, _o, _ref, _ref1, _ref2, _ref3;

  


  /*
  TODO rename
    storage           -> storage_type_str
    contract_storage  -> storage_var_name
   */

  this.storage = "state";

  this.contract_storage = "self";

  this.receiver_name = "receiver";

  this.callback_address = "callbackAddress";

  this.default_address = "tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg";

  this.burn_address = "tz1ZZZZZZZZZZZZZZZZZZZZZZZZZZZZNkiRg";

  this.empty_state = "reserved__empty_state";

  this.op_list = "opList";

  this.fix_underscore = "fx";

  this.reserved = "res";

  this.router_enum = "router_enum";

  this.int_type_list = ["int"];

  for (i = _i = 8; _i <= 256; i = _i += 8) {
    this.int_type_list.push("int" + i);
  }

  this.uint_type_list = ["uint"];

  for (i = _j = 8; _j <= 256; i = _j += 8) {
    this.uint_type_list.push("uint" + i);
  }

  this.any_int_type_list = [];

  this.any_int_type_list.append(this.int_type_list);

  this.any_int_type_list.append(this.uint_type_list);

  this.bytes_type_list = ["bytes"];

  for (i = _k = 1; _k <= 32; i = ++_k) {
    this.bytes_type_list.push("bytes" + i);
  }

  this.int_type_map = {};

  _ref = this.int_type_list;
  for (_l = 0, _len = _ref.length; _l < _len; _l++) {
    v = _ref[_l];
    this.int_type_map[v] = true;
  }

  this.uint_type_map = {};

  _ref1 = this.uint_type_list;
  for (_m = 0, _len1 = _ref1.length; _m < _len1; _m++) {
    v = _ref1[_m];
    this.uint_type_map[v] = true;
  }

  this.any_int_type_map = {};

  _ref2 = this.any_int_type_list;
  for (_n = 0, _len2 = _ref2.length; _n < _len2; _n++) {
    v = _ref2[_n];
    this.any_int_type_map[v] = true;
  }

  this.bytes_type_map = {};

  _ref3 = this.bytes_type_list;
  for (_o = 0, _len3 = _ref3.length; _o < _len3; _o++) {
    v = _ref3[_o];
    this.bytes_type_map[v] = true;
  }

}).call(window.require_register("./config"));
