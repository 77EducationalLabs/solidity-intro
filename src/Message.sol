///SPDX-License_Identifier: MIT
pragma solidity 0.8.26;

/**
	*@notice Forneça contexto sobre o seu contrato.
	*@dev Passe informações sobre caracteristicas peculiares do seu contrato para outros Devs
    *@author Seu nome.
*/
contract Message {

	/// State Variables ///
	///@notice variável para armazenar mensagens
	string s_mensagem;
		
	/// Eventos ///
    ///@notice variável emitida quando a mensagem é atualizada
	event Message_MensagemAtualizada();
		
	/// Funções ///
    /**
        *@notice função para atualizar a mensagem do contrato
        *@param _mensagem mensagem que deverá ser armazenada
        *@dev deve emitir um evento para sempre que a mensagem for atualizada
    */
	function setMensagem(string memory _mensagem) external {
		s_mensagem = _mensagem;
		
		emit Message_MensagemAtualizada();
	}
	
    /**
        *@notice função get para retornar a mensagem armazenada
        *@return _mensagem armazenada
    */
	function getMessage() public view returns(string memory _mensagem){
	_mensagem = s_mensagem;
	} 
}
