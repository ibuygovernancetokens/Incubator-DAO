// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// @title Exchange contract from ROOK to pROOK and USDC
/// @author IANAL
contract ExchangeROOK is Ownable, Pausable {
	using SafeMath for uint256;
	using SafeERC20 for ERC20;

	/// @notice ROOK
	ERC20 public tokenROOK;

	/// @notice pROOK
	ERC20 public tokenPROOK;

	/// @notice USDC
	ERC20 public tokenUSDC;

	/// @notice Exchange Rate
	uint256 public exchangeRate;

	/// @notice emitted when exchange ROOK to pROOK and USDC
	event Exchange(address indexed user, uint256 amount, uint256 value);

	//
	// @notice constructor
	// @param _tokenROOK ROOK token address
	// @param _tokenPROOK pROOK token address
	// @param _tokenUSDC USDC token address
	// @param _exchangeRate exchange rate value with 4 decimals
	//
	constructor(ERC20 _tokenROOK, ERC20 _tokenPROOK, ERC20 _tokenUSDC, uint256 _exchangeRate) Ownable() {
		tokenROOK = _tokenROOK;
		tokenPROOK = _tokenPROOK;
		tokenUSDC = _tokenUSDC;
		exchangeRate = _exchangeRate;
		_pause();
	}

	function pause() public onlyOwner {
		_pause();
	}

	function unpause() public onlyOwner {
		_unpause();
	}

	/**
	 * @notice Exchange rate value with 4 decimals, example 455000 = $45.50
	 * @param _exchangeRate to use
	 */
	function setExchangeRate(uint256 _exchangeRate) external onlyOwner {
		exchangeRate = _exchangeRate;
	}

	/**
	 * @notice Withdraw ERC20 token
	 * @param _token address for withdraw
	 * @param _amount to withdraw
	 */
	function withdrawAssets(ERC20 _token, uint256 _amount) external onlyOwner {
		_token.safeTransfer(owner(), _amount);
	}

	/**
	 * @notice Exchange from ROOK to pROOK and USDC
	 * @param _amount of ROOK exchanged
	 */
	function exchange(uint256 _amount) external whenNotPaused {
		tokenROOK.safeTransferFrom(_msgSender(), address(this), _amount);
		uint256 _value = _amount.mul(exchangeRate).div( 10000000000000000 );
		tokenPROOK.safeTransfer(_msgSender(), _amount);
		tokenUSDC.safeTransfer(_msgSender(), _value);

		emit Exchange(_msgSender(), _amount, _value);
	}
}
