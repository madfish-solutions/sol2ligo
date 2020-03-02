#!/bin/sh

mkdir -p examples
for filename in solidity_samples/popular/*.sol
do
  ./manual_test.coffee --full --file $filename --print > examples/$(basename $filename .sol).ligo
done