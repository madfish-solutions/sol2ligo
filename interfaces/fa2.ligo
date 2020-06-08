type token_id is nat

type transfer_destination is record [
  to_ : address;
  token_id : token_id;
  amount : nat;
]

type transfer_destination_michelson is transfer_destination

type transfer is record [
  from_ : address;
  txs : transfer_destination list;
]

type transfer_aux is record [
  from_ : address;
  txs : transfer_destination_michelson list;
]

type transfer_michelson is transfer_aux

type balance_of_request is record [
  owner : address;
  token_id : token_id;
]

type balance_of_request_michelson is balance_of_request

type balance_of_response is record [
  request : balance_of_request;
  balance : nat;
]

type balance_of_response_aux is record [
  request : balance_of_request_michelson;
  balance : nat;
]

type balance_of_response_michelson is balance_of_response_aux

type balance_of_param is record [
  requests : balance_of_request list;
  callback : (balance_of_response_michelson list) contract;
]

type balance_of_param_aux is record [
  requests : balance_of_request_michelson list;
  callback : (balance_of_response_michelson list) contract;
]

type balance_of_param_michelson is balance_of_param_aux

type total_supply_response is record [
  token_id : token_id;
  total_supply : nat;
]

type total_supply_response_michelson is total_supply_response

type total_supply_param is record [
  token_ids : token_id list;
  callback : (total_supply_response_michelson list) contract;
]

type total_supply_param_michelson is total_supply_param

type token_metadata is record [
  token_id : token_id;
  symbol : string;
  name : string;
  decimals : nat;
  extras : (string, string) map;
]

type token_metadata_michelson is token_metadata

type token_metadata_param is record [
  token_ids : token_id list;
  callback : (token_metadata_michelson list) contract;
]

type token_metadata_param_michelson is token_metadata_param

type operator_param is record [
  owner : address;
  operator : address;
]

type operator_param_michelson is operator_param

type update_operator is
  | Add_operator_p of operator_param
  | Remove_operator_p of operator_param

type update_operator_aux is
  | Add_operator of operator_param_michelson
  | Remove_operator of operator_param_michelson

type update_operator_michelson is update_operator_aux michelson_or_right_comb

type is_operator_response is record [
  operator : operator_param;
  is_operator : bool;
]

type is_operator_response_aux is record [
  operator : operator_param_michelson;
  is_operator : bool;
]

type is_operator_response_michelson is is_operator_response_aux

type is_operator_param is record [
  operator : operator_param;
  callback : (is_operator_response_michelson) contract;
]

type is_operator_param_aux is record [
  operator : operator_param_michelson;
  callback : (is_operator_response_michelson) contract;
]

type is_operator_param_michelson is is_operator_param_aux

(* permission policy definition *)

type operator_transfer_policy is
  | No_transfer
  | Owner_transfer
  | Owner_or_operator_transfer

type operator_transfer_policy_michelson is operator_transfer_policy michelson_or_right_comb

type owner_hook_policy is
  | Owner_no_hook
  | Optional_owner_hook
  | Required_owner_hook

type owner_hook_policy_michelson is owner_hook_policy michelson_or_right_comb

type custom_permission_policy is record [
  tag : string;
  config_api: address option;
]

type custom_permission_policy_michelson is custom_permission_policy

type permissions_descriptor is record [
  operator : operator_transfer_policy;
  receiver : owner_hook_policy;
  sender : owner_hook_policy;
  custom : custom_permission_policy option;
]

type permissions_descriptor_aux is record [
  operator : operator_transfer_policy_michelson;
  receiver : owner_hook_policy_michelson;
  sender : owner_hook_policy_michelson;
  custom : custom_permission_policy_michelson option;
]

type permissions_descriptor_michelson is permissions_descriptor_aux

type fa2_entry_points is
  | Transfer of transfer_michelson list
  | Balance_of of balance_of_param_michelson
  | Total_supply of total_supply_param_michelson
  | Token_metadata of token_metadata_param_michelson
  | Permissions_descriptor of permissions_descriptor_michelson contract
  | Update_operators of update_operator_michelson list
  | Is_operator of is_operator_param_michelson


type transfer_destination_descriptor is record [
  to_ : address option;
  token_id : token_id;
  amount : nat;
]

type transfer_destination_descriptor_michelson is
  transfer_destination_descriptor

type transfer_descriptor is record [
  from_ : address option;
  txs : transfer_destination_descriptor list
]

type transfer_descriptor_aux is record [
  from_ : address option;
  txs : transfer_destination_descriptor_michelson list
]

type transfer_descriptor_michelson is transfer_descriptor_aux

type transfer_descriptor_param is record [
  fa2 : address;
  batch : transfer_descriptor list;
  operator : address;
]

type transfer_descriptor_param_aux is record [
  fa2 : address;
  batch : transfer_descriptor_michelson list;
  operator : address;
]

type transfer_descriptor_param_michelson is transfer_descriptor_param_aux

type fa2_token_receiver is
  | Tokens_received of transfer_descriptor_param_michelson

type fa2_token_sender is
  | Tokens_sent of transfer_descriptor_param_michelson