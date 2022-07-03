pragma solidity >=0.4.24;

contract Casino {

    event BetPlaced(address indexed author, uint amount);

    bytes32 public nonce;

    constructor(bytes32 _nonce) {
       nonce = _nonce;
    }

    function bet(string memory signed) payable public {
        emit BetPlaced(msg.sender, msg.value);
        //_value = string(abi.encodePacked(value , "d"));
        // _value = value;
    }
}
