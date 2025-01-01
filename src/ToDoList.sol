// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ToDoList {
	
	/// Variáveis de Estado ///
    ///@notice struct para armazenar informações de tarefas
	struct Tarefa{
		string descricao;
		uint256 tempoDeCriacao;
		bool foiCompletada;
	}
	
    ///@notice array de Tarefas
	Tarefa[] public s_tarefas;
	
	/// Events ///
    ///@notice evento emitido quando uma nova tarefa é adicionada
	event ToDoList_TarefaAdicionada(Tarefa tarefa);
    ///@notice evento emitido quando uma tarefa é completada
	event ToDoList_TarefaCompletada(string descricao);
	
	/// Functions ///
    /**
        *@notice função para deletar tarefas completadas do array
        *@param _descricao a descrição da tarefa à ser deletada
        *@dev precisa emitir evento sempre que uma tarefa for removida
    */
	function deletarTarefa(string memory _descricao) external {
		uint256 tamanho = s_tarefas.length;
		
		for(uint256 i; i < tamanho; i++ ){
			if(keccak256(abi.encodePacked(_descricao)) == keccak256(abi.encodePacked(s_tarefas[i].descricao))){
				s_tarefas[i] = s_tarefas[tamanho -1];
				s_tarefas.pop();
				
				emit ToDoList_TarefaCompletada(_descricao);
				return;
			}
		}
	}
	
    /**
        *@notice função para adicionar tarefas pendentes ao contrato
        *@param _descricao descrição da tarefa à ser adicionada.
        *@dev precisa emitir um evento sempre que uma tarefa for adicionada
    */
	function setTarefa(string memory _descricao) external {
		Tarefa memory tarefa = Tarefa({
			descricao: _descricao,
			tempoDeCriacao: block.timestamp,
			foiCompletada: false
		});
		
		s_tarefas.push(tarefa);
		
		emit ToDoList_TarefaAdicionada(tarefa);
	}
	
    /**
        *@notice função para retornar informações de tarefas
        *@return _tarefa um array de tarefas
    */
	function getTarefa() external view returns(Tarefa[] memory _tarefa){
		_tarefa = s_tarefas;
	}
}