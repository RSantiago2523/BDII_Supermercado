import psycopg2
from psycopg2.extras import RealDictCursor
from functools import wraps
from django.http import HttpResponseForbidden


# Configure sua conexão com o PostgreSQL
def get_postgres_connection():
    return psycopg2.connect(
        dbname="BDII_PROJETO",
        user="postgres_!5",
        password="xqC797FGL",
        host="localhost",
        port="5432"
    )


def authenticate_user(email, password):
    try:
        # Conecte-se ao PostgreSQL
        conn = get_postgres_connection()
        cursor = conn.cursor(cursor_factory=RealDictCursor)
        # Consulte o usuário pelo e-mail e senha
        cursor.execute(
            """
            SELECT * FROM UTILIZADORES
            WHERE email = %s AND password = %s
            """,
            (email, password)
        )
        user = cursor.fetchone()
        cursor.close()
        conn.close()
        return user
    except Exception as e:
        print(f"Erro ao autenticar o user: {e}")
        return None
    

def has_permission(permission):
    def decorator(view_func):
        @wraps(view_func)
        def _wrapped_view(request, *args, **kwargs):
            if request.user.is_authenticated:
                try:
                    # Conexão ao PostgreSQL
                    conn = get_postgres_connection()
                    cursor = conn.cursor(cursor_factory=RealDictCursor)
                    # Consulte o utilizador pelo e-mail
                    cursor.execute(
                        """
                        SELECT TIPO_UTILIZADOR FROM UTILIZADORES
                        WHERE email = %s
                        """,
                        (request.user.email,)
                    )
                    user = cursor.fetchone()
                    cursor.close()
                    conn.close()
                    # Verifique a permissão do usuário
                    if user and user.get('TIPO_UTILIZADOR ') == permission:
                        request.user_role = user.get('TIPO_UTILIZADOR ')
                        return view_func(request, *args, **kwargs)
                except Exception as e:
                    print(f"Erro ao verificar permissão: {e}")
            return HttpResponseForbidden("You don't have permission to access this page.")
        return _wrapped_view
    return decorator