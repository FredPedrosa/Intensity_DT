library(readxl)
library(dplyr)
library(psych) # Para a PCA

# Carregar os dados (se já não estiverem carregados)
dat4 <- read.csv("~/PIBIT2025/Circumplex/BasesDados/EMO2018-SCR/dat4.csv")

# 1.1 Selecionar as variáveis de interesse
# Vamos focar nas medidas de magnitude da resposta de GSR (CDA)
physio_vars_names <- c("CDA.nSCR", "CDA.AmpSum", "CDA.SCR", "CDA.ISCR", "CDA.PhasicMax")
# Adicione outras que julgar interessantes, como Global.Mean ou Global.MaxDeflection

physio_data <- dat4 %>%
  select(all_of(physio_vars_names))

# 1.2 Lidar com Dados Faltantes (NA)
# Por enquanto, a abordagem mais simples e robusta é a exclusão (listwise deletion)
# Isso remove qualquer linha que tenha NA em qualquer uma das colunas selecionadas
physio_data_clean <- na.omit(physio_data)

cat(sprintf("Número original de observações: %d\n", nrow(physio_data)))
cat(sprintf("Número de observações após remover NAs: %d\n", nrow(physio_data_clean)))

# 1.3 Padronizar (escalar) os dados
# A PCA requer que as variáveis estejam na mesma escala para evitar viés.
physio_data_scaled <- scale(physio_data_clean)


# --- PASSO 2: ANÁLISE DE COMPONENTES PRINCIPAIS (PCA) ---

# 2.1 Verificar a fatorabilidade dos dados (Teste KMO)
# Se o KMO for baixo (< 0.6), a PCA pode não ser apropriada.
cor <- cor(physio_data_scaled, method = "spearman")
kmo_result <- KMO(cor)
print(kmo_result)

# 2.2 Determinar o número de componentes a extrair (Análise Paralela)
parallel_analysis <- fa.parallel(physio_data_scaled, fa = "both") # 'pc' para Componentes Principais
print(parallel_analysis)
# A análise irá sugerir o número ideal de componentes.

# 2.3 Rodar a PCA final (sem rotação) para testar a hipótese do Fator Geral
# Use o número de componentes sugerido pela análise paralela
n_components <- parallel_analysis$ncomp 

pca_results <- principal(physio_data_scaled, nfactors = n_components, rotate = "none")

# Imprimir as cargas fatoriais.
# ESTE É O MOMENTO DA VERDADE:
# O PC1 explica a maior parte da variância? Todas as variáveis carregam positivamente nele?
print(pca_results$loadings, cutoff = 0)


# --- PASSO 3.1: PREPARAÇÃO FINAL DOS DADOS ---

# 1. Extrair os escores da nossa PCA final
pca_scores <- as.data.frame(pca_results$scores)
colnames(pca_scores) <- "PC1_Intensity"

# 2. Juntar os escores de volta ao data frame limpo
# Lembre-se que 'physio_data_clean' tem o mesmo número de linhas que 'pca_scores'
# Mas precisamos dos identificadores, que estão no 'dat4' original.
# Vamos pegar as linhas do 'dat4' que correspondem ao nosso 'physio_data_clean'
# A função na.omit() no 'physio_data' removeu linhas, então precisamos rastrear quais ficaram.
# 'attr(physio_data_clean, "na.action")' nos diz quais linhas foram removidas. Se for NULL, nenhuma foi.
clean_rows_indices <- as.numeric(rownames(physio_data_clean))
dat4_clean <- dat4[clean_rows_indices, ]

# Agora, junte tudo: identificadores, escores da PCA, e os dados originais
analysis_df <- cbind(dat4_clean, pca_scores)

# 3. Carregar e preparar os ratings de Arousal/Valência
arousal_valence_ratings <- read_excel("~/PIBIT2025/Circumplex/BasesDados/EMO2018-SCR/arousal-valence-ratings.xlsx")

# 4. Juntar os ratings ao nosso data frame principal
# Usaremos 'left_join' do dplyr, que é mais seguro. A chave é 'EmoId'.
analysis_df_final <- analysis_df %>%
  left_join(arousal_valence_ratings, by = "EmoId")

# Verifique o resultado. Agora temos um data frame com tudo que precisamos.
glimpse(analysis_df_final)



# --- ANÁLISE FINAL: TESTANDO SE A INTENSIDADE FISIOLÓGICA (PC1) VARIA POR EMOÇÃO ---

# (Assumimos que você já tem o 'analysis_df_final' com os escores da PCA. 
# Mesmo que os ratings de Arousal/Valence estejam errados, os escores do PC1 estão corretos.)

library(ggplot2)
library(lme4)
library(lmerTest)

# 1. VISUALIZAÇÃO EXPLORATÓRIA
# Vamos criar um boxplot para ver se existem diferenças visuais.

ggplot(analysis_df_final, aes(x = EmoId, y = PC1_Intensity, fill = EmoId)) +
  geom_boxplot() +
  labs(
    title = "Intensidade Fisiológica (PC1) por Categoria de Emoção",
    x = "Categoria de Emoção",
    y = "Escore de Intensidade Fisiológica (PC1)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# 2. O TESTE ESTATÍSTICO (MODELO MISTO)
# Usamos um modelo misto para levar em conta que múltiplas observações

# Modelo: O escore de Intensidade (PC1) é previsto pela Categoria de Emoção (EmoId),
# com interceptos aleatórios para cada participante.
model_final <- lmerTest::lmer(PC1_Intensity ~ EmoId + (1 | ParticipantId), data = analysis_df_final)

# Obter a tabela da ANOVA para ver o efeito principal de EmoId
anova(model_final)

# Se o efeito for significativo, podemos fazer comparações post-hoc para ver
# quais emoções são diferentes umas das outras.
library(emmeans)
post_hoc_results <- emmeans(model_final, pairwise ~ EmoId, pbkrtest.limit = 7549)
print(post_hoc_results)






####### TESTES E LIXEIRA
# --- ANÁLISE FINAL: VERSÃO CORRIGIDA PARA JUNÇÃO ---

library(dplyr)
library(readxl)
library(randomForest)
library(caret)

# 1. CARREGAR OS DADOS ESSENCIAIS
dat4 <- read.csv("~/PIBIT2025/Circumplex/BasesDados/EMO2018-SCR/dat4.csv")
labels <- read_excel("~/PIBIT2025/Circumplex/BasesDados/ECG_GSR/Version3/Self-Annotation Labels/Self-annotation_Multimodal.xlsx")

# 2. PREPARAR O DATA FRAME MESTRE (A FORMA CORRETA)

# Preparar o 'labels' para a junção. Renomear e garantir tipos corretos.
labels_para_join <- labels %>%
  rename(
    Participant = `Participant Id`, # Renomear para corresponder à coluna numérica em dat4
    Event.Nr = `Video ID`
  ) %>%
  # Garantir que as chaves de junção sejam do tipo correto (inteiro)
  mutate(
    Participant = as.integer(Participant),
    Event.Nr = as.integer(Event.Nr)
  )

# Preparar o 'dat4' para a junção
dat4_para_join <- dat4 %>%
  # Garantir que as chaves de junção sejam do tipo correto (inteiro)
  mutate(
    Participant = as.integer(Participant),
    Event.Nr = as.integer(Event.Nr)
  )

# Agora, junte os dois data frames usando as colunas corretas e compatíveis
master_df_final <- inner_join(dat4_para_join, labels_para_join, by = c("Participant", "Event.Nr"))

# Verificação: o data frame final deve ter as colunas de fisiologia E as colunas de Valence/Arousal level
glimpse(master_df_final)


# 3. CRIAR A VARIÁVEL ALVO "INTENSIDADE"
class_data_raw <- master_df_final %>%
  select(`Arousal level`, CDA.nSCR, CDA.AmpSum, CDA.SCR, CDA.ISCR, CDA.PhasicMax) %>%
  na.omit()

median_arousal <- median(class_data_raw$`Arousal level`)
class_data <- class_data_raw %>%
  mutate(
    Intensidade = factor(if_else(`Arousal level` <= median_arousal, "Baixa", "Alta"))
  ) %>%
  select(-`Arousal level`)

# 4. TREINAR E AVALIAR O MODELO
set.seed(123)
train_indices <- createDataPartition(class_data$Intensidade, p = 0.8, list = FALSE)
train_data <- class_data[train_indices, ]
test_data  <- class_data[-train_indices, ]

rf_model_intensidade <- randomForest(Intensidade ~ ., data = train_data)

print(rf_model_intensidade)
predictions <- predict(rf_model_intensidade, test_data)
confusionMatrix(predictions, test_data$Intensidade)

varImpPlot(rf_model_intensidade)






# --- ANÁLISE DA ESTRUTURA DOS RATINGS SUBJETIVOS ---

library(dplyr)
library(psych)

# 1. Preparar os dados
# Usaremos o 'master_df_final', que contém os ratings para cada evento.
# Selecionamos as três colunas de ratings e removemos os NAs.
ratings_data <- master_df_final %>%
  select(`Valence level`, `Arousal level`, `Dominance level`) %>%
  na.omit()

# Renomear para facilitar
colnames(ratings_data) <- c("Valence", "Arousal", "Dominance")

# 2. Padronizar (escalar) os dados
ratings_scaled <- scale(ratings_data)

# 3. Verificar a fatorabilidade (KMO)
KMO(ratings_scaled)
# Esperamos um KMO bom, pois são apenas 3 variáveis que devem estar relacionadas.

# 4. Análise Paralela
fa.parallel(ratings_scaled, fa = "pc")
# Isso nos dirá se a estrutura é unidimensional ou multidimensional.

# 5. Rodar a PCA sem rotação para procurar o Fator Geral
pca_ratings <- principal(ratings_scaled, nfactors = 3, rotate = "none") # Pedimos 3 para ver a estrutura completa

# 6. INTERPRETAR OS RESULTADOS!
print(pca_ratings$loadings, cutoff = 0)





library(lavaan)

# (Usaremos 'ratings_scaled' que você já criou)

# --- HIPÓTESE 1: EXISTE UM FATOR GERAL ÚNICO? ---

# Definir o modelo de um fator
cfa_model_1factor <- '
  Fator_Geral =~ Valence + Arousal + Dominance
   Valence ~~ Dominance
'

# Ajustar o modelo
fit_1factor <- cfa(cfa_model_1factor, data = as.data.frame(ratings_scaled),
                   estimator = "wlsmv", ordered = T)

cat("--- RESULTADOS DO MODELO DE 1 FATOR ---\n")
# Avaliar o ajuste. Esperamos que seja ruim.
summary(fit_1factor, fit.measures = TRUE)


# --- HIPÓTESE 2: EXISTEM DOIS FATORES (AVALIAÇÃO E AROUSAL)? ---
# Este modelo é inspirado diretamente nos resultados da sua PCA

# Definir o modelo de dois fatores
cfa_model_2factors <- '
Fator_Geral =~ Valence + Arousal + Dominance

  Avaliacao =~ Valence + Dominance
  Arousal_Factor =~ Arousal
'

# Ajustar o modelo
fit_2factors <- cfa(cfa_model_2factors, data = as.data.frame(ratings_scaled), orthogonal = T,
                    estimator = "wlsmv",)

cat("\n\n--- RESULTADOS DO MODELO DE 2 FATORES ---\n")
# Avaliar o ajuste. Esperamos que seja melhor que o modelo de 1 fator.
summary(fit_2factors, fit.measures = TRUE)








# --- SINTAXE FINAL E COMPLETA ---

library(dplyr)
library(readxl)
library(psych)
library(lme4)
library(lmerTest) # Para p-valores nos modelos mistos
library(ggplot2)
library(performance)


# --- PASSO 1: PREPARAÇÃO COMPLETA E LIMPEZA ---

# Carregar dados
dat4 <- read.csv("~/PIBIT2025/Circumplex/BasesDados/EMO2018-SCR/dat4.csv")
labels <- read_excel("~/PIBIT2025/Circumplex/BasesDados/EMO2018-SCR/arousal-valence-ratings.xlsx") # Renomeei o caminho
self_annotations <- read_excel("~/PIBIT2025/Circumplex/BasesDados/ECG_GSR/Version3/Self-Annotation Labels/Self-annotation_Multimodal.xlsx")

# Preparar os dados de auto-relato para a junção
self_annotations_to_join <- self_annotations %>%
  rename(Participant = `Participant Id`, Event.Nr = `Video ID`) %>%
  mutate(Participant = as.integer(Participant), Event.Nr = as.integer(Event.Nr))

# Juntar os dados fisiológicos (dat4) com os auto-relatos
dat4_com_labels <- dat4 %>%
  mutate(Participant = as.integer(Participant), Event.Nr = as.integer(Event.Nr)) %>%
  inner_join(self_annotations_to_join, by = c("Participant", "Event.Nr"))

# Selecionar as features de GSR e remover NAs
physio_features_names <- c("CDA.nSCR", "CDA.AmpSum", "CDA.SCR", "CDA.ISCR", "CDA.PhasicMax")
data_completa <- dat4_com_labels %>%
select(ParticipantId, EmoId, `Arousal level`, `Valence level`, `Dominance level`,all_of(physio_features_names)) %>%
  na.omit()

dat4_com_labels <- dat4_com_labels %>%
  rename(Arousal.lavel = `Arousal level`)



# --- PASSO 2: EXTRAIR O FATOR DE INTENSIDADE (PC1) ---

# Padronizar apenas as colunas de fisiologia
physio_scaled <- scale(data_completa[, physio_features_names])

# Rodar a PCA
pca_results <- principal(physio_scaled, nfactors = 1, rotate = "none", scores = TRUE)

# Adicionar os escores ao nosso data frame limpo
data_final <- cbind(data_completa, as.data.frame(pca_results$scores))
colnames(data_final)[ncol(data_final)] <- "PC1_Intensity"


# --- PASSO 3: MODELAGEM HIERÁRQUICA (A RESPOSTA PARA SUA PERGUNTA) ---

# Pergunta 1: A Intensidade Fisiológica (PC1) prevê o Arousal SUBJETIVO?
# Usamos um modelo misto para controlar as diferenças entre participantes.
# Fórmula: Arousal ~ PC1_Intensity + (1 | ParticipantId)
# O termo (1 | ParticipantId) diz ao modelo: "espere que cada participante
# tenha seu próprio nível de base de arousal".
model_arousal_lmer <- lmerTest::lmer(`Arousal level` ~ PC1_Intensity + (1 | ParticipantId), data = data_final)
summary(model_arousal_lmer)
r2(model_arousal_lmer)


# Pergunta 2: A Intensidade Fisiológica (PC1) prevê a Valência SUBJETIVA?
model_valence_lmer <- lmerTest::lmer(`Valence level` ~ PC1_Intensity + (1 | ParticipantId), data = data_final)
summary(model_valence_lmer)
r2(model_valence_lmer)


# Pergunta 2.1: A Intensidade Fisiológica (PC1) prevê a Valência SUBJETIVA?
# Testando a relação quadrática (em "U") que havíamos hipotetizado.
#model_valence_lmer <- lmer(`Valence level` ~ PC1_Intensity + I(PC1_Intensity^2) + (1 | ParticipantId), data = data_final)
#summary(model_valence_lmer)

# Pergunta 2.2: A Valência SUBJETIVA prevê a Intensidade Fisiológica (PC1)?
model_interaction <- lmerTest::lmer(PC1_Intensity ~  `Valence level`*`Arousal level` + (1 | ParticipantId), data = data_final)
summary(model_interaction)
r2(model_interaction)

# Pergunta 3: (A mais interessante) A Intensidade Fisiológica (PC1) varia por EMOÇÃO, controlando pelo participante?
model_emo_lmer <- lmerTest::lmer(PC1_Intensity ~ EmoId + (1 | ParticipantId), data = data_final)
anova(model_emo_lmer) # Teste do efeito geral da emoção
emmeans::emmeans(model_emo_lmer, pairwise ~ EmoId) # Comparações par a par


model_interaction <- lm(PC1_Intensity ~  `Valence level`*`Arousal level`, data = data_final)
summary(model_interaction)


library(janitor) # Pacote para limpar nomes

# --- PASSO 1: LIMPAR OS NOMES DAS COLUNAS ---
# Use a função clean_names() no início do seu data frame final
data_final_clean <- data_final %>%
  clean_names()

# Verifique os novos nomes. `Arousal level` virou `arousal_level`, etc.
glimpse(data_final_clean)


# --- PASSO 2: REFAZER OS MODELOS COM OS NOMES LIMPOS ---

# Modelo de Arousal (agora sem backticks)
model_arousal_lmer_clean <- lmerTest::lmer(arousal_level ~ pc1_intensity + (1 | participant_id), data = data_final_clean)

# Modelo de Valência
model_valence_lmer_clean <- lmerTest::lmer(valence_level ~ pc1_intensity + (1 | participant_id), data = data_final_clean)

# Modelo de Interação (o mais importante)
model_interaction_clean <- lmerTest::lmer(pc1_intensity ~ valence_level * arousal_level + (1 | participant_id), data = data_final_clean)


# --- PASSO 3: CALCULAR O R² SEM AVISOS ---

# Agora, a função r2() funcionará perfeitamente.
r2(model_arousal_lmer_clean)
r2(model_valence_lmer_clean)
r2(model_interaction_clean)



####################### MULTIVERSE
library(ggplot2)
library(dplyr)
library(janitor)

# Use o seu dataframe limpo
data_clean <- data_final %>%
  janitor::clean_names()

# Para criar um mapa de calor, precisamos agrupar os dados.
# Vamos criar "bins" (caixas) para valência e arousal.
# Por exemplo, vamos arredondá-los para o inteiro mais próximo.
plot_data <- data_clean %>%
  mutate(
    valence_bin = round(valence_level),
    arousal_bin = round(arousal_level)
  ) %>%
  group_by(valence_bin, arousal_bin) %>%
  summarise(
    mean_intensity = mean(pc1_intensity),
    .groups = 'drop' # Importante para evitar problemas futuros
  )

# Agora, crie o gráfico
ggplot(plot_data, aes(x = valence_bin, y = arousal_bin, fill = mean_intensity)) +
  geom_tile(color = "white") + # Adiciona uma borda branca às células
  scale_fill_viridis_c(option = "C") + # Uma boa paleta de cores
  labs(
    x = "Nível de Valência (Subjetivo)",
    y = "Nível de Arousal (Subjetivo)",
    fill = "Intensidade\nFisiológica (PC1)",
    title = "Superfície de Resposta da Intensidade Fisiológica",
    subtitle = "Interação entre Valência e Arousal"
  ) +
  theme_minimal() +
  coord_equal() # Garante que os quadrados sejam realmente quadrados


library(rpart)
library(rpart.plot)

# A fórmula é simples: prever a intensidade com base na valência e arousal.
tree_model <- rpart(
  pc1_intensity ~ valence_level + arousal_level,
  data = data_clean,
  method = "anova" # "anova" é para uma variável de resposta contínua
)
summary(tree_model)

# Plotar a árvore de forma bonita
rpart.plot(
  tree_model,
  type = 3, # Tipo de plotagem
  extra = 101, # Mostra as porcentagens e contagens
  box.palette = "BuGn", # Paleta de cores
  branch.lty = 3,
  shadow.col = "gray",
  main = "Árvore de Regressão para a Intensidade Fisiológica"
)








library(caret)
library(randomForest)
library(ipred)
library(tidyverse)
library(janitor)

# 2. Preparar os Dados
data_clean <- data_final %>%
  janitor::clean_names() %>%
  # Selecionar apenas as colunas necessárias para a modelagem
  select(pc1_intensity, valence_level, arousal_level) %>%
  na.omit() # Garantir que não há NAs


# 3. Configurar a Validação Cruzada
# Usaremos 10-fold cross-validation, repetida 5 vezes para mais estabilidade
train_control <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 5
)


# 4. Treinar os Modelos com 'caret'
set.seed(123) # Para replicabilidade

# Modelo 1: Regressão Linear (com interação)
model_lm <- train(
  pc1_intensity ~ valence_level * arousal_level,
  data = data_clean,
  method = "lm",
  trControl = train_control
)

# Modelo 2: Árvore de Regressão Única
model_rpart <- train(
  pc1_intensity ~ valence_level + arousal_level,
  data = data_clean,
  method = "rpart",
  trControl = train_control
)

# Modelo 3: Bagging
model_bag <- train(
  pc1_intensity ~ valence_level + arousal_level,
  data = data_clean,
  method = "treebag", # Este é o método de bagging do caret
  trControl = train_control
)

# Modelo 4: Random Forest
model_rf <- train(
  pc1_intensity ~ valence_level + arousal_level,
  data = data_clean,
  method = "rf",
  trControl = train_control
)


# 5. Comparar os Resultados dos Modelos
# A função resamples() do caret é perfeita para isso

results <- resamples(list(
  LM = model_lm,
  Tree = model_rpart,
  Bagging = model_bag,
  RF = model_rf
))

# Ver um resumo estatístico das métricas (Rsquared e RMSE)
summary(results)

# Plotar os resultados para uma comparação visual clara
bwplot(results, metric = "Rsquared", main = "Comparação de R² entre Modelos (Validação Cruzada)")
bwplot(results, metric = "RMSE", main = "Comparação de RMSE entre Modelos (Validação Cruzada)")






### GRáficos

# Slope plot
library(ggplot2)
library(ggeffects)

# Calcule os efeitos previstos
pred_effects <- ggpredict(model_interaction_clean, terms = c("valence_level", "arousal_level"))

# Crie o gráfico
ggplot(pred_effects, aes(x = x, y = predicted, colour = group)) +
  geom_line(size = 1.2) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill = group), alpha = 0.2) +
  labs(
    title = "Interação entre Valência e Excitação na Previsão da Intensidade da Resposta",
    x = "Nível de Valência",
    y = "Intensidade Prevista (PC1)",
    colour = "Nível de Excitação",
    fill = "Nível de Excitação"
  ) +
  theme_minimal(base_size = 15) +
  scale_color_viridis_d() + # Paleta de cores amigável para daltônicos
  scale_fill_viridis_d()



# Usando o mesmo objeto 'pred_effects' do exemplo anterior
plot_data <- data_clean %>%
  mutate(
    valence_bin = round(valence_level),
    arousal_bin = round(arousal_level)
  ) %>%
  group_by(valence_bin, arousal_bin) %>%
  summarise(
    mean_intensity = mean(pc1_intensity),
    .groups = 'drop'
  )

# Agora, o gráfico com a escala de cores corrigida
ggplot(plot_data, aes(x = valence_bin, y = arousal_bin, fill = mean_intensity)) +
  geom_tile(color = "white") +
  
  # --- ESTA É A LINHA CORRIGIDA ---
  scale_fill_gradient2(
    midpoint = 0, 
    low = "blue", 
    mid = "white",
    high = "red",
    name = "Intensidade\nFisiológica (PC1)" # O nome da legenda vai aqui
  ) +
  # ---------------------------------

labs(
  x = "Nível de Valência (Subjetivo)",
  y = "Nível de Arousal (Subjetivo)",
  # 'fill' já foi definido dentro da escala
  title = "Superfície de Resposta da Intensidade Fisiológica",
  subtitle = "Interação entre Valência e Arousal"
) +
  theme_minimal() +
  coord_equal()

# Forest plot
library(dotwhisker)

dwplot(model_interaction_clean, dot_args = list(size = 3),
       whisker_args = list(size = 1)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey") +
  labs(
    title = "",
    x = "Valor do Coeficiente (Estimativa)",
    y = "Preditores"
  ) +
  theme_classic(base_size = 15)




# Instale o pacote se ainda não o tiver
# install.packages("broom.mixed")

library(lmerTest) # Seu modelo foi criado com este
library(dotwhisker)
library(dplyr)
library(broom.mixed) # <-- A SOLUÇÃO! Carregue este pacote.

# Agora o seu código original irá funcionar sem erros
model_tidy <- tidy(model_interaction_clean) %>%
  mutate(term = recode(term,
                       "valence_level" = "Valence",
                       "arousal_level" = "Arousal",
                       "valence_level:arousal_level" = "Valence x Arousal (Interaction)",
                       "(Intercept)" = "Intercept",
                       "sd__(Intercept)" = "SD (Intercept per Participant)",
                       "sd__Observation" = "SD (Residual)"))

# O código do gráfico continua o mesmo e agora funcionará
dwplot(model_tidy,
       dot_args = list(size = 3),
       whisker_args = list(size = 1)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  coord_cartesian(xlim = c(-0.5, 0.5)) +
  labs(
    title = "",
    subtitle = "",
    x = "Coeficient (Estimate)",
    y = ""
  ) +
  theme_bw(base_size = 16) +
  theme(
    legend.position = "none",
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 14)
  )



# 1. Carregar Pacotes
# install.packages("interactions")
# install.packages("jtools") # Para complementar o interactions

library(interactions)
library(jtools)
library(ggplot2)

# 2. Re-ajustar seu modelo lmer (usando os nomes de coluna limpos)
# Supondo que você já tem o 'data_clean'
model_interaction_lmer <- lmerTest::lmer(
  pc1_intensity ~ valence_level * arousal_level + (1 | participant_id),
  data = data_final_clean
)

# 3. Criar o gráfico de interação
# A função interact_plot() é a principal aqui.
# pred = preditor no eixo X
# modx = moderador (a variável cujos níveis serão plotados como linhas diferentes)
interact_plot(
  model = model_interaction_lmer,
  pred = valence_level,
  modx = arousal_level,
  plot.points = TRUE, # Mostra os pontos de dados originais
  point.alpha = 0.5,
  point.size = 2,
  line.thickness = 1.5,
  colors = "viridis" # Usa uma paleta de cores bonita
) +
  labs(
    x = "Nível de Valência (Subjetivo)",
    y = "Intensidade Fisiológica (PC1)",
    title = "Interação entre Valência e Arousal na Predição da Intensidade Fisiológica",
    subtitle = "Relação para Níveis Baixo, Médio e Alto de Arousal",
    color = "Nível de Arousal"
  ) +
  theme_minimal()







library(lavaan)

# Definir o modelo usando a sintaxe de lavaan
multilevel_sem_model <- '
  level: 1  # Modelo Within-Participant
    # Modelo de Mensuração: Definir o fator latente de Intensidade
    intensidade_w =~ cda_amp_sum + cda_scr + cda_iscr + cda_phasic_max + cda_n_scr

    # Modelo Estrutural: Prever a intensidade a partir do afeto
    intensidade_w ~ arousal_level + valence_level 
    
    # Para testar a interação, você precisaria criar a variável antes
    # intensidade_w ~ arousal_level + valence_level + arousal_X_valence

  level: 2  # Modelo Between-Participant
    # Modelo de Mensuração: O fator também existe entre as pessoas
    intensidade_b =~ cda_amp_sum + cda_scr + cda_iscr + cda_phasic_max + cda_n_scr

    # Opcional: Modelar relações entre as médias das pessoas
    intensidade_b ~ arousal_level + valence_level
'

# Ajustar o modelo
# 'cluster = "ParticipantId"' informa ao lavaan qual é a variável de agrupamento
fit_multilevel_sem <- sem(
  model = multilevel_sem_model,
  data = data_final_clean, # Seu data frame com os dados
  cluster = "participant_id",
  estimator = "MLR" # Estimador robusto para dados não normais
)

# Ver os resultados
summary(fit_multilevel_sem, fit.measures = TRUE, standardized = TRUE)
varTable(fit_multilevel_sem)




# Modelo mais simples, focando apenas nas relações do Nível 1
simple_multilevel_model <- '
  level: 1
    intensidade_w =~ cda_amp_sum + cda_scr + cda_iscr + cda_phasic_max + cda_n_scr
    intensidade_w ~ arousal_level + valence_level

  level: 2
    intensidade_b =~ cda_amp_sum + cda_scr + cda_iscr + cda_phasic_max + cda_n_scr
'

fit_simple <- sem(
  model = simple_multilevel_model,
  data = data_final_clean,
  cluster = "participant_id",
  estimator = "MLR"
)

summary(fit_simple, fit.measures = TRUE, standardized = TRUE)
varTable(fit_simple)
