/* 
    Projeto | Perfil Comportamental dos Clientes

Quantidade de transações históricas (Vida, D7, D14, D28, D56)
Dias desde a última transação
Idade na base
Produto mais usado (Vida, D7, D14, D28, D56)
Saldo de pontos atual
Pontos acumulados positivos (Vida, D7, D14, D28, D56)
Pontos acumulados negativos (Vida, D7, D14, D28, D56)
Dias da semana mais ativos (D28)
Período do dia mais ativo (D28)
Engajamento em D28 versus Vida 

*/

WITH TB_Transacoes AS (
    SELECT
        IdTransacao,
        IdCliente,
        QtdePontos,
        Datetime (Substr(DtCriacao, 1, 19)) AS DT_Criacao,
        Julianday ('now') - Julianday (Substr(DtCriacao, 1, 10)) AS Diff_Date,
        CAST (Strftime ('%H', Substr (DtCriacao, 1, 19)) AS INTEGER) AS DT_Hora

    FROM transacoes
),

TB_Clientes AS (
    SELECT 
        IdCliente,
        Datetime (Substr (DtCriacao, 1, 19)) AS Dt_Criacao,
        Julianday ('now') - Julianday (Substr(DtCriacao, 1, 10)) AS Idade_Base
    
    FROM clientes
),

TB_Sumario_Transacoes AS (
    SELECT
        IdCliente, 
        COUNT (IdTransacao) AS Qtde_Transacoes_Vida, 
        COUNT (CASE WHEN Diff_Date <= 56 THEN IdTransacao END) AS Qtde_Transacoes_D56, 
        COUNT (CASE WHEN Diff_Date <= 28 THEN IdTransacao END) AS Qtde_Transacoes_D28, 
        COUNT (CASE WHEN Diff_Date <= 14 THEN IdTransacao END) AS Qtde_Transacoes_D14, 
        COUNT (CASE WHEN Diff_Date <= 7 THEN IdTransacao END) AS Qtde_Transacoes_D7, 
         
        MIN (Diff_Date) AS Dias_Ultima_Interacao,
        
        SUM (QtdePontos) AS Saldo_Pontos,

        SUM (CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS Qtde_Pontos_Positivos_Vida,
        SUM (CASE WHEN QtdePontos > 0 AND Diff_Date <= 56 THEN QtdePontos ELSE 0 END) AS Qtde_Pontos_Positivos_D56,
        SUM (CASE WHEN QtdePontos > 0 AND Diff_Date <= 28 THEN QtdePontos ELSE 0 END) AS Qtde_Pontos_Positivos_D28,
        SUM (CASE WHEN QtdePontos > 0 AND Diff_Date <= 14 THEN QtdePontos ELSE 0 END) AS Qtde_Pontos_Positivos_D14,
        SUM (CASE WHEN QtdePontos > 0 AND Diff_Date <=  7 THEN QtdePontos ELSE 0 END) AS Qtde_Pontos_Positivos_D7,

        SUM (CASE WHEN QtdePontos < 0 THEN QtdePontos ELSE 0 END) AS Qtde_Pontos_Negativos_Vida,
        SUM (CASE WHEN QtdePontos < 0 AND Diff_Date <= 56 THEN QtdePontos ELSE 0 END) AS Qtde_Pontos_Negativos_D56,
        SUM (CASE WHEN QtdePontos < 0 AND Diff_Date <= 28 THEN QtdePontos ELSE 0 END) AS Qtde_Pontos_Negativos_D28,
        SUM (CASE WHEN QtdePontos < 0 AND Diff_Date <= 14 THEN QtdePontos ELSE 0 END) AS Qtde_Pontos_Negativos_D14,
        SUM (CASE WHEN QtdePontos < 0 AND Diff_Date <= 7 THEN QtdePontos ELSE 0 END) AS Qtde_Pontos_Negativos_D7

    FROM TB_Transacoes

    GROUP BY IdCliente
),

TB_Transacao_Produto AS (
    SELECT T1.*,
            T2.IdProduto,
            T3.DescNomeProduto,
            T3.DescCategoriaProduto

    FROM TB_Transacoes AS T1

    LEFT JOIN transacao_produto AS T2
    ON T1.IdTransacao = T2.IdTransacao

    LEFT JOIN produtos AS T3
    ON T2.IdProduto = T3.IdProduto
),

TB_Cliente_Produto AS (
    SELECT
        IdCliente,
        DescNomeProduto,
        COUNT (*) AS Qtde_Vida,
        COUNT (CASE WHEN Diff_Date <= 56 THEN IdTransacao END) AS Qtde_Vida_D56,
        COUNT (CASE WHEN Diff_Date <= 28 THEN IdTransacao END) AS Qtde_Vida_D28,
        COUNT (CASE WHEN Diff_Date <= 14 THEN IdTransacao END) AS Qtde_Vida_D14,
        COUNT (CASE WHEN Diff_Date <= 7 THEN IdTransacao END) AS Qtde_Vida_D7

    FROM TB_Transacao_Produto

    GROUP BY IdCliente, DescNomeProduto
),

TB_Cliente_Produto_RN AS (
    SELECT *,
            Row_Number () OVER (PARTITION BY IdCliente ORDER BY Qtde_Vida DESC) AS RN_Vida,
            Row_Number () OVER (PARTITION BY IdCliente ORDER BY Qtde_Vida_D56 DESC) AS RN_D56,
            Row_Number () OVER (PARTITION BY IdCliente ORDER BY Qtde_Vida_D28 DESC) AS RN_D28,
            Row_Number () OVER (PARTITION BY IdCliente ORDER BY Qtde_Vida_D14 DESC) AS RN_D14,
            Row_Number () OVER (PARTITION BY IdCliente ORDER BY Qtde_Vida_D7 DESC) AS RN_D7

    FROM TB_Cliente_Produto
),

TB_Cliente_Dia AS (
    SELECT 
        idCliente,
        Strftime ('%w', DT_Criacao) AS DT_Dia,
        COUNT (*) AS Qtde_Transacao

    FROM TB_Transacoes

    WHERE Diff_Date <= 28

    GROUP BY IdCliente, DT_Dia
),

TB_Cliente_Dia_RN AS (
    SELECT *,
            Row_Number () OVER (PARTITION BY idCliente ORDER BY Qtde_Transacao) AS RN_Dia

    FROM TB_Cliente_Dia
),

TB_Cliente_Periodo AS (
    SELECT
        idCliente,
        CASE 
            WHEN DT_Hora BETWEEN 7 AND 12 THEN 'Manhã'
            WHEN DT_Hora BETWEEN 13 AND 18 THEN 'Tarde'
            WHEN DT_Hora BETWEEN 19 AND 23 THEN 'Noite'
            ELSE 'Madrugada'
        END AS Periodo,
        COUNT (*) AS Qtde_Transacoes

    FROM TB_Transacoes

    WHERE Diff_Date <= 28

    GROUP BY IdCliente, Periodo
),

TB_Cliente_Periodo_RN AS (
    SELECT *,
            Row_Number () OVER (PARTITION BY IdCliente ORDER BY Qtde_Transacoes DESC) AS RN_Periodo

    FROM TB_Cliente_Periodo
),

TB_Join AS (
    SELECT T1.*,
            T2.Idade_Base,
            T3.DescNomeProduto AS Produto_Vida,
            T4.DescNomeProduto AS Produto_Vida_D56,
            T5.DescNomeProduto AS Produto_Vida_D28,
            T6.DescNomeProduto AS Produto_Vida_D14,
            T7.DescNomeProduto AS Produto_Vida_D7,
            COALESCE (T8.DT_Dia, -1) AS DT_Dia_D28,
            COALESCE (T9.Periodo, 'Sem Informação') AS Periodo_D28


    FROM TB_Sumario_Transacoes AS T1

    LEFT JOIN TB_Clientes AS T2
    ON T1.IdCliente = T2.IdCliente

    LEFT JOIN TB_Cliente_Produto_RN AS T3
    ON T1.IdCliente = T3.IdCliente
    AND T3.RN_Vida = 1

    LEFT JOIN TB_Cliente_Produto_RN AS T4
    ON T1.IdCliente = T4.IdCliente
    AND T4.RN_D56 = 1

    LEFT JOIN TB_Cliente_Produto_RN AS T5
    ON T1.IdCliente = T5.IdCliente
    AND T5.RN_D28 = 1

    LEFT JOIN TB_Cliente_Produto_RN AS T6
    ON T1.IdCliente = T6.IdCliente
    AND T6.RN_D14 = 1

    LEFT JOIN TB_Cliente_Produto_RN AS T7
    ON T1.IdCliente = T7.IdCliente
    AND T7.RN_D7 = 1

    LEFT JOIN TB_Cliente_Dia_RN AS T8
    ON T1.IdCliente = T8.IdCliente
    AND T8.RN_Dia = 1

    LEFT JOIN TB_Cliente_Periodo_RN AS T9
    ON T1.IdCliente = T9.IdCliente
    AND T9.RN_Periodo = 1
)

SELECT *,
        1.* Qtde_Transacoes_D28 / Qtde_Transacoes_Vida AS Engajamento_D28_Vida

FROM TB_Join