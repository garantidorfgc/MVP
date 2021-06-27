# Bibliotecas
require(textclean)
#require(odbc)
require(DBI)

library(RJDBC) ### sempre usar essa biblioteca para conectar no db2

# Chaves da conexao 
drv <- JDBC(driverClass="com.ibm.db2.jcc.DB2Driver", classPath="/opt/ibm/dsdriver/java/db2jcc4.jar")

### URl da conexão
Db2_FGC_url <- paste("jdbc:db2://",
                     "db2w-yarheby.us-south.db2w.cloud.ibm.com",
                     ":", "50001",
                     "/", "BLUDB", ":sslConnection=true;retrieveMessagesFromServerOnGetMessage=true;globalSessionVariables=SQL_COMPAT=NPS;",
                     sep=""
)

### Usuário e senha da conexão
Db2_FGC_connection <- dbConnect(drv,
                                Db2_FGC_url,
                                "bluadmin",
                                "pE9bnZ5bzYDo0qrh6yX4_ZZ9_RQT7"
)

query <- "SELECT * FROM FGCDATAMART.TB_DEP_ELEG_RISCO"
# Pega a conexão com o banco e faz a query definida acima
data <- dbSendQuery(Db2_FGC_connection, query) 
# Transforma o dado raw em dataframe
risco <- dbFetch(data)
risco <- data.table(risco)

setorder(risco,DT_COMP_FECHAMENTO)
EAD = risco[,.(DATA=DT_COMP_FECHAMENTO,CNPJ=CD_CNPJ_LIDER,ELEG=VL_ELEGIVEIS,EAD_TOTAL=VL_EAD_TOTAL,EAD_ORD=VL_EAD_ORDINARIA,EAD_COR=VL_EAD_CORRETORA,EAD_DPGE=VL_EAD_DPGE)]
ncols = c("EAD_ORD", "EAD_COR", "EAD_DPGE", "EAD_TOTAL","ELEG")
EAD[,(ncols):=lapply(.SD,function(x) ifelse(is.na(x),0,x)),.SDcols = ncols]
EAD[,DATA:=as.yearmon(as.Date(paste0(DATA,"01"),format="%Y%m%d"))]
setkey(EAD,CNPJ,DATA)
arqto   = paste0(SDataEAD,"ElegiveisBI - ",Sys.Date(),".csv")
print(paste("Realizando c?pia da extra??o SQL do BI para:",arqto))
dataMaxElegiveis = max(EAD$DATA)

# Salvar csv's
# Salvar o csv dentro do storage do Watson (vai continuar com 2 storages?) colocar o c?digo e as chaves da conex?o                     
write.csv2(EAD,arqto,row.names = FALSE)
write.csv2(EAD,paste0(SDataEAD,"ElegiveisBI.csv"),row.names = FALSE)
put_object(paste0(destCOS,SDataEAD,"ElegiveisBI - ",Sys.Date(),".csv"), file = paste0(SDataEAD,"ElegiveisBI - ",Sys.Date(),".csv"), bucket = bucketCOS, region = "")
put_object(paste0(destCOS,SDataEAD,"ElegiveisBI.csv"), file = paste0(SDataEAD,"ElegiveisBI.csv"), bucket = bucketCOS, region = "")                                   
