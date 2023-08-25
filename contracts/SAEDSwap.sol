// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IERC20 {

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SAEDSwap is ReentrancyGuard, Ownable{

    event TokenPerUSDPriceUpdated(uint256 amount);
    event UsdtTosaedSwapped(address user, uint256 amount);
    event saedToUsdtSwapped(address user, uint256 amount);
    event TokenRecovered(address tokenAddress, address walletAddress, uint256 amount);
    
    address public  SAEDAddress;
    address public SUSDAddress;
    address public  USDTAddress;

    uint256  saedAmountPerUSDT = 367;

//0,1,2,3,4,5
    enum SWAPTYPE {
        SAEDToSUSD,
        SAEDToUSDT,
        SUSDToSAED,
        SUSDToUSDT,
        USDTToSAED,
        USDTToSUSD
    }

    struct swapParams {
        SWAPTYPE swapType;
        uint256 amount;
    }

    struct swapCoreParams {
        address token0;
        address token1;
        uint256 amount;
    }

    constructor(address _SAEDAddress, address _susdAddress,address _USDTAddress) {
        SAEDAddress = _SAEDAddress;
        SUSDAddress = _susdAddress;
        USDTAddress = _USDTAddress;

    }

    function getPair(swapParams memory params) internal view returns(swapCoreParams memory) {

        if(SWAPTYPE.SAEDToSUSD == params.swapType){
            uint256 amount = getSAEDToUSDTRate(params.amount);
            return swapCoreParams(SAEDAddress, SUSDAddress, amount);
        }                
        if(SWAPTYPE.SAEDToUSDT == params.swapType){
            uint256 amount = getSAEDToUSDTRate(params.amount);
            return swapCoreParams(SAEDAddress, USDTAddress, amount);
        }
        if(SWAPTYPE.SUSDToSAED == params.swapType){
            uint256 amount = getUSDTToSAEDRate(params.amount);
            return swapCoreParams(SUSDAddress, SAEDAddress, amount);
        }
        if(SWAPTYPE.SUSDToUSDT == params.swapType){
            return swapCoreParams(SUSDAddress, USDTAddress, params.amount);
        }
        if(SWAPTYPE.USDTToSAED == params.swapType){
            uint256 amount = getUSDTToSAEDRate(params.amount);
            return swapCoreParams(USDTAddress, SAEDAddress, amount);
        }
        if(SWAPTYPE.USDTToSUSD == params.swapType){
            return swapCoreParams(USDTAddress, SUSDAddress,params.amount);
        }

        return swapCoreParams(address(0), address(0), 0);
    }

    function swapToken(swapParams memory swap) external nonReentrant{
        require(swap.amount > 0, "Invalid token amount");
        swapCoreParams memory params = getPair(swap);
        bool status  = IERC20(params.token0).transferFrom(
            msg.sender,
            address(this),
            swap.amount
        );
        if(status) {
            IERC20(params.token1).transfer(msg.sender, params.amount);
            emit UsdtTosaedSwapped(msg.sender, params.amount);
        }
    }
    
    function recoverToken(address tokenAddress, address walletAddress, uint256 amount)
        external
        onlyOwner
    {
        require(walletAddress != address(0), "Null address");
        require(amount <= IERC20(tokenAddress).balanceOf(address(this)), "Insufficient amount");
        bool status = IERC20(tokenAddress).transfer(
            walletAddress,
            amount
        );
        emit TokenRecovered(tokenAddress, walletAddress, amount);
    }
    
    function setsaedPricePerUSDT(uint256 saedAmount)
        external
        onlyOwner
    {
        saedAmountPerUSDT = saedAmount;
        emit TokenPerUSDPriceUpdated(saedAmountPerUSDT);
    }
    

    function getSAEDToUSDTRate(uint256 tokenAmount)
        public
        view
        returns (uint256)
    {
        return ((tokenAmount * saedAmountPerUSDT * 1e6) / 100)/1e6;
    }

    function getUSDTToSAEDRate(uint256 tokenAmount)
        public
        view
        returns (uint256)
    {
        return ((((tokenAmount) / saedAmountPerUSDT *1e6)) * 100)/1e6;
    }

}