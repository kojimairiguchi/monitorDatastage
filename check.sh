#!/bin/bash

########       Revision estado ETLs              ########
##                                                     ##
##        Autor : Nicolas Martinez                     ##
##        [COMPANY NAME]                               ##
##                                                     ##
##                                                     ##
##                                                     ##
#########################################################

#opciones
alias allclear='clear; echo -e "\033c\e[3J"'
OK='\e[0;32m'
Warning='\e[0;33m'
Failed='\e[0;31m'
Running='\e[1;34m'
nc='\e[0m'
hora=$(date +"%d-%m-%Y %H:%m:%S")
l=0
bold=`tput bold`
normal=`tput sgr0`

#obtiene resultados

IFS=$'\n' read  -d'' -r -a inlines  < listado

long=${#inlines[@]}


#progress bar
function barra {
        let _progress=(${1}*100/${2}*100)/100
        let _done=(${_progress}*4)/10
        let _left=40-$_done

        _done=$(printf "%${_done}s")
        _left=$(printf "%${_left}s")
	
        echo -e "\rAvance : [${_done// /#}${_left// /-}] ${_progress}%%"

}


function procesa_all {
	rm -f salida.log
	C=0
	while [ $C -lt $long ]
	do
		clear
		echo "Favor espere un momento mientras se procesa la informacion"
		barra ${C} ${long}
		sshpass -p [PASSWORD] ssh [USER]@[SERVER] "${inlines[$C]}" >> salida.log
		((C++))
		sleep 0.1
	done
}



procesa_all 2>/dev/null


ready=$(grep CORRECTA salida.log | cut -d',' -f1)
warnings=$(grep AVISOS salida.log | cut -d',' -f1)
errores=$(grep ANOMALA salida.log | cut -d',' -f1)
#runnings=$(grep  salida.log | cut -d',' -f1)


#crea arrays


allclear

#salidas de prueba
divider===============================
divider=$divider$divider
divider=$divider$divider
clear
echo -e "\t############ ${bold}Monitoreo ETL produccion${normal} ############"
echo -e "\t\t\t$(date +'%d-%m-%Y %H:%M:%S')"
echo -e ""
echo -e ""
echo -e "\t\t${Failed}${bold}ETL con error${normal}"

echo -e "\t\t[Proyecto][Ruta][Secuencia]"
echo -e "$divider"
for each in "${errores[@]}"
do
  echo -e "$each"
done
echo -e ""
echo -e "\t\t${Warning}${bold}ETL con advertencias${normal}"
echo -e "\t\t[Proyecto][Ruta][Secuencia]"
echo -e "$divider"
for each in "${warnings[@]}"
do
  echo -e "$each"
done
echo -e ""
echo -e "\t\t${Running}${bold}ETL en ejecucion${normal}"
echo -e "\t\t[Proyecto][Ruta][Secuencia]"
echo -e "$divider"
for each in "${runnings[@]}"
do
  echo -e "$each"
done
echo -e ""
echo -e "\t\t${OK}${bold}ETL finalizados normalmente${normal}${nc}"
echo -e "\t\t[Proyecto][Ruta][Secuencia]"
echo -e "$divider"
for each in "${ready[@]}"
do
  echo -e "$each"|more
done
echo -e ""
echo -e "\t\t\t\tFIN"

