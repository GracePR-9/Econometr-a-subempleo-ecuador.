# ==============================================================================
# TRABAJO PRÁCTICO EXPERIMENTAL 4 - ECONOMETRÍA APLICADA
# TEMA: DETERMINANTES DEL SUBEMPLEO EN ECUADOR (MODELO LOGIT - SPSS)
# ==============================================================================

# ------------------------------------------------------------------------------
# PUNTO 0: INSTALACIÓN Y CARGA DE PAQUETES (Control de Errores)
# ------------------------------------------------------------------------------
if(!require(haven)) install.packages("haven")
if(!require(tidyverse)) install.packages("tidyverse")
if(!require(car)) install.packages("car")
if(!require(lmtest)) install.packages("lmtest")
if(!require(pscl)) install.packages("pscl")
if(!require(caret)) install.packages("caret", dependencies = TRUE)
if(!require(pROC)) install.packages("pROC")
if(!require(mfx)) install.packages("mfx")

library(haven)       
library(tidyverse)   
library(car)         
library(lmtest)     
library(pscl)       
library(caret)      
library(pROC)       
library(mfx)        

# ------------------------------------------------------------------------------
# PUNTO 1: CARGA DE DATOS Y LIMPIEZA DE LA MUESTRA
# ------------------------------------------------------------------------------
base_persona <- read_sav("C:/Users/GRACE/OneDrive/Escritorio/ECONOMETRIA APLICADA/1_BDD_ENEMDU_2026_I_TRIMESTRE_SPSS/enemdu_persona_2026_l_trimestre.sav")

datos_limpios <- base_persona %>%
  zap_labels() %>% 
  filter(as.numeric(periodo) == 202603) %>% 
  filter(as.numeric(condact) >= 1 & as.numeric(condact) <= 4) %>% 
  mutate(
    subempleo         = ifelse(as.numeric(condact) == 2, 1, 0),
    anios_escolaridad = as.numeric(nnivins), 
    edad              = as.numeric(p03),     
    sexo              = ifelse(as.numeric(p02) == 2, 1, 0), 
    area              = ifelse(as.numeric(area) == 1, 1, 0) 
  ) %>%
  drop_na(subempleo, anios_escolaridad, edad, sexo, area)

# ------------------------------------------------------------------------------
# PUNTO 2: ESTADÍSTICA DESCRIPTIVA (Corregido con dplyr::select)
# ------------------------------------------------------------------------------
print("--- PUNTO 2: ESTADÍSTICA DESCRIPTIVA ---")
summary(datos_limpios %>% dplyr::select(subempleo, anios_escolaridad, edad, sexo, area))

# ------------------------------------------------------------------------------
# PUNTO 3: ESTIMACIÓN DEL MODELO LOGIT
# ------------------------------------------------------------------------------
modelo_logit <- glm(subempleo ~ anios_escolaridad + edad + sexo + area, 
                    data = datos_limpios, family = binomial(link = "logit"))

print("--- PUNTO 3: ESTIMACIÓN DEL MODELO LOGIT ---")
summary(modelo_logit)

# ------------------------------------------------------------------------------
# PUNTO 4: PRUEBAS DE VALIDACIÓN Y SUPUESTOS
# ------------------------------------------------------------------------------

# A. Multicolinealidad (VIF)
print("--- 4.A. EVALUACIÓN DE MULTICOLINEALIDAD (VIF) ---")
vif_auxiliar <- lm(subempleo ~ anios_escolaridad + edad + sexo + area, data = datos_limpios)
vif(vif_auxiliar)

# B. Test de Significancia Global (LR Test)
print("--- 4.B. TEST DE RAZÓN DE VEROSIMILITUD (LR TEST) ---")
modelo_nulo <- glm(subempleo ~ 1, data = datos_limpios, family = binomial(link = "logit"))
lrtest(modelo_nulo, modelo_logit)

# C. Bondad de Ajuste (Pseudo R-cuadrado de McFadden)
print("--- 4.C. PSEUDO R-CUADRADO DE MCFADDEN ---")
pR2(modelo_logit)["McFadden"]

# D. Capacidad Predictiva (Matriz de Confusión)
print("--- 4.D. MATRIZ DE CONFUSIÓN Y MÉTRICAS DE CLASIFICACIÓN ---")
predicciones_prob <- predict(modelo_logit, type = "response")
predicciones_clase <- ifelse(predicciones_prob > 0.5, 1, 0)

matriz_confusion <- confusionMatrix(as.factor(predicciones_clase), 
                                    as.factor(datos_limpios$subempleo), 
                                    positive = "1")
print(matriz_confusion)

# E. Capacidad Discriminante (Curva ROC y AUC)
print("--- 4.E. CÁLCULO DEL ÁREA BAJO LA CURVA (AUC) ---")
curva_roc <- roc(datos_limpios$subempleo, predicciones_prob)
print(auc(curva_roc))

# Gráfico CURVA ROC
plot(curva_roc, col = "#2980b9", main = "Curva ROC - Modelo Subempleo (ENEMDU 2026)",
     xlab = "Especificidad (1 - Falsos Positivos)", ylab = "Sensibilidad (Verdaderos Positivos)", lwd = 3)
grid()

# ------------------------------------------------------------------------------
# PUNTO 5: CÁLCULO DE EFECTOS MARGINALES
# ------------------------------------------------------------------------------
print("--- PUNTO 5: EFECTOS MARGINALES EN EL PROMEDIO (MEMs) ---")
logitmfx(subempleo ~ anios_escolaridad + edad + sexo + area, data = datos_limpios, atmean = TRUE)

# ------------------------------------------------------------------------------
# PUNTO 6: TABLA OPCIONAL DE REFUERZO (Formato APA en Viewer y Exportación)
# ------------------------------------------------------------------------------
# 1. Asegurar la instalación y carga de flextable
if(!require(flextable)) install.packages("flextable")
library(flextable)

# 2. Extraer los coeficientes del modelo logit a un data.frame limpio
summary_logit <- as.data.frame(summary(modelo_logit)$coefficients)

tabla_datos_logit <- data.frame(
  Variable = c("Intercepto", "Años de Escolaridad", "Edad", "Sexo (Mujer)", "Área (Urbana)"),
  Estimacion = round(summary_logit$Estimate, 4),
  Error_Std  = round(summary_logit$`Std. Error`, 4),
  Z_Value    = round(summary_logit$`z value`, 4),
  P_Value    = round(summary_logit$`Pr(>|z|)`, 4)
)

# 3. Construir la tabla con formato APA en flextable
tabla_apa <- flextable(tabla_datos_logit) %>%
  # Cambiar las etiquetas de los encabezados
  set_header_labels(
    Variable   = "Variable",
    Estimacion = "Coeficiente (β)",
    Error_Std  = "Error Estándar",
    Z_Value    = "Estadístico z",
    P_Value    = "p-valor"
  ) %>%
  # Aplicar el tema APA clásico (líneas horizontales reglamentarias)
  theme_apa() %>%
  # Alinear el texto al centro (excepto la primera columna)
  align(align = "center", part = "header") %>%
  align(j = 2:5, align = "center", part = "body") %>%
  # Ajustar el ancho de las celdas automáticamente
  autofit()

# 4. Mostrar de inmediato en la pestaña Viewer con fondo blanco nativo
tabla_apa

# 5. Exportarla directamente a Word con formato APA listo para el informe
save_as_docx(tabla_apa, path = "tabla_logit_enemdu_apa.docx")