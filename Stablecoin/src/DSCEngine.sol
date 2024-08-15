// SPDX-License-Identifier: UNLICENSED

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

pragma solidity ^0.8.18;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {DecentralisedStableCoin} from "./DecentralisedStableCoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
 * @title DSCEngine
 * @author Kelbels
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only wETH and wBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of
 * all collateral < the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS (DAI) system
 */
contract DSCEngine is ReentrancyGuard {
    ///////////////////
    // Errors
    ///////////////////

    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error DSCEngine__TokenNotAllowed();
    error DSCEngine__TransferFailed();

    ///////////////////
    // Types
    ///////////////////

    ///////////////////
    // State Variables
    ///////////////////

    /// @dev Mapping of token address to price feed address
    mapping(address token => address priceFeed) private s_priceFeeds; // tokenToPriceFeeds
    /// @dev Amount of collateral deposited by user
    mapping(address user => mapping(address collateralToken => uint256 amount)) private s_collateralDeposited;
    /// @dev Amount of DSC minted by user
    mapping(address user => uint256 amount) private s_DSCMinted;

    address[] private s_collateralTokens;

    DecentralisedStableCoin private immutable i_dsc;

    ///////////////////
    // Events
    ///////////////////

    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    ///////////////////
    // Modifiers
    ///////////////////

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed();
        }
        _;
    }

    ///////////////////
    // Functions
    ///////////////////

    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
        }
        // using USD Price Feeds for consistency and accuracy ETH/USD and BTC/USD
        // loop through addresses to add to mapping
        for (uint256 i = 0; 1 < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }

        i_dsc = DecentralisedStableCoin(dscAddress);
    }

    ///////////////////
    // External Functions
    ///////////////////

    function depositCollateralAndMintDsc() external {}

    /*
     * @param tokenCollateralAddress: The ERC20 token address of the collateral being deposited
     * @param amountCollateral: The amount of collateral deposited
     */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        external
        moreThanZero(amountCollateral)
        isAllowedToken(tokenCollateralAddress)
        nonReentrant
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        // emit event when updating state
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    /*
     * @param amountDscToMint: The amount of DSC you want to mint
     * You can only mint DSC if you have enough collateral
     */
    function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
        // check if collateral value is more than dsc amount? price feeds? values of collateral?
        s_DSCMinted[msg.sender] += amountDscToMint;
        // if they minted too much
        revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external {}

    ///////////////////
    // Public Functions
    ///////////////////

    ///////////////////
    // Private Functions
    ///////////////////

    //////////////////////////////
    // Private & Internal View & Pure Functions
    //////////////////////////////

    /*
     * @param user: person in debt
     * gets information from s_DSCMinted mapping and getAccountCollateralValue function
     */
    function _getAccountInformation(address user)
        private
        view
        returns (uint256 totalDscMinted, uint256 collateralValueInUsd)
    {
        totalDscMinted = s_DSCMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    /*
     * Returns how close to liquidation a user is.
     * If user goes below 1 they can get liquidated
     * @param user: person in debt
     * gets information from _getAccountInformation
     */
    function _healthFactor(address user) private view returns (uint256) {
        // get total DSC minted
        // get total collateral value
    }
    function revertIfHealthFactorIsBroken(address user) internal view {
        // check health factor (do they have enough collateral)
        // revert if they do not
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    // External & Public View & Pure Functions
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    /*
     * Returns collateral value in USD
     * @param token:
     * @param amount:
     * called by getAccountCollateralValue
     */
    function getUsdValue(address token, uint256 amount) external view returns (uint256) {
        // amount is in WEI
        return _getUsdValue(token, amount);
    }

    /*
     * Returns collateral value in USD
     * @param user: person in debt
     * gets information from _getUsdValue
     * called by _getAccountInformation
     */
    function getAccountCollateralValue(address user) public view returns (uint256 totalCollateralValueInUsd) {
        // loop through each collateral token, get amount they have deposited and map it to the price, to get USD value

        for (uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += _getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }
}
