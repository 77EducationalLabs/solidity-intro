// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Faucet {
    ///Type Declarations///

    ///State Variables///
    enum Withdrawable{
        yes, //0
        no //1
    }

    Withdrawable withdrawable;

    struct UserWithdraws{
        uint256 nextWithdraw;
        bytes txInfoEncode; //@audit-info need to improve this. Doesn't make sense now.
        bytes txInfoPacked; //@audit-info need to improve this. Doesn't make sense now.
    }

    ///@notice immutable variable to hold owner address
    address immutable i_owner;
    ///@notice constant variable to hold max withdraw amount
    uint256 constant WITHDRAW_AMOUNT = 2*10**17;
    ///@notice constant variable to hold the max amount an user can have after withdrawing from our faucet
    uint256 constant USER_BALANCE_LIMIT = 5*10**17;
    ///@notice constant variable to hold standard decimals
    uint256 constant STANDARD_DECIMALS = 1*10**18;

    ///@notice state variable to count the number of withdraws performed
    uint256 public s_withdrawsCounter;
    ///@notice state variable to hold the result between withdraw/donations
    int256 public s_nativeOperationBalance;
    ///@notice variable to store the hashed password to withdraw on this faucet
    bytes32 internal s_faucetPassword; //@audit-info need to find another usage

    ///@notice array to track native donations to the contract
    address[] public s_donationsControl;
    ///@notice mapping to store the UserWithdraws struct info
    mapping(address user => UserWithdraws) private s_userRegisters;

    ///@notice event emitted when a new deposit is made
    event Faucet_NewAmountDeposited(uint256 _amount);
    ///@notice event emitted when a withdraw is completed
    event Faucet_NewWithdrawCompleted(address withdrawer, uint256 amount);

    ///@notice error emitted when the caller is not the owner
    error Faucet_OnlyOwnerAllowed(address caller, address owner);
    ///@notice error emitted when the user balance + withdrawAmount is bigger than threshold
    error Faucet_UserBalanceWillOverpassLimit(uint256 posBalance);
    ///@notice error emitted when the user already withdrawal in the last 24 hours
    error Faucet_TwentyFourHoursCooldown();
    ///@notice error emitted when a transfer fails
    error Faucet_TransferFailed(bytes erro);

    modifier onlyOwner(){
        if(msg.sender != i_owner) revert Faucet_OnlyOwnerAllowed(msg.sender, i_owner);
        _;
    }

    constructor(address _owner){
        i_owner = _owner;
    }

    receive() external payable {}

    fallback() external {}

    function donateNative() external payable {
        s_nativeOperationBalance = s_nativeOperationBalance + int(msg.value);

        if(msg.value >= USER_BALANCE_LIMIT){
            s_donationsControl.push(msg.sender);
        }

        emit Faucet_NewAmountDeposited(msg.value);
    }

    function withdrawNative(address _receiver) external onlyOwner{
        uint256 balancePosWithdraw = _receiver.balance + WITHDRAW_AMOUNT;

        if(balancePosWithdraw > USER_BALANCE_LIMIT) revert Faucet_UserBalanceWillOverpassLimit(balancePosWithdraw);
        require(address(this).balance >= WITHDRAW_AMOUNT, "Not Enough Balance");
        
        if(block.timestamp < s_userRegisters[_receiver].nextWithdraw){
            revert Faucet_TwentyFourHoursCooldown();
        } else if(s_userRegisters[_receiver].nextWithdraw == 0){
            _createReceiverRegister(_receiver);
        } else {
            s_userRegisters[_receiver].nextWithdraw = block.timestamp + 1 days;
        }

        s_withdrawsCounter++;
        s_nativeOperationBalance -= int(WITHDRAW_AMOUNT);

        emit Faucet_NewWithdrawCompleted(_receiver, WITHDRAW_AMOUNT);

        _transferEth(_receiver);
    }

    ///Internal///
    function _transferEth(address _receiver) internal {
        (bool success, bytes memory erro) = _receiver.call{value: WITHDRAW_AMOUNT}("");
        if(!success) revert Faucet_TransferFailed(erro);
    }

    function _createReceiverRegister(address _receiver) private {
        s_userRegisters[_receiver] = UserWithdraws({
            nextWithdraw: block.timestamp + 1 days,
            txInfoEncode: abi.encode(_receiver, block.timestamp),
            txInfoPacked: abi.encodePacked(_receiver, block.timestamp)
        });
    }

    ///View & Pure///
    function checkFaucetBalance() public view returns(uint256 _balance){
        _balance = address(this).balance;
    }
}

///// Variables
/// Reference Types
// Struct to register user withdraws
    //timestamp to limit number of withdraws each 24h
    //address the user
    //bytes abi.encode user info
    //bytes abi.encodePacked user info

/// Value Types
// Enum to create an status
// Immutable to control access to critical functionalities
// Constant to remove magic numbers e limit the withdrawal amount
    //Per Withdraw
    //Per balance
// Constant to hold decimals and introduce wei units
// State variable to count withdraws
    // uint256 counter
    // int256 operationsBalance
    // bytes32 hashed password

///// Storage
// mapping to store the withdraws struct
// mapping to blacklist user using boolean isBlocked == true
// array to ?? track donations?
    //Need to loop over it.

///// Error Handling
// If statements + Custom Errors to show the efficient way to deal with it.
// require to provide handling options
    //Both use operators and global variable msg.sender

///// Events
// After each storage update

///// Functions
// Constructor to initiate immutables
// modifier to control access
// modifier to check for blacklisted addresses
// receive & fallback functions to receive ether
// depositEth
    //external payable
    //use global variable msg.value
// withdrawEth
    //external, common
    //using state variable to count number of withdraws
// checkBalance
    //public, view, returns
// transferValue
    //private common
    // internal
// blackListingRegister
    //private, common