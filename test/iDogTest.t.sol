// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {iDog} from "../src/iDog.sol";
import {Test, console2} from "lib/forge-std/src/Test.sol";

contract iDogTest is Test {
    iDog idog;
    address public constant OWNER = address(1);
    address public constant USER = address(2);

    function setUp() public {
        idog = new iDog(OWNER);
    }

    function testRegistroDeProdutoNotOwner() public {
        uint256 id = 0;
        uint256 valor = 1e18;
        uint8 status = 1;

        vm.startBroadcast(USER);
        vm.expectRevert(abi.encodeWithSelector(iDog.iDog_UsuarioNaoPermitido.selector, USER, OWNER));
        idog.registroDeProduto(id, valor, status);
        vm.stopBroadcast();
    }

    function testRegistroDeProdutosComValorMinimo() public {
        uint256 id = 0;
        uint256 valor = 1e15;
        uint256 valorMinimo = 1e16;
        uint8 status = 1;

        vm.startBroadcast(OWNER);
        vm.expectRevert(abi.encodeWithSelector(iDog.iDog_ValorInferiorAoMinimo.selector, valor, valorMinimo));
        idog.registroDeProduto(id, valor, status);
        vm.stopBroadcast();
    }

    function testQuantidadeRegistroProduto() public {
        uint256 valor = 1e18;
        uint8 status = 1;

        vm.startBroadcast(OWNER);

        for (uint256 i = 0; i < 20; i++) {
            idog.registroDeProduto(i, valor, status);
        }

        vm.expectRevert();
        idog.registroDeProduto(21, valor, status);
        vm.stopBroadcast();
    }

    function testRegistroDeProduto() public {
        uint256 id = 0;
        uint256 valor = 1e18;
        uint8 status = 1;

        vm.startBroadcast(OWNER);
        vm.expectEmit(true, true, true, true);
        emit iDog.iDog_NovoProdutoCadastrado(id, valor, status);
        idog.registroDeProduto(id, valor, status);
        vm.stopBroadcast();
    }

    function testAtualizarProdutoNotOwner() public {
        uint256 id = 0;
        uint256 valor = 1e18;
        uint256 valorAtt = 2e18;
        uint8 status = 1;
        uint8 statusAtt = 2;

        vm.startBroadcast(OWNER);
        idog.registroDeProduto(id, valor, status);
        vm.stopBroadcast();

        vm.expectRevert();
        vm.startBroadcast(USER);
        idog.atualizarProduto(id, valorAtt, statusAtt);
        vm.stopBroadcast();
    }

    function testAtualizarProdutoValorMinimo() public {
        uint256 id = 0;
        uint256 valor = 1e18;
        uint256 valorAtt = 1e15;
        uint8 status = 1;
        uint8 statusAtt = 2;

        vm.startBroadcast(OWNER);
        idog.registroDeProduto(id, valor, status);
        vm.stopBroadcast();

        vm.expectRevert();
        vm.startBroadcast(OWNER);
        idog.atualizarProduto(id, valorAtt, statusAtt);
        vm.stopBroadcast();
    }

    function testAtualizarProduto() public {
        uint256 id = 0;
        uint256 valor = 1e18;
        uint256 valorAtt = 2e18;
        uint8 status = 1;
        uint8 statusAtt = 2;

        vm.startBroadcast(OWNER);
        idog.registroDeProduto(id, valor, status);

        vm.expectEmit(true, true, true, true);
        emit iDog.iDog_ProdutoAtualizado(id, valorAtt, iDog.Status(statusAtt));
        idog.atualizarProduto(id, valorAtt, statusAtt);

        iDog.Produtos[20] memory produtos = idog.buscarProdutos();

        iDog.Produtos memory produto = produtos[0];

        assertEq(produto.idProduto, id);
        assertEq(produto.valor, valorAtt);
        assertEq(uint8(produto.status), statusAtt);

        vm.stopBroadcast();
    }

    function testCompraPrecoMenor() public {
        uint256 id = 0;
        uint256 valor = 1e18;
        uint8 status = 1;
        uint256 valorMenor = 1e17;
        uint256 initialBalance = 2 ether;

        vm.startBroadcast(OWNER);
        idog.registroDeProduto(id, valor, status);
        vm.stopBroadcast();

        vm.deal(USER, initialBalance);
        vm.startBroadcast(USER);
        vm.expectRevert(
            abi.encodeWithSelector(iDog.iDog_ValorEnviadoEDiferenteDoValorDoProduto.selector, valorMenor, valor)
        );
        idog.comprar{value: valorMenor}(id);
        vm.stopBroadcast();
    }

    function testCompraProdutoIndisponivel() public {
        uint256 id = 0;
        uint256 valor = 1e18;
        uint8 status = 1;
        uint8 statusAtt = 2;
        uint256 initialBalance = 2 ether;

        vm.startBroadcast(OWNER);
        idog.registroDeProduto(id, valor, status);
        idog.atualizarProduto(id, valor, statusAtt);
        vm.stopBroadcast();

        vm.deal(USER, initialBalance);
        vm.startBroadcast(USER);
        vm.expectRevert(abi.encodeWithSelector(iDog.iDog_ProdutoNaoDisponivel.selector, iDog.Status(statusAtt)));
        idog.comprar{value: valor}(id);
        vm.stopBroadcast();
    }

    function testSaqueNotOwner() public {
        uint256 id = 0;
        uint256 valor = 1e18;
        uint8 status = 1;
        uint256 initialBalance = 2 ether;

        vm.startBroadcast(OWNER);
        idog.registroDeProduto(id, valor, status);
        vm.stopBroadcast();

        vm.deal(USER, initialBalance);
        vm.startBroadcast(USER);
        idog.comprar{value: valor}(id);
        vm.stopBroadcast();

        vm.startBroadcast(USER);
        vm.expectRevert(abi.encodeWithSelector(iDog.iDog_UsuarioNaoPermitido.selector, USER, OWNER));
        idog.saque();
        vm.stopBroadcast();
    }

    function testSaque() public {
        uint256 id = 0;
        uint256 valor = 1e18;
        uint8 status = 1;
        uint256 initialBalance = 2 ether;

        vm.startBroadcast(OWNER);
        idog.registroDeProduto(id, valor, status);
        vm.stopBroadcast();

        vm.deal(USER, initialBalance);
        vm.startBroadcast(USER);
        idog.comprar{value: valor}(id);
        vm.stopBroadcast();

        vm.expectEmit(true, true, true, true);
        emit iDog.iDog_SaldoSacadoComSucesso(OWNER, address(idog).balance);
        vm.startBroadcast(OWNER);
        idog.saque();
        assertEq(address(idog).balance, 0);
        assert(address(OWNER).balance > 0);
        vm.stopBroadcast();
    }
}
