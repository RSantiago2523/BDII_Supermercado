CREATE OR REPLACE FUNCTION criar_encomenda_trigger()
RETURNS TRIGGER AS $$
BEGIN
    -- Se a operação for uma inserção (INSERT)
    IF TG_OP = 'INSERT' THEN
        -- Inserir na tabela ENCOMENDAS_A_FORNECEDORES quando um produto for criado
        INSERT INTO ENCOMENDAS_A_FORNECEDORES (
            UTILIZADOR_ID, 
            PRODUTO_ID, 
            DATA_ENCOMENDA_FORNECEDOR, 
            ESTADO_ENCOMENDA_FORNECEDOR, 
            PRECO_TOTAL_FORNECEDOR, 
            QUANTIDADE
        ) VALUES (
            NEW.UTILIZADOR_ID,  -- Relaciona com o fornecedor que criou o produto
            NEW.PRODUTO_ID, 
            CURRENT_TIMESTAMP, 
            'Pendente', 
            NEW.QUANTIDADE * NEW.PRECO,  -- Preço total para a quantidade inicial
            NEW.QUANTIDADE  -- A quantidade inserida inicialmente
        );

    -- Se a operação for uma atualização (UPDATE) e a quantidade foi aumentada
    ELSIF TG_OP = 'UPDATE' AND NEW.QUANTIDADE > OLD.QUANTIDADE THEN
        -- Inserir na tabela ENCOMENDAS_A_FORNECEDORES quando a quantidade de um produto for aumentada
        INSERT INTO ENCOMENDAS_A_FORNECEDORES (
            UTILIZADOR_ID, 
            PRODUTO_ID, 
            DATA_ENCOMENDA_FORNECEDOR, 
            ESTADO_ENCOMENDA_FORNECEDOR, 
            PRECO_TOTAL_FORNECEDOR, 
            QUANTIDADE
        ) VALUES (
            NEW.UTILIZADOR_ID,  -- Relaciona com o fornecedor
            NEW.PRODUTO_ID, 
            CURRENT_TIMESTAMP, 
            'Pendente', 
            (NEW.QUANTIDADE - OLD.QUANTIDADE) * NEW.PRECO,  -- Diferença de preço baseada na quantidade aumentada
            NEW.QUANTIDADE - OLD.QUANTIDADE  -- Diferença da quantidade
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE or replace TRIGGER trigger_criar_encomenda
AFTER INSERT OR UPDATE ON PRODUTOS
FOR EACH ROW
EXECUTE FUNCTION criar_encomenda_trigger();





CREATE OR REPLACE FUNCTION atualizar_valor_total_transacao() 
RETURNS TRIGGER AS $$
BEGIN
    -- Atualizar o valor total da transação
    UPDATE TRANSACOES
    SET VALOR_TOTAL = VALOR_TOTAL + NEW.PRECO_TOTAL
    WHERE ENCOMENDA_ID = NEW.ENCOMENDA_ID;

    -- Retornar o novo item de encomenda
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar o trigger para disparar a função quando um item de encomenda for inserido
CREATE TRIGGER trigger_atualizar_valor_total
AFTER INSERT ON ITEM_DE_ENCOMENDA
FOR EACH ROW
EXECUTE FUNCTION atualizar_valor_total_transacao();

-- Criar o trigger para disparar a função quando uma encomenda for inserida
CREATE OR REPLACE FUNCTION criar_transacao_ao_criar_encomenda() 
RETURNS TRIGGER AS $$
DECLARE
    nova_transacao_id INT;
BEGIN
    -- Inserir uma nova transação com os dados da encomenda
    INSERT INTO TRANSACOES (ENCOMENDA_ID, UTILIZADOR_ID, DATA_TRANSACAO, METODO_PAGAMENTO, VALOR_TOTAL)
    VALUES (
        NEW.ENCOMENDA_ID,  -- ID da encomenda
        NEW.UTILIZADOR_ID, -- ID do utilizador
        NOW(),             -- Data da transação
        'Pendente',        -- Método de pagamento (pode ser ajustado conforme necessário)
        0                   -- Valor total inicial (será atualizado depois pela trigger 2)
    )
    RETURNING TRANSACAO_ID INTO nova_transacao_id;

    -- Atualizar a tabela ENCOMENDAS com o ID da nova transação
    UPDATE ENCOMENDAS
    SET TRANSACAO_ID = nova_transacao_id
    WHERE ENCOMENDA_ID = NEW.ENCOMENDA_ID;

    -- Retornar a nova encomenda
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_criar_transacao
AFTER INSERT ON ENCOMENDAS
FOR EACH ROW
EXECUTE FUNCTION criar_transacao_ao_criar_encomenda();



CREATE OR REPLACE FUNCTION atualizar_stock_produto()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
BEGIN
    UPDATE PRODUTOS
    SET stock = stock - NEW.quantidade
    WHERE id = NEW.id_produto;
    
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_atualizar_stock_produto
AFTER INSERT ON ITEM_DE_ENCOMENDA
FOR EACH ROW
EXECUTE FUNCTION atualizar_stock_produto();


CREATE OR REPLACE FUNCTION repor_stock_produto()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
BEGIN
    UPDATE PRODUTOS
    SET stock = stock + NEW.quantidade
    WHERE id = NEW.id_produto;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_repor_stock_produto
AFTER INSERT ON ENCOMENDAS_A_FORNECEDORES
FOR EACH ROW
EXECUTE FUNCTION repor_stock_produto();
