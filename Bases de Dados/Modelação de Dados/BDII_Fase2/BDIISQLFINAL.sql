-- ==============================================================
-- Verificar e remover tabelas existentes                      
-- ==============================================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'avaliacoes') THEN
        DROP TABLE AVALIACOES;
    END IF;

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

/*
-- ==============================================================
-- Tabela: AVALIACOES                                           
-- ==============================================================
CREATE TABLE AVALIACOES (
   AVALIACAO_ID         SERIAL PRIMARY KEY,
   UTILIZADOR_ID        INT NOT NULL,
   PRODUTO_ID           INT NOT NULL,
   CLASSIFICACAO        FLOAT,
   COMENTARIO           TEXT,
   DATA_AVALIACAO       TIMESTAMP,
   CONSTRAINT FK_AVALIACO_ESCREVER_UTILIZAD FOREIGN KEY (UTILIZADOR_ID)
      REFERENCES UTILIZADORES (UTILIZADOR_ID),
   CONSTRAINT FK_AVALIACO_RELACIONA_PRODUTOS FOREIGN KEY (PRODUTO_ID)
      REFERENCES PRODUTOS (PRODUTO_ID)
);
