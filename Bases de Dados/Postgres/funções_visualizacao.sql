-- Exibir produtos
CREATE OR REPLACE FUNCTION public.exibir_produtos()
RETURNS TABLE(
    produto_id BIGINT, 
    fornecedor_nome TEXT, 
    produto_nome TEXT, 
    descricao TEXT, 
    preco DECIMAL(10,2), 
    categoria TEXT, 
    quantidade INT,
    desconto DECIMAL(10,2)
) 
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY SELECT * FROM view_todos_produtos;
END;
$BODY$;

-- Exibir funcionários
CREATE OR REPLACE FUNCTION public.exibir_funcionarios()
RETURNS TABLE(
    utilizador_id BIGINT, 
    nome TEXT, 
    email TEXT, 
    tipo_utilizador TEXT, 
    morada TEXT, 
    telefone TEXT, 
    funcoes TEXT
) 
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY SELECT * FROM listar_funcionarios_view;
END;
$BODY$;

-- Exibir utilizadores (exceto funcionários)
CREATE OR REPLACE FUNCTION public.exibir_utilizadores()
RETURNS TABLE(
    utilizador_id BIGINT, 
    nome TEXT, 
    email TEXT, 
    tipo_utilizador TEXT, 
    morada TEXT, 
    telefone TEXT
) 
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY SELECT * FROM listar_utilizadores_view;
END;
$BODY$;

-- Exibir transações
CREATE OR REPLACE FUNCTION public.exibir_transacoes()
RETURNS TABLE(
    transacao_id BIGINT, 
    encomenda_id BIGINT, 
    utilizador_id BIGINT, 
    nome_utilizador TEXT, 
    data_transacao TIMESTAMP, 
    metodo_pagamento TEXT, 
    valor_total DECIMAL(10,2)
) 
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY SELECT * FROM vw_transacoes;
END;
$BODY$;

-- Exibir detalhes das encomendas
CREATE OR REPLACE FUNCTION public.exibir_detalhes_encomendas()
RETURNS TABLE(
    encomenda_id BIGINT, 
    utilizador_id BIGINT, 
    data_encomenda TIMESTAMP, 
    estado TEXT, 
    produto_id BIGINT, 
    nome TEXT, 
    quantidade INT, 
    preco_total DECIMAL(10,2),
    tipo_entrega TEXT,
    morada TEXT
) 
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY SELECT * FROM vw_detalhes_encomendas;
END;
$BODY$;

-- Exibir detalhes das encomendas dos fornecedores
CREATE OR REPLACE FUNCTION public.exibir_detalhes_encomendas_fornecedores()
RETURNS TABLE(
    encomenda_fornecedor_id BIGINT, 
    utilizador_id BIGINT, 
    produto_id BIGINT, 
    produto_nome TEXT, 
    data_encomenda_fornecedor TIMESTAMP, 
    estado_encomenda_fornecedor TEXT, 
    quantidade INT, 
    preco_total_fornecedor DECIMAL(10,2)
) 
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY SELECT * FROM vw_detalhes_encomendas_fornecedores;
END;
$BODY$;
