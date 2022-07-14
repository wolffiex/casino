pragma solidity >=0.8;

contract CasinoProp {
    struct Prop {
        uint8 probability;
        Odds odds;
    }

    struct Odds {
        uint8 numerator;
        uint8 denominator;
    }
}

contract Casino is CasinoProp {
    event BetPlaced(address indexed author, uint256 amount);

    bytes32 public nonce;
    Prop[] public props;
    Odds max_payout;

    constructor(bytes32 _nonce, Prop[] memory _props) {
        max_payout = Odds({numerator: 0, denominator: 0});
        nonce = _nonce;
        Prop memory don = Prop({
            probability: 127,
            odds: Odds({numerator: 2, denominator: 1})
        });
        props.push(don);
        for (uint256 i = 0; i < _props.length; i++) {
            uint256 test_amount = 10000;
            Odds memory odds = _props[i].odds;
            if (
                calculateReturn(test_amount, odds) >
                calculateReturn(test_amount, max_payout)
            ) {
                max_payout = odds;
            }
            props.push(_props[i]);
        }
    }

    function calculateReturn(uint256 amount, Odds memory odds)
        internal
        pure
        returns (uint256)
    {
        if (odds.numerator == 0) return 0;
        return (amount / odds.denominator) * odds.numerator;
    }

    function bet(string memory signed) public payable {
        emit BetPlaced(msg.sender, msg.value);
        //_value = string(abi.encodePacked(value , "d"));
        // _value = value;
    }

    function getProps() public view returns (Prop[] memory) {
        Prop[] memory m_props = new Prop[](props.length);
        for (uint256 i = 0; i < props.length; i++) {
            m_props[i] = props[i];
        }
        return m_props;
    }
}
