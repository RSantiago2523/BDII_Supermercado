-- 1. Criar Encomenda (Create)
CREATE OR REPLACE PROCEDURE public.create_encomenda(
    IN cliente_id integer,
    IN data date,
    IN status text)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    new_id integer;
BEGIN
    SELECT nextval('encomendas_id_seq') INTO new_id;
    
    INSERT INTO encomendas (id, cliente_id, data, status)
    VALUES (new_id, cliente_id, data, status);
END;
$BODY$;

-- 2. Criar Item de Encomenda (Create)
CREATE OR REPLACE PROCEDURE public.create_item_encomenda(
    IN encomenda_id integer,
    IN produto_id integer,
    IN quantidade integer,
    IN preco numeric)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    new_id integer;
BEGIN
    SELECT nextval('itens_encomenda_id_seq') INTO new_id;

    INSERT INTO itens_encomenda (id_item, encomenda_id, produto_id, quantidade, preco)
    VALUES (new_id, encomenda_id, produto_id, quantidade, preco);
END;
$BODY$;

-- 3. Criar Cliente (Create)
CREATE OR REPLACE PROCEDURE public.create_cliente(
    IN nome text,
    IN email text,
    IN telefone text)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    new_id integer;
BEGIN
    SELECT nextval('clientes_id_seq') INTO new_id;

    INSERT INTO clientes (id, nome, email, telefone)
    VALUES (new_id, nome, email, telefone);
END;
$BODY$;

-- 4. Criar Produto (Create)
CREATE OR REPLACE PROCEDURE public.create_produto(
    IN nome_produto text,
    IN descricao_produto text,
    IN preco numeric)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    new_id integer;
BEGIN
    SELECT nextval('produtos_id_seq') INTO new_id;

    INSERT INTO produtos (id, nome_produto, descricao_produto, preco)
    VALUES (new_id, nome_produto, descricao_produto, preco);
END;
$BODY$;

-- 5. Criar Tipo de Produto (Create)
CREATE OR REPLACE PROCEDURE public.create_tipo_produto(
    IN nome_tipo text,
    IN descricao_tipo text)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    new_id integer;
BEGIN
    SELECT nextval('tipos_produto_id_seq') INTO new_id;

    INSERT INTO tipos_produto (id, nome_tipo, descricao_tipo)
    VALUES (new_id, nome_tipo, descricao_tipo);
END;
$BODY$;

-- 6. Criar Produto em Estoque (Create)
CREATE OR REPLACE PROCEDURE public.create_produto_estoque(
    IN produto_id integer,
    IN quantidade integer,
    IN preco_unitario numeric)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    new_id integer;
BEGIN
    SELECT nextval('produtos_estoque_id_seq') INTO new_id;

    INSERT INTO produtos_estoque (id, produto_id, quantidade, preco_unitario)
    VALUES (new_id, produto_id, quantidade, preco_unitario);
END;
$BODY$;

-- 7. Atualizar Encomenda (Update)
CREATE OR REPLACE PROCEDURE public.update_encomenda(
    IN encomenda_id integer,
    IN cliente_id integer,
    IN data date,
    IN status text)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE encomendas
    SET cliente_id = cliente_id, data = data, status = status
    WHERE id = encomenda_id;
END;
$BODY$;

-- 8. Atualizar Item de Encomenda (Update)
CREATE OR REPLACE PROCEDURE public.update_item_encomenda(
    IN item_id integer,
    IN encomenda_id integer,
    IN produto_id integer,
    IN quantidade integer,
    IN preco numeric)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE itens_encomenda
    SET encomenda_id = encomenda_id, produto_id = produto_id, quantidade = quantidade, preco = preco
    WHERE id_item = item_id;
END;
$BODY$;

-- 9. Atualizar Cliente (Update)
CREATE OR REPLACE PROCEDURE public.update_cliente(
    IN cliente_id integer,
    IN nome text,
    IN email text,
    IN telefone text)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE clientes
    SET nome = nome, email = email, telefone = telefone
    WHERE id = cliente_id;
END;
$BODY$;

-- 10. Atualizar Produto (Update)
CREATE OR REPLACE PROCEDURE public.update_produto(
    IN produto_id integer,
    IN nome_produto text,
    IN descricao_produto text,
    IN preco numeric)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE produtos
    SET nome_produto = nome_produto, descricao_produto = descricao_produto, preco = preco
    WHERE id = produto_id;
END;
$BODY$;

-- 11. Atualizar Tipo de Produto (Update)
CREATE OR REPLACE PROCEDURE public.update_tipo_produto(
    IN tipo_produto_id integer,
    IN nome_tipo text,
    IN descricao_tipo text)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE tipos_produto
    SET nome_tipo = nome_tipo, descricao_tipo = descricao_tipo
    WHERE id = tipo_produto_id;
END;
$BODY$;

-- 12. Atualizar Produto em Estoque (Update)
CREATE OR REPLACE PROCEDURE public.update_produto_estoque(
    IN estoque_id integer,
    IN produto_id integer,
    IN quantidade integer,
    IN preco_unitario numeric)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE produtos_estoque
    SET produto_id = produto_id, quantidade = quantidade, preco_unitario = preco_unitario
    WHERE id = estoque_id;
END;
$BODY$;

-- 13. Deletar Encomenda (Delete)
CREATE OR REPLACE PROCEDURE public.delete_encomenda(
    IN encomenda_id integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    DELETE FROM encomendas WHERE id = encomenda_id;
END;
$BODY$;

-- 14. Deletar Item de Encomenda (Delete)
CREATE OR REPLACE PROCEDURE public.delete_item_encomenda(
    IN item_id integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    DELETE FROM itens_encomenda WHERE id_item = item_id;
END;
$BODY$;

-- 15. Deletar Cliente (Delete)
CREATE OR REPLACE PROCEDURE public.delete_cliente(
    IN cliente_id integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    DELETE FROM clientes WHERE id = cliente_id;
END;
$BODY$;

-- 16. Deletar Produto (Delete)
CREATE OR REPLACE PROCEDURE public.delete_produto(
    IN produto_id integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    DELETE FROM produtos WHERE id = produto_id;
END;
$BODY$;

-- 17. Deletar Tipo de Produto (Delete)
CREATE OR REPLACE PROCEDURE public.delete_tipo_produto(
    IN tipo_produto_id integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    DELETE FROM tipos_produto WHERE id = tipo_produto_id;
END;
$BODY$;

-- 18. Deletar Produto em Estoque (Delete)
CREATE OR REPLACE PROCEDURE public.delete_produto_estoque(
    IN estoque_id integer)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    DELETE FROM produtos_estoque WHERE id = estoque_id;
END;
$BODY$;
