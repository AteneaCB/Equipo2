##Curso Data Science Santander-BEDU | Módulo 2: R
## Equipo 2: Zoé Ariel García Martínez, Gerardo Miguel Pérez Solis, Atenea De La Cruz Brito
##Proyecto: Generación de energía en México: alternativas limpias

########################## I. Inicio ##########################
#Librerías
library(DescTools)
library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)
library(foreign)

#Directorio de trabajo
#setwd("Aqui va la direccion")
setwd("C:/Users/Familia Solis/Documents/Documentos de Gerardo/CURSO DATA SCIENCE/Proyecto") #Cambiar según usuario

# Extracción de datos .dbf y transformación a .csv
i_gen <- read.dbf("/mx_inventory_gen_new/mx_inventory_gen_new.dbf")
i_pot <- read.dbf("/mx_inventory_pot_new/mx_inventory_pot_new.dbf")
i_dni <- read.dbf("/nsrdb_mx_dni_new/nsrdb_mx_dni_new.dbf")

write.csv(i_gen,"mx_inventory_gen_new.csv",row.names = F)
write.csv(i_pot,"mx_inventory_pot_new.csv",row.names = F)
write.csv(i_dni,"nsrdb_mx_dni_new.csv",row.names = F)

#parte atenea

gen <- read.csv("mx_inventory_gen_new.csv")
head(gen); tail(gen); names(gen); class(gen); str(gen); summary(gen)

pot <- read.csv("mx_inventory_pot_new.csv")
head(pot); tail(pot); names(pot); class(pot); str(pot); summary(pot)

dni <- read.csv("nsrdb_mx_dni_new.csv")
head(dni); tail(dni); names(dni); class(dni); str(dni); summary(dni)

rank <- read.csv("solargis_pvpot_countryrank_2020.csv")
head(rank); tail(rank); names(rank); class(rank); str(rank); summary(rank)

#Seleccionar y renombrar columnas a emplear
rank <- select(rank, iso = ISO_A3, country = Country, region = WorldBankRegion,
               theoghi = Average_theoretical_potential_GHI_kWh_m2dayLongterm,
               pracpvout = Average_practical_potential_PVOUT_Level1_kWh_kWdayLongterm,
               avlcoe = Average_economic_potential_LCOE_USD_kWh2018,
               pvpc = AveragePVseasonality_index_longterm)
head(rank); tail(rank); length(rank)

########################## II. Consulta de datos ########################################

#Cuantas veces aparece un estado en gen

unique(gen$ESTADO) # <- hay 27 estados listados

(cuentaEstado <- count(gen, ESTADO)) # <- cuento qué tantas veces se repite un estado

cuentaEstado[cuentaEstado$n == max(cuentaEstado$n), ] # <- el estado más repetido es Veracruz

cuentaEstado[cuentaEstado$n == min(cuentaEstado$n), ] # <- Colima e Hidalgo los que menos aparecen

#Análisis tipo de plantas en gen: 

unique(gen$plant_type) # <- hay 5 tipos de plantas

(cuentaPlanta <- count(gen, plant_type)) # <- enlisto los tipo de plantas

# tenemos 96 plantas de poder h?drico funcionando...


#datos con los de la BD pot

unique(pot$ESTADO) # <- 32 estados potenciales para tener plantas generadoras

(cuentaEstadoP <- count(pot, ESTADO)) #<- cuanto se repite cada estado

cuentaEstadoP[cuentaEstadoP$n == max(cuentaEstadoP$n), ] # <- el EDO que aparece m?s veces es jal?sco

cuentaEstadoP[cuentaEstadoP$n == min(cuentaEstadoP$n), ] #el EDO que aparece menos es Tlaxcala

#plantas que se tienen listadas en pot: 

unique(pot$plant_type) # <- hay 5 tipos de plantas

(cuentaPlantaP <- count(pot, plant_type)) # <- cuanto se repiten tipo de plantas

#la planta en pot que se repite más veces es la geot?rmica con 1089 veces.

########################## III. Análisis Exploratorio de Datos ##########################

#Medidas de dispersión: Rango Intercuartílico, Varianza y Desviación Estándar
IQR(gen$gengwh)
var(gen$gengwh)
sd(gen$gengwh)

IQR(pot$potencial)
var(pot$potencial)
sd(pot$potencial)

IQR(dni$dni)
var(dni$dni)
sd(dni$dni)

IQR(rank$avlcoe)
var(rank$avlcoe)
sd(rank$avlcoe)

#Histogramas
hist(gen$gengwh,
     main = "Histograma generación eléctrica GWh",
     xlab = "Generación en GWh",
     ylab = "Frecuencia",
     col = "red4")

hist(pot$potencial,
     main = "Histograma potencial eléctrico GWh",
     xlab = "Potencial en GWh",
     ylab = "Frecuencia",
     col = "orange")

hist(dni$dni,
     main = "Histograma irradiación normal diaria",
     xlab = "dni",
     ylab = "Frecuencia",
     col = "yellow2")

hist(rank$avlcoe,
     main = "Histograma potencial económico LCOE",
     xlab = "LCOE promedio",
     ylab = "Frecuencia",
     col = "navy")

#Gráficas
ggplot(gen, aes(x=lon, y=lat, colour=gengwh)) +
  geom_point()+
  theme_light()+
  facet_wrap("plant_type")+
  ggtitle("Generación GWh por ubicación geográfica y tipo de planta")+
  xlab("Longitud")+
  ylab("Latitud")+
  scale_color_gradient(low="orange", high="red4")

ggplot(pot, aes(x=lon, y=lat, colour=potencial)) +
  geom_point()+
  theme_light()+
  facet_wrap("plant_type")+
  ggtitle("Potencialpor ubicación geográfica y tipo de planta en GWh")+
  xlab("Longitud")+
  ylab("Latitud")+
  scale_color_gradient(low="khaki", high="navy")

ggplot(rank, aes(x=theoghi, y=pracpvout, colour=avlcoe)) +
  geom_point()+
  theme_light()+
  facet_wrap("region")+
  ggtitle("Promedio teórico, práctico y económico de PV mundial")+
  xlab("Longitud")+
  ylab("Latitud")+
  scale_color_gradient(low="lightblue", high="royalblue")

boxplot(dni~ESTADO, data = dni, col=c("gold", "green3"), main="Irradiación solar directa por Estado")

(scatplot_theo <- ggplot(rank, aes(x=theoghi, y=pracpvout)) + 
    geom_point() + 
    geom_smooth(method = "lm", se = T) +
    xlab('Potencial teórico medio') +
    ylab('Potencial práctico medio'))

#Resultado: relación positiva, potencial de generación de energía teórico y práctico se relacionan.

(scatplot_avpv <- ggplot(rank, aes(x=rank$pvpc, y=rank$pracpvout)) + 
    geom_point() + 
    geom_smooth(method = "lm", se = T) + 
    xlab('Indice PV estacional') + 
    ylab('Potencial práctico medio'))
#Resultado: relación negativa, a menor variabilidad entre estaciones del año, mayor potencial práctico.

#Muestra de países de América Latina y el Caribe solamente
ranka <- subset(rank, region=="LCR")
head(ranka); tail(ranka)

(scatplot_theoa <- ggplot(ranka, aes(x=ranka$theoghi, y=ranka$pracpvout)) + 
    geom_point() + 
    geom_smooth(method = "lm", se = T) + 
    xlab('Potencial teórico medio') + 
    ylab('Potencial práctico medio'))
#Resultado: relación positiva

(scatplot_avpva <- ggplot(ranka, aes(x=ranka$pvpc, y=ranka$pracpvout)) + 
    geom_point() + 
    geom_smooth(method = "lm", se = T) + 
    xlab('Indice PV estacional') + 
    ylab('Potencial práctico medio'))
#Resultado: sin relación aparente

#Para México
ranka[ranka$iso=="MEX",]
#Verificamos que el pvpv para México es de 1.33, es decir que su potencial de generación de energía varía poco.
#Esto es importante, ya que México tiene un alto potencial de generación de energía sin problemas de cambios bruscos.

#Limpiar
dev.off()

################################## IV.Otros Gráficos##########################################
#promedio de generacion de energía por tipo de planta
count(gen,plant_type)

(gen.mean.estado <- aggregate(gengwh~plant_type,FUN =mean,data = gen))
ggplot(gen.mean.estado,aes(x=gengwh,y=plant_type,fill=plant_type))+ 
  geom_bar(stat = "identity",position ="stack",col="black")+
  ggtitle("Generacion electrica (GWh) promedio por tipo de planta")+
  xlab("Generación en GWh")+ylab("Planta")+
  labs(fill = "Tipo Planta")

#promedio de generación de energía por estado y planta
count(gen,plant_type,ESTADO)

gen.mean.edo.plant <- aggregate(gengwh~plant_type+ESTADO,FUN =mean,data = gen)

ggplot(gen.mean.edo.plant,aes(x=gengwh,y=ESTADO,fill =plant_type))+
  geom_bar(stat = "identity",position ="stack",col="black")+
  ggtitle("Generación promedio por estado ")+
  xlab("Generación en GWh")+ylab("Estado")+
  labs(fill = "Tipo Planta")

#promedio de potencial por tipo de planta
count(pot,plant_type)

(pot.mean.plant <- aggregate(potencial~plant_type,FUN =mean,data = pot))
ggplot(pot.mean.plant,aes(x=potencial,y=plant_type,fill =plant_type))+
  geom_bar(stat = "identity",position ="stack",col="black")+
  ggtitle("Potencial promedio por tipo de planta")+
  xlab("Potencial")+ylab("Planta")+
  labs(fill = "Tipo Planta")

#promedio de potencial por estado y tipo de planta
count(pot,plant_type,ESTADO)

pot.mean.edo.plant <- aggregate(potencial~plant_type+ESTADO,FUN =mean,data = pot)
baja_california <- pot.mean.edo.plant[pot.mean.edo.plant$ESTADO=="Baja California",]
otros_edos <- pot.mean.edo.plant[pot.mean.edo.plant$ESTADO!="Baja California",]

ggplot(otros_edos,aes(x=potencial,y=ESTADO,fill =plant_type))+
  geom_bar(stat = "identity",position ="stack",col="black")+
  ggtitle("Potencial promedio por estado ")+
  xlab("Potencial en GWh")+ylab("Estado")+
  labs(fill = "Tipo Planta")

ggplot(baja_california,aes(x=potencial,y=ESTADO,fill =plant_type))+
  geom_bar(stat = "identity",position ="stack",col="black")+
  ggtitle("Potencial promedio de Baja California")+
  xlab("Potencial en GWh")+ylab("Estado")+
  labs(fill = "Tipo Planta")

####################### V. ANALISIS DE CONSUMO DE ENERGÍA ###########################
#lectura del consumo de energía eléctrica por entidad federativa 

ConsumoEE <- read.csv("Consumo_por_enttidad_2012_2017.csv")
head(ConsumoEE); str(ConsumoEE)

tConsumoEE <- t(ConsumoEE[-1])

colnames(tConsumoEE) <- ConsumoEE[,1] #renombro las columnas con los nombres de la primer columna

tConsumoEE <- as.data.frame(tConsumoEE) # traspongo la matriz y la paso a DF
tConsumoEE <- rename(tConsumoEE, CDMX = DistritoFederal)
#

#construyo las fechas: 
#library(lubridate)

tConsumoEE[, "Fecha"] <- c(names(ConsumoEE[-1]))
tConsumoEE$Fecha <- substring(tConsumoEE$Fecha, 2, 11)

tConsumoEE$Fecha <- as.Date(tConsumoEE$Fecha, format = "%m.%d.%Y") #2012 <- %m.%d.%Y , 2015 <- %d.%m.%Y
str(tConsumoEE); #reviso si ya son type Date: CHECK

#limpio los datos 2012:
tConsumoEE <-  select(tConsumoEE, -V34)

#añado la columna año, porque voy a sacar el promedio por año 
tConsumoEE[, "year"] <- year(tConsumoEE$Fecha)

Estados <- colnames(tConsumoEE)


#así obtengo el promedio por año:
#quito los datos de Diciembre, hay algo extraño en ellos, en diciembre el consumo debería crecer...
tConsumoEE_sD <- tConsumoEE[-c(12, 24, 36, 48, 60, 72), ]

prom_anual <- tConsumoEE_sD %>%
  group_by(year) %>%
  summarise(Eprom = mean(TotalNacional1))

prom_anual <- as.data.frame(prom_anual)
str(prom_anual)

plot(prom_anual, xlab = "Tiempo",
     main = "Consumo electrico Total Gw/h", 
     sub = "Consumo Eléctrico por en México periodo 2012-2017")

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
  ggtitle("Consumo promedio de Energía en México") +
  xlab("Años") + 
  ylab("Energía promedio Gw/h")

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
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,5:7], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,8:10], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,11:13], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,14:16], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,17:19], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,20:22], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,23:25], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,26:28], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,29:31], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

tsTotalNacional_1 <- ts(tConsumoEE_sD[,32:33], start = 2012, end = 2018, frequency = 11)
aggregate(tsTotalNacional_1) %>% 
  plot(main = "Consumo eléctrico por Estado Gw/h", ylab= "Consumo Gw/h", xlab = "Año",
       sub = "Consumo en el periodo 2012 - 2018",
       col = "red", lty = 3 ,lwd = 2)

#Finalmente obtuve las series de tiempo y realicé representaciones 
#para el consumo de energíaen barras y en tipo pastel:
  

  #graficas de pastel para representar quién consume más
  
  #creo un df conveniente para esta representación
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
  ggtitle("Porcentaje de Consumo Eléctrico Por Entidad")

par(mar=c(11,4,4,4))
barplot(height = cakeE$Porcentaje, names = cakeE$Estado, col = "#bd032c", horiz = F, las=2,
        font.lab = 1, col.lab = "black", cex.lab = 2,
        main = "Porcentaje de Consumo Eléctrico Por Entidad") 

par(mar=c(11,4,4,4))
barplot(height = cakeE$Consumo, names = cakeE$Estado, col = "#bd032c", horiz = F, las=2,
        font.lab = 1, col.lab = "black", cex.lab = 2,
        main = "Porcentaje de Consumo Eléctrico Por Entidad GW/h") 
