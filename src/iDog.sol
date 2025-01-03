///SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
    *@title Nome do Contrato
    *@notice Descrição do Projeto
    *@author Seu nome
*/
contract iDog{

	/// State Variables
	///@notice enum para fornecer dados de disponibilidade de forma mais descritiva
	enum Status{
		producao, //0
		disponivel, //1
		esgotado //2
	}
	
	///@notice struct para armazenar informações do produto
	struct Produtos{
		uint256 idProduto;
		uint256 valor;
		Status status;
	}
	
	///@notice variável para armazenar o endereço do dono do contrato
	address immutable i_owner;
	///@notice variável para armazenar o valor mínimo de cada produto
	uint256 constant VALOR_MINIMO = 1*10**16;
	///@notice variável para contar os produtos adicionados
	uint256 s_contadorDeProdutos;

	///@notice array para armazenar os produtos cadastrados
	Produtos[20] s_produtos;
	
	/// Events ///
	///@notice evento emitido quando um novo produto é cadastrado.
	event iDog_NovoProdutoCadastrado(uint256 id, uint256 valor, uint8 status);
	///@notice evento emitido quando um produto é atualizado
	event iDog_ProdutoAtualizado(uint256 id, uint256 valor, Status status);
	///@notice evento emitido quando um produto é vendido
	event iDog_ProdutoVendido(uint256 id, uint256 valor);
	///@notice evento emitido quando um saque é efetuado
	event iDog_SaldoSacadoComSucesso(address recebedor, uint256 valor);
	
	/// Errors ///
	///@notice erro emitido quando o chamador não é o dono do contrato.
	error iDog_UsuarioNaoPermitido(address chamador, address owner);
	///@notice erro emitido quando o valor do input é menor que o minimo exigido 
	error iDog_ValorInferiorAoMinimo(uint256 valorEnviado, uint256 valorMinimo);
	///@notice erro emitido quando o valor enviado é diferente do valor do produto selecionado
	error iDog_ValorEnviadoEDiferenteDoValorDoProduto(uint256 valorEnviado, uint256 valorDoProduto);
	///@notice erro emitido quando um produto não está disponível
	error iDog_ProdutoNaoDisponivel(Status status);
	///@notice erro emitido quando uma transferencia falha
	error iDog_TransferenciaFalhou(bytes erro);
	
	/// Functions ///
	///@notice modifier para checar se o chamador é o dono do contrato.
	modifier onlyOwner() {
		if(msg.sender != i_owner) revert iDog_UsuarioNaoPermitido(msg.sender, i_owner);
		_;
	}
	
	constructor(address _owner){
		i_owner = _owner;
	}
	
	/**
		*@notice função payable para que usuários possam comprar os produtos
		*@param _index posição do produto no array
		*@dev a função deve reverter se: 1) valor for diferente. 2) se o produto não estiver disponível
	*/
	function comprar(uint256 _index) external payable {
		Produtos memory produto = s_produtos[_index];
		if(msg.value != produto.valor) revert iDog_ValorEnviadoEDiferenteDoValorDoProduto(msg.value, produto.valor);
		if(produto.status != Status.disponivel) revert iDog_ProdutoNaoDisponivel(produto.status);
		
		emit iDog_ProdutoVendido(produto.idProduto, msg.value);
	}
	
	/**
		*@notice função para sacar o valor dos produtos vendidos acumulados no contrato
		*@dev apenas o dono do contrato pode sacar
		*@dev emite um evento se ocorrer bem, reverte se tiver algum problema.
	*/
	function saque() external onlyOwner{
		emit iDog_SaldoSacadoComSucesso(i_owner, address(this).balance);
	
		(bool success, bytes memory erro) = i_owner.call{value: address(this).balance}("");
		if(!success) revert iDog_TransferenciaFalhou(erro);
	}
	
	/**
		*@notice funcão para atualizar um produto cadastrado
		*@param _index a posição do produto no array
		*@param _valor o valor do produto
		*@param _status o status do produto
	*/
	function atualizarProduto(uint256 _index, uint256 _valor, uint8 _status) external onlyOwner{
		if(_valor < VALOR_MINIMO) revert iDog_ValorInferiorAoMinimo(_valor, VALOR_MINIMO);
		
		Produtos storage produto = s_produtos[_index];
		produto.valor = _valor;
		produto.status = Status(_status);
		
		emit iDog_ProdutoAtualizado(produto.idProduto, produto.valor, produto.status);
	}
	
	/**
		*@notice Função para registrar produtos no marketplace
		*@param _id O identificador do produto
		*@param _valor o valor do produto
		*@param _status o status do produto
		*@dev Essa função precisa reverter se o chamador não for o owner.
		*@dev Um produto não pode ter um valor inferior à constante VALOR_MINIMO
	*/
	function registroDeProduto(uint256 _id, uint256 _valor, uint8 _status) external onlyOwner{
		if(_valor < VALOR_MINIMO) revert iDog_ValorInferiorAoMinimo(_valor, VALOR_MINIMO);
		
		s_produtos[s_contadorDeProdutos] = Produtos ({
			idProduto: _id,
			valor: _valor,
			status: Status(_status)
		});
		
		s_contadorDeProdutos = s_contadorDeProdutos + 1;
		
		emit iDog_NovoProdutoCadastrado(_id, _valor, _status);
	}
	
	/// Pure & View ///
	/**
		*@notice função getter para retornar os produtos disponíveis
		*@return _produto array de produtos registrados.
	*/
	function buscarProdutos() external view returns(Produtos[20] memory _produto){
		_produto = s_produtos;
	}
}