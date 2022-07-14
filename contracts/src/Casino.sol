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

    struct Signed {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}

contract Casino is CasinoProp {
    event BetPlaced(address indexed author, uint256 amount);

    address bank;
    bytes32 public nonce;
    Prop[] public props;
    Odds max_payout;

    constructor(bytes32 _nonce, Prop[] memory _props) payable {
        require(msg.value > 0, "Casino must be funded");
        bank = msg.sender;
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

    function placeBet(Signed memory signed) public payable {
        uint256 amount = msg.value;
        require(amount > 0, "Gotta have skin in the game");
        require(
            calculateReturn(amount, max_payout) < address(this).balance,
            "Can't pay winners"
        );
        address signer = ecrecover(nonce, signed.v, signed.r, signed.s);
        emit BetPlaced(msg.sender, msg.value);
        require(signer == msg.sender, "Bad signature");
    }

    function getProps() public view returns (Prop[] memory) {
        Prop[] memory m_props = new Prop[](props.length);
        for (uint256 i = 0; i < props.length; i++) {
            m_props[i] = props[i];
        }
        return m_props;
    }
}
