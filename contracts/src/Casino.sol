pragma solidity >=0.8;

contract CasinoProp {
    struct Prop { 
        uint8 probability;
        Odds odds;
    }

    struct Odds { 
        uint8 mult;
        uint8 div;
    }
}

contract Casino is CasinoProp{


    event BetPlaced(address indexed author, uint amount);

    bytes32 public nonce;
    Prop[] public props;
    Odds max_payout;

    constructor(bytes32 _nonce, Prop[] memory _props) {
        max_payout = Odds({
            mult: 0,
            div: 0
        });
        nonce = _nonce;
        Prop memory don = Prop({
            probability : 127,
            odds : Odds({
                mult: 2,
                div: 0
            })
        });
        props.push(don);
        for (uint i=0; i < _props.length; i++) {
            Odds memory odds = _props[i].odds;
            if (odds.mult < max_payout.mult || (
                odds.mult == max_payout.mult && odds.div < max_payout.div
            )) {
                max_payout = odds;
            }
            props.push(_props[i]);
        }
    }

    function bet(string memory signed) payable public {
        emit BetPlaced(msg.sender, msg.value);
        //_value = string(abi.encodePacked(value , "d"));
        // _value = value;
    }

    function getProps() public view returns (Prop[] memory) {
        Prop[] memory m_props = new Prop[](props.length);
        for (uint i = 0; i < props.length; i++) {
            m_props[i] = props[i];
        }
        return m_props;
    }
}
