from django.conf import settings
from datetime import datetime

# Conectando à coleção 'avaliacoes' no MongoDB
avaliacoes_collection = settings.MONGO_DB['avaliacoes']

def adicionar_avaliacao(utilizador_id, produto_id, classificacao, comentario):
    """
    Salva uma avaliação no MongoDB.
    """
    if not (1 <= classificacao <= 5):
        raise ValueError("Classificação deve estar entre 1 e 5.")

    avaliacao = {
        'utilizador_id': int(utilizador_id),
        'produto_id': int(produto_id),
        'classificacao': int(classificacao),
        'comentario': comentario,
        'data_criacao': datetime.now(),
    }
    avaliacoes_collection.insert_one(avaliacao)

def buscar_avaliacoes_por_produto(produto_id):
    """
    Retorna todas as avaliações de um produto específico.
    """
    return list(avaliacoes_collection.find({'produto_id': produto_id}))

def calcular_media_classificacao(produto_id):
    """
    Calcula a média das classificações de um produto.
    """
    avaliacoes = buscar_avaliacoes_por_produto(produto_id)
    if not avaliacoes:
        return 0

    total_classificacao = sum(avaliacao['classificacao'] for avaliacao in avaliacoes)
    return total_classificacao / len(avaliacoes)
