-- ==============================================================
-- Verificar e remover tabelas existentes                      
-- ==============================================================
DO $$
BEGIN

    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'produtos') THEN
        DROP TABLE PRODUTOS;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'item_de_encomenda') THEN
        DROP TABLE ITEM_DE_ENCOMENDA;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'encomendas_a_fornecedores') THEN
        DROP TABLE ENCOMENDAS_A_FORNECEDORES;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'encomendas') THEN
        DROP TABLE ENCOMENDAS;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'transacoes') THEN
        DROP TABLE TRANSACOES;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'utilizadores') THEN
        DROP TABLE UTILIZADORES;
    END IF;
END $$;




-- ==============================================================
-- Tabela: UTILIZADORES                                         
-- ==============================================================
CREATE TABLE UTILIZADORES (
   UTILIZADOR_ID        SERIAL PRIMARY KEY,
   NOME                 VARCHAR(255),
   EMAIL                VARCHAR(255),
   PASSWORD             VARCHAR(255),
   TIPO_UTILIZADOR      VARCHAR(50),
   MORADA               VARCHAR(255),
   TELEFONE             VARCHAR(15),
   FUNCOES              VARCHAR(255)
);

-- ==============================================================
-- Tabela: ENCOMENDAS                                           
-- ==============================================================
CREATE TABLE ENCOMENDAS (
   ENCOMENDA_ID         SERIAL PRIMARY KEY,
   UTILIZADOR_ID        INT NOT NULL,
   TRANSACAO_ID         INT,
   DATA_ENCOMENDA       TIMESTAMP,
   ESTADO               VARCHAR(50),
   TIPO_ENTREGA         VARCHAR(50) DEFAULT 'entrega',
   MORADA               VARCHAR(255) NULL,
   CONSTRAINT FK_ENCOMEND_FAZER_UTILIZAD FOREIGN KEY (UTILIZADOR_ID)
      REFERENCES UTILIZADORES (UTILIZADOR_ID)
);

-- ==============================================================
-- Tabela: TRANSACOES                                           
-- ==============================================================
CREATE TABLE TRANSACOES (
   TRANSACAO_ID         SERIAL PRIMARY KEY,
   ENCOMENDA_ID         INT ,
   UTILIZADOR_ID        INT ,
   DATA_TRANSACAO       TIMESTAMP,
   METODO_PAGAMENTO     VARCHAR(50),
   VALOR_TOTAL          FLOAT,
   CONSTRAINT FK_TRANSACO_PAGA_ENCOMEND FOREIGN KEY (ENCOMENDA_ID)
      REFERENCES ENCOMENDAS (ENCOMENDA_ID),
   CONSTRAINT FK_TRANSACO_SUPERVISI_UTILIZAD FOREIGN KEY (UTILIZADOR_ID)
      REFERENCES UTILIZADORES (UTILIZADOR_ID)
);

-- ==============================================================
-- Tabela: PRODUTOS                                             
-- ==============================================================
CREATE TABLE PRODUTOS (
   PRODUTO_ID           SERIAL PRIMARY KEY,
   UTILIZADOR_ID        INT NOT NULL,
   NOME                 VARCHAR(255),
   DESCRICAO            TEXT,
   PRECO                FLOAT,
   CATEGORIA            VARCHAR(50),
   QUANTIDADE           FLOAT,
   DESCONTO             FLOAT DEFAULT 0,
   CONSTRAINT FK_PRODUTOS_GERIR_UTILIZAD FOREIGN KEY (UTILIZADOR_ID)
      REFERENCES UTILIZADORES (UTILIZADOR_ID)
);


-- ==============================================================
-- Tabela: ITEM_DE_ENCOMENDA                                    
-- ==============================================================
CREATE TABLE ITEM_DE_ENCOMENDA (
   ITEM_DE_ENCOMENDA_ID SERIAL PRIMARY KEY,
   PRODUTO_ID           INT NOT NULL,
   ENCOMENDA_ID         INT,
   QUANTIDADE           FLOAT,
   PRECO_TOTAL          FLOAT,
   CONSTRAINT FK_ITEM_DE__TER_ENCOMEND FOREIGN KEY (ENCOMENDA_ID)
      REFERENCES ENCOMENDAS (ENCOMENDA_ID),
   CONSTRAINT FK_ITEM_DE_REFERENCIA_PRODUTOS FOREIGN KEY (PRODUTO_ID)
      REFERENCES PRODUTOS (PRODUTO_ID) 
);


-- ==============================================================
-- Tabela: ENCOMENDAS_A_FORNECEDORES                            
-- ==============================================================
CREATE TABLE ENCOMENDAS_A_FORNECEDORES (
   ENCOMENDA_FORNECEDOR_ID SERIAL PRIMARY KEY,
   UTILIZADOR_ID        INT NOT NULL,
   PRODUTO_ID           INT NOT NULL,
   DATA_ENCOMENDA_FORNECEDOR TIMESTAMP,
   ESTADO_ENCOMENDA_FORNECEDOR VARCHAR(50),
   PRECO_TOTAL_FORNECEDOR FLOAT,
   QUANTIDADE Int,
   CONSTRAINT FK_ENCOMEND_COMPRAR_UTILIZAD FOREIGN KEY (UTILIZADOR_ID)
      REFERENCES UTILIZADORES (UTILIZADOR_ID),
   CONSTRAINT FK_ITEM_DE_REFERENCIA_PRODUTOS FOREIGN KEY (PRODUTO_ID)
      REFERENCES PRODUTOS (PRODUTO_ID) 
);




CREATE OR REPLACE FUNCTION add_produto(
    p_fornecedor_id INT,
    p_nome VARCHAR(255),
    p_descricao TEXT,
    p_preco FLOAT,
    p_categoria VARCHAR(50),
    p_quantidade FLOAT
) RETURNS VOID AS $$
BEGIN
    -- Verifica se UTILIZADOR_ID existe
    IF NOT EXISTS (SELECT 1 FROM UTILIZADORES WHERE UTILIZADOR_ID = p_fornecedor_id) THEN
        RAISE EXCEPTION 'Utilizador com ID % não existe.', p_fornecedor_id;
    END IF;

    -- Insere o produto
    INSERT INTO PRODUTOS (
        UTILIZADOR_ID,
        NOME,
        DESCRICAO,
        PRECO,
        CATEGORIA,
        QUANTIDADE
    ) VALUES (
        p_fornecedor_id,
        p_nome,
        p_descricao,
        p_preco,
        p_categoria,
        p_quantidade
    );
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION remove_produto(p_produto_id INT)
RETURNS VOID AS $$
BEGIN
    -- Verifica se o produto existe antes de tentar deletar
    IF EXISTS (SELECT 1 FROM PRODUTOS WHERE PRODUTO_ID = p_produto_id) THEN
        -- Primeiro remove as referências do produto na tabela encomendas_a_fornecedores
        DELETE FROM encomendas_a_fornecedores WHERE produto_id = p_produto_id;
        
        -- Agora tenta excluir o produto
        DELETE FROM PRODUTOS WHERE PRODUTO_ID = p_produto_id;
        
        RAISE NOTICE 'Produto com ID % e suas referências em encomendas_a_fornecedores foram removidos com sucesso.', p_produto_id;
    ELSE
        RAISE NOTICE 'Produto com ID % não encontrado.', p_produto_id;
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION atualizar_estoque(p_produto_id INT, p_quantidade FLOAT)
RETURNS VOID AS $$
BEGIN
    -- Verifica se o produto existe antes de tentar atualizar
    IF EXISTS (SELECT 1 FROM PRODUTOS WHERE PRODUTO_ID = p_produto_id) THEN
        UPDATE PRODUTOS
        SET QUANTIDADE = QUANTIDADE + p_quantidade  -- Adiciona a quantidade ao estoque atual
        WHERE PRODUTO_ID = p_produto_id;
        RAISE NOTICE 'Estoque atualizado para o produto com ID %. Quantidade adicionada: %.', p_produto_id, p_quantidade;
    ELSE
        RAISE NOTICE 'Produto com ID % não encontrado.', p_produto_id;
    END IF;
END;
$$ LANGUAGE plpgsql;




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
	

CREATE OR REPLACE FUNCTION remover_funcionario(p_utilizador_id INTEGER) 
RETURNS VOID AS 
$$
BEGIN
    -- Apagar transações associadas às encomendas do funcionário
    DELETE FROM transacoes 
    WHERE encomenda_id IN (
        SELECT encomenda_id FROM encomendas WHERE utilizador_id = p_utilizador_id
    );

    -- Apagar itens da encomenda
    DELETE FROM item_de_encomenda 
    WHERE encomenda_id IN (
        SELECT encomenda_id FROM encomendas WHERE utilizador_id = p_utilizador_id
    );

    -- Apagar encomendas associadas ao funcionário
    DELETE FROM encomendas WHERE utilizador_id = p_utilizador_id;

    -- Apagar o funcionário
    DELETE FROM utilizadores WHERE utilizador_id = p_utilizador_id;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION adicionar_utilizador(
    p_nome VARCHAR(255),
    p_email VARCHAR(255),
    p_password VARCHAR(255),
    p_morada VARCHAR(255),
    p_telefone VARCHAR(15),
    p_funcoes VARCHAR(255)
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO UTILIZADORES (
        NOME,
        EMAIL,
        PASSWORD,
        TIPO_UTILIZADOR,
        MORADA,
        TELEFONE,
        FUNCOES
    ) VALUES (
        p_nome,
        p_email,
        p_password,
        'Funcionario', -- Valor fixo para TIPO_UTILIZADOR
        p_morada,
        p_telefone,
        p_funcoes
    );
    RAISE NOTICE 'Funcionário % foi adicionado com sucesso.', p_nome;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION editar_funcionario(
    p_utilizador_id INT,
    p_nome VARCHAR(255),
    p_email VARCHAR(255),
    p_password VARCHAR(255),
    p_morada VARCHAR(255),
    p_telefone VARCHAR(15),
    p_funcoes VARCHAR(255)
)
RETURNS VOID AS $$
BEGIN
    -- Verifica se o funcionário existe antes de tentar atualizar
    IF EXISTS (SELECT 1 FROM UTILIZADORES WHERE UTILIZADOR_ID = p_utilizador_id) THEN
        UPDATE UTILIZADORES
        SET 
            NOME = COALESCE(p_nome, NOME),
            EMAIL = COALESCE(p_email, EMAIL),
            PASSWORD = COALESCE(p_password, PASSWORD),
            MORADA = COALESCE(p_morada, MORADA),
            TELEFONE = COALESCE(p_telefone, TELEFONE),
            FUNCOES = COALESCE(p_funcoes, FUNCOES)
        WHERE UTILIZADOR_ID = p_utilizador_id;
    ELSE
        RAISE NOTICE 'Funcionário com ID % não encontrado.', p_utilizador_id;
    END IF;
END;
$$ LANGUAGE plpgsql;




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


-- Trigger para criar a transação quando a encomenda for criada
-- ==============================================================

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

-- Inserir 8 utilizadores na tabela UTILIZADORES com UTILIZADOR_ID de 1 a 8
INSERT INTO UTILIZADORES (UTILIZADOR_ID, NOME, EMAIL, PASSWORD, TIPO_UTILIZADOR, MORADA, TELEFONE, FUNCOES)
VALUES
    -- Cliente 1
    (1, 'João Silva', 'joao.silva@example.com', 'senha123', 'Cliente', 'Rua das Flores, 123', '912345678', NULL),
    
    -- Cliente 2
    (2, 'Ana Costa', 'ana.costa@example.com', 'senha123', 'Cliente', 'Avenida Central, 456', '932345678', NULL),
    
    -- Funcionario 1
    (3, 'Pedro Almeida', 'pedro.almeida@example.com', 'senha123', 'Funcionario', 'Rua da Liberdade, 789', '952345678', 'Vendedor'),
    
    -- Funcionario 2
    (4, 'Mariana Lopes', 'mariana.lopes@example.com', 'senha123', 'Funcionario', 'Travessa do Sol, 321', '962345678', 'Atendimento ao Cliente'),
    
    -- Fornecedor 1
    (5, 'Empresa A', 'empresa.a@example.com', 'senha123', 'Fornecedor', 'Parque Industrial, Lote 1', '972345678', 'Distribuição de Produtos'),
    
    -- Fornecedor 2
    (6, 'Empresa B', 'empresa.b@example.com', 'senha123', 'Fornecedor', 'Zona Comercial, Bloco 10', '982345678', 'Fornecimento de Matérias-primas'),
    
    -- Cliente 3
    (7, 'Carlos Nunes', 'carlos.nunes@example.com', 'senha123', 'Cliente', 'Rua do Campo, 654', '991234567', NULL),
    
    -- Cliente 4
    (8, 'Sofia Mendes', 'sofia.mendes@example.com', 'senha123', 'Cliente', 'Praça da Paz, 987', '981234567', NULL);


-- Inserir 8 encomendas na tabela ENCOMENDAS para os clientes, com ENCOMENDA_ID de 1 a 8
INSERT INTO ENCOMENDAS (ENCOMENDA_ID, UTILIZADOR_ID, TRANSACAO_ID, DATA_ENCOMENDA, ESTADO, TIPO_ENTREGA, MORADA)
VALUES
    -- Encomendas feitas por João Silva (ID: 1) - Alternando entre entrega e recolha
    (1, 1, 1, NOW() - INTERVAL '7 days', 'Pendente', 'entrega', 'Rua das Flores, 123'),
    (2, 1, 2, NOW() - INTERVAL '6 days', 'Enviado', 'recolha', NULL),  -- Recolha, morada será NULL

    -- Encomendas feitas por Ana Costa (ID: 2) - Alternando entre entrega e recolha
    (3, 2, 3, NOW() - INTERVAL '5 days', 'Pendente', 'entrega', 'Avenida Central, 456'),
    (4, 2, 4, NOW() - INTERVAL '4 days', 'Entregue', 'recolha', NULL),  -- Recolha, morada será NULL

    -- Encomendas feitas por Carlos Nunes (ID: 7) - Alternando entre entrega e recolha
    (5, 7, 5, NOW() - INTERVAL '3 days', 'Enviado', 'entrega', 'Rua do Campo, 654'),
    (6, 7, 6, NOW() - INTERVAL '2 days', 'Entregue', 'recolha', NULL),  -- Recolha, morada será NULL

    -- Encomendas feitas por Sofia Mendes (ID: 8) - Alternando entre entrega e recolha
    (7, 8, 7, NOW() - INTERVAL '1 day', 'Pendente', 'entrega', 'Praça da Paz, 987'),
    (8, 8, 8, NOW(), 'Entregue', 'recolha', NULL);  -- Recolha, morada será NULL



-- Inserir 8 produtos na tabela PRODUTOS para os fornecedores com ID 5 e 6
INSERT INTO PRODUTOS (PRODUTO_ID, UTILIZADOR_ID, NOME, DESCRICAO, PRECO, CATEGORIA, QUANTIDADE)
VALUES
    -- Produtos fornecidos pela Empresa A (ID: 5)
    (1, 5, 'Produto A1', 'Produto de alta qualidade, ideal para o uso diário.', 25.99, 'Eletrônicos', 100),
    (2, 5, 'Produto A2', 'Produto com excelente durabilidade e desempenho.', 15.49, 'Eletrodomésticos', 150),
    (3, 5, 'Produto A3', 'Produto versátil e fácil de usar.', 8.99, 'Acessórios', 200),
    (4, 5, 'Produto A4', 'Produto inovador para melhorar a produtividade.', 45.00, 'Tecnologia', 50),

    -- Produtos fornecidos pela Empresa B (ID: 6)
    (5, 6, 'Produto B1', 'Produto eficiente com bom custo-benefício.', 12.75, 'Vestuário', 300),
    (6, 6, 'Produto B2', 'Produto popular entre os consumidores, de alta qualidade.', 30.00, 'Calçados', 120),
    (7, 6, 'Produto B3', 'Produto confortável e ideal para o uso diário.', 20.99, 'Acessórios', 250),
    (8, 6, 'Produto B4', 'Produto de excelente qualidade, recomendado para todas as idades.', 55.99, 'Tecnologia', 75);


-- Inserir 16 itens de encomenda na tabela ITEM_DE_ENCOMENDA (2 itens por encomenda)
INSERT INTO ITEM_DE_ENCOMENDA (PRODUTO_ID, ENCOMENDA_ID, QUANTIDADE, PRECO_TOTAL)
VALUES
    -- Itens para a encomenda 1 (João Silva, Encomenda ID: 1)
    (1, 1, 2, 51.98), -- Produto A1
    (2, 1, 1, 15.49), -- Produto A2

    -- Itens para a encomenda 2 (João Silva, Encomenda ID: 2)
    (3, 2, 3, 26.97), -- Produto A3
    (4, 2, 1, 45.00), -- Produto A4

    -- Itens para a encomenda 3 (Ana Costa, Encomenda ID: 3)
    (5, 3, 2, 25.50), -- Produto B1
    (6, 3, 1, 30.00), -- Produto B2

    -- Itens para a encomenda 4 (Ana Costa, Encomenda ID: 4)
    (7, 4, 1, 20.99), -- Produto B3
    (8, 4, 1, 55.99), -- Produto B4

    -- Itens para a encomenda 5 (Carlos Nunes, Encomenda ID: 5)
    (1, 5, 1, 25.99), -- Produto A1
    (2, 5, 2, 30.98), -- Produto A2

    -- Itens para a encomenda 6 (Carlos Nunes, Encomenda ID: 6)
    (3, 6, 3, 26.97), -- Produto A3
    (4, 6, 1, 45.00), -- Produto A4

    -- Itens para a encomenda 7 (Sofia Mendes, Encomenda ID: 7)
    (5, 7, 2, 25.50), -- Produto B1
    (6, 7, 2, 60.00), -- Produto B2

    -- Itens para a encomenda 8 (Sofia Mendes, Encomenda ID: 8)
    (7, 8, 1, 20.99), -- Produto B3
    (8, 8, 1, 55.99); -- Produto B4



SELECT setval('encomendas_a_fornecedores_encomenda_fornecedor_id_seq', (SELECT MAX(encomenda_fornecedor_id) FROM encomendas_a_fornecedores) + 1);

SELECT setval('encomendas_encomenda_id_seq', (SELECT MAX(encomenda_id) FROM encomendas) + 1);

SELECT setval('item_de_encomenda_item_de_encomenda_id_seq', (SELECT MAX(item_de_encomenda_id) FROM item_de_encomenda) + 1);

SELECT setval('produtos_produto_id_seq', (SELECT MAX(produto_id) FROM produtos) + 1);

SELECT setval('transacoes_transacao_id_seq', (SELECT MAX(transacao_id) FROM transacoes) + 1);

SELECT setval('utilizadores_utilizador_id_seq', (SELECT MAX(utilizador_id) FROM utilizadores) + 1);