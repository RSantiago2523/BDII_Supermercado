from django.contrib import admin
from django.urls import path
from Loja import views

urlpatterns = [
    path('', views.home, name='home'),  # Página principal
    path('login/', views.login_view, name='login'),  # Login
    path('logout/', views.logout_view, name='logout'),  # Logout
    path('registro/', views.registar_cliente, name='registro'),
    
    path('produtos/', views.lista_produtos_view, name='lista_produtos'),
    path('produtos/<int:produto_id>/', views.detalhes_produto, name='detalhes_produto'),
    #path('produtos/<int:produto_id>/', views.produto_detalhe_view, name='produto_detalhe'),

    path('adicionar-carrinho/<int:produto_id>/', views.adicionar_ao_carrinho, name='adicionar_ao_carrinho'),
    path('carrinho/', views.visualizar_carrinho, name='visualizar_carrinho'),
    path('remover-carrinho/<int:produto_id>/', views.remover_do_carrinho, name='remover_do_carrinho'),
    path('confirmar-compra/', views.confirmar_compra, name='confirmar_compra'),


    path('listar-encomendas/', views.listar_encomendas_view, name='listar_encomendas'),
    path('atualizar_desconto/<int:produto_id>/', views.atualizar_desconto, name='atualizar_desconto'),
    path('excluir_encomenda/<int:encomenda_id>/', views.excluir_encomenda, name='excluir_encomenda'),
    path('marcar_como_entregue/<int:encomenda_id>/', views.marcar_como_entregue, name='marcar_como_entregue'),
    # URLs para encomendas de fornecedores
    path('encomendas_fornecedor/excluir/<int:encomenda_fornecedor_id>/', views.excluir_encomenda_fornecedor, name='excluir_encomenda_fornecedor'),
    path('encomendas_fornecedor/entregar/<int:encomenda_fornecedor_id>/', views.marcar_como_entregue_fornecedor, name='marcar_como_entregue_fornecedor'),
    
    path('minhas-encomendas/', views.visualizar_encomendas, name='visualizar_encomendas'),
    path('encomenda/<int:encomenda_id>/', views.detalhes_encomenda, name='detalhes_encomenda'),

    path('transacoes/', views.listar_transacoes, name='listar_transacoes'),

    # rotas da lista dos funcionarios
    path('gestor/lista_funcionarios', views.listar_funcionarios, name='lista_utilizadores'),
    path('gestor/lista_funcionarios/remover/<int:utilizador_id>/', views.remover_funcionario, name='remover_funcionario'),
    path('gestor/lista_funcionarios/adicionar/', views.adicionar_utilizador, name='adicionar_utilizador'),
    path('gestor/lista_funcionarios/editar/<int:utilizador_id>/', views.editar_funcionario, name='editar_funcionario'),
    # Rotas da lista dos produtos versao do gestores
    path('gestor/lista/', views.gestor_lista, name='gestor_lista'),
    path('gestor/remove/<int:produto_id>/', views.remove_produto, name='remove_produto'),
    path('gestor/atualizar/<int:produto_id>/', views.atualizar_estoque, name='atualizar_estoque'),
    path('gestor/adicionar/', views.adicionar_produto, name='adicionar_produto'),

]
    