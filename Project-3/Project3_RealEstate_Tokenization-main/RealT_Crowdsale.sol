pragma solidity ^0.5.0;

import "./RealT_Token.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/crowdsale/distribution/RefundableCrowdsale.sol";

/*
 * This contract creates a crowdsale for the tokens from the imported
 */
contract RealT_Sale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale {

    constructor(
        uint rate,
        address payable wallet,
        RealT token
        )
        
        /**
        * @dev The paraments of the constructor are
        * passed to this inherited function to create
        * a crowdsale.
        */
        Crowdsale(
            rate,
            wallet,
            token
            )
        
        /**
        * @dev The inherited function is being hardcoded
        * to cap the crowdsale at 3 Ether, a low amount
        * for test purposes.
        */
        CappedCrowdsale(
            3 ether
            )
        
        /**
        * @dev This inherited function is being hardcoded
        * with the open and close dates. It is set to 1 minute
        * for test purposes.
        */
        TimedCrowdsale(
            now,
            now + 1 minutes
            )
        
        /**
        * @dev This inherited function is being hardcoded
        * the amount of Ether that could be refunded. It is
        * set to be able to refund the amount it is capped at,
        * 3 Ether.
        */
        RefundableCrowdsale(
            3 ether
            )
        
        public
    {}
}

/**
 * @title RealT Sale Deployer
 * This contract serves to deploy both the NewCoin
 * and RealTCrowdsale contracts under a single
 * transaction.
 */
contract RealTSaleDeployer {

    address public tokenSaleAddress;
    address public tokenAddress;

    /**
    * @dev The parameters are accepted and passed to the
    * RealT and RealT_Sale contracts.
    * @param name a string saved to memory that is
    * the name of the token.
    * @param symbol a string saved to memory that is
    * the symbol (similar to a traditional stock ticker)
    * of the token.
    * @param wallet The main wallet that will have the newly
    * minted RealT.
    */
    constructor(
        string memory name,
        string memory symbol,
        address payable wallet
    )
        public
    {
        // Creating the RealT and saving it's address
        // to the previously declared tokenAddress variable.
        RealT token = new RealT(name, symbol);
        tokenAddress = address(token);
        
        // Creating the RealTSale and passing it
        // the rate, wallet, and token parameters. Then
        // saving its address to the previously declared
        // tokenSaleAddress variable.
        RealT_Sale tokenSale = new RealT_Sale(1, wallet, token);
        tokenSaleAddress = address(tokenSale);

        // Making the RealTSale contract a minter,
        // then have the RealTSaleDeployer renounce its minter role.
        token.addMinter(tokenSaleAddress);
        token.renounceMinter();
    }
}
