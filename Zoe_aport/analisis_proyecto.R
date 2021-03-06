library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

#Realizo apertura de los datos .dbf convertidos a .csv

gen <- read.csv("mx_inventory_gen_new.csv")
head(gen); names(gen); class(gen)

pot <- read.csv("mx_inventory_pot_new.csv")
head(pot); names(pot); class(pot)

dni <- read.csv("nsrdb_mx_dni_new.csv")
head(dni); names(dni); class(dni)


#reviso qu� tantas veces aparece un estado en gen

group_by(gen, ESTADO) # <- hay 27 estados listados

cuentaEstado <- count(gen, ESTADO) # <- cuento qu� tantas veces se repite un estado

cuentaEstado[cuentaEstado$n == max(cuentaEstado$n), ] # <- el estado m�s repetido es Veracruz

cuentaEstado[cuentaEstado$n == min(cuentaEstado$n), ] # <- el estado que menos aparece

#Ahora hago un an�logo con las plantas que se tienen listadas en gen: 

group_by(gen, plant_type) # <- hay 5 tipos de plantas

cuentaPlanta <- count(gen, plant_type) # <- enlisto los tipo de plantas

# tenemos 96 plantas de poder h�drico funcionando...

################################################################################
###
##
#

#Ahora voy a comparar estos datos con los de la BD pot

group_by(pot, ESTADO) # <- aqu� se enlistan 32 estados potenciales para tener plantas generadoras

cuentaEstadoP <- count(pot, ESTADO)

cuentaEstadoP[cuentaEstadoP$n == max(cuentaEstadoP$n), ] # <- el EDO que aparece m�s veces es jal�sco

cuentaEstadoP[cuentaEstadoP$n == min(cuentaEstadoP$n), ] #el EDO que aparece menos es Tlaxcala

#ahora analizo las plantas que se tienen listadas en pot: 

group_by(pot, plant_type) # <- hay 5 tipos de plantas

cuentaPlantaP <- count(pot, plant_type) # <- enlisto los tipo de plantas

#la planta en pot que se repite m�s veces es la geot�rmica con 1089 veces.


#ahora voy a realizar una lectura del consumo de energ�a el�ctrica por entidad federativa 

ConsumoEE <- read.csv("Consumo_por_enttidad_2012_2017.csv")
head(ConsumoEE); str(ConsumoEE)

tConsumoEE <- t(ConsumoEE[-1])

colnames(tConsumoEE) <- ConsumoEE[,1] #renombro las columnas con los nombres de la primer columna

tConsumoEE <- as.data.frame(tConsumoEE) # traspongo la matriz y la paso a DF
tConsumoEE <- rename(tConsumoEE, CDMX = DistritoFederal)
#

#construyo las fechas: 
library(lubridate)

tConsumoEE[, "Fecha"] <- c(names(ConsumoEE[-1]))
tConsumoEE$Fecha <- substring(tConsumoEE$Fecha, 2, 11)

tConsumoEE$Fecha <- as.Date(tConsumoEE$Fecha, format = "%m.%d.%Y") #2012 <- %m.%d.%Y , 2015 <- %d.%m.%Y
str(tConsumoEE); #reviso si ya son type Date: CHECK

#limpio los datos 2012:
tConsumoEE <-  select(tConsumoEE, -V34)

#a�ado la columna a�o, porque voy a sacar el promedio por a�o 
tConsumoEE[, "year"] <- year(tConsumoEE$Fecha)

Estados <- colnames(tConsumoEE)


#as� obtengo el promedio por a�o:
#quito los datos de Diciembre, hay algo extra�o en ellos, en diciembre el consumo deber�a crecer...
tConsumoEE_sD <- tConsumoEE[-c(12, 24, 36, 48, 60, 72), ]

prom_anual <- tConsumoEE_sD %>%
      group_by(year) %>%
          summarise(Eprom = mean(TotalNacional1))

prom_anual <- as.data.frame(prom_anual)
str(prom_anual)

plot(prom_anual, xlab = "Tiempo",
     main = "Consumo electrico Total Gw/h", 
     sub = "Consumo El�ctrico por en M�xico periodo 2012-2017")

prom_anual %>%
  ggplot() + 
  aes(x = year,y = Eprom)  + 
  geom_point() + 
  theme_light() +
  geom_smooth(method =  "lm") +
  
  annotate("text", x = 2017, y=17000, label = expression(paste('Recta estimada:',
                                                               ' ',
                                                               hat(y)[i] == -402118.66  + 208.4*x[i])),
           adj = 1, font = 2) +
  ggtitle("Consumo promedio de Energ�a en M�xico") +
  xlab("A�os") + 
  ylab("Energ�a promedio Gw/h")

attach(prom_anual) 

depE <- lm(Eprom~year)
summary(depE)

lm(ts(prom_anual)~time(prom_anual))

#veo los elementos de Aguascalientes
for (i in tConsumoEE[,1]){
  print(i)
}

#defino un ts para Aguascalientes: 
#fecha inicial y final:
head(tConsumoEE$Fecha, 1); tail(tConsumoEE$Fecha, 1)


#graficas de ts de cada estado 

tsTotalNacional_1 <- ts(tConsumoEE_sD[,2:4], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,5:7], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,8:10], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,11:13], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,14:16], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,17:19], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,20:22], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,23:25], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,26:28], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,29:31], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,32:33], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo el�ctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "A�o",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)



#graficas de pastel para representar qui�n consume m�s

#creo un df conveniente para esta representaci�n
cakeE <- lapply(tConsumoEE_sD, mean)
cakeE <- as.data.frame(cakeE)
cakeE <- cakeE[-c(1, 34, 35)]
cakeE <- t(cakeE)
cakeE <- as.data.frame(cakeE)
cakeE[,"Estado"] <- c(row.names(cakeE))
cakeE <- rename(cakeE, Consumo = V1)

#hago una columna de porcentaje: 

cakeE[,"Porcentaje"] <- (cakeE$Consumo/sum(cakeE$Consumo))*100

colorr = c("#af601a", "#273746", "#424949", "#eaeded", "#b3b6b7", "#f6ddcc",
           "#049514", "#260ea4", "#97fd18", "#bd032c", "#10f2c5",
           "#786913", "#b630b3", "#c62d58", "#1465e1", "#7c15a2", 
           "#7644f4", "#4a8ce4", "#f38f7c", "#d3b928", "#45230b",
           "#8692b4", "#f0f80c", "#b54f32", "#f3e4cf", "#7a6cfb",
           "#f553d6", "#675a02", "#dbe2d9", "#e8f73f",
           "#c15583", "#fce99a")

length(colorr); colorr[10]

pie(cakeE$Consumo)

ggplot(cakeE, mapping = aes(x = "", y= Porcentaje, fill =Estado)) +
  geom_bar(stat = "identity", color = "white") + 
  coord_polar(theta = "y") + 
  geom_text(aes(label=round(Porcentaje)),
            position=position_stack(vjust=0.5)) + 
  theme_void() +
  scale_fill_manual(values=colorr) + 
  ggtitle("Porcentaje de Consumo El�ctrico Por Entidad")

par(mar=c(11,4,4,4))
barplot(height = cakeE$Porcentaje, names = cakeE$Estado, col = "#bd032c", horiz = F, las=2,
        font.lab = 1, col.lab = "black", cex.lab = 2,
        main = "Porcentaje de Consumo El�ctrico Por Entidad") 

#par(mar=c(11,4,4,4))
barplot(height = cakeE$Consumo, names = cakeE$Estado, col = "#bd032c", horiz = F, las=2,
        font.lab = 1, col.lab = "black", cex.lab = 2,
        main = "Consumo El�ctrico Por Entidad GW/h") 