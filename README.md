# sol2ligo

Transpiler from Solidity to Ligo language for easier migrating to Tezos 🚀️

This project is Solidity to LIGO syntax converter and transpiler. It takes a `.sol` file as an input, parses it and yields PascalLIGO code as a result.
It is able to convert conditionals, loops, functions and many more. Also it can emulate state and create router for multple entrypoints.

The project is in _EXPERIMENTAL_: it may crash or silently skip some statements, resulting code may be insecure or even plain wrong. Please do not deploy anything without prior review and audit.

## 📖️ Example
Input solidity code

```solidity
contract FooBarContract {
  function foo(uint number) returns (int) {
    string[2] memory arr = ["hello", "world"];
    bool isEven = number % 2 == 0;
    int result = 42 * 42;
    return isEven ? -1 : result;
  }
}
```

Translated LIGO code
```js
type foo_args is record
  number : nat;
  callbackAddress : address;
end;

type state is unit;

type router_enum is
  | Foo of foo_args;

function foo (const number : nat) : (int) is
  block {
    const arr : map(nat, string) = map
      0n -> "hello";
      1n -> "world";
    end;
    const isEven : bool = ((number mod 2n) = 0n);
    const result : int = (42 * 42);
  } with ((case isEven of | True -> -(1) | False -> result end));

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Foo(match_action) -> block {
    const tmp : (int) = foo(match_action.number);
    var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(int))) end;
  } with ((opList, self))
  end);
```

### 📚️ More examples 
To further check out what this utility can produce, please refer to `examples` directory and Readme there:
https://github.com/madfish-solutions/sol2ligo/tree/pretty-ligo/examples


## 🏗️ Installation
You need to have NodeJS installed on your machine.
It was tested and developed using NodeJS v.10.13.0, but it’s expected to work on versions starting from v6.x.x up to v12.x.x

We suggest using node version manger (like [nvm](https://github.com/nvm-sh/nvm))
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
# relogin or source ~/.bashrc
nvm i 12
```

To try it out you will need Node.js, NPM and Iced Coffee Script

```sh
npm i -g iced-coffee-script
npm i -g madfish-solutions/sol2ligo
```

Optional. You can install ligo compiler for tests

```
curl -o /tmp/ligo.deb https://ligolang.org/deb/ligo.deb
dpkg -i /tmp/ligo.deb
```

## 🌈️ Usage

```sh
sol2ligo <filename>
```

After transpiling you are likely gonna need to modify and thorougly audit the generated code. Follow transpiler warnings and comments inside the code to get more insight on what has to be done.

## 🏥️ Tests
You need clone github repository and install packages
```
git clone https://github.com/madfish-solutions/sol2ligo
cd sol2ligo
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
MIT
