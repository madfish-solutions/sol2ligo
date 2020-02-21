# sol2ligo

Transpiler from Solidity to Ligo language

This project is Solidity to LIGO syntax converter and transpiler. It takes `.sol` file as an input, parses it and yields PascalLIGO code as a result.
It converts conditionals, loops, functions and many more. Also it can emulate state and create router for multple entrypoints.

The project is in _EXPERIMENTAL_: it may crash or silently skip some statements, resulting code may be insecure or even plain wrong. Please do not deploy anything without prior review and audit.

# Example
Solidity code
```solidity
pragma solidity ^0.5.0;
    
contract IsNegative {
  function isNegative() public returns (string) {
    int i = -1;
    return i < 0 ? "yes" : "no";
  }
}
```
Transpiled LIGO code
```js
function isNegative (const opList : list(operation); const self : state) :
  (list(operation) * state * string) is 
  block {
    const i : int = -(1);
  } with (opList, self, (case (i < 0) of | True -> "yes" | False -> "no" end));
```

# Installation

```sh
npm i -g iced-coffee-script
npm i -g madfish-solutions/sol2ligo
```

# Usage

```sh
sol2ligo <filename>
```

# Tests
For full test run
```sh
npm test 
```

For quick test run
```sh
npm run test-ext-compiler-fast
```

To run specific test case
```sh
npm run test-specific <test-name>
```


# Documentation
Check out [wiki](https://github.com/madfish-solutions/sol2ligo/wiki) for knowledge base

# Licensing
TBD
