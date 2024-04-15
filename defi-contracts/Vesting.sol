// SPDX-License-Identifier: MIT
// Creator: Davi / Felipe
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error ContractIsEnabled(bool);

/**
 * @title TokenVesting
 * @dev Contrato de aquisição de tokens com liberação programada.
 * @author Davi / Felipe
 */
contract TokenVesting is Ownable, ReentrancyGuard {

    IERC20 public soulPrimeToken;

    bool public isEnabled;
    uint public startTime;
    address public beneficiary;
    uint256 public cliffDuration = 180 days;
    uint256 public monthlyDuration = 30 days;
    uint public teste1;

    uint public totalVestingAmount;
    uint public totalReleased;
    
    // @dev Fases de pagamento ao investidor (10%, 25%, 40%, 55%, 70%, 85% e 100%)
    uint[] public paymentFases = [15_000_000 ether, 37_500_000 ether, 60_000_000 ether, 82_500_000 ether, 105_000_000 ether, 127_500_000 ether, 150_000_000 ether];

    event ContractStarted(uint timestamp); 
    event TokensReleased(uint amount);
    event TokenDeposited(uint amount);

    /**
     * @dev Modificador para garantir que o contrato está ativado.
     */
    modifier isContractEnabled() {
        if (!isEnabled) { 
            revert ContractIsEnabled(isEnabled);
        }
        _;  
    }

    /**
     * @notice Inicializa o contrato e distribui inicialmente os tokens.
     * @dev Somente o proprietário pode chamar esta função.
     * @param _tokenAddress Endereço do contrato ERC-20.
     * @param _beneficiary Endereço que receberá os tokens.
     */
    function startContract(address _tokenAddress, address _beneficiary) external onlyOwner {
        soulPrimeToken = IERC20(_tokenAddress);
        isEnabled = true;
        startTime = block.timestamp;
        beneficiary = _beneficiary;
        totalVestingAmount = soulPrimeToken.balanceOf(address(this));
        emit ContractStarted(startTime);
    }

    /**
     * @notice Deposita o fundo de 150.000.000 de tokens PRT ao contrato.
     * @dev Somente o proprietário pode chamar esta função.
     */
    function depositTokens() external onlyOwner {
        require(soulPrimeToken.balanceOf(msg.sender) >= 150_000_000 ether, "Owner must have more than 150.000.000 PRTs");
        bool sent = soulPrimeToken.transferFrom(msg.sender ,address(this), 150_000_000 ether);
        require(sent, "Error to sent PRT Transfer to Contract");
        totalVestingAmount = 150_000_000 ether;
    }

    /**
     * @notice Libera os tokens programados.
     * @dev Esta função é protegida contra reentrada.
     * @dev Esta função pode ser bloqueada / desbloqueada pelo Owner
     */
    function releaseTokens() external nonReentrant isContractEnabled {
        require(block.timestamp >= startTime + cliffDuration, "Cliff duration not reached");
        uint256 elapsedTime = (block.timestamp - startTime) - cliffDuration;
        uint256 vestedAmount = 0;
        for(uint i = 0; i < paymentFases.length; i++){
            if(elapsedTime >= i * monthlyDuration){
                vestedAmount = paymentFases[i];
            }
        }
        uint256 amountToRelease = vestedAmount - totalReleased;
        require(amountToRelease > 0, "No tokens to release");
        totalReleased = vestedAmount;
        bool sent = soulPrimeToken.transfer(beneficiary, amountToRelease);
        require(sent, "erro");
        emit TokensReleased(amountToRelease);
    }

    /**
     * @notice Altera o estado do contrato, permitindo bloquear e desbloquear ele.
     * @dev Somente o proprietário pode chamar esta função.
     */
    function changeStateEnable() public onlyOwner {
        if (isEnabled) {
            require(block.timestamp <= startTime + cliffDuration, "Payment time just started");
        }
        isEnabled = !isEnabled;
    }

    /**
     * @notice Permite a retirada dos tokens caso o investidor não cumpra o combinado. É necessário bloquear
     * o contrato antes do período inicial de pagamento e chamar só depois desse período iniciar.
     * @dev Somente o proprietário pode chamar esta função.
     */
    function withdrawEmergency(address _addressTo) public onlyOwner {
        require(block.timestamp >= startTime + cliffDuration, "This function needs to wait 180 days to be called");
        require(!isEnabled, "Contract must to be blocked for investor");
        uint amount = soulPrimeToken.balanceOf(address(this));
        soulPrimeToken.transfer(_addressTo, amount);
    }
}