# Bibliotecas
require(textclean)
require(odbc)
require(DBI)

# Conexão com o Oracle
# Chaves da conexão 
# Códigos necessários para a visualização da base no RStudio

con <- dbConnect(odbc::odbc(), .connection_string = "Driver={Oracle in instantclient_19_6};Dbq=//192.168.10.13:1521/PDB1;Uid=LUCAS.PIRES;Pwd=Fundo@2020",encoding="UTF-8")
risco <- data.table(dbGetQuery(con,paste0("select * from fgcdatamart.TB_DEP_ELEG_RISCO")))
dbDisconnect(con)

setorder(risco,DT_COMP_FECHAMENTO)
EAD = risco[,.(DATA=DT_COMP_FECHAMENTO,CNPJ=CD_CNPJ_LIDER,ELEG=VL_ELEGIVEIS,EAD_TOTAL=VL_EAD_TOTAL,EAD_ORD=VL_EAD_ORDINARIA,EAD_COR=VL_EAD_CORRETORA,EAD_DPGE=VL_EAD_DPGE)]
ncols = c("EAD_ORD", "EAD_COR", "EAD_DPGE", "EAD_TOTAL","ELEG")
EAD[,(ncols):=lapply(.SD,function(x) ifelse(is.na(x),0,x)),.SDcols = ncols]
EAD[,DATA:=as.yearmon(as.Date(paste0(DATA,"01"),format="%Y%m%d"))]
setkey(EAD,CNPJ,DATA)
arqto   = paste0(SDataEAD,"ElegÍveisBI - ",Sys.Date(),".csv")
print(paste("Realizando cópia da extração SQL do BI para:",arqto))
dataMaxElegiveis = max(EAD$DATA)

# Salvar csv's
# Salvar o csv dentro do storage do Watson (vai continuar com 2 storages?) colocar o código e as chaves da conexão
write.csv2(EAD,arqto,row.names = FALSE)
write.csv2(EAD,paste0(SDataEAD,"ElegÍveisBI.csv"),row.names = FALSE)
