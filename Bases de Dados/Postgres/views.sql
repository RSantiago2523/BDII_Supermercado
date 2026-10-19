CREATE OR REPLACE VIEW public.view_todos_produtos
 AS
 SELECT produtos.produto_id,
    utilizadores.nome AS fornecedor_nome,
    produtos.nome AS produto_nome,
    produtos.descricao,
    produtos.preco,
    produtos.categoria,
    produtos.quantidade,
	produtos.desconto
   FROM produtos
     JOIN utilizadores ON produtos.utilizador_id = utilizadores.utilizador_id;

CREATE OR REPLACE VIEW listar_funcionarios_view AS
SELECT 
    UTILIZADOR_ID,
    NOME,
    EMAIL,
    TIPO_UTILIZADOR,
    MORADA,
    TELEFONE,
    FUNCOES
FROM 
    UTILIZADORES
WHERE 
    TIPO_UTILIZADOR NOT IN ('Cliente', 'Fornecedor','Administrador');
	
CREATE OR REPLACE VIEW listar_utilizadores_view AS
SELECT 
    UTILIZADOR_ID,
    NOME,
    EMAIL,
    TIPO_UTILIZADOR,
    MORADA,
    TELEFONE
FROM 
    UTILIZADORES
WHERE 
    TIPO_UTILIZADOR NOT IN ('Funcionario');
	
	CREATE OR REPLACE VIEW vw_transacoes AS
SELECT 
    t.transacao_id,
    t.encomenda_id,
    t.utilizador_id,
    u.nome AS nome_utilizador,
    t.data_transacao,
    t.metodo_pagamento,
    t.valor_total
FROM 
    transacoes t
LEFT JOIN 
    utilizadores u ON t.utilizador_id = u.utilizador_id;
	


CREATE OR REPLACE VIEW vw_detalhes_encomendas AS
SELECT 
    e.encomenda_id,
    e.utilizador_id,
    e.data_encomenda,
    e.estado,
    i.produto_id,
    p.nome,
    i.quantidade,
    i.preco_total,
	e.tipo_entrega,
	e.morada
FROM 
    encomendas e
LEFT JOIN 
    item_de_encomenda i ON e.encomenda_id = i.encomenda_id
LEFT JOIN 
    produtos p ON i.produto_id = p.produto_id;
	
CREATE OR REPLACE VIEW vw_detalhes_encomendas_fornecedores AS
SELECT 
    e.encomenda_fornecedor_id,
    e.utilizador_id,
    e.produto_id,
    p.nome AS produto_nome,
    e.data_encomenda_fornecedor,
    e.estado_encomenda_fornecedor,
    e.quantidade,
    e.preco_total_fornecedor
FROM 
    encomendas_a_fornecedores e
LEFT JOIN 
    produtos p ON e.produto_id = p.produto_id;
