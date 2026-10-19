CREATE OR REPLACE FUNCTION public.export_encomenda_to_json(
    encomenda_id integer)
    RETURNS jsonb
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    result_json jsonb;
BEGIN
    SELECT json_agg(row_to_json(b)) INTO result_json
    FROM (SELECT * FROM encomendas WHERE id_enc = encomenda_id) b;

    RETURN result_json;
END;
$BODY$;


CREATE OR REPLACE FUNCTION public.export_itens_encomenda_to_json(
    encomenda_id integer)
RETURNS jsonb
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    result_json jsonb;
BEGIN
    SELECT jsonb_agg(row_to_json(i)) INTO result_json
    FROM itens_encomenda i
    WHERE i.encomenda_id = encomenda_id;

    RETURN result_json;
END;
$BODY$;


CREATE OR REPLACE FUNCTION public.export_itens_fatura_encomenda_to_json(fatura_id integer)      
RETURNS jsonb
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    result_json jsonb;
BEGIN
    SELECT jsonb_agg(row_to_json(i)) INTO result_json
    FROM item_fatura_enc i
    WHERE i.fatura_id = fatura_id;

    RETURN result_json;
END;
$BODY$;



CREATE OR REPLACE PROCEDURE public.proc_importar_utilizadores_json(
    IN importar_utilizadores json)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    nome_utilizador text;
    email_utilizador text;
BEGIN
    nome_utilizador := importar_utilizadores->>'nome_utilizador';
    email_utilizador := importar_utilizadores->>'email_utilizador';
    
    INSERT INTO utilizadores (nome, email)
    VALUES (nome_utilizador, email_utilizador);
END;
$BODY$;


CREATE OR REPLACE PROCEDURE importar_produto(import_json JSONB)
LANGUAGE plpgsql 
AS $$
BEGIN
    INSERT INTO PRODUTOS (nome, descricao, preco, estoque)
    VALUES (
        import_json->>'nome',
        import_json->>'descricao',
        (import_json->>'preco')::DECIMAL,
        (import_json->>'estoque')::INT
    );
END;
$$;



CREATE OR REPLACE FUNCTION exportar_fornecedores_json()
RETURNS JSONB 
LANGUAGE plpgsql 
AS $$
DECLARE
    resultado JSONB;
BEGIN
    SELECT json_agg(row_to_json(f)) INTO resultado
    FROM (SELECT * FROM FORNECEDORES) f;
    
    RETURN resultado;
END;
$$;
