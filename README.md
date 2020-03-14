# sol2ligo

Transpiler from Solidity to Ligo language for easier migrating to Tezos 🚀️

This project is Solidity to LIGO syntax converter and transpiler. It takes a `.sol` file as an input, parses it and yields PascalLIGO code as a result.
It is able to convert conditionals, loops, functions and many more. Also it can emulate state and create router for multple entrypoints.

The project is in _EXPERIMENTAL_: it may crash or silently skip some statements, resulting code may be insecure or even plain wrong. Please do not deploy anything without prior review and audit.

## 📖️ Example
Input solidity code

```solidity
contract FooBarContract {
  function foo(uint number) internal returns (int) {
    string[2] memory arr = ["hello", "world"];
    bool isEven = number % 2 == 0;
    int result = 42 * 42;
    return isEven ? -1 : result;
  }
}
```

Translated LIGO code
```js
function foo (const self : state; const number : nat) : (state * int) is
  block {
    const arr : map(nat, string) = map
      0n -> "hello";
      1n -> "world";
    end;
    const isEven : bool = ((number mod 2n) = 0n);
    const result : int = (42 * 42);
  } with (self, (case isEven of | True -> -(1) | False -> result end));
```

### 📚️ More examples 
To further check out what this utility can produce, please refer to `examples` directory and Readme there:
https://github.com/madfish-solutions/sol2ligo/tree/pretty-ligo/examples


## 🏗️ Installation
To try it out you will need Node.js, NPM and Iced Coffee Script

```sh
npm i -g iced-coffee-script
npm i -g madfish-solutions/sol2ligo
```

## 🌈️ Usage

```sh
sol2ligo <filename>
```

After transpiling you are likely gonna need to modify and thorougly audit the generated code. Follow transpiler warnings and comments inside the code to get more insight on what has to be done.

## 🏥️ Tests
In order to run tests you need to install dependecies first

```sh
npm i
```

For full test run
```sh
npm test 
```

For quick testing run
```sh
npm run test-ext-compiler-fast
```

To run specific test case
```sh
npm run test-specific <test-name>
```


## 📑️ Documentation
Check out [wiki](https://github.com/madfish-solutions/sol2ligo/wiki) for the knowledge base

## Licensing
TBD
