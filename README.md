# sol2ligo

Transpiler from Solidity to Ligo language for easier migrating to Tezos 🚀️

This project is Solidity to LIGO syntax converter and transpiler. It takes a `.sol` file as an input, parses it and yields PascalLIGO code as a result.
It is able to convert conditionals, loops, functions and many more. Also it can emulate state and create router for multple entrypoints.

The project is in _EXPERIMENTAL_: it may crash or silently skip some statements, resulting code may be insecure or even plain wrong. Please do not deploy anything without prior review and audit.

## 📖️ Example
Input solidity code

```solidity
pragma solidity ^0.5.11;

contract Coin {
    address minter;
    mapping (address => uint) balances;
    
    constructor() public {
        minter = msg.sender;
    }
    function mint(address owner, uint amount) public {
        if (msg.sender == minter) {
            balances[owner] += amount;
        }
    }
    function send(address receiver, uint amount) public {
        if (balances[msg.sender] >= amount) {
            balances[msg.sender] -= amount;
            balances[receiver] += amount;
        }
    }
    function queryBalance(address addr) public view returns (uint balance) {
        return balances[addr];
    }
}
```

Translated LIGO code
```js
type constructor_args is unit;
type mint_args is record
  owner : address;
  res__amount : nat;
end;

type send_args is record
  receiver : address;
  res__amount : nat;
end;

type queryBalance_args is record
  addr : address;
  callbackAddress : address;
end;

type state is record
  minter : address;
  balances : map(address, nat);
end;

type router_enum is
  | Constructor of constructor_args
 | Mint of mint_args
 | Send of send_args
 | QueryBalance of queryBalance_args;

function constructor (const self : state) : (state) is
  block {
    self.minter := Tezos.sender;
  } with (self);

function mint (const self : state; const owner : address; const res__amount : nat) : (state) is
  block {
    if (Tezos.sender = self.minter) then block {
      self.balances[owner] := ((case self.balances[owner] of | None -> 0n | Some(x) -> x end) + res__amount);
    } else block {
      skip
    };
  } with (self);

function send (const self : state; const receiver : address; const res__amount : nat) : (state) is
  block {
    if ((case self.balances[Tezos.sender] of | None -> 0n | Some(x) -> x end) >= res__amount) then block {
      self.balances[Tezos.sender] := abs((case self.balances[Tezos.sender] of | None -> 0n | Some(x) -> x end) - res__amount);
      self.balances[receiver] := ((case self.balances[receiver] of | None -> 0n | Some(x) -> x end) + res__amount);
    } else block {
      skip
    };
  } with (self);

function queryBalance (const self : state; const addr : address) : (nat) is
  block {
    const res__balance : nat = 0n;
  } with ((case self.balances[addr] of | None -> 0n | Some(x) -> x end));

function main (const action : router_enum; const self : state) : (list(operation) * state) is
  (case action of
  | Constructor(match_action) -> ((nil: list(operation)), constructor(self))
  | Mint(match_action) -> ((nil: list(operation)), mint(self, match_action.owner, match_action.res__amount))
  | Send(match_action) -> ((nil: list(operation)), send(self, match_action.receiver, match_action.res__amount))
  | QueryBalance(match_action) -> block {
    const tmp : (nat) = queryBalance(self, match_action.addr);
    var opList : list(operation) := list transaction((tmp), 0mutez, (get_contract(match_action.callbackAddress) : contract(nat))) end;
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
npm ci
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

## ⚒ Using sol2ligo as a node module

To add sol2ligo as a dependency, you need to install Iced Coffee Script first:
```sh
npm i -g iced-coffee-script
npm i madfish-solutions/sol2ligo
```
Then use `sol2ligo.compile` function like this:
```javascript
const sol2ligo = require("sol2ligo");

console.log(sol2ligo.compile(`
  pragma solidity ^0.5.12;
  
  contract FooBarContract {
    function foo(uint number) internal returns (int) {
      string[2] memory arr = ["hello", "world"];
      bool isEven = number % 2 == 0;
      int result = 42 * 42;
      return isEven ? -1 : result;
    }
  }`, {
    // you can specify compilation options here
  }));
```
The second argument `opt` is optional. It's an object that can have these possible fields:
```javascript
{
  solc_version: String,           //                            override solc version specified in pragma
  suggest_solc_version: String,   // (default: 0.4.26)          suggested solc version if pragma is not specified
  auto_version: Boolean,          // (default: true)            setting this to false disables reading solc version from pragma
  allow_download: Boolean,        // (default: true)            download solc catalog
  router: Boolean,                // (default: true)            generate router
  contract: String,               // (default: <last contract>) name of contract to generate router for
  replace_enums_by_nats: Boolean, // (default: true)            transform enums to number constants
  debug: Boolean                  // (default: false)           self explanatory
}
```
When deciding which Solidity compiler version to use, `solc_version` has the highest priority. If `solc_version` is not specified, `sol2ligo` uses solc version from the `pragma` directive in sol_code. If `pragma` is absent too, or if `auto_version` is set to `false`, `suggest_solc_version`, which has the least priority, will be used.

If `allow_download` is `false` and no necessary solc version is found in the solc catalog, compilation fails with an error.

The function returns an object with the following fields:
```javascript
{
  errors: Array,
  warnings: Array,
  ligo_code: String,
  default_state: String,
  prevent_deploy: Boolean
}
```

## 📑️ Documentation
Check out [wiki](https://github.com/madfish-solutions/sol2ligo/wiki) for the knowledge base

## Licensing
MIT
