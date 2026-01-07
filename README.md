# Projeto SQL | Tabela do Perfil Comportamental do Cliente:

Este repositório contém o projeto final do curso de SQL do canal **Teo Me Why**, focado na construção de uma **Feature Store** (Tabela de Características de seus espectadores). O objetivo é transformar dados transacionais brutos em uma visão analítica comportamental por cliente (safra), a fim de ser utilizada em modelos de Machine Learning (como previsão de Churn, recomendação ou propensão de compra).

## Objetivo Principal

Criar uma tabela do comportamento do cliente em datas específicas. Em vez de apenas olhar para o estado atual, o projeto reconstrói o passado para entender como o cliente se comportava em períodos de tempo definido (últimos 7, 28, 56 dias).

Permitindo responder perguntas como:
* *"Qual era a frequência de compra desse cliente há 3 meses?"*
* *"Qual o produto favorito dele nos últimos 28 dias?"*
* *"Ele está abandonando a plataforma? (Churn)"*

## Variáveis Desenvolvidas:

A query SQL transforma logs de transações em uma tabela onde cada linha representa um cliente em uma data específica, contendo:

* **Recência (Recency):** Dias desde a última transação.
* **Idade na Base:** Tempo desde o cadastro do usuário.
* **Frequência (Frequency):**
  * Quantidade total de transações (Vida).
  * Transações nas janelas de 7, 14, 28 e 56 dias.
* **Engajamento:** Razão entre transações recentes (28 dias) e o histórico total.
* **Monetário/Pontos:**
  * Saldo atual de pontos.
  * Pontos ganhos e gastos (acumulado e por janelas de tempo).
* **Preferências:**
  * Produto mais consumido (Vida e por janelas de tempo).
  * Dia da semana favorito para transacionar.
  * Período do dia favorito (Manhã, Tarde ou Noite).

## Técnicas Abordadas

* **SQL Avançado:**
  * **CTEs (Common Table Expressions):** Para organizar a lógica e dividir o problema em porções menores.
  * **Window Functions (`ROW_NUMBER`, `PARTITION BY`):** Para encontrar "o mais frequente" (moda) de produtos e dias.
  * **Case When & Coalesce:** Para tratamento de nulos e criação de faixas de horário.
  * **Joins Complexos:** Cruzamento de múltiplas visões do cliente.
