// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "../inc/Base.sol";
import "../inc/CoreLibrary.sol";
import "../interfaces/IReserveModule.sol";

import "../interfaces/IAddressProvider.sol";
import "../interfaces/IOracleModule.sol";
import "../interfaces/IZTokenCore.sol";

contract ReserveModule is IReserveModule, Base {
    using SafeMathUpgradeable for uint256;

    IAddressProvider public addressProvider;

    struct UserReserveData {
        uint256 freezeAmount;
        uint256 blockedAmount;
        uint256 userCurrentLiquidityIndex;
        uint40 lastUpdateTimestamp;
        bool collateralEnabled;
        bool collateralChanged;
    }

    struct ReserveData {
        uint256 lastLiquidityIndex;
        uint256 currentLiquidityIndex;
        uint256 totalLoans;
        uint256 decimals;
        address zTokenAddress;
        uint40 lastUpdateTimestamp;
        bool loanEnabled;
        bool collateralEnabled;
        bool isActive;
        bool isFreezed;
    }

    mapping(address => ReserveData) public reserves;
    mapping(address => address) public reservesZ;

    mapping(address => mapping(address => UserReserveData))
        public usersReserveData;

    address[] public reservesList;
    uint256[] public frozenList;

    uint256 public DEFAULT_INDEX;
    bytes32 public constant POOL = "POOL";
    bytes32 public constant RESERVE_MODULE_ADMIN = "RESERVE_MODULE_ADMIN";
    bytes32 public constant ORACLE_MODULE = "ORACLE_MODULE";

    modifier onlyPool {
        require(
            addressProvider.getAddress(POOL) == msg.sender,
            "The caller must be the Pool"
        );
        _;
    }

    function initialize(address _addressProvider) public initializer {
        OwnableUpgradeable.__Ownable_init();
        addressProvider = IAddressProvider(_addressProvider);
        DEFAULT_INDEX = 10**8;
    }

    function freezeUserLiquidityETH(address _user, uint256 _amountETH)
        public
        override
        onlyPool
        returns (
            address[] memory newFrozenAssets_,
            uint256[] memory newFrozenAmounts_,
            uint256[] memory newFrozenRates_,
            uint256 assetsNumber_
        )
    {
        uint256 tmpamount = _amountETH;
        newFrozenAssets_ = new address[](reservesList.length);
        newFrozenAmounts_ = new uint256[](reservesList.length);
        newFrozenRates_ = new uint256[](reservesList.length);
        for (uint256 i = 0; i < reservesList.length; i++) {
            (
                uint256 amount,
                uint256 amountETH,
                uint256 rate,
                uint256 decimals
            ) = checkUserReserverCollateral(reservesList[i], _user);

            if (amountETH <= 0) continue;

            uint256 freezeAmount = 0;

            if (amountETH <= tmpamount) {
                freezeAmount = amount;
                tmpamount = tmpamount.sub(amountETH);
            } else {
                freezeAmount = tmpamount.mul(10**decimals).div(rate);
                tmpamount = 0;
            }

            usersReserveData[reservesList[i]][_user]
                .freezeAmount = usersReserveData[reservesList[i]][_user]
                .freezeAmount
                .add(freezeAmount);

            newFrozenAssets_[assetsNumber_] = reservesList[i];
            newFrozenAmounts_[assetsNumber_] = freezeAmount;
            newFrozenRates_[assetsNumber_] = rate;

            assetsNumber_++;
            if (tmpamount == 0) break;
        }

        return (
            newFrozenAssets_,
            newFrozenAmounts_,
            newFrozenRates_,
            assetsNumber_
        );
    }

    function checkUserReserverCollateral(address _reserve, address _user)
        private
        returns (
            uint256 amount_,
            uint256 amountETH_,
            uint256 rate_,
            uint256 decimals_
        )
    {
        if (!reserves[_reserve].collateralEnabled) return (0, 0, 0, 0);

        if (usersReserveData[_reserve][_user].collateralChanged)
            if (!usersReserveData[_reserve][_user].collateralEnabled)
                return (0, 0, 0, 0);

        amount_ = getUserAvailableBalance(_reserve, _user);

        if (amount_ == 0) return (0, 0, 0, 0);

        (amountETH_, rate_, decimals_) = getAssetValueETH(_reserve, amount_);
    }

    function getAssetValueETH(address _reserve, uint256 _amount)
        public
        override
        onlyPool
        returns (
            uint256 amount_,
            uint256 price_,
            uint8 decimals_
        )
    {
        address oracleAddress = addressProvider.getAddress(ORACLE_MODULE);
        IOracleModule oracleModule = IOracleModule(oracleAddress);
        (uint256 currentPrice, uint8 decimals) =
            oracleModule.getPrice(_reserve);

        require(currentPrice > 0, "Reserve Price is below Zero");

        return (
            _amount.mul(currentPrice).div(10**decimals),
            currentPrice,
            decimals
        );
    }

    function getUserAvailableBalance(address _reserve, address _user)
        public
        view
        override
        returns (uint256 availableBalance_)
    {
        IZTokenCore zToken = IZTokenCore(reserves[_reserve].zTokenAddress);
        return zToken.availableBalanceOf(_user);
    }
}
