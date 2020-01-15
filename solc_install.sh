#!/bin/sh

TARGET_DIR=solc-bin/bin

mkdir -p $TARGET_DIR

curl https://raw.githubusercontent.com/ethereum/solc-bin/gh-pages/bin/list.js --output $TARGET_DIR/list.js

curl https://raw.githubusercontent.com/ethereum/solc-bin/gh-pages/bin/list.txt | grep commit | grep -v nightly |
  while IFS= read -r filename
  do
    echo downloading "$filename"
    curl https://raw.githubusercontent.com/ethereum/solc-bin/gh-pages/bin/$filename --output $TARGET_DIR/$filename
  done

curl https://raw.githubusercontent.com/ethereum/solc-bin/gh-pages/bin/soljson-latest.js --output $TARGET_DIR/soljson-latest.js
