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

    struct Bet {
        address payable bettor;
        uint256 amount;
    }

    struct Signed {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}

contract Casino is CasinoProp {
    event BetPlaced(Bet bet);
    event BetResolved(uint8 result, Bet bet, Prop prop, uint256 payout);
    event Blem(uint a, uint b);

    address bank;
    bytes32 public nonce;
    Prop[] public props;
    Odds max_payout;
    enum Phase {
        Betting,
        Banking
    }

    Phase public phase;
    Bet pending_bet;

    constructor(bytes32 _nonce, Prop[] memory _props) payable {
        require(msg.value > 0, "Casino must be funded");
        bank = msg.sender;
        max_payout = Odds({numerator: 0, denominator: 0});
        nonce = _nonce;
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
        if (odds.numerator == 0 || odds.denominator == 0) return 0;
        return (amount / odds.denominator) * odds.numerator;
    }

    function placeBet(Signed memory signed) public payable {
        uint256 amount = msg.value;
        require(phase == Phase.Betting, "Awaiting bank");
        require(amount > 0, "Gotta have skin in the game");
        require(
            calculateReturn(amount, max_payout) < address(this).balance,
            "Can't pay winners"
        );
        address signer = ecrecover(nonce, signed.v, signed.r, signed.s);
        require(signer == msg.sender, "Bad signature");
        phase = Phase.Banking;
        nonce = keccak256(abi.encode(signed));
        pending_bet = Bet({
            bettor: payable(msg.sender),
            amount: amount
        });
        emit BetPlaced(pending_bet);
    }

    function resolveBet(Signed memory signed) public payable {
        require(phase == Phase.Banking, "Awaiting bet");
        address signer = ecrecover(nonce, signed.v, signed.r, signed.s);
        require(signer == bank, "Bad signature");
        nonce = keccak256(abi.encode(signed));
        uint8 result = reduceToUint(nonce);
        uint8 ptr = 0;
        Prop memory matched_prop;
        for (uint i=0; i < props.length; i++) {
            Prop memory p = props[i];
            ptr += p.probability;
            if (result < ptr) {
                matched_prop = p;
                break;
            }
            
        }
        uint256 payout = calculateReturn(pending_bet.amount, matched_prop.odds);
        if (payout > 0) { 
            bool sent = pending_bet.bettor.send(payout);
            require(sent, "Unable to pay bettor");
        }
        emit BetResolved(result, pending_bet, matched_prop, payout);
        phase = Phase.Betting;
    }

    function reduceToUint(bytes32 a) public returns (uint8){
        uint result = 0;
        for (uint i=0; i < 32; i++) {
            uint8 bite = uint8(a[i]);
            emit Blem(result, bite);
            result = (result + bite) % 100;
        }
        return uint8(result);
    }
}
