library(lubridate)
library(dplyr)
library(tidyr)

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