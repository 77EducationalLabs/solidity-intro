//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
	*@notice Descrição objetiva para dar contexto
	*@author Seu nome
*/
contract Dognations {

	/// State Variables ///
	///@notice variável imutável para armazenar o endereço que deve sacar as doações
	address immutable i_beneficiario;
	
	///@notice mapping para armazenar o valor doado por usuário
	mapping(address usuario => uint256 valor) public s_doacoes;
	///@notice mapping para armazenar as notas submetidas
	mapping(uint256 notaID => bool foiSubmetida) public s_notasDeGastos;
	
	/// Events ///
	///@notice evento emitido quando uma nova doação é feita
	event Dognations_DoacaoRecebida(address doador, uint256 valor);
	///@notice evento emitido quando um saque é realizado
	event Dognations_SaqueRealizado(address recebedor, uint256 valor);
	
	/// Errors ///
	///@notice erro emitido quando uma transação falha
	error Dognations_TrasacaoFalhou(bytes erro);
	///@notice erro emitido quando um endereço diferente do beneficiario tentar sacar
	error Dognations_SacadorNaoPermitido(address chamador, address beneficiario);
	///@notice erro emitido se uma nota repetida for submetida
	error Dognations_NotaSubtmetidaAnteriormente(uint256 id);
	
	/// Functions ///
	constructor(address _beneficiario){
		i_beneficiario = _beneficiario;
	}
	
	
	///@notice função para receber ether diretamente
	receive() external payable{}
	fallback() external{}
	
	/**
		*@notice função para receber doações
		*@dev essa função deve somar o valor doado por cada endereço no decorrer do tempo
		*@dev essa função precisa emitir um evento informando a doação.
	*/
	function doe() external payable {
		s_doacoes[msg.sender] = s_doacoes[msg.sender] += msg.value;
	
		emit Dognations_DoacaoRecebida(msg.sender, msg.value);
	}
	
	/**
		*@notice função para saque do valor das doações
		*@notice o valor do saque deve ser o valor da nota enviada
		*@dev somente o beneficiário pode sacar
		*@param _id O ID da nota fiscal
		*@param _valor O valor da nota fiscal
	*/
	function saque(uint256 _id, uint256 _valor) external {
		if(msg.sender != i_beneficiario) revert Dognations_SacadorNaoPermitido(msg.sender, i_beneficiario);
		
		if(s_notasDeGastos[_id] == true){
			revert Dognations_NotaSubtmetidaAnteriormente(_id);
		} else {
			s_notasDeGastos[_id] = true;
		}
		
		emit Dognations_SaqueRealizado(msg.sender, _valor);
		
		_transferirEth(_valor);
	}
	
	/**
		*@notice função privada para realizar a transferência do ether
		*@param _valor O valor à ser transferido
		*@dev precisa reverter se falhar
	*/
	function _transferirEth(uint256 _valor) private {
		(bool sucesso, bytes memory erro) = msg.sender.call{value: _valor}("");
		if(!sucesso) revert Dognations_TrasacaoFalhou(erro);
	}
	
	/**
		*@notice função pure para calcular o valor necessário para cobrir uma despesa
		*@param _valorDisponivel valor de ether em caixa
		*@param _valorDaNota valor da despesa a ser paga
	*/
	function calculo(int256 _valorDisponivel, int256 _valorDaNota) public pure returns(int256 _resultado){
		_resultado = _valorDisponivel - _valorDaNota;
	}
}