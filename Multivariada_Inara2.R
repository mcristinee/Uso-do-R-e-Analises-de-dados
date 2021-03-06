#########################################################
############ Multivariadas ##############################
rm(list=ls())

version
library(vegan) #Pacote para fazer ordena��es


###########################################################################
################### PCA - Principal Components Analysis ###################

#executar PCA em uma planilha de dados sobre peixes em diferentes ambientes

env<-read.csv("DoubsEnv.csv", row.name= 1)
View(env)
summary(env)

#devido as diferentes unidades de medida ser� necess�rio fazer uma transforma��o dos dados
#para fazer a transforma��o utiliza-se o argumento "scale=TRUE" significa que quero que fa�a transforma�ao
#RDA � a fun��o para fazer PCA

env.pca<-rda(env, scale=T) #n�o preciso de matriz pq PCA usa obrigatoriamente euclidiana
env.pca
summary(env.pca)
biplot(env.pca, xlab="PC1(54%)", ylab="PC2(20%)")

#scaling � uma fun��o que define como as coordenadas dos pontos s�o contru�das no gr�fico
#default scaling no R s�o os locais (independente)
#usando scaling=1 prioriza as vari�veis(dependente)

biplot(env.pca, scaling= 1, xlab="PC1(54%)", ylab="PC2(20%)")



par(mfrow=c(1,2))
biplot(env.pca, xlab="PC1(54%)", ylab="PC2(20%)")
biplot(env.pca, scaling= 1, xlab="PC1(54%)", ylab="PC2(20%)", main="scaling1")

ambiente<-rep(c("Estuario","Rio","Lagoa"),each=10)
ambiente

## Substituir n�mero por pontos
## "sites" � o nome dado as amostras
## "species" � o nome dado as vari�veis

biplot(env.pca, 
       scaling= 1,
       xlab="PC1(54%)", ylab="PC2(20%)",
       main="PCA",
       display = c("sites", "species"),
       type = c("text","points"))

# Mostrar agrupamento por ambiente
# Se usou scaling no plot acima, precisa usar scaling 1 aqui tbm

ordihull(env.pca,scaling=1,
         group = ambiente,
         col = c(1,2,3))

# Colocar legenda

legend("topright",
       col = c(1,2,3), 
       pch = 1,
       cex = 0.6,
       legend = c("Estu�rio","Rio","Lagoa"))


######################################################
######### PCoA- Principal Coordenate Analysis ########
rm(list=ls())

data(dune)
head(dune)
str(dune)

## Gerar matriz com vegdist, fun��o que j� vem com o pacote vegan
library(vegan)
?vegdist

#dados de contagem, usar disimilaridade Bray-Curtis
matriz.dune<-vegdist(dune, method="bray")
round(matriz.dune,2)

?cmdscale #fun��o para gerar PCoA, vem junto com o pacote vegan
dune.pcoa<-cmdscale(matriz.dune, eig=TRUE)
dune.pcoa$eig

#pacote ape extrai eigenvalues humanizado(de f�cil compreens�o humana)
library(ape)
eigen<-pcoa(matriz.dune)
eigen$values

#plotar pcoa com a fun��o ordiplot
ordiplot(dune.pcoa)

#plotar identificador de amostras
ordiplot(dune.pcoa, type='t')

#plotar a ordena��o
dune.pcoa$points #n tem o nome das sps, ent�o vamos adicionar
dune.pcoa$species <- wascores(dune.pcoa$points[,1:2],dune)
dune.pcoa

plot.pcoa<-ordiplot(dune.pcoa, type="none")
points(plot.pcoa, "sites",pch=15, col=rep(c(1,3),each=10))
text(plot.pcoa,"species", cex=0.5)



#######################################################
########### non-metric MDS ############################

?metaMDS #fun��o para fazer nMDS

#constroi a matriz direto dentro do nMDS
#Op��o autotransform= T by default. Se n�o forem dados de comunidade � melhor desativar

nmds.dune<-metaMDS(dune, distance = "bray", try = 50)

nmds.dune # stress de 11% 
stressplot(nmds.dune)

#plotar ordena��o
plot(nmds.dune)

#c�ruculos representam objetos/observa��es cruzes representam esp�cies
#mas n temos como saber quem � quem

#plotar com informa��es
plot(nmds.dune, type="t")

plot(nmds.dune, type="n")
points(nmds.dune, "sites",pch=15, col=rep(c(1,3),each=10))
text(nmds.dune, "species", cex= 0.5)



##Comparar pcoa e nmds
par(mfrow=c(1,2))

plot.pcoa<-ordiplot(dune.pcoa, type="none", main="PCoA")
points(plot.pcoa, "sites",pch=15, col=rep(c(1,3),each=10))

plot(nmds.dune, type="n", main="nMDS")
points(nmds.dune, "sites",pch=15, col=rep(c(1,3),each=10))


#######################################
######### PERMANOVA ###################

## pacotes para o teste pareado
install.packages('devtools')
library(devtools)
install_github("pmartinezarbizu/pairwiseAdonis/pairwiseAdonis")
library(pairwiseAdonis)

data(dune)
data(dune.env)
head(dune.env) 

# SF - standard farming,
# BF - biological farming
# HF - hobby-farming
# NM - nature conservation management


#testando homocedasticidade
#funcao betadisper

#gerar matriz
dune.matriz<-vegdist(dune, method="bray")

#teste de homocedastidicidade com betadisper
mod<-betadisper(dune.matriz, dune.env$Management)
mod2<-betadisper(dune.matriz, dune.env$Use)

#Resultado da homocedasticidade
anova(mod)
anova(mod2)

#Caso d� significativo, fazer teste pareado para 
#identificar onde as var�ncias s�o diferentes
permutest(mod, pairwise=T)

#plotar as vari�ncias
#como � multidimensional, utiliza de centroides
plot(mod)
plot(mod2)

#adonis � um fun��o dentro do pacote R)
#adonis para 1 fator
adonis(dune ~ Management, data = dune.env, method="bray", permutations = 9999)

#teste pareado
pairwise.adonis(dune, dune.env$Management, perm = 9999)

## modelo com 2 fatores
adonis(dune ~ Management + Use, data = dune.env, method="bray", permutations = 9999)

# se trocar a ordem faz diferen�a? permuta��es....
adonis(dune ~ Use + Management, data = dune.env, method="bray", permutations = 9999)

#modelo com intera��o
adonis(dune ~ Use + Management+ Use*Management, data = dune.env, method="bray", permutations = 9999)


## pairwise.adonis N�O aceita intera��es
## pairwise.adonis2 aceitar� intera��o, trabalho em progresso. 

#Nas palavras do autor:

#pairwise.adonis2
#This function accepts strata
#NOTE: This is still a developing version -- 
#results using interactions may not be right.
#Please validate. I would appreciate feed back.
# https://github.com/pmartinezarbizu/pairwiseAdonis


############ Exerc�cios ##################

## 1) plotar PCA usando varechem data(varechem)

data(varechem)
head(varechem)
?varechem

#padronizar PCA devido a unidades diferente... SCALE=TRUE

varepca<-rda(varechem, scale=TRUE)
summary(varepca)

biplot(varepca,scaling=1,xlab = "PC1 52%", ylab="PC2 31%")


## 2) plotar PCoA e nMDS usando iris.
##Ser� necess�rio remover a coluna de characters (species)

data(iris)
head (iris)
iris[, 1:4]

##pcoa

iris2<-iris[,-c(5)]
head(iris2)

iris.matriz<-vegdist(iris2, 'bray')
pcoa.iris <- cmdscale(iris.matriz, eig=T)
pcoa.iris

pcoa.iris$points #n tem o nome das sps, ent�o vamos adicionar
pcoa.iris$species <- wascores(pcoa.iris$points[,1:2],iris2,expand=T)
pcoa.iris$species

plot.iris<-ordiplot(pcoa.iris, type="n")
points(plot.iris, "sites", pch=20, col=rep(c("blue","red","purple"),each=50))
text(plot.iris, "species",cex=0.5)


##nmds

nmds.iris<-metaMDS(iris[,1:4], distance= "bray", try=50, autotransform=F)

plot(nmds.iris)

plot(nmds.iris, type="n",)
points(nmds.iris, "sites", pch=20, col=rep(c("blue","red","purple"),each=50))
text(nmds.iris, 'species', cex=0.7)


### 3) Permanova Iris

permanova.iris<-adonis(iris[,1:4] ~ iris$Species, method="bray", permutations= 9999)
permanova.iris

pairwise.adonis(iris[,1:4],iris$Species)

### 4) conclus�es gerais analisando em conjunto uma ordena��o (PcoA ou nDMS) e PERMANOVA

library(DataEditR)
devtools::install_github("DillonHammill/rhandsontable")

data_edit(iris, save_as = "iris_edit.csv" )
