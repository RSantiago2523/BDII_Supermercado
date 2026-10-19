-- Criar o utilizador
CREATE USER supermercado_user WITH PASSWORD 'senha123';

-- Dar acesso à base de dados e ao schema
GRANT CONNECT ON DATABASE "bdII" TO supermercado_user;
GRANT USAGE ON SCHEMA public TO supermercado_user;

-- ─────────────────────────────────────────
-- TABELAS (acesso direto via cursor no views.py)
-- ─────────────────────────────────────────

-- Login, listagem de staff, registo
GRANT SELECT, INSERT, UPDATE, DELETE ON UTILIZADORES TO supermercado_user;

-- Catálogo, stock, descontos
GRANT SELECT, INSERT, UPDATE, DELETE ON PRODUTOS TO supermercado_user;

-- Encomendas de clientes
GRANT SELECT, INSERT, UPDATE, DELETE ON ENCOMENDAS TO supermercado_user;

-- Itens de cada encomenda
GRANT SELECT, INSERT, DELETE ON ITEM_DE_ENCOMENDA TO supermercado_user;

-- Transações (também criadas pelos triggers — precisam de INSERT)
GRANT SELECT, INSERT, UPDATE, DELETE ON TRANSACOES TO supermercado_user;

-- Encomendas a fornecedores (também criadas pelos triggers)
GRANT SELECT, INSERT, UPDATE, DELETE ON ENCOMENDAS_A_FORNECEDORES TO supermercado_user;


-- ─────────────────────────────────────────
-- VIEWS (só leitura)
-- ─────────────────────────────────────────

GRANT SELECT ON view_todos_produtos TO supermercado_user;
GRANT SELECT ON listar_funcionarios_view TO supermercado_user;
GRANT SELECT ON listar_utilizadores_view TO supermercado_user;
GRANT SELECT ON vw_transacoes TO supermercado_user;
GRANT SELECT ON vw_detalhes_encomendas TO supermercado_user;
GRANT SELECT ON vw_detalhes_encomendas_fornecedores TO supermercado_user;


-- ─────────────────────────────────────────
-- FUNÇÕES (chamadas via CALL/SELECT no views.py)
-- ─────────────────────────────────────────

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO supermercado_user;


-- ─────────────────────────────────────────
-- SEQUÊNCIAS (para os IDs automáticos)
-- ─────────────────────────────────────────

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO supermercado_user;