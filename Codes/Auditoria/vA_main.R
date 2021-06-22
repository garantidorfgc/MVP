# Bibliotecas
require(data.table)
require(xts)
require(dplyr)
require(scales)
require(ggplot2)
require(RColorBrewer)
require(textclean)

# Estrutra de Diret?rios
# Alterar SR para o nfs  Usando storage do Watson (vai continuar com 2 storages?) colocando as chaves de conex?o
SR = "~/MVP/"
SData  = paste0(SR,"Data/");dir.create(SData, showWarnings = FALSE)
SDataEAD = paste0(SData,"EAD/");dir.create(SDataEAD, showWarnings = FALSE)
SDataOut= paste0(SR,"DataOut/");dir.create(SDataOut, showWarnings = FALSE)
SDataOutMod = paste0(SDataOut,"MODELO/");dir.create(SDataOutMod, showWarnings = FALSE)
SDataOutEAD = paste0(SDataOut,"EAD/");dir.create(SDataOutEAD, showWarnings = FALSE)
SAux = paste0(SR,"Auxiliar/");dir.create(SAux, showWarnings = FALSE)
SAuxMod= paste0(SAux,"MODELO/");dir.create(SAuxMod, showWarnings = FALSE)
# SAuxFIN = paste0(SAux,"FINANCEIRO\\")
SAuxFIN = paste0(SAux,"FINANCEIRO/");dir.create(SAuxFIN, showWarnings = FALSE)
SMod = paste0(SR,"Modelos/");dir.create(SMod, showWarnings = FALSE)
SModIBBA = paste0(SMod,"IBBA/");dir.create(SModIBBA, showWarnings = FALSE)
SModIBBAAnalise = paste0(SModIBBA,"Analise/");dir.create(SModIBBAAnalise, showWarnings = FALSE)
SCodes= paste0(SR,"Codes/")
SCodesAuditAux = paste0(SCodes,"Auditoria/Auxiliares/")


# source para os demais c?digos 
# mostrar um exemplo de como realizar a conex?o no git hub
# Colocar exemplos de como fazemos a altera??o    
source(paste0(SCodesAuditAux,"vA_MontaEAD_NCenso.R"))
source(paste0(SCodesAuditAux,"vA_MontaBaseBalancete.R"))
source(paste0(SCodesAuditAux,"vA_Outputs.R"))
    