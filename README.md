# sol2ligo

Transpiler from Solidity to Ligo language

This project is Solidity to LIGO syntax converter and transpiler. It takes `.sol` file as an input, parses it and yields PascalLIGO code as a result.
It converts conditionals, loops, functions and many more. Also it can emulate state and create router for multple entrypoints.

The project is in _EXPERIMENTAL_: it may crash or silently skip some statements, resulting code may be insecure or even plain wrong. Please do not deploy anything without prior review and audit.

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
