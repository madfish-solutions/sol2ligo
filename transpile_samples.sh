#!/bin/sh

mkdir -p examples
for filename in solidity_samples/popular/*.sol
do
  echo $(basename $filename .sol)
  ./manual_test.coffee --full --file $filename --print --contract $(basename $filename .sol) > examples/$(basename $filename .sol).ligo
done