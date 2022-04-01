// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

    // This contract is a yield stratagy for FEI dao.

    // Here are the steps to success:

    // 1) Deposit cDAI into Rari.capital 
    // 2) Borrow cDAI off of FEI from rari.capital
    // 3) Unwrap cDAI to DAI using Compound
    // 4) Swap DAI to LUSD using Curve.fi
    // 5) Deposit LUSD into the liquity stability pool

    // now to the code:

contract PrintMoney {

    constructor(){

        //Input FEI DAO address
    }

//// Variables that this contract uses:

    ERC20 DAI  = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    ERC20 FEI  = ERC20(0x956F47F50A910163D8BF957Cf5846D573E7f87CA);
    ERC20 LUSD = ERC20(0x5f98805A4E8be255a32880FDeC7F6728C6568bA0);

    Comp cDAI  = Comp(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    Rari fcDAI = Rari(0x0000000000000000000000000000000000000000); // Replace with the actual fcDAI address please.
    Rari fcFEI = Rari(0x0000000000000000000000000000000000000000); // Replace with the actual fcFEI address pretty please.

    address DAO;
  

    

    // This contract zaps this yield stratagy instantly in one transaction.
    // it can also reverse the entire stratagy or a percentage of it in one transaction.

    // Visible Functions this contract has:

    function deposit(uint amount) public {

//  Step 1: Deposit FEI into rari.capital.
        FEI.transferFrom(msg.sender, address(this), amount);
        FEI.approve(address(fcFEI), amount);
        fcFEI.mint(amount);

//  Step 2: Borrow cDAI at 110% LTV and unwrap it.
        uint AvalBorrow;
        uint a;
        (a, AvalBorrow, a) = fcDAI.getAccountLiquidity(address(this));
        fcDAI.borrow((AvalBorrow-(AvalBorrow/10)));
        cDAI.redeem(cDAI.balanceOf(address(this)));

//  Step 3: Swap DAI to LUSD on Curve.fi.





    }

    function withdraw(uint amount) public {


    }

    // Internal and External Functions this contract uses:
    // (msg.sender SHOULD NOT be used in any of these functions.)


}

//// Contracts that this contract uses, contractception!

interface Rari{

    // Rari Dev Docs https://docs.rari.capital/fuse/#general
    function mint(uint) external returns (uint);
    function redeem(uint) external returns (uint);
    function redeemUnderlying(uint) external returns (uint);
    function transferFrom(address, address, uint256) external;
    function transfer(address, uint256) external;
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function balanceOf(address) external view returns(uint);
    function getAccountLiquidity(address account) external returns (uint, uint, uint);
}

interface Curve{


}

interface Comp {

    // Comp dev docs https://medium.com/compound-finance/supplying-assets-to-the-compound-protocol-ec2cf5df5aa#afff
    function mint(uint256) external returns (uint256);
    function exchangeRateCurrent() external returns (uint256);
    function supplyRatePerBlock() external returns (uint256);
    function redeem(uint) external returns (uint);
    function redeemUnderlying(uint) external returns (uint);
    function approve(address, uint256) external returns (bool success);
    function transferFrom(address, address, uint256) external;
    function transfer(address, uint256) external;
    function balanceOf(address) external view returns(uint);
}

interface ERC20{

    function transferFrom(address, address, uint256) external;
    function transfer(address, uint256) external;
    function balanceOf(address) external view returns(uint);
    function approve(address, uint256) external returns (bool success);
}
