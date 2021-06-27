# Bibliotecas
require(readxl)
require(data.table)
require(xts)
require(dplyr)
require(scales)
require(ggplot2)
require(RColorBrewer)
require(textclean)

### Força a versão por causa do get object
require(devtools)
install_version("aws.s3", version = "0.3.12")

## Puxa a aws.s3
library("aws.s3")
library("readr")
install.packages("xlsx")
library("xlsx")

destCOS = "s3://mvpfundsize-donotdelete-pr-8nsdgny9fj7grs/"
bucketCOS = "mvpfundsize-donotdelete-pr-8nsdgny9fj7grs"

# Estrutra de Diretórios
SR = "~/MVP/"
SCodes= paste0(SR,"Codes/")
SCodesAuditAux = paste0(SCodes,"Auditoria/Auxiliares/")

SData  = paste0(SR,"Data/");dir.create(SData, showWarnings = FALSE)
SDataEAD = paste0(SData,"EAD/");dir.create(SDataEAD, showWarnings = FALSE)
SDataOut= paste0(SR,"DataOut/");dir.create(SDataOut, showWarnings = FALSE)
SDataOutMod = paste0(SDataOut,"MODELO/");dir.create(SDataOutMod, showWarnings = FALSE)
SDataOutEAD = paste0(SDataOut,"EAD/");dir.create(SDataOutEAD, showWarnings = FALSE)
SAux = paste0(SR,"Auxiliar/");dir.create(SAux, showWarnings = FALSE)
SAuxMod= paste0(SAux,"MODELO/");dir.create(SAuxMod, showWarnings = FALSE)
SAuxFIN = paste0(SAux,"FINANCEIRO/");dir.create(SAuxFIN, showWarnings = FALSE)
SMod = paste0(SR,"Modelos/");dir.create(SMod, showWarnings = FALSE)
SModIBBA = paste0(SMod,"IBBA/");dir.create(SModIBBA, showWarnings = FALSE)
SModIBBAAnalise = paste0(SModIBBA,"Analise/");dir.create(SModIBBAAnalise, showWarnings = FALSE)

# source para os demais códigos 
source(paste0(SCodesAuditAux,"vA_MontaEAD_NCenso.R"))
source(paste0(SCodesAuditAux,"vA_MontaBaseBalancete.R"))
source(paste0(SCodesAuditAux,"vA_Outputs.R"))


### Configuração das credenciais do object storage (COS)
Sys.setenv("AWS_S3_ENDPOINT" = "s3.us.cloud-object-storage.appdomain.cloud",
           "AWS_ACCESS_KEY_ID" = "aa1f87ecb5d24147b8c93b09d0107ef4",
           "AWS_SECRET_ACCESS_KEY" = "53d327883fdbc38a939cb7efb5cd98470cc12de4675a2af0")

### Lê arquivo do COS
tmp <- tempfile(fileext = ".xls")
r <- aws.s3::save_object(bucket = "mvpfundsize-donotdelete-pr-8nsdgny9fj7grs", object = "201611CONGLOMERADOS.xls", file = tmp)
df_xls <- read.xlsx(file = tmp, sheetIndex = 1)

##df <- read.csv(text = rawToChar(obj)) Transforma o objeto em base de dados

############################# lilian_modif ############################ 
#library("stringi")
#require(devtools)
#install_version("aws.s3", version = "0.3.12")
#
### Puxa a aws.s3
#library("aws.s3")
#
#Sys.setenv("AWS_S3_ENDPOINT" = "s3.us.cloud-object-storage.appdomain.cloud",
#           "AWS_ACCESS_KEY_ID" = "aa1f87ecb5d24147b8c93b09d0107ef4",
#           "AWS_SECRET_ACCESS_KEY" = "53d327883fdbc38a939cb7efb5cd98470cc12de4675a2af0")
#
#list_directory <- list(SDataEAD)
#
#for (dir in list_directory){
#  for (i in list.files(dir)){
#    dest = paste0("s3://mvpfundsize-donotdelete-pr-8nsdgny9fj7grs/", stri_sub(dir, 3, nchar(dir)), i)
#    file = paste0(dir,i)
#    put_object(dest, file = file, bucket = "mvpfundsize-donotdelete-pr-8nsdgny9fj7grs", region="")
#    print(file) ###coloca o arquivo no cos
#    unlink(file) ###remove os arquivos do rstudio    
#  }
#}
