db.createCollection("avaliacoes", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["utilizador_id", "produto_id", "classificacao", "comentario", "data_criacao"],
            properties: {
                utilizador_id: {
                    bsonType: "int",
                    description: "O ID do utilizador é obrigatório e deve ser um número inteiro."
                },
                produto_id: {
                    bsonType: "int",
                    description: "O ID do produto é obrigatório e deve ser um número inteiro."
                },
                classificacao: {
                    bsonType: "int",
                    minimum: 1,
                    maximum: 5,
                    description: "A classificação é obrigatória e deve ser um número entre 1 e 5."
                },
                comentario: {
                    bsonType: "string",
                    description: "O comentário é obrigatório e deve ser uma string."
                },
                data_criacao: {
                    bsonType: "date",
                    description: "A data de criação é obrigatória e deve ser um valor de data."
                }
            }
        }
    }
});

db.avaliacoes.insertMany([
    // Avaliações para o produto 1
    {
        utilizador_id: 1,
        produto_id: 1,
        classificacao: 5,
        comentario: "Excelente produto, recomendo!",
        data_criacao: new Date()
    },
    {
        utilizador_id: 2,
        produto_id: 1,
        classificacao: 4,
        comentario: "Muito bom, atendeu minhas expectativas.",
        data_criacao: new Date()
    },

    // Avaliações para o produto 2
    {
        utilizador_id: 3,
        produto_id: 2,
        classificacao: 3,
        comentario: "Poderia ser melhor, mas é razoável.",
        data_criacao: new Date()
    },
    {
        utilizador_id: 4,
        produto_id: 2,
        classificacao: 2,
        comentario: "Não gostei muito, veio com defeito.",
        data_criacao: new Date()
    },

    // Avaliações para o produto 3
    {
        utilizador_id: 5,
        produto_id: 3,
        classificacao: 4,
        comentario: "Ótima relação custo-benefício.",
        data_criacao: new Date()
    },
    {
        utilizador_id: 6,
        produto_id: 3,
        classificacao: 5,
        comentario: "Superou as expectativas!",
        data_criacao: new Date()
    },

    // Avaliações para o produto 4
    {
        utilizador_id: 7,
        produto_id: 4,
        classificacao: 1,
        comentario: "Péssima qualidade, não recomendo.",
        data_criacao: new Date()
    },
    {
        utilizador_id: 8,
        produto_id: 4,
        classificacao: 3,
        comentario: "Produto razoável, mas poderia melhorar.",
        data_criacao: new Date()
    }
]);
