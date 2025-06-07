// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Dognations} from "../src/Dognations.sol";
import {Test, console2} from "lib/forge-std/src/Test.sol";

contract DognationsTest is Test {
    Dognations dognations;
    address public constant BENEFICIARIO = address(1);
    address public constant USER = address(2);

    function setUp() public {
        dognations = new Dognations(BENEFICIARIO);
    }

    function testDoe() public {
        uint256 initialBalance = 1 ether;
        uint256 donationAmount = 0.1 ether;

        vm.deal(USER, initialBalance);
        vm.expectEmit(true, true, true, true);
        emit Dognations.Dognations_DoacaoRecebida(USER, donationAmount);

        vm.startBroadcast(USER);
        dognations.doe{value: donationAmount}();
        vm.stopBroadcast();

        assertEq(USER.balance, initialBalance - donationAmount);
        assertEq(address(dognations).balance, donationAmount);
    }

    function testSaqueNaoBeneficiario() public {
        uint256 initialBalance = 1 ether;
        uint256 donationAmount = 0.1 ether;

        vm.deal(USER, initialBalance);

        vm.startBroadcast(USER);
        dognations.doe{value: donationAmount}();
        vm.stopBroadcast();

        vm.startBroadcast(USER);
        vm.expectRevert(abi.encodeWithSelector(Dognations.Dognations_SacadorNaoPermitido.selector, USER, BENEFICIARIO));
        dognations.saque(1, donationAmount);
        vm.stopBroadcast();
    }

    function testSaqueNotaExistente() public {
        uint256 initialBalance = 1 ether;
        uint256 donationAmount = 0.1 ether;
        uint256 id = 1;
        vm.deal(USER, initialBalance);

        vm.startBroadcast(USER);
        dognations.doe{value: donationAmount}();
        vm.stopBroadcast();
        vm.startBroadcast(BENEFICIARIO);
        dognations.saque(id, donationAmount);
        vm.stopBroadcast();

        vm.startBroadcast(USER);
        dognations.doe{value: donationAmount}();
        vm.stopBroadcast();

        vm.startBroadcast(BENEFICIARIO);
        vm.expectRevert(abi.encodeWithSelector(Dognations.Dognations_NotaSubtmetidaAnteriormente.selector, id));
        dognations.saque(id, donationAmount);
        vm.stopBroadcast();
    }

    function testTransferErro() public {
        uint256 initialBalance = 1 ether;
        uint256 donationAmount = 0.1 ether;
        uint256 saque = 0.2 ether;
        uint256 id = 1;

        vm.deal(USER, initialBalance);

        vm.startBroadcast(USER);
        dognations.doe{value: donationAmount}();
        vm.stopBroadcast();

        vm.startBroadcast(BENEFICIARIO);
        vm.expectRevert(abi.encodeWithSelector(Dognations.Dognations_TrasacaoFalhou.selector, bytes("")));
        dognations.saque(id, saque);
        vm.stopBroadcast();
    }

    function testSaque() public {
        uint256 initialBalance = 1 ether;
        uint256 donationAmount = 0.1 ether;
        uint256 id = 1;

        vm.deal(USER, initialBalance);

        vm.startBroadcast(USER);
        dognations.doe{value: donationAmount}();
        vm.stopBroadcast();

        vm.startBroadcast(BENEFICIARIO);
        vm.expectEmit(true, true, true, true);
        emit Dognations.Dognations_SaqueRealizado(BENEFICIARIO, donationAmount);
        dognations.saque(id, donationAmount);
        vm.stopBroadcast();

        assertEq(address(dognations).balance, 0);
        assertEq(BENEFICIARIO.balance, donationAmount);
    }

    function testCalculo() public view {
        int256 valorDisponivel = 1000;
        int256 valorDaNota = 400;
        int256 resultadoEsperado = 600;

        int256 resultado = dognations.calculo(valorDisponivel, valorDaNota);

        assertEq(resultado, resultadoEsperado);
    }
}
