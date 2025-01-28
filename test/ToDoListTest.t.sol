// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {ToDoList} from "../src/ToDoList.sol";
import {Test, console2} from "lib/forge-std/src/Test.sol";

contract ToDoListTest is Test {
    ToDoList toDoList;
    address public constant USER = address(1);
    string public constant DESCRICAO = "Estudar";

    function setUp() public {
        toDoList = new ToDoList();
    }

    function testSetTarefa() public {
        vm.startBroadcast(USER);
        vm.expectEmit(true, true, true, true);
        emit ToDoList.ToDoList_TarefaAdicionada(
            ToDoList.Tarefa({descricao: DESCRICAO, tempoDeCriacao: block.timestamp, foiCompletada: false})
        );
        toDoList.setTarefa(DESCRICAO);
        ToDoList.Tarefa[] memory tarefas = toDoList.getTarefa();
        ToDoList.Tarefa memory tarefa = tarefas[0];
        assertEq(tarefa.descricao, DESCRICAO);
        assertEq(tarefa.foiCompletada, false);
        assert(tarefa.tempoDeCriacao <= block.timestamp);
        vm.stopBroadcast();
    }

    function testDeletarTarefa() public {
        vm.startBroadcast(USER);
        toDoList.setTarefa(DESCRICAO);
        vm.expectEmit(true, true, true, true);
        emit ToDoList.ToDoList_TarefaCompletada(DESCRICAO);

        toDoList.deletarTarefa(DESCRICAO);

        ToDoList.Tarefa[] memory tarefas = toDoList.getTarefa();

        bool tarefaExistente = false;

        for (uint256 i = 0; i < tarefas.length; i++) {
            if (keccak256(abi.encodePacked(tarefas[i].descricao)) == keccak256(abi.encodePacked(DESCRICAO))) {
                tarefaExistente = true;
                break;
            }
        }
        assert(!tarefaExistente);
        vm.stopBroadcast();
    }
}
