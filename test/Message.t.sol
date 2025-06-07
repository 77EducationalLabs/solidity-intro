// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Message} from "../src/Message.sol";
import {Test, console2} from "lib/forge-std/src/Test.sol";

contract MessageTest is Test {
    Message message;
    address public constant USER = address(1);
    string public constant NOVA_MENSAGEM = "Mensagem atualizada com sucesso!";

    function setUp() public {
        message = new Message();
    }

    function testSetMensagem() public {
        vm.startBroadcast(USER);
        vm.expectEmit(true, true, true, true);
        emit Message.Message_MensagemAtualizada();
        message.setMensagem(NOVA_MENSAGEM);
        assertEq(message.getMessage(), NOVA_MENSAGEM);
        vm.stopBroadcast();
    }
}
