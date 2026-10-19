from datetime import datetime

class Avaliacao:
    def __init__(self, id_utilizador, id_produto, classificacao, comentario, data_criacao=None):
        self.id_utilizador = id_utilizador
        self.id_produto = id_produto
        self.classificacao = classificacao
        self.comentario = comentario
        self.data_criacao = data_criacao or datetime.utcnow()

    def to_dict(self):
        """Converte a avaliação para um dicionário para armazenar no MongoDB."""
        return {
            'id_utilizador': self.id_utilizador,
            'id_produto': self.id_produto,
            'classificacao': self.classificacao,
            'comentario': self.comentario,
            'data_criacao': self.data_criacao,
        }
