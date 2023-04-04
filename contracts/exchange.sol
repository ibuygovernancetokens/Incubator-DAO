pragma solidity ^0.8.0;

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    _setOwner(_msgSender());
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view virtual returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _setOwner(newOwner);
  }

  function _setOwner(address newOwner) private {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
      require(b > 0, errorMessage);
      uint256 c = a / b;
      return c;
  }
}

interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Exchange is Ownable {
  using SafeMath for uint256;

  address constant PROOK = 0x66BB736208544e0FC73cb8087f6De94D44B1D75f;
  address constant USDC = 0x258deEc1021B551fb2c339A8A5294CF2b736292D;
  uint256 public EXCHANGERATE = 395000;

  constructor() Ownable() {}

  // _EXCHANGERATE must be given with 4 decimals; example: 395000 = $39.50
  function setExchangeRate(uint256 _EXCHANGERATE) external onlyOwner {
    EXCHANGERATE = _EXCHANGERATE;
  }

  // This function is used to transfer assets owned by the contract to an address.
  function transferAssets(
    address _to,
    uint256 _amount,
    address _token
  ) external onlyOwner {
    require(
      _amount <= IERC20(_token).balanceOf(address(this)),
      "Not enough balance"
    );

    IERC20(_token).transfer(_to, _amount);
  }

  // This function is used to exchange pROOK for assets from the smart contract. Amount must be given in pROOK, which has 18 decimals.
  function exchangeForAssets(uint256 _amount) external {
    require(_amount <= IERC20(PROOK).balanceOf(msg.sender), "You don't have enough pROOK");
    require(_amount > 0, "Amount is 0");

    require(
      IERC20(PROOK).allowance(msg.sender, address(this)) >= _amount,
      "You need to approve this contract to spend your pROOK"
    );

    IERC20(PROOK).transferFrom(msg.sender, address(this), _amount);

    uint256 _value = _amount.mul(EXCHANGERATE).div( 10000000000000000 );

    require(
      _value <= IERC20(USDC).balanceOf(address(this)),
      "Error, not enough assets available on the smart contract"
    );
    IERC20(USDC).transfer(msg.sender, _value);
  }
}