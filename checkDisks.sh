#!/bin/sh

function mail() {

        # Credenciales
        USER="lostmail@qinaya.tech"
        PASWD="DonBoricito.68"

        # Datos Correo
        FROM="reportes@qinaya.tech" # Alias "reportes" de lostmail
        SUBJECT="Alerta Disco $2" # Asunto
        TO="aalcaino@qinaya.tech" # Cliente
        DISTRIBUTION="cloudhelp@qinaya.tech" # Lista de distribución "cloudhelp"
        MESSAGE=$1 # Mensaje

        echo -e "\nEnviando correo a $TO $DISTRIBUTION"

        python3 /etc/cron.daily/diskAlert/sendEmail.py -u $USER -p $PASWD -f $FROM -t $TO -d $DISTRIBUTION -s "$SUBJECT" -m "$MESSAGE" 

        if [ $? -eq 0 ]; then
                echo -e "\nCorreo enviado"
        fi

}

clean_message() {

    echo -e "\nHOSTNAME: $(hostname)"    
    echo "NIVEL DE ALERTA: $1%"
    echo "FECHA: $(date)"

    echo -e "\nDISCO: $partition    DIRECTORIO: $directory"

    echo -e "\nTAMAÑO: $size    UTILIZADO: $used ($usep%)   DISPONIBLE: $available"
}

main_prog() {

    ALERT1=80 # Nivel de alerta
    ALERT2=90
    ALERT3=100

    while read -r output; do
        #echo "Working on $output ..."
        usep=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1)
        partition=$(echo "$output" | awk '{print $3}')
        directory=$(echo "$output" | awk '{print $2}')
        size=$(echo "$output" | awk '{print $4}')
        used=$(echo "$output" | awk '{print $5}')
        available=$(echo "$output" | awk '{print $6}')

        if [ $usep -ge $ALERT3 ] ; then
            message=$(clean_message $ALERT3)
            mail "$message" "$ALERT3"
            
        elif [ $usep -ge $ALERT2 ] ; then
            message=$(clean_message $ALERT2)
            mail "$message" "$ALERT2"
            
        elif [ $usep -ge $ALERT1 ] ; then
            message=$(clean_message $ALERT1)
            mail "$message" "$ALERT1"

        fi
    done
}
 
message=$(df -h | grep -vE "^Filesystem|tmpfs|cdrom|sr0|loop" | awk '{print $5 " " $6 " " $1 " " $2 " " $3 " " $4}' | main_prog)

echo "$message"
