pragma solidity >=0.8.0;

contract Oracle {

    function get(bytes calldata data) external pure returns (bool success, uint256 exchangeRate) {
        success = true;
        exchangeRate = 42069;
    }     
}
