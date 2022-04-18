// SPDX-License-Identifier: CC-BY-SA 4.0
//https://creativecommons.org/licenses/by-sa/4.0/

// TL;DR: The creator of this contract (@LogETH) is not liable for any damages associated with using the following code
// This contract must be deployed with credits toward the original creator, @LogETH.
// You must indicate if changes were made in a reasonable manner, but not in any way that suggests I endorse you or your use.
// If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
// You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.
// This TL;DR is solely an explaination and is not a representation of the license.

// By deploying this contract, you agree to the licence above and the terms and conditions that come with it.

pragma solidity >=0.7.0 <0.9.0;

//// What is this contract? 

//// This contract simply distributes an ERC20 token among NFT owners.
//// Users register their NFT by using register() to receive rewards.
//// In order for this contract to function properly, transfer(), transferfrom(), safetransfer(), and safetransferfrom() MUST BE DISABLED on the main NFT contract.

//// Commissioned by spagetti#7777 on 3/17/2022

contract NFTRegisterRewardDistribution{

//// The constructor will execute when the contract is deployed, replace the address(0) with the token and NFT.
//// You can change the token and the NFT later using EditNFT() and EditToken()

//// The person who deploys the contract is the admin. The admin is hardcoded into the contract, it cannot be changed.

    constructor(){

        NOKO = ERC20(address(0));
        OnePercent = NFT(address(0));
        admin = msg.sender;
    }

//// The Contracts this contract uses goes here, OnePercent and NOKO token

    NFT OnePercent;
    ERC20 NOKO;

//// Variables that this contract uses, the first one counts time, the second one keeps track of how many NFTs are registered to your address.
//// The third one keeps track of how many NFTs are registered in total.

    mapping(address => uint) TimeRegistered;
    mapping(address => uint) NFTs;
    mapping(uint => address) user;
    uint totalRegistered;
    uint RewardFactor;
    uint public TotalRewardsClaimed;
    uint Nonce;
    address admin;
    mapping(address => bool) perm;
    mapping(address => uint) PendingReward;

//// Functions that allow the admin to edit the Token, NFT, and emmission rate.

    function EditToken(ERC20 Token) public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button");
        require(isContract(address(Token)) == true, "The address you put in is not a contract.");
        require(Token.balanceOf(address(this)) > 0, "This contract's balance of the token you requested is zero! Add some tokens as rewards before switching the token.");
        NOKO = Token;
    }

    function EditNFT(NFT CollectionAddress) public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button");
        require(isContract(address(CollectionAddress)) == true, "The address you put in is not a contract.");
        OnePercent = CollectionAddress;
    }

//// Editing the emission rate claims everyone's rewards.

    function EditEmission(uint TokensPerNFT, uint HowManyBlocks) public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button");

        RewardFactor = CalculateEmission(TokensPerNFT, HowManyBlocks, NOKO.decimals());

        SaveRewards();
    }

//// Withdraw's the balance of a token on this contract.
//// Only usable if that current token is not being used as rewards.

    function ReplaceToken(ERC20 TokenAddress) public {

        require(msg.sender == admin, "You aren't the admin so you can't press this button");
        require(isContract(address(TokenAddress)) == true, "The address you put in is not a contract.");
        require(TokenAddress != NOKO, "This token is currently being used as rewards! You cannot withdraw it while its being used!");
        TokenAddress.transfer(msg.sender, TokenAddress.balanceOf(address(this)));
    }

//// ForceClaim allows you to claim everyones rewards instantly.
//// The claimed tokens still go to their rightful owner.

    function forceClaim() public {

        require(msg.sender == admin || perm[msg.sender] == true, "You aren't the admin so you can't press this button");

        ForceClaim();
    }

//// This button claims your rewards, that's it.

    function Claim() public {

        uint Unclaimed = CalculateRewards(msg.sender, this.CalculateTime(msg.sender)) + PendingReward[msg.sender];

        require(NOKO.balanceOf(address(this)) >= Unclaimed, "This contract is out of tokens to give as rewards! Ask devs to do something");
        TimeRegistered[msg.sender] = block.timestamp;
        NOKO.transfer(msg.sender, Unclaimed);

        TotalRewardsClaimed += Unclaimed;
    }

////The Register button reads the underlying NFT contract for a person's balance and keeps track of it.

    function Register() public {

        require(OnePercent.balanceOf(msg.sender) > 0, "You don't have any NFTs to register!");
        require(OnePercent.balanceOf(msg.sender) != NFTs[msg.sender], "You already registered all your NFTs.");
        require(NFTs[msg.sender] < 100, "You have registered the max amount, 100 NFTs");
        require(msg.sender != address(0), "What the fuck");

        ClaimOnBehalf(msg.sender);

        NFTs[msg.sender] = OnePercent.balanceOf(msg.sender);

        if(OnePercent.balanceOf(msg.sender) > 100){NFTs[msg.sender] = 100;}

        TimeRegistered[msg.sender] = block.timestamp;

        user[Nonce] = msg.sender;
        Nonce += 1;
    }

//// Assign perms lets you give an external address permission to call admin only functions like forceClaim()

    function AssignPermission(address Who, bool TrueOrFalse) public {
        
        require(msg.sender == admin, "You aren't the admin so you can't press this button");
        perm[Who] = TrueOrFalse;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// The internal/external functions this contract uses, it compresses big commands into tiny ones so its easier to implement in the actual buttons. ////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////msg.sender and tx.origin should NOT be used in any of the below functions.
  
    function CalculateTime(address YourAddress) external view returns (uint256){

        uint Time = block.timestamp - TimeRegistered[YourAddress];
        if(Time == block.timestamp){Time = 0;}

        return Time;
    }

    function CalculateRewards(address YourAddress, uint256 StakeTime) internal view returns (uint256){

        uint LocalReward = StakeTime;

        LocalReward = LocalReward * NFTs[YourAddress] * RewardFactor;

        return LocalReward;
    }

    function ClaimOnBehalf(address User) internal {

        uint Unclaimed = CalculateRewards(User, this.CalculateTime(User)) + PendingReward[User];

        require(NOKO.balanceOf(address(this)) >= Unclaimed, "This contract is out of tokens to give as rewards! Ask devs to do something");
        TimeRegistered[User] = block.timestamp;
        NOKO.transfer(User, Unclaimed);

        TotalRewardsClaimed += Unclaimed;
    }

    function RecordReward(address User) internal {

        uint Unclaimed = CalculateRewards(User, this.CalculateTime(User));
        PendingReward[User] += Unclaimed;
        TimeRegistered[User] = block.timestamp;
    }

    function SaveRewards() internal {

        uint UserNonce;

        while(user[UserNonce] != address(0)){

            RecordReward(user[UserNonce]);
            UserNonce += 1;
        }
    }

    function ForceClaim() internal {

        uint UserNonce;

        while(user[UserNonce] != address(0)){

            ClaimOnBehalf(user[UserNonce]);
            UserNonce += 1;
        }
    }

    function CalculateEmission(uint TokensPerBlockPerNFT, uint HowManyBlocks, uint decimals) public pure returns(uint) {

        uint Value = TokensPerBlockPerNFT * (10**decimals);
        TokensPerBlockPerNFT = Value/HowManyBlocks;
        return TokensPerBlockPerNFT;
    }

///////////////////////////////////////////////////////////
//// The internal/external functions used for UI data  ////
///////////////////////////////////////////////////////////

    function CheckUnclaimedRewards(address YourAddress) external view returns (uint256){

        return (CalculateRewards(YourAddress, this.CalculateTime(YourAddress)));
    }

    function GetMultiplier(address YourAddress) external view returns (uint){

        return NFTs[YourAddress];
    }

    function GetTotalRegistered() external view returns (uint){

        return totalRegistered;
    }

    function isContract(address addr) internal view returns (bool) {

        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }       

    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Additional functions that are not part of the core functionality, if you add anything, please add it here ////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////



}
    
/////////////////////////////////////////////////////////////////////////////////////////
//// The functions that this contract calls to the other contracts, contractception! ////
/////////////////////////////////////////////////////////////////////////////////////////

interface NFT{
    function transferFrom(address, address, uint256) external;
    function balanceOf(address) external returns (uint);
}
interface ERC20{
    function transferFrom(address, address, uint256) external;
    function transfer(address, uint256) external;
    function balanceOf(address) external view returns(uint);
    function decimals() external view returns (uint8);
}
