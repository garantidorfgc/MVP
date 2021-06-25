# # Bibliotecas
# library(hrbrthemes)
# 
# # Leitura dos csv's
# # Mostrar as conexões necessárias para a leitura do CSV
# lf =list.files(SDataOutMod)
# iIncFile = max(lf[grepl("analiseIncremental",lf)])
# lf = list.files(SModIBBAAnalise)
# iRevFile = max(lf[grepl("IFS_REVIEW",lf)])
# incremental = fread(file = paste0(SDataOutMod,iIncFile),dec=",")
# ifsReview = fread(file = paste0(SModIBBAAnalise,iRevFile),dec=",")
# 
# setkey(incremental,CI)
# setkey(ifsReview,CI)
# totalAlocado = sum(incremental$incremento)
# 
# # Leitura de csv
# # Mostrar as conexões necessárias para a leitura do CSV
# lf =list.files( SModIBBAAnalise)
# fsFile = max(lf[grepl("FundSizeAbsCorrelS1.c",lf)])
# fsDt = fread(file = paste0(SModIBBAAnalise,fsFile),dec=",")
# fsDt[,dataEAD:=as.yearmon(dataEAD)]
# 
# fundSizeFin = fsDt[anoPD=="2016"&PROB==0.998&dataEAD==max(dataEAD)]$C70*10^9
# joined = incremental[ifsReview][,.(dataEAD,dataBAL,NOMECI,S,PD,Rating,Elegíveis,Risco,EAD,FSinc=incremento)]
# rm(incremental,ifsReview,iIncFile,iRevFile,lf,fsDt,fsFile)
# joined[,Rating:=factor(Rating,levels = paste0("FGC-",1:10))]
# joined[,EL := Risco*PD/100]
# joined[,UL := FSinc-EL]
# joined[,covRatio:=Risco*100/Elegíveis]
# joined[,fs_ead:=FSinc*100/EAD]
# joined[,fgcNum:= as.numeric(gsub("FGC-","",Rating))]
# joined[,classBC:= ifelse(fgcNum%in%c(1:4),1,ifelse(fgcNum%in%c(5,6),2,ifelse(fgcNum%in%c(7:8),3,4)))]
# joined[classBC==1,labelBC:="Tranquilo"]
# joined[classBC==2,labelBC:="Atenção"]
# joined[classBC==3,labelBC:="Cuidado"]
# joined[classBC==4,labelBC:="Crítico"]
# joined[,novaClasse:= ifelse(fgcNum%in%c(1:3),1,ifelse(fgcNum%in%c(4,5),2,ifelse(fgcNum%in%c(6:7),3,4)))]
# joined[novaClasse==1,labelNova:="PD <= 1.27"]
# joined[novaClasse==2,labelNova:="1.50 < PD <= 8.90"]
# joined[novaClasse==3,labelNova:="8.90 < PD <= 17.59"]
# joined[novaClasse==4,labelNova:="PD > 17.59"]
# joined[,labelBC:=factor(labelBC,levels = c("Tranquilo","Atenção","Cuidado","Crítico"))]
# analiticoRatingFGC = joined[S!="S1",.(Elegiveis = sum(Elegíveis),Cobertos=sum(Risco),EL=sum(EL),UL=sum(UL),`FS marginal`=sum(FSinc)),by="Rating"]
# analiticoRatingFGC[,covRatio:=Cobertos*100/Elegiveis]
# analiticoRatingFGC[,marginal_EAD:=`FS marginal`*100/Cobertos]
# setorder(analiticoRatingFGC,Rating)
# analiticoRatingBCB = joined[S!="S1",.(Elegiveis = sum(Elegíveis),Cobertos=sum(Risco),EL=sum(EL),UL=sum(UL),`FS marginal`=sum(FSinc)),by="labelBC"]
# analiticoRatingBCB[,covRatio:=Cobertos*100/Elegiveis]
# analiticoRatingBCB[,marginal_EAD:=`FS marginal`*100/Cobertos]
# setorder(analiticoRatingBCB,labelBC)
# analiticoS = joined[S!="S1",.(Elegiveis = sum(Elegíveis),Cobertos=sum(Risco),EL=sum(EL),UL=sum(UL),`FS marginal`=sum(FSinc)),by="S"]
# analiticoS[,covRatio:=Cobertos*100/Elegiveis]
# analiticoS[,marginal_EAD:=`FS marginal`*100/Cobertos]
# setorder(analiticoS,S)
# analiticoNovaExS1 = unique(joined[S!="S1",.(N=.N,Elegiveis = sum(Elegíveis),Cobertos=sum(Risco),EL=sum(EL),UL=sum(UL),`FS marginal`=sum(FSinc),novaClasse,PDmedia=mean(PD)),by="labelNova"],by="labelNova")
# analiticoNovaExS1[,PD := EL*100/Cobertos]
# analiticoNovaExS1[,covRatio:=Cobertos*100/Elegiveis]
# analiticoNovaExS1[,marginal_EAD:=`FS marginal`*100/Cobertos]
# setorder(analiticoNovaExS1,novaClasse)
# total = data.table(labelNova="Total",unique(joined[S!="S1",.(N=.N,Elegiveis = sum(Elegíveis),Cobertos=sum(Risco),EL=sum(EL),UL=sum(UL),`FS marginal`=sum(FSinc),novaClasse,PDmedia=mean(PD))]))[1]
# total[,PD := EL*100/Cobertos]
# total[,covRatio:=Cobertos*100/Elegiveis]
# total[,marginal_EAD:=`FS marginal`*100/Cobertos]
# names(analiticoRatingBCB)[1]="Segmentacao"
# names(analiticoRatingFGC)[1]="Segmentacao"
# names(analiticoS)[1]="Segmentacao"
# names(analiticoNovaExS1)[1]="Segmentacao"
# analiticos = rbind(analiticoRatingBCB,analiticoRatingFGC,analiticoS)
# analiticos[,Segmentacao:=as.character(Segmentacao)]
# analiticos2 = rbind(analiticoNovaExS1)
# newFrame = data.table(Segmentacao="Não Alocado",Elegiveis=0,Cobertos=0,EL=0,UL=(fundSizeFin-totalAlocado),`FS marginal`=(fundSizeFin-totalAlocado),covRatio=sum(analiticoRatingFGC$Cobertos)*100/sum(analiticoRatingFGC$Elegiveis),marginal_EAD=numeric(1))
# newFrame[,marginal_EAD:=NA]
# analiticos = rbind(analiticos,newFrame)
# names(analiticos)[1]="Segmentação"
# 
# # Salvar csv's
# # Salvar o csv dentro do storage do Watson (vai continuar com 2 storages?) colocar o código e as chaves da conexão
# write.csv2(analiticos,file=paste0(SModIBBAAnalise,Sys.Date(),"_analiticos.csv"),row.names = FALSE)
# write.csv2(analiticos2,file=paste0(SModIBBAAnalise,Sys.Date(),"_analiticos2.csv"),row.names = FALSE)
# 
# # Leitura de csv
# # Salvar o csv dentro do storage do Watson (vai continuar com 2 storages?) colocar o código e as chaves da conexão
# lf = list.files(SDataOutEAD)
# lf = lf[grepl("EADELEGHRTG",lf)]
# BIRISCOTOTAL = fread(paste0(SDataOutEAD,max(lf)),dec=",")
# 
# total = BIRISCOTOTAL[S!="S1",.(CORRETORA= sum(EAD_COR,na.rm=TRUE)),by="DATA"]
# total[,date:= as.yearmon(DATA)]
# setorder(total,date)
# total[,dateStr:= factor(date,levels=as.character( total$date))]
# total[DATA==max(DATA),cortxt:= round(CORRETORA/10^9,1)]
# total[,cortxt:= round(CORRETORA/10^9,1)]
# 
# # Gerar gráfico e salvar png
# #-Salvar usando storage do Watson (vai continuar com 2 storages?)
# tlt = "EAD em Corretoras - Ex-S1"
# p37<-ggplot(total[date>"jun 2017"],aes(dateStr,CORRETORA/10^9,group=1))+
#   geom_line(size=1,color=blues9[8])+ylab("R$ Bilhões")+ggtitle(tlt)+
#   geom_text(aes(y=(CORRETORA/10^9)+2.4,label=cortxt),size=5,angle=90)+theme_bw()+
#   theme(axis.text.x = element_text(angle=90,vjust = 0.5),axis.title.x = element_blank(),text = element_text(size=20))
# png(paste0(SModIBBAAnalise,Sys.Date(),"_REL_",tlt,".PNG"),width = 900,height = 450)
# print(p37)
# dev.off()
# 
# # Leitura de csv
# lf = list.files(SDataOutEAD)
# lf = lf[grepl("EADELEGHRTG",lf)]
# BIRISCOTOTAL = fread(paste0(SDataOutEAD,max(lf)),dec=",")
# total = BIRISCOTOTAL[S!="S1",.(EAD= sum(EAD_TOTAL,na.rm=TRUE)),by="DATA"]
# total[,date:= as.yearmon(DATA)]
# setorder(total,date)
# total[,dateStr:= factor(date,levels=as.character( total$date))]
# total[,eadtxt:= round(EAD/10^9,1)]
# 
# # Gerar gráfico e salvar png
# tlt = "EAD Ex-S1"
# p38<-ggplot(total[date>"jun 2017"],aes(dateStr,EAD/10^9,group=1))+
#   geom_line(size=1,color=blues9[8])+ylab("R$ Bilhões")+ggtitle(tlt)+
#   geom_text(aes(y=(EAD/10^9)+3,label=eadtxt),size=5,angle=90)+theme_bw()+
#   theme(axis.text.x = element_text(angle=90,vjust = 0.5),axis.title.x = element_blank(),text = element_text(size=20))+
#   ylim(c(min(total[date>"jun 2017"]$EAD/10^9)-5,max(total[date>"jun 2017"]$EAD/10^9)+5))
# png(paste0(SModIBBAAnalise,Sys.Date(),tlt,".PNG"),width = 900,height = 450)
# print(p38)
# dev.off()
SR = "~/MVP/"
SMod = paste0(SR,"Modelos/");dir.create(SMod, showWarnings = FALSE)
SModIBBA = paste0(SMod,"IBBA/");dir.create(SModIBBA, showWarnings = FALSE)
SModIBBAAnalise = paste0(SModIBBA,"Analise/");dir.create(SModIBBAAnalise, showWarnings = FALSE)

# Leitura de csv
lf = list.files(SDataOutEAD)
lf = lf[grepl("EADELEGHRTG",lf)]
BIRISCOTOTAL = fread(paste0(SDataOutEAD,max(lf)),dec=",")

BIRISCOTOTAL = BIRISCOTOTAL[CI!=4814563]
# dtInicial = as.yearmon("dez 2019")
dtInicial = as.yearmon("dec 2019")
mes_origin = c('fev', 'abr', 'mai', 'ago', 'set', 'out', 'dez')
mes_dest = c('feb', 'apr', 'may', 'aug', 'sep', 'oct', 'dec')
for(i in 1:length(mes_origin)){
  BIRISCOTOTAL$DATA = gsub(mes_origin[i], mes_dest[i], BIRISCOTOTAL$DATA)
}
BIRISCOTOTAL[,DATA:=as.yearmon(DATA)]
BIRISCO_ADJ = copy(BIRISCOTOTAL[DATA>=dtInicial&S!="S1"])
setorder(BIRISCO_ADJ,DATA)
BIRISCO_ADJ = unique(BIRISCO_ADJ,by=c("DATA","CI"))
BIRISCO_ADJ[DATA==dtInicial,EAD_COR_base:=EAD_COR]
BIRISCO_ADJ[,EAD_COR_base:=na.locf(EAD_COR_base),by="CNPJ"]
BIRISCO_ADJ[,EAD_COR_IDX:=(EAD_COR/EAD_COR_base)*100]
BIRISCO_ADJ[,EAD_COR_DELTA:=(EAD_COR-EAD_COR_base)]
BIRISCO_ADJ[,date:= as.yearmon(DATA)]
BIRISCO_ADJ[,dateStr:= factor(date,levels=as.character( unique(BIRISCO_ADJ$date)))]
cisAplicaveis = unique(BIRISCO_ADJ[abs(EAD_COR_base)>20000000]$CI)
BIRISCO_ADJ = BIRISCO_ADJ[CI%in%cisAplicaveis]
BIRISCO_ADJ[is.na(EAD_COR_IDX)]
mediaMercado=BIRISCO_ADJ[,.(EAD_COR_IDX=mean(EAD_COR_IDX,na.rm = TRUE)),by="dateStr"]
mediaMercado[,NOMECI:="Média Mercado"]
setorder(BIRISCO_ADJ,EAD_COR_DELTA)
maioresReducoesCash=BIRISCO_ADJ[DATA==max(DATA)&!is.na(EAD_COR_IDX)&abs(EAD_COR_base)>20000000][1:5]$CNPJ
maioresAumentosCash=BIRISCO_ADJ[DATA==max(DATA)&!is.na(EAD_COR_IDX)&abs(EAD_COR_base)>20000000][(.N-4):.N]$CNPJ
setorder(BIRISCO_ADJ,date)

# Gerar gráfico e salvar png
#-Salvar usando storage do Watson (vai continuar com 2 storages?)
tlt = "Maiores Reduções de EAD em Corretoras"
auxplot=rbind(BIRISCO_ADJ[CNPJ%in%maioresReducoesCash,.(dateStr,EAD_COR_IDX,NOMECI)])
p39<-ggplot()+
  geom_line(data=auxplot,aes(x=dateStr,y=EAD_COR_IDX,group=NOMECI,color=NOMECI),size=1.2)+
  scale_color_viridis_d(option = "D")+geom_point(data=auxplot,aes(x=dateStr,y=EAD_COR_IDX,group=NOMECI,color=NOMECI,shape=NOMECI),size=4)+
  theme_bw()+
  ggtitle(tlt)+theme(axis.title.x = element_blank(),axis.text.x = element_text(angle=90,vjust=.5))+
  ylab("Índice - base 100 em jun/2019")+labs(color="",shape="")+theme(legend.position = "top",text = element_text(size=16))+
  geom_line(data=mediaMercado,aes(x=dateStr,y=EAD_COR_IDX,group=1),color="black",linetype="dashed",size=1.2)
png(paste0(SModIBBAAnalise,Sys.Date(),"_REL_1",tlt,".PNG"),width = 700,height = 500)
print(p39)
dev.off()

library("stringi")
require(devtools)
install_version("aws.s3", version = "0.3.12")

## Puxa a aws.s3
library("aws.s3")


Sys.setenv("AWS_S3_ENDPOINT" = "s3.us.cloud-object-storage.appdomain.cloud",
           "AWS_ACCESS_KEY_ID" = "aa1f87ecb5d24147b8c93b09d0107ef4",
           "AWS_SECRET_ACCESS_KEY" = "53d327883fdbc38a939cb7efb5cd98470cc12de4675a2af0")

put_object(paste0("s3://mvpfundsize-donotdelete-pr-8nsdgny9fj7grs/",SModIBBAAnalise
                  ,"2021-06-25_REL_1Maiores Reduções de EAD em Corretoras.PNG")
           , file =paste0(SModIBBAAnalise,"2021-06-25_REL_1Maiores Reduções de EAD em Corretoras.PNG"), bucket = "mvpfundsize-donotdelete-pr-8nsdgny9fj7grs", region="")
print(file)


for (i in list.files(SModIBBAAnalise)){
  dest = paste0("s3://mvpfundsize-donotdelete-pr-8nsdgny9fj7grs/", SModIBBAAnalise, i)
  file = paste0(SModIBBAAnalise,i)
  
  put_object(dest, file = file, bucket = "mvpfundsize-donotdelete-pr-8nsdgny9fj7grs", region="")
  
  print(file) ###coloca o arquivo no cos
##  unlink(file) ###remove os arquivos do rstudio
  
}
