// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * Token ERC20 que simbolizará um ativo do mundo real (RWA). Pode ser que 20 tokens ERC20 signifiquem uma casa,
 * um carro...
 */
contract Token is ERC20 {
    string public contrato_rwa;
    address public carteira_tokenizadora;
    address public carteira_cliente;
    bool public cliente_assinou = false;
    bool public tokenizadora_assinou = false;
    bool public contrato_setado = false;
    bool public contrato_iniciado = false;

    constructor
    (
        address client_wallet,
        address tokenizadora_wallet
    ) 
    ERC20('Token', 'TKN') 
    {
        carteira_tokenizadora = tokenizadora_wallet;
        carteira_cliente = client_wallet;
    }

    function changeStateClient()  public {
        require(
            msg.sender == carteira_cliente, "Somente o cliente pode assinar"
        );
        require(
            !contrato_iniciado, "Contrato ja foi aprovado e iniciado pelas partes"
        );
        cliente_assinou = !cliente_assinou;
    }

    function changeStateTokenizadora()  public {
        require(
            msg.sender == carteira_tokenizadora, "Somente a tokenizadora pode assinar"
        );
        require(
            !contrato_iniciado, "Contrato ja foi aprovado e iniciado pelas partes"
        );
        tokenizadora_assinou = !tokenizadora_assinou;
    }

    function setarContratoRwa(string memory uri) public {
        require(
            msg.sender == carteira_tokenizadora, "Somente a tokenizadora pode assinar"
        );
        contrato_rwa = uri;
        contrato_setado = true;
    }

    function inicialize() public {
        require(
            !contrato_iniciado, "Contrato ja foi iniciado"
        );
        require(
            cliente_assinou, "Client precisa ter assinado o contrato"
        );
        require(
            tokenizadora_assinou, "Tokenizadora precisa ter assinado o contrato"
        );
        require(
            contrato_setado, "Contrato precisa estar setado"
        );
        contrato_iniciado = true;
        _mint(carteira_cliente, 1000 ether);
    }
}