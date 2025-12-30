# Intensidade, Saliência e Magnitude do Afeto: a recorrência da Estrutura Hierárquica

![Status](https://img.shields.io/badge/Status-Active-green)
![Language](https://img.shields.io/badge/Language-R_%7C_Python-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

## 📋 Sobre o Projeto

Este repositório contém os códigos-fonte, datasets processados e rotinas de análise estatística que fundamentam o projeto de pesquisa **"Desenvolvimento, Validação e Aplicação Clínica de Sistemas Inteligentes para Avaliação Afetiva em Musicoterapia"**.

O objetivo central é demonstrar empiricamente a existência de uma **Estrutura Hierárquica do Afeto**, onde a **Intensidade** (Saliência/Magnitude) atua como uma dimensão primária e unipolar, distinta do *Arousal* (ativação) e da *Valência* (prazer-desprazer) do modelo circumplexo tradicional.

Esta base de código oferece suporte à transparência e reprodutibilidade dos achados submetidos ao CNPq (Chamada 23/2025 - Bolsas de Produtividade).

---

## 🗂️ Estrutura do Repositório

O projeto organiza-se em três eixos de investigação que triangulam dados semânticos, psicométricos, fisiológicos e musicais.

### 📂 1. A Estrutura Hierárquica (Semântica e Autorrelato)
Investigação comparativa da estrutura latente em dois domínios: a linguagem natural e a experiência subjetiva (Manuscrito *"Before the Circumplex"*).

- **Dados:** 
    - (A) Corpus de 57.000 comentários do YouTube (Embeddings).
    - (B) Amostra clínica e não-clínica respondendo ao PANAS ($N=457$).
- **Método:** Modelagem Comparativa usando PCA, PLS-SEM (Formativo) e CFA (Reflexivo).
- **Principal Achado:** A estrutura hierárquica confirma-se em ambos os domínios, mas com naturezas distintas. Na **Linguagem**, a Intensidade é Saliência Semântica (independente da valência). Na **Experiência Subjetiva**, a Intensidade colapsa com o Afeto Negativo (*Distress*).

### 📂 2. Análise Fisiológica (GSR/EDA)
Reanálise de dados psicofisiológicos para testar a unipolaridade da ativação biológica.

- **Dados:** Dataset secundário EMO2018-SCR (Juuse et al., 2024), contendo condutância da pele de 102 participantes.
- **Método:** Análise de Decomposição Contínua (CDA) e PCA sobre métricas de reatividade.
- **Principal Achado:** Todas as métricas fisiológicas carregam positivamente em um único **Fator Geral de Intensidade Fisiológica**. Isso refuta a ideia de *arousal* bipolar no nível autonômico e confirma a existência de uma dimensão de "Mobilização de Energia" bruta.

### 📂 3. Percepção Musical (MEET)
Evidência da hierarquia no domínio auditivo (Estudo "Marília").

- **Dados:** Respostas de 200 participantes a 116 estímulos musicais originais, compostos teoricamente para representar os 4 quadrantes afetivos.
- **Método:** Teoria de Resposta ao Item (TRI) e Modelagem Bifatorial.
- **Principal Achado:** Mesmo com estímulos desenhados para serem distintos, a Análise Fatorial revelou um **Fator Geral Robusto** que explica a maior parte da variância, sugerindo que a percepção musical é primariamente guiada pela **Intensidade Afetiva Geral** antes da diferenciação qualitativa.

---

## 🚀 Como Reproduzir as Análises

### Pré-requisitos
Certifique-se de ter instalado:
*   R (versão 4.0+)
*   Python (versão 3.8+)
*   RStudio

### Executando os Estudos
Cada pasta contém um arquivo RMarkdown (`.Rmd`) que gera o relatório completo da análise.

1.  **Semântica e Autorrelato:** `scripts/study1_semantics/CircumplexClean.Rmd`
2.  **Fisiologia:** `scripts/study3_physiology/EMO2018_FG.Rmd`
3.  **Música (MEET):** `scripts/study4_music/AnaliseMarilia.Rmd`

---

## 📊 Visualizações Chave

### A "Falha" do Modelo Vetorial (Semântica)
![Scatter Plot Saliência vs Vetor](images/scatter_semantica.png)
> *Figura 1: A correlação negativa (r = -0.71) entre a Saliência Semântica real e a Intensidade Vetorial teórica demonstra a necessidade de uma revisão hierárquica do modelo: a intensidade na linguagem não é apenas um vetor, mas uma dimensão de magnitude.*

### A Dissociação Psicofisiológica
![Modelo Misto Fisiologia](images/forest_plot_gsr.png)
> *Figura 2: Análise de coeficientes (Modelo Linear Misto) demonstrando que o 'Arousal' normativo (subjetivo) não prediz significativamente a Intensidade Fisiológica (GSR/EDA). O intervalo de confiança cruzando a linha zero (tracejada) confirma que a mobilização biológica é uma dimensão distinta da ativação percebida.*

---

## 📝 Citação

Se você utilizar os códigos ou a taxonomia proposta, por favor cite:

> **Pedrosa, F. G. (2025).** *Intensidade, Saliência e Magnitude do Afeto: a recorrência do Fator Geral em dados secundários*. GitHub Repository. Disponível em: https://github.com/FredPedrosa/Intensity_DT

---

## 📞 Contato

**Frederico Gonçalves Pedrosa**
*   Universidade Federal de Minas Gerais (UFMG)
*   Escola de Música | Depto. de Instrumentos e Canto
*   **PPG Música & PPG Neurociências**
*   Email: [frederico.musicoterapia@gmail.com](mailto:frederico.musicoterapia@gmail.com)
