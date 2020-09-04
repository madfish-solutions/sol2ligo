(function() {
  var bad_spec_id_trans_map, config, reserved_map, spec_id_trans_map, warning_once_map;

  config = require("./config");

  reserved_map = {
    "get_force": true,
    "get_chain_id": true,
    "transaction": true,
    "get_contract": true,
    "get_entrypoint": true,
    "size": true,
    "abs": true,
    "is_nat": true,
    "amount": true,
    "balance": true,
    "now": true,
    "unit": true,
    "source": true,
    "sender": true,
    "failwith": true,
    "bitwise_or": true,
    "bitwise_and": true,
    "bitwise_xor": true,
    "bitwise_lsl": true,
    "bitwise_lsr": true,
    "Bitwise": true,
    "string_concat": true,
    "string_slice": true,
    "crypto_check": true,
    "crypto_map_key": true,
    "bytes_concat": true,
    "bytes_slice": true,
    "bytes_pack": true,
    "bytes_unpack": true,
    "set_empty": true,
    "set_mem": true,
    "set_add": true,
    "set_remove": true,
    "set_iter": true,
    "set_fold": true,
    "list_iter": true,
    "list_fold": true,
    "list_map": true,
    "map_iter": true,
    "map_map": true,
    "map_fold": true,
    "map_remove": true,
    "map_update": true,
    "map_get": true,
    "map_mem": true,
    "sha_256": true,
    "sha_512": true,
    "blake2b": true,
    "cons": true,
    "EQ": true,
    "NEQ": true,
    "NEG": true,
    "ADD": true,
    "SUB": true,
    "TIMES": true,
    "DIV": true,
    "MOD": true,
    "NOT": true,
    "AND": true,
    "OR": true,
    "GT": true,
    "GE": true,
    "LT": true,
    "LE": true,
    "CONS": true,
    "self_address": true,
    "implicit_account": true,
    "set_delegate": true,
    "to": true,
    "args": true,
    "main": true,
    "Tezos": true,
    "map": true,
    "some": true
  };

  reserved_map[config.contract_storage] = true;

  reserved_map[config.op_list] = true;

  this.translate_var_name = function(name, ctx) {
    if (name[0] === "_") {
      name = name.replace("_", "") + "_";
    }
    name = name[0].toLowerCase() + name.substr(1);
    if (name.startsWith("@")) {
      return name.substr(1);
    } else if (reserved_map.hasOwnProperty(name)) {
      return "" + config.reserved + "__" + name;
    } else {
      return name;
    }
  };

  spec_id_trans_map = {
    "now": "abs(now - (\"1970-01-01T00:00:00Z\": timestamp))",
    "msg.sender": "sender",
    "tx.origin": "source",
    "block.timestamp": "abs(now - (\"1970-01-01T00:00:00Z\": timestamp))",
    "msg.value": "(amount / 1mutez)",
    "abi.encodePacked": ""
  };

  bad_spec_id_trans_map = {
    "block.coinbase": "(" + (JSON.stringify(config.default_address)) + " : address)",
    "block.difficulty": "0n",
    "block.gaslimit": "0n",
    "block.number": "0n",
    "msg.data": "(\"00\": bytes)",
    "msg.gas": "0n",
    "msg.sig": "(\"00\": bytes)",
    "tx.gasprice": "0n"
  };

  warning_once_map = {};

  this.spec_id_translate = function(t, name) {
    var val;
    if (spec_id_trans_map.hasOwnProperty(t)) {
      return spec_id_trans_map[t];
    } else if (bad_spec_id_trans_map.hasOwnProperty(t)) {
      val = bad_spec_id_trans_map[t];
      if (!warning_once_map.hasOwnProperty(t)) {
        warning_once_map.hasOwnProperty[t] = true;
        perr("WARNING (translate). We don't have a proper translation for Solidity '" + t + "', so it is translated as '" + val + "'");
      }
      return val;
    } else {
      return name;
    }
  };

}).call(window.require_register("./translate_var_name"));
