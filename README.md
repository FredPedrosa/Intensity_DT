# A Arquitetura da Intensidade: Evidências Computacionais e Psicométricas

![Status](https://img.shields.io/badge/Status-Active-green)
![Language](https://img.shields.io/badge/Language-R_%7C_Python-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 📋 Sobre o Projeto

Este repositório contém os códigos-fonte, datasets processados e rotinas de análise estatística que fundamentam o projeto de pesquisa **"Desenvolvimento, Validação e Aplicação Clínica de Sistemas Inteligentes para Avaliação Afetiva em Musicoterapia"**.

O objetivo central é demonstrar empiricamente a existência de uma **Estrutura Hierárquica do Afeto**, onde a **Intensidade** (Saliência/Magnitude) atua como uma dimensão primária e unipolar, distinta do *Arousal* (ativação) e da *Valência* (prazer-desprazer) do modelo circumplexo tradicional.

Esta base de código oferece suporte à transparência e reprodutibilidade dos achados submetidos ao CNPq (Chamada 23/2025 - Bolsas de Produtividade).

---

## 🗂️ Estrutura do Repositório

O projeto divide-se em quatro estudos complementares que triangulam dados semânticos, psicométricos, fisiológicos e musicais.

### 📂 1. Análise Semântica (NLP & Embeddings)
Investigação da estrutura latente da linguagem afetiva natural.
- **Dados:** Corpus de 57.000 comentários do YouTube sobre música brasileira.
- **Método:** Extração de *Word Embeddings* (BERT/MPNet) e análise dimensional (PCA e PLS-SEM).
- **Principal Achado:** Identificação de uma correlação negativa robusta ($r = -0.71$) entre a Saliência Semântica (PC1) e a Intensidade Vetorial teórica de Reisenzein, sugerindo que a intensidade na linguagem é uma dimensão de magnitude independente.

### 📂 2. Estrutura do Autorrelato (PANAS)
Investigação da estrutura fenomenológica da experiência subjetiva.
- **Dados:** Amostra brasileira respondendo à escala PANAS ($N=457$).
- **Método:** Análise Fatorial Confirmatória (CFA) e Modelos Bifatoriais.
- **Principal Achado:** Na experiência subjetiva, a "Intensidade" tende a colapsar com o Afeto Negativo (*Distress*), diferenciando-se da estrutura semântica pura.

### 📂 3. Análise Fisiológica (GSR/EDA)
Reanálise de dados psicofisiológicos para testar a unipolaridade da ativação.
- **Dados:** Dataset secundário EMO2018-SCR (Juuse et al., 2024), contendo condutância da pele de 102 participantes.
- **Método:** Análise de Decomposição Contínua (CDA) e PCA sobre métricas de reatividade (Frequência, Amplitude, Área sob a Curva).
- **Principal Achado:** Todas as métricas fisiológicas carregam positivamente em um único **Fator Geral de Intensidade Fisiológica**. Isso refuta a ideia de *arousal* bipolar no nível autonômico e confirma a existência de uma dimensão de "Mobilização de Energia" bruta que precede a qualificação emocional.

### 📂 4. Percepção Musical (MEET)
Evidência da hierarquia no domínio auditivo (Estudo "Marília").
- **Dados:** Respostas de 200 participantes a 116 estímulos musicais originais, compostos teoricamente para representar os 4 quadrantes afetivos distintos (Alegria, Medo/Raiva, Tristeza, Serenidade).
- **Método:** Teoria de Resposta ao Item (TRI) e Modelagem Bifatorial.
- **Principal Achado:** Mesmo com estímulos desenhados para serem distintos, a Análise Fatorial revelou um **Fator Geral Robusto** que explica a maior parte da variância das respostas, sobrepondo-se às categorias específicas. Isso sugere que, assim como na semântica e na fisiologia, a percepção musical é primariamente guiada por uma dimensão de **Intensidade Afetiva Geral** antes da diferenciação qualitativa.

---

## 🚀 Como Reproduzir as Análises

### Pré-requisitos
Certifique-se de ter instalado:
*   R (versão 4.0+)
*   Python (versão 3.8+)
*   RStudio

## 🚀 Executando os Estudos

Cada pasta contém um arquivo RMarkdown (`.Rmd`) que gera o relatório completo da análise, garantindo a reprodutibilidade total dos resultados apresentados.

1.  **Fisiologia:** `scripts/study3_physiology/analysis_GSR.Rmd`
2.  **Semântica:** `scripts/study1_semantics/analysis_embeddings.Rmd`
3.  **Música (MEET):** `scripts/study4_music/validation_MEET.Rmd`

---

## 📊 Visualizações Chave

### A "Falha" do Modelo Vetorial (Semântica)
<!-- Insira a imagem do gráfico na pasta 'images' e ajuste o nome abaixo -->
![Scatter Plot Saliência vs Vetor](images/scatter_semantica.png)
> *Figura 1: A correlação negativa (r = -0.71) entre a Saliência Semântica real e a Intensidade Vetorial teórica demonstra a necessidade de uma revisão hierárquica do modelo: a intensidade na linguagem não é apenas um vetor, mas uma dimensão de magnitude.*

### O Fator Geral Fisiológico
<!-- Insira a imagem do gráfico na pasta 'images' e ajuste o nome abaixo -->
![PCA Fisiologia](images/pca_fisiologia.png)
> *Figura 2: A convergência de todas as métricas de condutância da pele (GSR/EDA) em um único componente principal unipolar confirma a existência de uma dimensão de Intensidade Fisiológica independente da valência.*

---

## 📝 Citação

Se você utilizar estes dados, códigos ou a taxonomia proposta, por favor cite:

> **Pedrosa, F. G. (2025).** *song_sent_scores: Computational Design for Charting Dynamic Emotion in Songs with a Multimodal Circumplex Framework*. GitHub Repository. Disponível em: https://github.com/FredPedrosa/youtube_circumplex

---

## 📞 Contato

**Frederico Gonçalves Pedrosa**
*   Universidade Federal de Minas Gerais (UFMG)
*   Escola de Música | Depto. de Instrumentos e Canto
*   **PPG Música & PPG Neurociências**
*   Email: [frederico.musicoterapia@gmail.com](mailto:frederico.musicoterapia@gmail.com)














```r
source("scripts/00_setup.R")
