# Credenciais do nfs comum

Sys.setenv("AWS_S3_ENDPOINT" = "s3.us-south.cloud-object-storage.appdomain.cloud",
           "AWS_ACCESS_KEY_ID" = "55a53226f77a454ab5ebe08256fd89ad",
           "AWS_SECRET_ACCESS_KEY" = "88109a953cba3d743b33d2c1a588c34b7cb8b74ae72df667")


# Alterar SR para o nfs  Usando storage do Watson (vai continuar com 2 storages?) colocando as chaves de conex?o
SBal       = paste0(SData,"BALANCETE/");dir.create(SBal, showWarnings = FALSE)
SBalzip    = paste0(SData,"BAL_ZIP/");dir.create(SBalzip, showWarnings = FALSE)
SBal2      = paste0(SData,"BALANCETE");dir.create(SBal2, showWarnings = FALSE)


dtini = "2021-03-01"
vdata  = seq.Date(from = as.Date(dtini),to = Sys.Date(),by = "month")
vdata = substr(gsub("-","",vdata),1,6)
vtipo = c("sociedades","bancos","conglomerados","prudencial")
maxData = c(0,0,0,0)

# Baixar arquivos do 
#Mostrar uma conex?o com a URL
for(t in seq(vtipo)){
  for(i in seq(vdata)){
    itipo = vtipo[t]
    idata = vdata[i]
    iarq  = paste0(idata,toupper(itipo),".zip")
    iarq2 = paste0(idata,"BLO",toupper(itipo),".zip")
    
    iroot = paste0("http://www4.bcb.gov.br/fis/cosif/cont/balan/",itipo,"/")
    iurl = paste0(iroot,iarq)
    iurl2= paste0(iroot,iarq2)
    idestfile  = paste0(SBalzip,iarq)
    
    aux = try(download.file(url = iurl,destfile = idestfile),silent = TRUE)
    if(class(aux)=="try-error"){
      try({download.file(url = iurl2,destfile = idestfile)
        maxData[t] = max(maxData[t],as.integer( vdata[i]))},silent = TRUE)
    }else{
      maxData[t] = max(maxData[t],as.integer( vdata[i]))
    }
  }
}

# Unzip dos arquivos
zf = c(list.files(SBalzip,pattern = c("zip")),list.files(SBalzip,pattern = c("ZIP")))
for (izf in zf){
  unzip(paste0(SBalzip,izf),exdir = SBal2,overwrite = TRUE)
}
ano = 2000:year(Sys.Date())
vData = c(paste0(ano,"03"),paste0(ano,"06"),paste0(ano,"09"),paste0(ano,"12"),
paste0(ano,"01"),paste0(ano,"02"),paste0(ano,"04"),paste0(ano,"05"),paste0(ano,"07"),paste0(ano,"08"),paste0(ano,"10"),paste0(ano,"11"));
vData=sort(unique(vData))
tipo = c("BANCOS","CONGLOMERADOS","SOCIEDADES")

# Leitura dos arquivos
nomeBANCOS = c("DATA","DOCUMENTO","CNPJ","AGENCIA","NOME_INSTITUICAO","COD_CONGL",
"NOME_CONGL","TAXONOMIA","CONTA","NOME_CONTA","SALDO","ATE3M","APOS3M")
DB = NULL
for (ivData in vData){
  print(ivData)
  fileToRead = paste0(SBal,ivData,"BANCOS.CSV")
  if(!file.exists(fileToRead)){next}
  iDB = fread(fileToRead,dec=",")

  if(ivData<=201009){
    names(iDB) = c("DT","CNPJ","NINST","A","DOC","C","NCONTA","SALDO")
    iDB = iDB[,.(DT,DOC,CNPJ,AGENCIA=NA,NINST,COD_CONGL = NA,NOME_CONGL=NA,
    A,C,NCONTA,SALDO,ATE3M=NA,APOS3M=NA)]
  }else if(dim(iDB)[2]<=11){
   iDB[,(c("ATE3M","APOS3M")):= NA]
  }
  names(iDB) = nomeBANCOS
  DB = rbindlist(list(DB,iDB),fill = TRUE)
}
DB[,':='(CONTA=paste0("X",CONTA))]
DBBANCOS = DB
if(class(DBBANCOS[,SALDO])!="numeric"){DBBANCOS[,SALDO:=as.numeric(gsub(",",".",SALDO))]}
WDBBANCOS = dcast(DBBANCOS, DATA + DOCUMENTO + CNPJ + NOME_INSTITUICAO ~ CONTA, value.var = "SALDO")
nomeVarNA = names(WDBBANCOS)[substr(names(WDBBANCOS),1,1)%in%c("X")]
WDBBANCOS[,(nomeVarNA):=lapply(.SD,function(x) ifelse(is.na(x),0,x)), .SDcols = nomeVarNA ]

nomeCONGL = c("DATA","DOCUMENTO","CNPJ","AGENCIA","NOME_INSTITUICAO","COD_CONGL",
"NOME_CONGL","TAXONOMIA","CONTA","NOME_CONTA","SALDO")
DB = NULL
for (ivData in vData){
  print(ivData)
  fileToRead = paste0(SBal,ivData,"CONGLOMERADOS.CSV")
  if(!file.exists(fileToRead)){next}
  iDB = fread(fileToRead,dec=",")
  if(ivData<=201009&ivData>=200705){
    names(iDB) = c("DT","COD_CONGL","NOME_CONGL","A","DOC","C","NCONTA","SALDO")
    iDB = iDB[,.(DT,DOC,CNPJ = NA,AGENCIA=NA,NINST = NA,COD_CONGL,NOME_CONGL,
    A,C,NCONTA,SALDO)]
  }
  names(iDB) = nomeCONGL
  DB = rbind(DB,iDB)
}
DB[,':='(CONTA=paste0("X",CONTA))]
DB[,("COD_CONGL") := lapply(.SD, function(x) ifelse(nchar(x)==5,paste0("C00",x),x) ),.SDcols = "COD_CONGL"]
DB[,SALDO := as.numeric(gsub(",",".",SALDO))]
DBCONGL = DB
WDBCONGL = dcast(DBCONGL, DATA + DOCUMENTO + CNPJ + NOME_INSTITUICAO + COD_CONGL + NOME_CONGL ~ CONTA, value.var = "SALDO")
nomeVarNA = names(WDBCONGL)[substr(names(WDBCONGL),1,1)%in%c("X")]
WDBCONGL[,(nomeVarNA):=lapply(.SD,function(x) ifelse(is.na(x),0,x)), .SDcols = nomeVarNA ]

nomeCONGL = c("DATA","DOCUMENTO","CNPJ","AGENCIA","NOME_INSTITUICAO","COD_CONGL",
              "NOME_CONGL","TAXONOMIA","CONTA","NOME_CONTA","SALDO")
lf = list.files(SBal,pattern = ".CSV")
lfAdj = sort(lf[c(grep("PRUDENCIAL",lf))])
DB = NULL
for (ifile in lfAdj){
  print(ifile)
  fileToRead  = paste0(SBal,ifile)
  iDB = fread(fileToRead,dec=",")
  names(iDB) = nomeCONGL
  DB = rbind(DB,iDB)
}
DB[,':='(CONTA=paste0("X",CONTA))]
DB[,("COD_CONGL") := lapply(.SD, function(x) ifelse(nchar(x)==5,paste0("C00",x),x) ),.SDcols = "COD_CONGL"]
DB[,SALDO := as.numeric(gsub(",",".",SALDO))]
DBPRUD = DB
WDBPRUD = dcast(DBPRUD, DATA + DOCUMENTO + CNPJ + NOME_INSTITUICAO + COD_CONGL + NOME_CONGL ~ CONTA, value.var = "SALDO")
nomeVarNA = names(WDBPRUD)[substr(names(WDBPRUD),1,1)%in%c("X")]
WDBPRUD[,(nomeVarNA):=lapply(.SD,function(x) ifelse(is.na(x),0,x)), .SDcols = nomeVarNA ]

nomeSOC = c("DATA","DOCUMENTO","CNPJ","AGENCIA","NOME_INSTITUICAO","COD_CONGL",
"NOME_CONGL","TAXONOMIA","CONTA","NOME_CONTA","SALDO","ATE3M","APOS3M")
DB = NULL
for (ivData in vData){
  print(ivData)
  fileToRead = paste0(SBal,ivData,"SOCIEDADES.CSV")
  if(!file.exists(fileToRead)){next}
  iDB = fread(fileToRead,dec=",")
  if(ivData<=201009){
    names(iDB) = c("DT","CNPJ","NINST","A","DOC","C","NCONTA","SALDO")
    iDB = iDB[,.(DT,DOC,CNPJ,AGENCIA=NA,NINST,COD_CONGL = NA,NOME_CONGL=NA,
    A,C,NCONTA,SALDO,ATE3M=NA,APOS3M=NA)]
  }else if(dim(iDB)[2]<=11){
    iDB[,(c("ATE3M","APOS3M")):= NA]
  }
  names(iDB) = nomeSOC
  DB = rbind(DB,iDB)
}
DB[,':='(CONTA=paste0("X",CONTA))]
DB[,SALDO := as.numeric(gsub(",",".",SALDO))]
DBSOC = DB[!is.na(CNPJ)][!TAXONOMIA%in%c("O","A","T","C","K","J")]
DBSOC = DBSOC[!TAXONOMIA%in%c("SOCIEDADE DE CREDITO AO MICROEMPREENDEDOR",
                              "AGENCIAS DE FOMENTO OU DE DESENVOLVIMENTO",
                              "SOCIEDADES DE ARRENDAMENTO MERCANTIL",
                              "SOC. CORRETORA DE TITULOS E VALORES MOBILIARIOS",
                              "SOC DISTRIBUIDORA DE TITULOS E VALORES MOBILIARIOS",
                              "SOC. CORRETORA DE CAMBIO",
                              "INSTITUICOES DE PAGAMENTO")]
WDBSOC = dcast(DBSOC, DATA + DOCUMENTO + CNPJ + NOME_INSTITUICAO ~ CONTA, value.var = "SALDO")
nomeVarNA = names(WDBSOC)[substr(names(WDBSOC),1,1)%in%c("X")]
WDBSOC[,(nomeVarNA):=lapply(.SD,function(x) ifelse(is.na(x),0,x)), .SDcols = nomeVarNA ]
classWDBSOC = sapply(WDBSOC,class)
classWDBSOC[!classWDBSOC%in%c("numeric")]
classWDBCONGL = sapply(WDBCONGL,class)
classWDBCONGL[!classWDBCONGL%in%c("numeric")]
classWDBBANCOS = sapply(WDBBANCOS,class)
classWDBBANCOS[!classWDBBANCOS%in%c("numeric")]
classWDBPRUD = sapply(WDBPRUD,class)
classWDBPRUD[!classWDBPRUD%in%c("numeric")]
WDBSOC[.N,1:5]
WDBBANCOS[.N,1:5]
WDBCONGL[.N,1:7]
WDBPRUD[.N,1:7]
WDBSOC[1,1:5]
WDBBANCOS[1,1:5]
WDBCONGL[1,1:7]
WDBPRUD[1,1:7]
dataAtual = sort(unique(c(DBBANCOS$DATA,DBSOC$DATA,DBCONGL$DATA,DBPRUD$DATA)),decreasing = TRUE)[1]
dataAnt = sort(unique(c(DBBANCOS$DATA,DBSOC$DATA,DBCONGL$DATA,DBPRUD$DATA)),decreasing = TRUE)[2]

# Salvar csv's
# Salvar o csv dentro do storage do Watson (vai continuar com 2 storages?) colocar o c?digo e as chaves da conex?o
# Salvar um dos csv do Balancete dentro do db2
write.table(WDBSOC,paste0(SDataOutMod,"WDBSOC.CSV"),sep = ";",dec=",",row.names = FALSE)
write.table(WDBBANCOS,paste0(SDataOutMod,"WDBBANCOS.CSV"),sep = ";",dec=",",row.names = FALSE)
write.table(WDBCONGL,paste0(SDataOutMod,"WBCONGL.CSV"),sep = ";",dec=",",row.names = FALSE)
write.table(WDBPRUD,paste0(SDataOutMod,"WBPRUD.CSV"),sep = ";",dec=",",row.names = FALSE)
write.table(DBCONGL,paste0(SDataOutMod,"DBCONGL.CSV"),sep = ";",dec=",",row.names = FALSE)
write.table(DBBANCOS,paste0(SDataOutMod,"DBBANCOS.CSV"),sep = ";",dec=",",row.names = FALSE)
write.table(DBSOC,paste0(SDataOutMod,"DBSOC.CSV"),sep = ";",dec=",",row.names = FALSE)
write.table(DBPRUD,paste0(SDataOutMod,"DBPRUD.CSV"),sep = ";",dec=",",row.names = FALSE)

DBSOC[,':='(NOME_CONGL=NOME_INSTITUICAO,COD_CONGL=CNPJ)]
DBBANCOS[,':='(NOME_CONGL=NOME_INSTITUICAO,COD_CONGL=CNPJ)]
DBTOT = rbindlist(list(DBCONGL,DBBANCOS,DBSOC),fill = TRUE)
WDBTOT = dcast(DBTOT, DATA + DOCUMENTO + CNPJ + NOME_INSTITUICAO + COD_CONGL + NOME_CONGL ~ CONTA, value.var = "SALDO")
nomeVarNA = names(WDBTOT)[substr(names(WDBTOT),1,1)%in%c("X")]
WDBTOT[,(nomeVarNA):=lapply(.SD,function(x) ifelse(is.na(x),0,x)), .SDcols = nomeVarNA ]
classWDBTOT = sapply(WDBTOT,class)
classWDBTOT[!classWDBTOT%in%c("numeric")]

# Salvar csv's
# Salvar o csv dentro do storage do Watson (vai continuar com 2 storages?) colocar o c?digo e as chaves da conex?o
write.table(WDBTOT,paste0(SDataOutMod,"WDBTOT.CSV"),sep = ";",dec=",",row.names = FALSE)
write.table(DBTOT,paste0(SDataOutMod,"DBTOT.CSV"),sep = ";",dec=",",row.names = FALSE)

ncols = c("DOCUMENTO","AGENCIA","TAXONOMIA","CONTA","NOME_CONTA","SALDO")
DBCONGLAJ    = unique(copy(DBCONGL)[,(ncols):=NULL],by = c("COD_CONGL","DATA"))
DBCONGLAJ[is.na(CNPJ)]
ncols = c("CNPJ","NOME_INSTITUICAO")
DBCONGLAJ[,(ncols):=lapply(.SD, na.locf,na.rm = FALSE,fromLast = TRUE),.SDcols = ncols,by = "COD_CONGL"]
DBCONGLAJ[,(ncols):=lapply(.SD, na.locf,na.rm = FALSE),.SDcols = ncols,by = "COD_CONGL"]
DBCONGLAJ[is.na(CNPJ)]
DBCONGLAJ[COD_CONGL%in%"C0051602",':='(CNPJ = 52904364,
                                       NOME_INSTITUICAO = "CONC?RDIA S.A. CORRETORA DE VALORES MOBILI?RIOS, C?MBIO E COMMODITIES")]
setkey(DBCONGLAJ,DATA,COD_CONGL,CNPJ)
CONGLFIN  = unique(DBCONGLAJ,fromLast = TRUE,by=c("COD_CONGL","CNPJ"))
CONGLFIN1 = unique(DBCONGLAJ,fromLast = FALSE,by=c("COD_CONGL","CNPJ"))
names(CONGLFIN1)[1] = "DATA_INICIO"
CONGLFIN = CONGLFIN[CONGLFIN1[,.(DATA_INICIO,COD_CONGL,CNPJ)],on = c("COD_CONGL","CNPJ")]
CONGLFIN[,':='(CI = as.numeric(gsub("C00","",COD_CONGL)))]
setkey(CONGLFIN,COD_CONGL)

# Salvar csv's
# Salvar o csv dentro do storage do Watson (vai continuar com 2 storages?) colocar o c?digo e as chaves da conex?o
write.csv2(CONGLFIN,paste0(SAuxMod,"CONGLFIN.csv"),row.names = FALSE)

# Leitura de csv
formulas = fread(paste0(SAuxMod,"FORMULAS_BAL&IFDATA.csv"))$formula
formulas=unlist(strsplit(formulas,"\\+"), use.names=FALSE)
formulas=unlist(strsplit(formulas,"\\-"), use.names=FALSE)
formulas=unlist(strsplit(formulas,"\\*"), use.names=FALSE)
formulas=unlist(strsplit(formulas,"\\/"), use.names=FALSE)
formulas= strip(formulas,digit.remove = FALSE)
contasModelo = unique(formulas[substr(formulas,1,1)=="x"])
contasModelo = mgsub(contasModelo,"x","X")


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



#### Salva a base de output no db2



for(i in 1:nrow(CONGLFIN)){
  rows <- apply(CONGLFIN, 1, function(x){paste0("'", x, "'", collapse = ', ')})
  rows <- paste0('(', rows[i], ')')
  
    queryinsert <- paste0(
     "INSERT INTO FGCDATAMART.CONGLFIN(",   paste0(colnames(CONGLFIN), collapse = ', '),   ')', 
    ' VALUES ',  paste0(rows, collapse = ', ')
  )
  dbSendUpdate(Db2_FGC_connection,queryinsert)
}

