library(dplyr)
library(readxl)
library(tidyr)
library(janitor)


#### Calculo do indice de Kovats (índice de retenção), segundo Clement 1990:
#### 
#### 
#### 
#### 
#### 
#### 
#### 

CarbonoNumero= seq(from= 8, to= 20, by= 1) ## aqui, colocar o numero de carbonos do menor alcano da série
## depois de "from" e o numero do maior, depois de "to"

## carregar tabela com os tempos de retencao dos HIDROCARBONETOS HOMOLOGOS
## 
## 
## 

CaminhoCalculo= "C:/Users/HP/Desktop/"

NomeTabela= "calculoRetencao"

NalcanosRet= read_excel(".../gitAPIpubChem/AlcanosIR.xlsx") %>% 
  rename(TempoRet = Ret.Time) %>% 
  mutate(TempoRet = as.numeric(TempoRet)) %>% 
  mutate(Composto = CarbonoNumero) ## tabela com os indices de retencao dos picos dos Alcanos
## que servem de padrao para o calculo do Indice de Retencao

CalcIndRet= read_excel(".../gitAPIpubChem/OleosIR.xlsx",) 
## tabela com os indices de retencao dos compostos para os quais se deseja calcular os indices de retencao


####### NAO MEXER DAQUI PARA BAIXO, SERÁ INDICADO QUANDO MEXER NOVAMENTE
####### 
####### 
####### 
####### 
####### 

CalculoIndiceRetencao= function(tabelaComCromatograma, colunaComTempoRetencao,
                                tabelaAlcanos, colunaAlcanosTempoRetencao, colunaNCarbono){
  
  Cromatograma= tabelaComCromatograma
  colAnalito= as.numeric(Cromatograma[[colunaComTempoRetencao]])
  
  Alcanos= tabelaAlcanos
  TempoRet= as.numeric(Alcanos[[colunaAlcanosTempoRetencao]])
 
  Composto= as.numeric(Alcanos[[colunaNCarbono]])
  
  
  colnamesRI= c(names(Cromatograma), "Analito", 
                "RetNAnterior", "RetNPosterior", 
                "nCarbAnterior", "nCarbPosterior",
                "IndiceRet")
  tabelaRI <- matrix(ncol=length(colnamesRI), nrow=nrow(Cromatograma)) ## criando uma matriz vazia para popular com
  ## os dados do calculo do indice de retencao, o proprio indice, informacoes da amostra
  ## e do composto que o programa da shimadzu sugere que é
  colnames(tabelaRI)= colnamesRI
  
  for (i in 1:nrow(Cromatograma)) {
    
    analito= as.numeric(colAnalito)[i]
    
    
    ant= max(Alcanos$TempoRet[which(Alcanos$TempoRet <= analito)])
    
    post= min(Alcanos$TempoRet[which(Alcanos$TempoRet >= analito)])
    
    ant= ifelse(!is.finite(ant), NA, ant)
    post= ifelse(!is.finite(post), NA, post)
    
    Cant= unique(Alcanos$Composto[Alcanos$TempoRet == ant])
    Cpost= unique(Alcanos$Composto[Alcanos$TempoRet == post])
    
    IK= round((((analito-ant)*(Cpost-Cant)*100)/(post-ant))+100*Cant, digits=0)
    
    
    tabelaRI[i,1:ncol(tabelaRI)]= c(as.character(Cromatograma[i,]), 
                                                 analito,
                                                 c(ant, post),
                                                 c(Cant, Cpost),
                                                 IK
    )
   
    if(i == nrow(Cromatograma)){ tabelaRI= as.data.frame(tabelaRI) %>% clean_names()
    
    
    write.table(tabelaRI, paste0(CaminhoCalculo, NomeTabela,".txt"),
                sep= ";", dec= ".", row.names= FALSE, col.names= TRUE, fileEncoding= "UTF-16LE")
    
    }  

  } 
  
  return(tabelaRI)
  
}



##### RODAR ABAIXO
##### 
##### 
##### 
##### 
##### 
##### 


TabelaCalculos= CalculoIndiceRetencao(CalcIndRet, "Ret.Time",
                                      NalcanosRet, "TempoRet", "Composto")

### substituir CalcIndRet com o nome da tabela com os COMPOSTOS DE INTERESSE (SEM ASPAS)
### substituir "Ret.Time" pelo nome da coluna com os tempos de retenção dos compostos (COM ASPAS)
### substituir NalcanosRet com o nome da tabela com a SERIE HOMOLOGA DE HIDROCARBONETOS (SEM ASPAS)
### substituir TempoRet pelo nome da coluna com os tempos de retenção dos HIDROCARBONETOS DA SÉRIE (COM ASPAS)
### substituir TempoRet pelo nome da coluna com os números de carbonos da série homóloga (COM ASPAS)
