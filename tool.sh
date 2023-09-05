#!/bin/bash

LOGFILE="log.txt"

log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S"): $1" | tee -a $LOGFILE
}

# Verificar si el script se ejecuta como superusuario
if [[ $EUID -ne 0 ]]; then
   log "Por favor, ejecute este script como superusuario."
   exit 1
fi

WIN_ISO="/home/ticot/Descargas/Win10_22H2_Spanish_x64v1.iso"
FEDORA_ISO="/home/ticot/Descargas/Fedora-Workstation-Live-x86_64-38-1.6.iso"
LOGOPEDIA="/home/ticot/Documentos/Logopedia.zip"

safe_copy() {
    SOURCE=$1
    DEST=$2
    REQUIRED_SPACE=$(du -s $SOURCE | cut -f1)
    AVAILABLE_SPACE=$(df $DEST | tail -1 | awk '{print $4}')
    
    if [[ $REQUIRED_SPACE -gt $AVAILABLE_SPACE ]]; then
        log "No hay suficiente espacio en $DEST para copiar $SOURCE. Espacio necesario: $REQUIRED_SPACE, espacio disponible: $AVAILABLE_SPACE."
        exit 1
    fi

    rsync -ah --no-owner --no-group --progress $SOURCE $DEST || {
        log "Error usando rsync para copiar $SOURCE a $DEST. Intentando con cp..."
        cp -r $SOURCE $DEST || {
            log "Error copiando $SOURCE a $DEST con cp. Abortando."
            exit 1
        }
    }
}

# Función mejorada para desmontar particiones
unmount_partitions() {
    for partition in "$1"*; do
        if mountpoint -q $partition; then
            umount $partition || { log "Error desmontando $partition"; exit 1; }
        fi
    done
}

log "Verificando archivos..."
for FILE in $WIN_ISO $FEDORA_ISO $LOGOPEDIA; do
    if [[ ! -f $FILE ]]; then
        log "El archivo $FILE no existe."
        exit 1
    fi
done

USB_WIN="/dev/sdc"
USB_FEDORA="/dev/sdd"

log "Limpiando dispositivos..."
unmount_partitions $USB_WIN
wipefs -a $USB_WIN || { log "Error limpiando $USB_WIN"; exit 1; }
unmount_partitions $USB_FEDORA
wipefs -a $USB_FEDORA || { log "Error limpiando $USB_FEDORA"; exit 1; }

log "Creando particiones..."
echo -e ",10G,*\\n," | sfdisk $USB_WIN || { log "Error particionando $USB_WIN"; exit 1; }
echo -e ",10G,*\\n," | sfdisk $USB_FEDORA || { log "Error particionando $USB_FEDORA"; exit 1; }

log "Formateando particiones..."
mkfs.fat -F 32 ${USB_WIN}1 || { log "Error formateando ${USB_WIN}1"; exit 1; }
mkfs.fat -F 32 ${USB_FEDORA}1 || { log "Error formateando ${USB_FEDORA}1"; exit 1; }
mkfs.exfat ${USB_WIN}2 || { log "Error formateando ${USB_WIN}2"; exit 1; }
mkfs.exfat ${USB_FEDORA}2 || { log "Error formateando ${USB_FEDORA}2"; exit 1; }

log "Montando particiones..."
mkdir -p /mnt/win_data
mkdir -p /mnt/fedora_data

mount ${USB_WIN}2 /mnt/win_data || { log "Error montando ${USB_WIN}2"; exit 1; }
mount ${USB_FEDORA}2 /mnt/fedora_data || { log "Error montando ${USB_FEDORA}2"; exit 1; }

log "Copiando archivos..."
safe_copy /home/ticot/Documentos/ /mnt/fedora_data/
safe_copy $LOGOPEDIA /mnt/win_data

unmount_partitions $USB_WIN
unmount_partitions $USB_FEDORA

log "Creando USB de arranque..."
woeusb --target-filesystem NTFS --device $WIN_ISO ${USB_WIN}1 || { log "Error creando USB de arranque con $WIN_ISO"; exit 1; }
dd if=$FEDORA_ISO of=${USB_FEDORA}1 bs=4M status=progress oflag=sync || { log "Error creando USB de arranque con $FEDORA_ISO"; exit 1; }

log "Listo! Ambos USBs están preparados."
