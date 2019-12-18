pragma solidity ^0.5.0;

library stringUtils {

    function stringToUint(string memory str) public view returns(uint) {
        bytes memory strBytes = bytes(str);
        uint res = 0;
        uint pow = 10;
        bytes4 temp;
        
        for(uint i = 0; i < strBytes.length; i++) {
            res *= pow;
            temp = bytes4(strBytes[i]) >> 24;
            res += uint32(temp)-48;
        }
        return res;
    }

    function stringCompare (string memory str1, string memory str2) public view returns (bool isSame) {
      if(keccak256(bytes(str1)) == keccak256(bytes(str2))) {
         isSame = true;
      }
   }

   function stringLen(string memory str) public view returns (uint) {
      return bytes(str).length;
   }

   function stringConcat(string memory str1, string memory str2) public view returns (string memory) {
       bytes memory str_1 = bytes(str1);
       bytes memory str_2 = bytes(str2);
       bytes memory str_b = new bytes(str_1.length + str_2.length);
       uint i = 0;
       uint j = 0;
       
       while (i < str_1.length) {
           str_b[j++] = str_1[i++];
       }
       
       i=0;
       
       while (i < str_2.length) {
           str_b[j++] = str_2[i++];
       }
       return string(str_b);
   }
}
