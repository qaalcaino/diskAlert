#!/bin/bash

function mail() {

        # Credenciales
        USER="lostmail@qinaya.tech"
        PASWD="rwgrptrqnzbwqwbd"

        # Datos Correo
        FROM="reportes@qinaya.tech" # Alias "reportes" de lostmail
	
	option1=$2
	option2=$3

	if [ -z $option2  ] ; then
	
		SUBJECT="VCYT: imagenescyt Disco sobre $2%" # Asunto
	else
		SUBJECT="VCYT: imagenescyt Disco bajo $3%" # Asunto
	fi
	echo $SUBJECT
        TO="aalcaino@qinaya.tech" # Cliente
        DISTRIBUTION="cloudhelp@qinaya.tech" # Lista de distribución "cloudhelp"
        MESSAGE=$1 # Mensaje

        echo -e "\nEnviando correo a $TO $DISTRIBUTION"

        python3 /bin/diskAlert/sendEmail.py -u $USER -p $PASWD -f $FROM -t $TO -d $DISTRIBUTION -s "$SUBJECT" -m "$MESSAGE" 

        if [ $? -eq 0 ]; then
                echo -e "\nCorreo enviado"
        fi

}

fill_message() { # Mensaje si el tamaño del disco aumenta

    echo -e "\nHOSTNAME: $(hostname)"    
    echo "NIVEL DE ALERTA: $1%"
    echo "FECHA: $(date)"

    echo -e "\nDISCO: $partition    DIRECTORIO: $directory"

    echo -e "\nTAMAÑO: $size    UTILIZADO: $used ($usep%)   DISPONIBLE: $available"
}

decrease_message() { # Mensaje si el tamaño del disco disminuye

    echo -e "\nEl disco disminuyo de la alerta de $1% a $2%"
    echo -e "\nHOSTNAME: $(hostname)"    
    echo "NIVEL DE ALERTA: $2%"
    echo "FECHA: $(date)"

    echo -e "\nDISCO: $partition    DIRECTORIO: $directory"

    echo -e "\nTAMAÑO: $size    UTILIZADO: $used ($usep%)   DISPONIBLE: $available"
}

main_prog() {

    ALERT1=80 # Nivel de alerta
    ALERT2=90
    ALERT3=100

    while read -r output; do
        
	# Información del disco
        usep=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1)
        partition=$(echo "$output" | awk '{print $3}')
        directory=$(echo "$output" | awk '{print $2}')
        size=$(echo "$output" | awk '{print $4}')
        used=$(echo "$output" | awk '{print $5}')
        available=$(echo "$output" | awk '{print $6}')
        disk=$(echo "$output" | awk '{print $3}' | cut -d "/" -f3)
        [ -f alertLevel$disk ] || echo 0 > alertLevel$disk
        alertLevel=$(cat alertLevel$disk)

        if (( $alertLevel == 3 )) && (( $usep < $ALERT3 )) ; then # Verifica si el disco disminuyo

            if (( $usep >= $ALERT2 )) ; then

                message=$(decrease_message $ALERT3 $ALERT2)
		mail "$message" "$ALERT2" "$ALERT3"
                echo "Disco $disk disminuyo de 3 a 2"
                echo 2 > alertLevel$disk
            elif (( $usep >= $ALERT1 )) ; then

                message=$(decrease_message $ALERT3 $AlERT1)
                mail "$message" "$ALERT1" "$ALERT3"
                echo "Disco $disk disminuyo de 3 a 1"
                echo 1 > alertLevel$disk
            else

                message=$(decrease_message $ALERT3 "0")
                mail "$message" "0" "$ALERT3"
                echo "Disco $disk disminuyo de 3 a 0"
                echo 0 > alertLevel$disk
            fi
        
        elif (( $alertLevel == 2 )) && (( $usep < $ALERT2 )) ; then

            if (( $usep >= $ALERT1 )) ; then

                message=$(decrease_message $ALERT2 $ALERT1)
                mail "$message" "$ALERT1" "$ALERT2"
                echo "Disco $disk disminuyo de 2 a 1"
                echo 1 > alertLevel$disk
            else

                message=$(decrease_message $ALERT2 "0")
                mail "$message" "0" "$ALERT2"
                echo "Disco $disk disminuyo de 2 a 0"
                echo 0 > alertLevel$disk
            fi
        
        elif (( $alertLevel == 1 )) && (( $usep < $ALERT1 )) ; then
            
            message=$(decrease_message $ALERT1 "0")
            mail "$message" "0" "$ALERT1"
            echo "Disco $disk disminuyo de 1 a 0"
            echo 0 > alertLevel$disk
            echo 0 > counter$disk

        elif (( $usep >= $ALERT3 )) ; then # Revisa si el disco alcanzo alguna alerta
            
            if (( $alertLevel != 3 )) ; then
                
                message=$(fill_message $ALERT3)
                mail "$message" "$ALERT3"
                echo "Disco $disk Alerta 3"
                echo 3 > alertLevel$disk
            fi
        elif (( $usep >= $ALERT2 )) ; then

            if (( $alertLevel != 2 )) ; then
                
                message=$(fill_message $ALERT2)
                mail "$message" "$ALERT2"
                echo "Disco $disk Alerta 2"
                echo 2 > alertLevel$disk
            fi
        elif (( $usep >= $ALERT1 )) ; then

            if (( $alertLevel != 1 )) ; then
                    
                message=$(fill_message $ALERT1)
                mail "$message" "$ALERT1"
                echo "Disco $disk Alerta 1"
                echo 1 > alertLevel$disk
            fi
        fi        

    done
}
 
message=$(df -h | grep -vE "^Filesystem|tmpfs|cdrom|sr0|loop" | awk '{print $5 " " $6 " " $1 " " $2 " " $3 " " $4}' | main_prog)

echo "$message"
