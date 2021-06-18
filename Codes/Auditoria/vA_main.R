# Bibliotecas
require(data.table)
require(xts)
require(dplyr)
require(scales)
require(ggplot2)
require(RColorBrewer)
require(textclean)

# Estrutra de Diretórios
# Alterar SR para o nfs  Usando storage do Watson (vai continuar com 2 storages?) colocando as chaves de conexão
SR = "U:/R_IBM/"
  SData  = paste0(SR,"Data/")
    SDataEAD = paste0(SData,"EAD/")
  SDataOut= paste0(SR,"DataOut/")
    SDataOutMod = paste0(SDataOut,"MODELO/")
    SDataOutEAD = paste0(SDataOut,"EAD/")
  SAux = paste0(SR,"Auxiliar/")
    SAuxMod= paste0(SAux,"MODELO/")
    SAuxFIN = paste0(SAux,"FINANCEIRO\\")
  SModIBBAAnalise = paste0(SR,"Modelos/IBBA/Analise/")
  SCodes= paste0(SR,"Codes/")
    SCodesAuditAux = paste0(SCodes,"Auditoria\\Auxiliares\\")

# source para os demais códigos 
# mostrar um exemplo de como realizar a conexão no git hub
# Colocar exemplos de como fazemos a alteração    
source(paste0(SCodesAuditAux,"vA_MontaEAD_NCenso.R"))
source(paste0(SCodesAuditAux,"vA_MontaBaseBalancete.R"))
source(paste0(SCodesAuditAux,"vA_Outputs.R"))
    