pragma solidity ^0.5.0;
pragma experimental "ABIEncoderV2";

contract Arrays {

    uint[3] fixedSimpleArr;  // fixed sized array
    uint[] simpleDynamicArr; // dynamic array
    uint[3][3] fixedSized;   // fixed sized 2D array
    uint[][3] arrayDynamic;  // dynamic array with each element an array with 3
    uint[3][] dynamicArray;  // fixed sized array with each element a dynamic
    uint[][] dynamicArr;    // dynamic array with dynamic array elemnts.
    uint[3][3][3] threeDArr;
    constructor () public {
      fixedSimpleArr = [1,2,3];
      uint j;
      for (uint i=0;i<3;i++){
          j = i+1;
          fixedSized[i] = [j*1, j*2, j*3];
      }
      uint[3] memory temp = [uint(1),2,3];
      arrayDynamic[0] = new uint[](4);
      arrayDynamic[1] = [1,2,3,4,5,6,7,8];
      arrayDynamic[2] = temp;
      dynamicArray = new uint[2][](3);
      dynamicArray = [[1,2], [6,7], [9,0]];
      threeDArr = [
          [[1,2,3], [4,5,6], [7,8,9]],
          [[10,11,12], [13,14,15], [16,17,18]],
          [[19,20,21], [22,23,24], [25,26,27]]
      ];
    }

    function setFixedSimpleArr(uint[3] memory simpleArr) public {
      fixedSimpleArr = simpleArr;
    }

   // This function is illegal
    function setSimpleDynamicArr(uint[] memory simpleArr) public {
      simpleDynamicArr = simpleArr;
    }

    function setFixedSized(uint[3][3] memory inputArr) public {
        fixedSized = inputArr;
    }

    function setDynamicArray(uint[3][] memory inputArr) public {
        dynamicArray = inputArr;
    }

    // This function is illegal
    function setArrayDynamic(uint[][3] memory inputArr) public {
        arrayDynamic = inputArr;
    }

    // This function is illegal
    function setDynamicArr(uint[][] memory inputArr) public {
        dynamicArr = inputArr;
    }

    function setThreeDArr(uint[3][3][3] memory inputArr) public {
        threeDArr = inputArr;
    }

    function getFixedSimpleArr() public view returns (uint[3] memory) {
      return fixedSimpleArr;
    }

    function getSimpleDynamicArr() public view returns (uint[] memory) {
      return simpleDynamicArr;
    }

    function getFixedSized() public view returns (uint[3][3] memory) {
        return fixedSized;
    }

    function getDynamicArray() public view returns (uint[3][] memory) {
        return dynamicArray;
    }

    // This function is illegal
    function getArrayDynamic() public view returns (uint[][3] memory) {
        return arrayDynamic;
    }

    // This function is illegal
    function getDynamicArr() public view returns (uint[][] memory) {
        return dynamicArr;
    }

    function getThreeDArr() public view returns (uint[3][3][3] memory) {
        return threeDArr;
    }

    function getElementFixedSimpleArr(uint i) public view returns (uint) {
      return fixedSimpleArr[i];
    }

    // This function is illegal
    function getElementSimpleDynamicArr(uint i) public view returns (uint) {
      return simpleDynamicArr[i];
    }

    function getElementFixedSized(uint i, uint j) public view returns (uint) {
      return fixedSized[i][j];
    }

    function getElementDynamicArray(uint i, uint j) public view returns (uint) {
      return dynamicArray[i][j];
    }

    function getElementArrayDynamic(uint i, uint j) public view returns (uint) {
      return arrayDynamic[i][j];
    }

    function getElementDynamicArr(uint i, uint j) public view returns (uint) {
      return dynamicArr[i][j];
    }

    function getElementThreeDArr(uint i, uint j, uint k) public view returns (uint) {
        return threeDArr[i][j][k];
    }
}
