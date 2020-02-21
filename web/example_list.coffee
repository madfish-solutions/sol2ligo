window.example_list = [
  {
    title : '--- select example ---'
    code : ''
  }
  {
    title : 'int arithmetic'
    code : '''
    pragma solidity ^0.5.11;
    
    contract Arith {
      int public value;
      
      function arith() public returns (int yourMom) {
        int a = 0;
        int b = 0;
        int c = 0;
        c = -c;
        c = a + b;
        c = a - b;
        c = a * b;
        c = a / b;
        return c;
      }
    }
    '''
  }
  {
    title : 'uint arithmetic'
    code : '''
    pragma solidity ^0.5.11;
    
    contract Arith {
      uint public value;
      
      function arith() public returns (uint yourMom) {
        uint a = 0;
        uint b = 0;
        uint c = 0;
        c = a + b;
        c = a * b;
        c = a / b;
        c = a | b;
        c = a & b;
        c = a ^ b;
        return c;
      }
    }
    '''
  }
  {
    title : '--- control flow ---'
    code : ''
  }
  {
    title : 'if'
    code  : '''
    pragma solidity ^0.5.11;
    
    contract Ifer {
      uint public value;
      
      function ifer() public returns (uint) {
        uint x = 6;

        if (x == 5) {
            x += 1;
        }
        else {
            x += 10;
        }

        return x;
      }
    }
    '''
  }
  {
    title : 'for'
    code  : '''
    pragma solidity ^0.5.11;
    
    contract Forer {
      uint public value;
      
      function forer() public returns (uint yourMom) {
        uint y = 0;
        for (uint i=0; i<5; i+=1) {
            y += 1;
        }
        return y;
      }
    } 
    '''
  }
  {
    title : 'while'
    code  : '''
    pragma solidity ^0.5.11;
    
    contract Whiler {
      uint public value;
      
      function whiler() public returns (uint yourMom) {
        uint y = 0;
        while (y != 2) {
            y += 1;
        }
        return y;
      }
    } 
    '''
  }
  {
    title : '--- function capabilities ---'
    code : ''
  }
  {
    title : 'fn call'
    code : '''
    pragma solidity ^0.5.11;
    
    contract Fn_call {
      int public value;
      
      function fn1(int a) public returns (int yourMom) {
        value += 1;
        return a;
      }
      function fn2() public returns (int yourMom) {
        fn1(1);
        int res = 1;
        return res;
      }
    }
    '''
  }
  {
    title : '--- near-real examples ---'
    code : ''
  }
  {
    title : 'simplecoin'
    code : '''
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
    '''
  }
]