from django.db import models

# Create your models here.

class Utilizador(models.Model):
    utilizador_id = models.AutoField(primary_key=True)
    nome = models.CharField(max_length=255)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    tipo_utilizador = models.CharField(max_length=50)
    morada = models.CharField(max_length=255, blank=True, null=True)
    telefone = models.CharField(max_length=15, blank=True, null=True)
    funcoes = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        db_table = 'utilizadores'  # Nome da tabela existente no banco de dados
        managed = False  # Impede que o Django crie ou modifique a tabela

    def __str__(self):
        return self.nome
    

class Produto(models.Model):
    produto_id = models.AutoField(primary_key=True)
    utilizador = models.ForeignKey(Utilizador, on_delete=models.CASCADE, related_name='produtos')
    nome = models.CharField(max_length=255)
    descricao = models.TextField(null=True, blank=True)
    preco = models.FloatField()
    categoria = models.CharField(max_length=50)
    quantidade = models.FloatField()
    desconto = models.FloatField(default=0)

    class Meta:
        db_table = 'produtos'  # Nome da tabela existente no banco de dados
        managed = False  # Impede que o Django crie ou modifique a tabela

    def __str__(self):
        return self.nome
    



class Encomenda(models.Model):
    encomenda_id = models.AutoField(primary_key=True)
    utilizador = models.ForeignKey(Utilizador, on_delete=models.CASCADE, related_name='encomendas')  # Usando o modelo Utilizador aqui
    transacao_id = models.IntegerField(null=True, blank=True)
    data_encomenda = models.DateTimeField(auto_now_add=True)
    estado = models.CharField(max_length=50, default='Pendente')
    tipo_entrega = models.CharField(max_length=50, default='entrega')  # Novo campo com valor padrão 'entrega'
    morada = models.CharField(max_length=255, null=True, blank=True)  # Morada será null quando o tipo_entrega for 'recolha'

    def __str__(self):
        return f"Encomenda {self.encomenda_id} - {self.utilizador.nome}"

    class Meta:
        db_table = "encomendas"  # Associar ao nome da tabela no banco de dados
        managed = False  # Impede que o Django crie ou modifique a tabela

class ItemDeEncomenda(models.Model):
    item_de_encomenda_id = models.AutoField(primary_key=True)
    produto = models.ForeignKey('Produto', on_delete=models.CASCADE)
    encomenda = models.ForeignKey(Encomenda, on_delete=models.CASCADE, related_name='itens')
    quantidade = models.FloatField()
    preco_total = models.FloatField()

    def __str__(self):
        return f"Item {self.item_de_encomenda_id} - Produto {self.produto.produto_nome}"

    class Meta:
        db_table = "item_de_encomenda"  # Associar ao nome da tabela no banco de dados
        managed = False  # Impede que o Django crie ou modifique a tabela





class ViewTodosProdutos(models.Model):
    produto_id = models.IntegerField(primary_key=True)
    fornecedor_nome = models.CharField(max_length=255)
    produto_nome = models.CharField(max_length=255)
    descricao = models.TextField(blank=True, null=True)
    preco = models.FloatField()
    categoria = models.CharField(max_length=50)
    quantidade = models.FloatField()

    class Meta:
        managed = False  # Django não tentará criar ou alterar a tabela/view
        db_table = 'view_todos_produtos'  # Nome da view no banco de dados


class ViewFuncionario(models.Model):
    utilizador_id = models.IntegerField(primary_key=True)
    nome = models.CharField(max_length=255)
    email = models.CharField(max_length=255)
    tipo_utilizador = models.CharField(max_length=50)
    morada = models.CharField(max_length=255)
    telefone = models.CharField(max_length=15)
    funcoes = models.CharField(max_length=255, null=True)

    class Meta:
        managed = False  # Indica que esta tabela é gerida pelo banco de dados
        db_table = 'listar_funcionarios_view'  # Nome da view


