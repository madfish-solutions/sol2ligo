type token_id is nat

type transfer_destination is
  record [token_id : token_id; to_ : address; amount : nat]

type transfer_destination_michelson is
  michelson_pair_right_comb (transfer_destination)

type transfer is
  record [txs : list (transfer_destination); from_ : address
  ]

type transfer_aux is
  record [
    txs : list (transfer_destination_michelson);
    from_ : address
  ]

type transfer_michelson is
  michelson_pair_right_comb (transfer_aux)

type balance_of_request is
  record [token_id : token_id; owner : address]

type balance_of_request_michelson is
  michelson_pair_right_comb (balance_of_request)

type balance_of_response is
  record [request : balance_of_request; balance : nat]

type balance_of_response_aux is
  record [
    request : balance_of_request_michelson;
    balance : nat
  ]

type balance_of_response_michelson is
  michelson_pair_right_comb (balance_of_response_aux)

type balance_of_param is
  record [
    requests : list (balance_of_request);
    callback :
      contract (list (balance_of_response_michelson))
  ]

type balance_of_param_aux is
  record [
    requests : list (balance_of_request_michelson);
    callback :
      contract (list (balance_of_response_michelson))
  ]

type balance_of_param_michelson is
  michelson_pair_right_comb (balance_of_param_aux)

type operator_param is
  record [owner : address; operator : address]

type operator_param_michelson is
  michelson_pair_right_comb (operator_param)

type update_operator is
    Remove_operator_p of operator_param
  | Add_operator_p of operator_param

type update_operator_aux is
    Remove_operator of operator_param_michelson
  | Add_operator of operator_param_michelson

type update_operator_michelson is
  michelson_or_right_comb (update_operator_aux)

type token_metadata is
  record [
    token_id : token_id;
    symbol : string;
    name : string;
    extras : map (string, string);
    decimals : nat
  ]

type token_metadata_michelson is
  michelson_pair_right_comb (token_metadata)

type token_metadata_param is
  record [
    token_ids : list (token_id);
    handler : list (token_metadata_michelson)
  ]

type token_metadata_param_michelson is
  michelson_pair_right_comb (token_metadata_param)

type fa2_entry_points is
    Update_operators of list (update_operator_michelson)
  | Transfer of list (transfer_michelson)
  | Token_metadata_registry of contract (address)
  | Balance_of of balance_of_param_michelson

type fa2_token_metadata is
  Token_metadata of token_metadata_param_michelson

type operator_transfer_policy is
    Owner_transfer of unit
  | Owner_or_operator_transfer of unit | No_transfer of unit

type operator_transfer_policy_michelson is
  michelson_or_right_comb (operator_transfer_policy)

type owner_hook_policy is
    Required_owner_hook of unit | Owner_no_hook of unit
  | Optional_owner_hook of unit

type owner_hook_policy_michelson is
  michelson_or_right_comb (owner_hook_policy)

type custom_permission_policy is
  record [tag : string; config_api : option (address)]

type custom_permission_policy_michelson is
  michelson_pair_right_comb (custom_permission_policy)

type permissions_descriptor is
  record [
    sender : owner_hook_policy;
    receiver : owner_hook_policy;
    operator : operator_transfer_policy;
    custom : option (custom_permission_policy)
  ]

type permissions_descriptor_aux is
  record [
    sender : owner_hook_policy_michelson;
    receiver : owner_hook_policy_michelson;
    operator : operator_transfer_policy_michelson;
    custom : option (custom_permission_policy_michelson)
  ]

type permissions_descriptor_michelson is
  michelson_pair_right_comb (permissions_descriptor_aux)

type transfer_destination_descriptor is
  record [
    token_id : token_id;
    to_ : option (address);
    amount : nat
  ]

type transfer_destination_descriptor_michelson is
  michelson_pair_right_comb
    (transfer_destination_descriptor)

type transfer_descriptor is
  record [
    txs : list (transfer_destination_descriptor);
    from_ : option (address)
  ]

type transfer_descriptor_aux is
  record [
    txs : list (transfer_destination_descriptor_michelson);
    from_ : option (address)
  ]

type transfer_descriptor_michelson is
  michelson_pair_right_comb (transfer_descriptor_aux)

type transfer_descriptor_param is
  record [
    operator : address;
    batch : list (transfer_descriptor)
  ]

type transfer_descriptor_param_aux is
  record [
    operator : address;
    batch : list (transfer_descriptor_michelson)
  ]

type transfer_descriptor_param_michelson is
  michelson_pair_right_comb (transfer_descriptor_param_aux)
