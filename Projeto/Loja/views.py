from django.shortcuts import render,redirect,get_object_or_404
from django.utils.timezone import now
from django.db import connection
from django.http import HttpResponse
from .models import *
from django.db import connection
from django.views.decorators.csrf import csrf_exempt
from django.contrib import messages
from .services import adicionar_avaliacao, buscar_avaliacoes_por_produto, calcular_media_classificacao
from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from .models import Utilizador
from django.contrib.auth.models import User
from django.db import IntegrityError, connection
from django.http import JsonResponse, HttpResponse
from django.shortcuts import redirect
from django.contrib.messages import get_messages
from decimal import Decimal, ROUND_DOWN, ROUND_HALF_UP
from decimal import InvalidOperation

def registar_cliente(request):
    erro = None
    sucesso = None

    if request.method == 'POST':
        print("📩 Dados recebidos no POST:", request.POST)  # Exibe os dados no terminal

        nome = request.POST.get('nome')
        email = request.POST.get('email')
        password = request.POST.get('password')
        confirm_password = request.POST.get('confirm_password')
        morada = request.POST.get('morada')
        telefone = request.POST.get('telefone')

        print(f"📌 Nome: {nome}, Email: {email}, Senha: {password}, Confirmação: {confirm_password}")
        print(f"📌 Morada: {morada}, Telefone: {telefone}")

        # Verificar se as senhas coincidem
        if password != confirm_password:
            erro = 'As senhas não coincidem.'
            print("❌ Erro:", erro)  # Exibe no terminal
            return render(request, 'register.html', {'erro': erro})

        # Verificar se o email já existe
        if Utilizador.objects.filter(email=email).exists():
            erro = 'Este email já está em uso. Tente outro.'
            print("❌ Erro:", erro)
            return render(request, 'register.html', {'erro': erro})

        try:
            # Criar o novo utilizador com o tipo "cliente"
            novo_utilizador = Utilizador.objects.create(
                nome=nome,
                email=email,
                password=password,  
                morada=morada,
                telefone=telefone,
                tipo_utilizador='Cliente'
            )
            print("✅ Usuário criado com sucesso:", novo_utilizador)

            sucesso = 'Registro concluído com sucesso. Faça login para continuar.'
            return redirect('login')

        except IntegrityError:
            erro = 'Erro ao registrar. Verifique se os dados estão corretos.'
            print("❌ IntegrityError:", erro)
        except Exception as e:
            erro = f'Ocorreu um erro ao registrar: {e}'
            print("❌ Exception:", erro)

    return render(request, 'register.html', {'erro': erro, 'sucesso': sucesso})

def verificar_login(func):
    def wrapper(request, *args, **kwargs):
        if 'user_id' not in request.session:
            return redirect('home')  # Redireciona para a página inicial ou de login
        return func(request, *args, **kwargs)
    return wrapper

def verificar_funcionario(func):
    def wrapper(request, *args, **kwargs):
        if 'user_id' not in request.session:
            return redirect('home')  # Redireciona para a página inicial ou de login
        if request.session.get('user_type') != 'Funcionario':
            return redirect('home')  # Redireciona para a página inicial se não for funcionário
        return func(request, *args, **kwargs)
    return wrapper


# Lista de produtos gestores
@verificar_funcionario
def gestor_lista(request):
    if request.method == "POST":
        produto_id = request.POST.get("produto_id")
        desconto = request.POST.get("desconto")

        if produto_id and desconto is not None:
            try:
                desconto = Decimal(desconto)
                produto = Produto.objects.get(produto_id=produto_id)
                produto.desconto = desconto
                produto.save()
            except Produto.DoesNotExist:
                pass  # Produto não encontrado, não faz nada
            except InvalidOperation:
                pass  # Caso o desconto seja inválido

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT produto_id, fornecedor_nome, produto_nome, descricao, preco, categoria, quantidade, desconto
            FROM view_todos_produtos
            ORDER BY produto_id
        """)
        produtos_brutos = cursor.fetchall()

    # Transformar os dados e calcular o desconto
    produtos = []
    for produto in produtos_brutos:
        produto_id, fornecedor_nome, produto_nome, descricao, preco, categoria, quantidade, desconto = produto

        desconto = Decimal(desconto) if desconto is not None else Decimal(0)
        preco = Decimal(preco)

        preco_com_desconto = preco * (Decimal(1) - desconto / Decimal(100)) if desconto > 0 else preco

        preco = round(preco, 2)
        preco_com_desconto = round(preco_com_desconto, 2)

        produtos.append({
            "produto_id": produto_id,
            "fornecedor_nome": fornecedor_nome,
            "produto_nome": produto_nome,
            "descricao": descricao,
            "preco": preco,
            "categoria": categoria,
            "quantidade": quantidade,
            "desconto": desconto,
            "preco_com_desconto": preco_com_desconto
        })

    return render(request, 'lista_produtos_gestor.html', {'produtos': produtos})

@verificar_funcionario
def atualizar_desconto(request, produto_id):
    # Verificar se a requisição é POST
    if request.method == 'POST':
        # Recuperar o produto pela ID
        produto = get_object_or_404(Produto, produto_id=produto_id)
        
        # Recuperar o desconto enviado no formulário
        desconto = request.POST.get('desconto')

        try:
            # Verificar se o desconto é válido
            desconto = float(desconto)
            if desconto < 0 or desconto > 100:
                messages.error(request, 'O desconto deve ser entre 0% e 100%.')
                return redirect('gestor_lista')  # Redireciona de volta à lista de produtos

            # Atualizar o desconto no produto
            produto.desconto = desconto
            produto.save()

            # Mensagem de sucesso
            messages.success(request, f'Desconto de {desconto}% atualizado com sucesso!')
        except ValueError:
            messages.error(request, 'Desconto inválido. Por favor, insira um número.')

    return redirect('gestor_lista')  # Redirecionar de volta à lista de produtos


@verificar_funcionario
def remove_produto(request, produto_id):
    if request.method == "POST":
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT remove_produto(%s);", [produto_id])
            # Redireciona para a página de listar produtos em caso de sucesso
            return redirect('gestor_lista')
        except Exception as e:
            if "violates foreign key constraint" in str(e):
                # Caso existam dependências, apaga os itens relacionados e redireciona
                with connection.cursor() as cursor:
                    cursor.execute("DELETE FROM item_de_encomenda WHERE produto_id = %s;", [produto_id])
                    cursor.execute("SELECT remove_produto(%s);", [produto_id])
                return redirect('gestor_lista')
            # Caso ocorra outro erro
            return HttpResponse(f"Erro ao remover produto: {e}", status=500)

@verificar_funcionario
def atualizar_estoque(request, produto_id):
    if request.method == "POST":
        try:
            nova_quantidade = request.POST.get('quantidade')
            if nova_quantidade:
                with connection.cursor() as cursor:
                    cursor.execute("SELECT atualizar_estoque(%s, %s);", [produto_id, float(nova_quantidade)])
                return redirect('gestor_lista')  # Redireciona de volta para a lista de produtos
            else:
                return HttpResponse("Erro: quantidade não informada.", status=400)
        except Exception as e:
            return HttpResponse(f"Erro ao atualizar o estoque: {e}", status=500)
        
@verificar_funcionario
def adicionar_produto(request):
    if request.method == "POST":
        fornecedor_id = int(request.POST.get("fornecedor_id").split('-')[0])  # Extrai o ID numérico
        nome = request.POST.get("nome")
        descricao = request.POST.get("descricao")
        preco = request.POST.get("preco")
        categoria = request.POST.get("categoria")
        quantidade = request.POST.get("quantidade")

        try:
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT add_produto(%s, %s, %s, %s, %s, %s);",
                    [fornecedor_id, nome, descricao, preco, categoria, quantidade]
                )
            return redirect('gestor_lista')
        except Exception as e:
            return HttpResponse(f"Erro ao adicionar produto: {e}", status=500)

    # Obtém a lista de fornecedores (utilizadores com tipo "fornecedor")
    with connection.cursor() as cursor:
        cursor.execute("SELECT UTILIZADOR_ID, NOME FROM UTILIZADORES WHERE TIPO_UTILIZADOR = %s;", ['Fornecedor'])
        utilizadores = cursor.fetchall()  # Retorna uma lista de tuples [(1, 'Fornecedor1'), (2, 'Fornecedor2'), ...]

    # Preparando os dados para o template
    utilizadores = [f"{u[0]}-{u[1]}" for u in utilizadores]  # Formata como "id-nome"

    return render(request, 'adicionar_produto.html', {'utilizadores': utilizadores})

#listar os funcionarios
@verificar_funcionario
def listar_funcionarios(request):
    with connection.cursor() as cursor:
        # Buscar funcionários
        cursor.execute("SELECT * FROM listar_funcionarios_view")
        funcionarios = cursor.fetchall()

        # Buscar outros utilizadores (Clientes, Fornecedores, Administradores)
        cursor.execute("SELECT * FROM listar_utilizadores_view")
        utilizadores = cursor.fetchall()

    # Estruturar os dados em dicionários para o template
    dados_funcionarios = [
        {
            'utilizador_id': func[0],
            'nome': func[1],
            'email': func[2],
            'tipo_utilizador': func[3],
            'morada': func[4],
            'telefone': func[5],
            'funcoes': func[6],
        } for func in funcionarios
    ]

    dados_utilizadores = [
        {
            'utilizador_id': user[0],
            'nome': user[1],
            'email': user[2],
            'tipo_utilizador': user[3],
            'morada': user[4],
            'telefone': user[5],
        } for user in utilizadores
    ]

    return render(request, 'listar_funcionarios_gestor.html', {
        'funcionarios': dados_funcionarios,
        'utilizadores': dados_utilizadores
    })

@verificar_funcionario
def remover_funcionario(request, utilizador_id):
    if request.method == 'POST':
        with connection.cursor() as cursor:
            cursor.execute("SELECT remover_funcionario(%s)", [utilizador_id])
        # Redireciona de volta para a lista de funcionários
        return redirect('lista_utilizadores')
    
@verificar_funcionario
def adicionar_utilizador(request):
    if request.method == 'POST':
        nome = request.POST.get('nome')
        email = request.POST.get('email')
        password = request.POST.get('password')
        morada = request.POST.get('morada')
        telefone = request.POST.get('telefone')
        funcoes = request.POST.get('funcoes')

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT adicionar_utilizador(%s, %s, %s, %s, %s, %s);
            """, [nome, email, password, morada, telefone, funcoes])
        
        messages.success(request, 'Funcionário adicionado com sucesso!')
        return redirect('lista_utilizadores')  # Ajuste este nome para a URL correta da lista de funcionários

    return render(request, 'adicionar_utilizador.html')

@verificar_funcionario
def editar_funcionario(request, utilizador_id):
    if request.method == 'POST':
        nome = request.POST.get('nome')
        email = request.POST.get('email')
        password = request.POST.get('password')
        morada = request.POST.get('morada')
        telefone = request.POST.get('telefone')
        funcoes = request.POST.get('funcoes')

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT editar_funcionario(%s, %s, %s, %s, %s, %s, %s);
            """, [utilizador_id, nome, email, password, morada, telefone, funcoes])

        return redirect('lista_utilizadores')  # Redireciona de volta à lista de funcionários

    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM UTILIZADORES WHERE UTILIZADOR_ID = %s", [utilizador_id])
        funcionario = cursor.fetchone()

    if not funcionario:
        return render(request, 'erro.html', {'mensagem': 'Funcionário não encontrado.'})

    return render(request, 'editar_funcionario.html', {
        'funcionario': funcionario
    })

#lista produtos clientes

@verificar_login
def lista_produtos_view(request):
    categoria_id = request.GET.get('categoria', None)  # Pega a categoria escolhida (se houver)

    # Obter as categorias únicas para o filtro
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT DISTINCT categoria
            FROM view_todos_produtos
        """)
        categorias = cursor.fetchall()  # Obtém todas as categorias únicas
    
    # Montar a consulta para buscar os produtos
    with connection.cursor() as cursor:
        query = """
            SELECT produto_id, fornecedor_nome, produto_nome, descricao, preco, categoria, quantidade, desconto
            FROM view_todos_produtos
            WHERE 1=1
        """
        params = []
        
        # Se uma categoria foi selecionada, adicionar o filtro de categoria
        if categoria_id:
            query += " AND categoria = %s"
            params.append(categoria_id)
        
        query += " ORDER BY produto_id"
        
        # Executar a consulta
        cursor.execute(query, params)
        produtos_brutos = cursor.fetchall()  # Obtém os produtos filtrados
    
    # Transformar os dados em uma lista de dicionários e calcular o desconto
    produtos = []
    for produto in produtos_brutos:
        produto_id, fornecedor_nome, produto_nome, descricao, preco, categoria, quantidade, desconto = produto
        
        # Certificar-se de que o desconto não é nulo e calcular o preço final
        desconto = Decimal(desconto) if desconto is not None else Decimal(0)
        preco = Decimal(preco)
        preco_com_desconto = preco * (Decimal(1) - desconto / Decimal(100)) if desconto > 0 else preco

        # Formatando os valores para exibição com duas casas decimais
        preco = preco.quantize(Decimal("0.01"), rounding=ROUND_DOWN)
        preco_com_desconto = preco_com_desconto.quantize(Decimal("0.01"), rounding=ROUND_DOWN)

        produtos.append({
            "produto_id": produto_id,
            "fornecedor_nome": fornecedor_nome,
            "produto_nome": produto_nome,
            "descricao": descricao,
            "preco": float(preco),  # Convertendo para float para evitar problemas no template
            "categoria": categoria,
            "quantidade": quantidade,
            "desconto": float(desconto),  
            "preco_com_desconto": float(preco_com_desconto)
        })

    return render(request, 'lista_produtos.html', {'produtos': produtos, 'categorias': categorias})

@verificar_login
def detalhes_produto(request, produto_id):
    """Detalhes do produto com avaliações."""
    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT produto_id, fornecedor_nome, produto_nome, descricao, preco, categoria, quantidade, desconto
            FROM view_todos_produtos
            WHERE produto_id = %s
        """, [produto_id])
        produto_bruto = cursor.fetchone()
    
    if not produto_bruto:
        return redirect('lista_produtos')  # Redireciona se o produto não existir
    
    # Extrair os dados do produto
    produto_id, fornecedor_nome, produto_nome, descricao, preco, categoria, quantidade, desconto = produto_bruto
    
    # Calcular preço final com desconto
    desconto = Decimal(desconto) if desconto is not None else Decimal(0)
    preco = Decimal(preco)
    preco_com_desconto = preco * (Decimal(1) - desconto / Decimal(100)) if desconto > 0 else preco

    # Arredondar valores
    preco = preco.quantize(Decimal("0.01"), rounding=ROUND_DOWN)
    preco_com_desconto = preco_com_desconto.quantize(Decimal("0.01"), rounding=ROUND_DOWN)

    produto = {
        "produto_id": produto_id,
        "fornecedor_nome": fornecedor_nome,
        "produto_nome": produto_nome,
        "descricao": descricao,
        "preco": float(preco),
        "categoria": categoria,
        "quantidade": quantidade,
        "desconto": float(desconto),
        "preco_com_desconto": float(preco_com_desconto)
    }

    # Buscar avaliações do MongoDB
    avaliacoes = buscar_avaliacoes_por_produto(produto_id)
    media_classificacao = calcular_media_classificacao(produto_id)

    if request.method == 'POST':
        classificacao = int(request.POST.get('classificacao'))
        comentario = request.POST.get('comentario')
        adicionar_avaliacao(1, produto_id, classificacao, comentario)  # Ajuste para o ID do utilizador autenticado
        return redirect('detalhes_produto', produto_id=produto_id)

    return render(request, 'detalhes_produto.html', {
        'produto': produto,
        'avaliacoes': avaliacoes,
        'media_classificacao': media_classificacao,
    })

@verificar_login
def adicionar_ao_carrinho(request, produto_id):
    produto = get_object_or_404(Produto, produto_id=produto_id)  # Busca o produto no banco
    carrinho = request.session.get('carrinho', {})  # Obtém o carrinho da sessão ou inicializa vazio

    desconto = produto.desconto if hasattr(produto, 'desconto') else 0  # Obtém o desconto do produto, se existir
    preco_com_desconto = float(produto.preco) * (1 - desconto / 100) if desconto > 0 else float(produto.preco)

    if str(produto_id) in carrinho:
        carrinho[str(produto_id)]['quantidade'] += 1  # Incrementa a quantidade
    else:
        carrinho[str(produto_id)] = {
            'produto_nome': produto.nome,
            'preco': float(produto.preco),
            'desconto': desconto,  # Salva o desconto no carrinho
            'preco_com_desconto': round(preco_com_desconto, 2),  # Preço com desconto
            'quantidade': 1,
            'produto_id': produto.produto_id,
        }

    request.session['carrinho'] = carrinho  # Atualiza o carrinho na sessão
    return redirect('lista_produtos')  # Redireciona para a lista de produtos

@verificar_login
def visualizar_carrinho(request):
    carrinho = request.session.get('carrinho', {})
    total_geral = 0

    for produto_id, item in carrinho.items():
        desconto = item.get('desconto', 0)  # Obtém o desconto, se existir
        preco = Decimal(item['preco'])  # Converte para Decimal para precisão
        preco_com_desconto = preco * (Decimal(1) - Decimal(desconto) / Decimal(100)) if desconto > 0 else preco

        # Atualiza os valores dentro do carrinho convertendo Decimal para float
        item['preco_com_desconto'] = round(float(preco_com_desconto), 2)  
        item['total_item'] = round(float(item['preco_com_desconto'] * item['quantidade']), 2)  

        total_geral += item['total_item']

    request.session['carrinho'] = carrinho
    request.session.modified = True  # Garante que a sessão seja salva

    return render(request, 'visualizar_carrinho.html', {
        'carrinho': carrinho,
        'total': round(float(total_geral), 2)  # Converte para float para evitar erro de serialização
    })

@verificar_login
def remover_do_carrinho(request, produto_id):
    carrinho = request.session.get('carrinho', {})  # Obtém o carrinho da sessão

    produto_id = str(produto_id)  # Chave deve ser string
    if produto_id in carrinho:
        del carrinho[produto_id]  # Remove o produto do carrinho

    request.session['carrinho'] = carrinho  # Atualiza o carrinho na sessão
    return redirect('visualizar_carrinho')  # Redireciona para a página do carrinho



@verificar_login
def confirmar_compra(request):
    carrinho = request.session.get('carrinho', {})

    if not carrinho:
        return render(request, 'mensagem.html', {'mensagem': 'Seu carrinho está vazio!'})

    # Verificar se o usuário está logado
    user_id = request.session.get('user_id')  # Recupera o ID do usuário logado da sessão

    if not user_id:
        return render(request, 'mensagem.html', {'mensagem': 'Você precisa estar logado para confirmar a compra!'})

    # Obter o tipo de entrega e morada (caso aplicável)
    tipo_entrega = request.POST.get('tipo_entrega', 'entrega')  # O valor padrão é 'entrega'
    morada = None
    if tipo_entrega == 'entrega':
        morada = request.POST.get('morada', None)

    # Criar a encomenda
    encomenda = Encomenda.objects.create(
        utilizador_id=user_id,  # Usar o ID do usuário logado
        transacao_id=None,  # Pode ser ajustado posteriormente
        data_encomenda=now(),
        estado='Pendente',
        tipo_entrega=tipo_entrega,  # Adicionar o tipo de entrega
        morada=morada if tipo_entrega == 'entrega' else None  # Salvar morada somente se for entrega
    )

    for item in carrinho.values():
        # Obter o produto com base no ID
        produto = Produto.objects.get(produto_id=item['produto_id'])

        # Verificar o desconto do produto
        desconto = produto.desconto if produto.desconto else 0  # Se não houver desconto, assume 0%

        # Calcular o preço com desconto
        preco_com_desconto = Decimal(produto.preco) * (1 - Decimal(desconto) / Decimal(100))  # Preço com desconto aplicado

        # Arredondar o preço com desconto para 2 casas decimais
        preco_com_desconto = preco_com_desconto.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)

        # Calcular o total_item (preço com desconto * quantidade)
        total_item = preco_com_desconto * Decimal(item['quantidade'])

        # Arredondar o total_item para 2 casas decimais
        total_item = total_item.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)

        # Criar o item de encomenda com o preço com desconto
        ItemDeEncomenda.objects.create(
            produto_id=item['produto_id'],
            encomenda=encomenda,
            quantidade=item['quantidade'],
            preco_total=total_item  # Usar o preço com desconto para calcular o total
        )

        # Atualizar a quantidade do produto no estoque
        produto.quantidade -= item['quantidade']
        if produto.quantidade < 0:
            produto.quantidade = 0  # Evitar que a quantidade fique negativa

        produto.save()

    # Limpar o carrinho após a confirmação da compra
    request.session['carrinho'] = {}

    return render(request, 'mensagem.html', {'mensagem': 'Compra confirmada com sucesso!'})



#Lista de encomendas
@verificar_funcionario
def listar_encomendas_view(request):
    with connection.cursor() as cursor:
        # Buscar encomendas normais (clientes)
        cursor.execute("SELECT * FROM vw_detalhes_encomendas ORDER BY encomenda_id")
        encomendas = cursor.fetchall()

        # Buscar encomendas feitas aos fornecedores
        cursor.execute("SELECT * FROM vw_detalhes_encomendas_fornecedores ORDER BY encomenda_fornecedor_id")
        encomendas_fornecedores = cursor.fetchall()

    # Organizar encomendas normais (clientes)
    dados_encomendas = {}
    for encomenda in encomendas:
        encomenda_id = encomenda[0]
        if encomenda_id not in dados_encomendas:
            dados_encomendas[encomenda_id] = {
                'encomenda_id': encomenda_id,
                'utilizador_id': encomenda[1],
                'data_encomenda': encomenda[2],
                'estado': encomenda[3],
                'tipo_entrega': encomenda[8],  # Campo tipo_entrega para clientes
                'morada': encomenda[9],        # Campo morada para clientes
                'itens': [],
                'total': 0  # Inicializar o total
            }

        preco_total = encomenda[7] or 0  # Evitar None
        dados_encomendas[encomenda_id]['itens'].append({
            'produto_id': encomenda[4],
            'produto_nome': encomenda[5],
            'quantidade': encomenda[6],
            'preco_total': preco_total,
        })
        dados_encomendas[encomenda_id]['total'] += preco_total  

    for encomenda_id in dados_encomendas:
        dados_encomendas[encomenda_id]['total'] = round(dados_encomendas[encomenda_id]['total'], 2)


    # Organizar encomendas de fornecedores
    dados_encomendas_fornecedores = {}
    for encomenda in encomendas_fornecedores:
        encomenda_id = encomenda[0]
        if encomenda_id not in dados_encomendas_fornecedores:
            dados_encomendas_fornecedores[encomenda_id] = {
                'encomenda_id': encomenda_id,
                'utilizador_id': encomenda[1],
                'data_encomenda': encomenda[4],
                'estado': encomenda[5],
                'produto_id': encomenda[2],
                'produto_nome': encomenda[3],
                'quantidade': encomenda[6],
                'preco_total': encomenda[7] or 0
            }

    return render(request, 'listar_encomendas.html', {
        'dados_encomendas': dados_encomendas.values(),
        'dados_encomendas_fornecedores': dados_encomendas_fornecedores.values()
    })


@verificar_funcionario
def excluir_encomenda(request, encomenda_id):
    message = None
    try:
        # Excluir a transação associada à encomenda
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM transacoes WHERE ENCOMENDA_ID = %s", [encomenda_id])
        
        # Excluir a encomenda
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM encomendas WHERE encomenda_id = %s", [encomenda_id])
        
        message = "Encomenda removida com sucesso."
    except Exception as e:
        message = f"Erro ao remover encomenda: {e}"

    # Redirecionar para a página de listar encomendas e passar a mensagem como parâmetro
    return redirect('listar_encomendas')

@verificar_funcionario
def marcar_como_entregue(request, encomenda_id):
    if request.method == "POST":
        try:
            # Atualizar     o estado da encomenda para 'Entregue'
            with connection.cursor() as cursor:
                cursor.execute("UPDATE encomendas SET estado = 'Entregue' WHERE encomenda_id = %s", [encomenda_id])
            
            # Exibir mensagem de sucesso no terminal
            print(f"Estado da encomenda {encomenda_id} alterado para 'Entregue'.")
        except Exception as e:
            # Exibir mensagem de erro no terminal
            print(f"Erro ao alterar estado da encomenda {encomenda_id}: {e}")

    # Redirecionar para a página de listar encomendas
    return redirect('listar_encomendas')

@verificar_funcionario
def marcar_como_entregue_fornecedor(request, encomenda_fornecedor_id):
    if request.method == "POST":
        try:
            with connection.cursor() as cursor:
                cursor.execute("UPDATE encomendas_a_fornecedores SET estado_encomenda_fornecedor = 'Entregue' WHERE encomenda_fornecedor_id = %s", [encomenda_fornecedor_id])
            messages.success(request, f"Encomenda de fornecedor {encomenda_fornecedor_id} marcada como entregue.")
        except Exception as e:
            messages.error(request, f"Erro ao alterar estado da encomenda de fornecedor: {e}")
    return redirect('listar_encomendas')

@verificar_funcionario
def excluir_encomenda_fornecedor(request, encomenda_fornecedor_id):
    try:
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM encomendas_a_fornecedores WHERE encomenda_fornecedor_id = %s", [encomenda_fornecedor_id])
        messages.success(request, "Encomenda de fornecedor removida com sucesso.")
    except Exception as e:
        messages.error(request, f"Erro ao remover encomenda de fornecedor: {e}")
    return redirect('listar_encomendas')

#lista de encomendas cliente
@verificar_login
def visualizar_encomendas(request):
    user_id = request.session.get('user_id')
    
    # Obtém todas as encomendas do usuário
    encomendas = Encomenda.objects.filter(utilizador_id=user_id)

    # Para cada encomenda, calculamos o total
    for encomenda in encomendas:
        # Buscar todos os itens da encomenda
        itens = ItemDeEncomenda.objects.filter(encomenda=encomenda)
        
        # Calcular o total somando o preco_total de cada item
        total_encomenda = sum([item.preco_total for item in itens])
        
        # Adicionar o total calculado à encomenda
        encomenda.total = total_encomenda

    return render(request, 'visualizar_encomendas.html', {'encomendas': encomendas})


@verificar_login
def detalhes_encomenda(request, encomenda_id):
    user_id = request.session.get('user_id')

    # Buscar a encomenda específica do usuário
    encomenda = get_object_or_404(Encomenda, encomenda_id=encomenda_id, utilizador_id=user_id)

    # Buscar os itens dessa encomenda
    itens = ItemDeEncomenda.objects.filter(encomenda=encomenda)

    # Calcular o total da encomenda
    total_encomenda = 0
    for item in itens:
        total_encomenda += item.preco_total

    return render(request, 'detalhes_encomenda.html', {
        'encomenda': encomenda,
        'itens': itens,
        'total': total_encomenda
    })

@verificar_funcionario
def listar_transacoes(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT * FROM vw_transacoes ORDER BY data_transacao DESC")
        transacoes = cursor.fetchall()

    # Estruturar os dados para o template
    dados_transacoes = [
        {
            'transacao_id': transacao[0],
            'encomenda_id': transacao[1],
            'utilizador_id': transacao[2],
            'nome_utilizador': transacao[3],
            'data_transacao': transacao[4],
            'metodo_pagamento': transacao[5],
            'valor_total': transacao[6],
        } for transacao in transacoes
    ]

    return render(request, 'listar_transacoes.html', {'transacoes': dados_transacoes})
#########################################################
def home(request):
    # Verifica se o utilizador está logado pela sessão
    user_id = request.session.get('user_id')
    user_type = request.session.get('user_type')  # Recupera o tipo de utilizador da sessão
    
    is_authenticated = user_id is not None  # Considera autenticado se 'user_id' estiver na sessão

    context = {
        'is_authenticated': is_authenticated,
        'user_type': user_type  # Passa o tipo de utilizador para o template
    }
    return render(request, 'home.html', context)

def login_view(request):
    if request.method == "POST":
        email = request.POST.get("email")
        password = request.POST.get("password")

        try:
            # Buscar o utilizador com o email
            utilizador = Utilizador.objects.get(email=email)
            
            # Verificar se a senha corresponde
            if utilizador.password == password:  # Aqui você pode substituir por `check_password` se estiver utilizando hash
                # Marcar o utilizador como logado
                request.session['user_id'] = utilizador.utilizador_id  # Armazena o ID do usuário na sessão
                request.session['user_name'] = utilizador.nome        # Armazena o nome do usuário na sessão
                request.session['user_type'] = utilizador.tipo_utilizador  # Armazena o tipo de utilizador na sessão

                return redirect('home')  # Redireciona para a página inicial

            else:
                return render(request, 'login.html', {'error': 'Credenciais inválidas.'})

        except Utilizador.DoesNotExist:
            return render(request, 'login.html', {'error': 'Usuário não encontrado.'})

    return render(request, 'login.html')

def logout_view(request):
    # Limpa todas as informações da sessão, deslogando o usuário
    request.session.flush()
    return redirect('home')


