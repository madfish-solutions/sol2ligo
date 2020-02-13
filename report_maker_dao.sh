#!/bin/bash
./manual_test.coffee --full --file ./solidity_samples/maker_dao/fab.sol     --print --ligo > maker_dao_fab.log 2>&1
./manual_test.coffee --full --file ./solidity_samples/maker_dao/mom.sol     --print --ligo > maker_dao_mom.log 2>&1
./manual_test.coffee --full --file ./solidity_samples/maker_dao/pit.sol     --print --ligo > maker_dao_pit.log 2>&1
./manual_test.coffee --full --file ./solidity_samples/maker_dao/tap.sol     --print --ligo > maker_dao_tap.log 2>&1
./manual_test.coffee --full --file ./solidity_samples/maker_dao/top.sol     --print --ligo > maker_dao_top.log 2>&1
./manual_test.coffee --full --file ./solidity_samples/maker_dao/tub.sol     --print --ligo > maker_dao_tub.log 2>&1
./manual_test.coffee --full --file ./solidity_samples/maker_dao/vox.sol     --print --ligo > maker_dao_vox.log 2>&1
./manual_test.coffee --full --file ./solidity_samples/maker_dao/weth9.sol   --print --ligo > maker_dao_weth9.log 2>&1

