#!/bin/bash
#!/bin/bash

######################################################
#      Written By Alberto Aparicio (Worldsleaks)     #
#           Colegio Salesianos Atocha 2022           #
#           Tested on Ubuntu 20.04                   #
######################################################

if [[ $EUID -ne 0 ]]; then
    echo "[+] Este script tiene que ejecutarse como root..."
    sleep 1
    echo "[+] Cerrando programa..."
    sleep 1
else
    # Muestro Banner:
    figlet -f slant "Rush Me!"
    echo ""

    # Entro al Menú en bucle
    respuesta=100
    while [ $respuesta -ne 13 ]; do
        echo "1.- Instalar Suricata."                           
        echo "2.- Configurar Suricata."                         
        echo "3.- Actualizar reglas."                           
        echo "4.- Añadir fichero con reglas."                   
        echo "5.- Quitar reglas."                               
        echo "6.- Ver el estado de Suricata como servicio."     
        echo "7.- Levantar servicio."                           
        echo "8.- Detener servicio"                             
        echo "9.- Reiniciar el servicio"                        
        echo "10.- Devolver X número de logs."                  
        echo "11.- Restablecer archivos de configuración."      
        echo "12.- Desinstalar Suricata del sistema."           
        echo "13.- Salir del programa."                         
        echo ""

        read -p "¿Qué opción desea realizar?: " respuesta

        # Opciones Posibles:
        case $respuesta in 
            1)
                # Instalar Suricata:
                sleep 1
                echo "[+] Comprobando si el repositorio necesario existe..."
                sleep 1
                # Comprobar si existe previamente el repositorio:
                repoexist2=$(find /etc/apt/ -name "oisf_ubuntu_suricata-stable.gpg" | wc -l)
                if [ $repoexist2 -ne 0 ]; then
                    # El repositorio ya existe.
                    echo "[+] El repositorio necesario ya existe."
                    sleep 1
                    #Instalo Suricata.
                    echo "[+] Instalando Suricata..."
                    sudo apt install suricata -y > /dev/null 2> /dev/null
                    # Compruebo si se instaló bien Suricata: 
                    suricataexist=$(systemctl status suricata 2>/dev/null | wc -l)
                    if [ $suricataexist -ne 0 ]; then
                        echo "[+] Suricata se instaló correctamente!!"
                        sleep 1
                    else
                        echo "[+] Error en la instalación..."
                        sleep 1
                    fi
                    # Copia de seguridad de los archivos de configuración:
                    echo "[+] Realizando un back up del archivo de configuración principal..."
                    sleep 2
                    cp /etc/suricata/suricata.yaml /etc/suricata/backup_suricata.yaml 2> /dev/null
                    # Compruebo si se ejecutó bien:
                    if [ $? == 0 ]; then
                        # Back up hecho correctamente:
                        echo "[+] El back up se realizó correctamente!"
                        sleep 1
                        echo "[+] Volviendo al menu..."
                        sleep 1
                    else
                        # Error en el back up:
                        echo "[+] Hubo un error realizando el back up!!"
                        sleep 1
                        echo "[+] Volviendo al menu..."
                        sleep 1
                    fi
                else 
                    # El repositorio NO existe.
                    echo "[+] El repositorio necesario NO existe en el sistema..."
                    sleep 1
                    # Añado repositorio. En Ubuntu no está Suricata por defecto.
                    echo "[+] Añadiendo repositorio necesario..."
                    sleep 2
                    sudo add-apt-repository ppa:oisf/suricata-stable -y > /dev/null
                    # Compruebo si se instaló el repositorio:
                    repoexist=$(find /etc/apt/ -name "oisf_ubuntu_suricata-stable.gpg" | wc -l)
                    if [ $repoexist -ne 0 ]; then
                        echo "[+] Repositorio añadido correctamente!"
                        sleep 1
                        # Repositorio instalado. Instalo Suricata:
                        echo "[+] Instalando Suricata..."
                        sudo apt install suricata -y > /dev/null 2> /dev/null
                        # Compruebo si se instaló bien Suricata:
                        suricataexist=$(systemctl status suricata 2>/dev/null | wc -l)
                        if [ $suricataexist -ne 0 ]; then
                            echo "[+] Suricata se instaló correctamente!!"
                            sleep 1
                            # Copia de seguridad de los archivos de configuración:
                            echo "[+] Realizando un back up del archivo de configuración principal..."
                            sleep 2
                            cp /etc/suricata/suricata.yaml /etc/suricata/backup_suricata.yaml 2> /dev/null
                            # Compruebo si se ejecutó bien:
                            if [ $? == 0 ]; then
                                # Back up hecho correctamente:
                                echo "[+] El back up se realizó correctamente!"
                                sleep 1
                                echo "[+] Volviendo al menu..."
                                sleep 1
                            else
                                # Error en el back up:
                                echo "[+] Hubo un error realizando el back up!!"
                                sleep 1
                                echo "[+] Volviendo al menu..."
                                sleep 1
                            fi
                        else
                            echo "[+] Error en la instalación..."
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1
                        fi
                    else
                        echo "[+] No se pudo instalar el repositorio necesario..."
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    fi
                fi
            ;;

            2)
                # Configurar Suricata
                echo "[+] Comprobando si Suricata está en el sistema..."
                sleep 2
                # Comprobar si Suricata está instalado en el sistema:
                serviceexist3=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3 )
                serviceexist2=$(systemctl status suricata.service 2> /dev/null | wc -l)
                if [ $serviceexist2 -eq 0 ] || [ $serviceexist3 == "not-found" ]; then
                    # No instalado:
                    echo "[+] Suricata no parece estar en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Sí instalado:
                    echo "[+] Suricata sí está instalado en el sistema."
                    sleep 1
                    # Pregunto si la HOME_NET va a ser una red o una dirección IP:
                    read -p "[-] ¿La HOME_NET va a ser una IP o una Red (ip/red)?: " opcion 
                    case $opcion in
                        # Opción de introducir IP:
                        "ip"|"IP")
                            read -p "[-] Introduce la HOME_NET: " nuevaip
                            # Compruebo si la IP introducida es válida:
                            validate=$(echo $nuevaip | grep -E "^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$" | wc -l)
                            echo "[+] Comprobando validez de la dirección IP..."
                            sleep 2
                            # IP introducida NO válida:
                            if [ $validate -eq 0 ]; then
                                echo "[+] La dirección IP introducida NO es válida..."
                                sleep 1
                                echo "[+] Volviendo al menú..."
                                sleep 1
                            # IP introducida es válida:
                            else
                                echo "[+] La dirección IP introducida es válida."
                                sleep 1
                                # Sustituyo la HOME_NET por defecto por la nueva:
                                echo "[+] Actualizando la nueva HOME_NET..."
                                sleep 2
                                sudo sed -i "s/192.168.0.0\/16,10.0.0.0\/8,172.16.0.0\/12/$nuevaip/" /etc/suricata/suricata.yaml 2> /dev/null
                                if [ $? == 0 ]; then
                                    # La HOME_NET se actualizó
                                    echo "[+] La HOME_NET se actualizó correctamente!!"
                                    sleep 1
                                    # Configuro la interfaz de red a la principal de Ubuntu:
                                    echo "[+] Configurando interfaz de red..."
                                    sleep 3
                                    sudo sed -i 's/interface: eth0/interface: enp0s3/' /etc/suricata/suricata.yaml
                                    sudo sed -i 's/default-rule-path: \/var\/lib\/suricata\/rules/default-rule-path: \/etc\/suricata\/rules/' /etc/suricata/suricata.yaml
                                    # Compruebo si se ha editado bien:
                                    if [ $? == 0 ]; then
                                        # Se editó bien:
                                        echo "[+] La interfaz de red ha sido configurada correctamente!"
                                        sleep 1
                                        # Reinicio el servicio para recargar cambios:
                                        sudo systemctl restart suricata.service 2> /dev/null
                                        echo "[+] Reiniciando el servicio..."
                                        sleep 2
                                        if [ $? == 0 ]; then
                                            # Se actualizó bien:
                                            echo "[+] El servicio se actualizó correctamente!"
                                            sleep 1
                                            echo "[+] Volviendo al menú..."
                                            sleep 1
                                        else
                                            # No se pudo actualizar:
                                            echo "[+] La HOME_NET NO se pudo actualizar..."
                                            sleep 1
                                            echo "[+] Volviendo al menú..."
                                            sleep 1
                                        fi
                                    else
                                        # No se editó bien:
                                        echo "[+] La interfaz de red NO se ha podido actualizar..."
                                        sleep 1
                                        echo "[+] Volviendo al menú..."
                                        sleep 1
                                    fi
                                else
                                    # La HOME_NET NO se pudo actualizar
                                    echo "[+] La HOME_NET NO se pudo actualizar..."
                                    sleep 1
                                    echo "[+] Volviendo al menú..."
                                    sleep 1
                                fi
                            fi
                        ;;

                        # Opción de introducir Red:
                        "red"|"RED")
                            read -p "[-] Introduce la HOME_NET: " nuevared
                            # Compruebo si la RED introducida es válida:
                            validate=$(echo $nuevared | grep -E "\b((([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))/([0-9]{1}|1[0-9]{1}|2[0-9]{1}|3[0-2]{1}))\b" | wc -l)
                            echo "[+] Comprobando validez de la red proporcionada..."
                            sleep 2
                            # RED introducida NO válida:
                            if [ $validate -eq 0 ]; then
                                echo "[+] La Red introducida NO es válida..."
                                sleep 1
                                echo "[+] Volviendo al menú..."
                                sleep 1
                            # RED introducida es válida:
                            else
                                echo "[+] La Red introducida es válida."
                                sleep 1
                                # Sustituyo la HOME_NET por defecto por la nueva:
                                echo "[+] Actualizando la nueva HOME_NET..."
                                sleep 2
                                nuevared=$(echo $nuevared | sed -E "s/\//\\\\\//")
                                sudo sed -i "s/192.168.0.0\/16,10.0.0.0\/8,172.16.0.0\/12/$nuevared/" /etc/suricata/suricata.yaml 2> /dev/null
                                if [ $? == 0 ]; then
                                    # La HOME_NET se actualizó
                                    echo "[+] La HOME_NET se actualizó correctamente!!"
                                    sleep 1
                                    # Configuro la interfaz de red a la principal de Ubuntu:
                                    echo "[+] Configurando interfaz de red..."
                                    sleep 2
                                    sudo sed -i 's/interface: eth0/interface: enp0s3/' /etc/suricata/suricata.yaml
                                    # Compruebo si se ha editado bien:
                                    if [ $? == 0 ]; then
                                        # Se editó bien:
                                        echo "[+] La interfaz de red ha sido configurada correctamente!"
                                        # Reinicio el servicio para recargar cambios:
                                        sudo systemctl restart suricata.service 2> /dev/null
                                        echo "[+] Reiniciando el servicio..."
                                        sleep 2
                                        if [ $? == 0 ]; then
                                            # Se actualizó bien:
                                            echo "[+] El servicio se actualizó correctamente!"
                                            sleep 1
                                            echo "[+] Volviendo al menú..."
                                            sleep 1
                                        else
                                            # No se pudo actualizar:
                                            echo "[+] La HOME_NET NO se pudo actualizar..."
                                            sleep 1
                                            echo "[+] Volviendo al menú..."
                                            sleep 1
                                        fi
                                    else
                                        # No se editó bien:
                                        echo "[+] La interfaz de red NO se ha podido actualizar..."
                                        sleep 1
                                        echo "[+] Volviendo al menú..."
                                        sleep 1
                                    fi
                                else
                                    # La HOME_NET NO se pudo actualizar
                                    echo "[+] La HOME_NET NO se pudo actualizar..."
                                    sleep 1
                                    echo "[+] Volviendo al menú..."
                                    sleep 1
                                fi
                            fi
                        ;;

                        # Opciones NO contempladas
                        *)
                            echo "[+] Opción NO contemplada..."
                            sleep 1
                            echo "[*] Volviendo al menú..."
                            sleep 1
                        ;;
                    esac 
                fi
            ;;
            

            3)
                # Actualizar reglas
                # Añadir fichero con reglas:
                echo "[+] Comprobando si está instalado Suricata..."
                sleep 2
                # Primero compruebo si suricata está instalado o no:
                serviceexist3=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3 )
                serviceexist2=$(systemctl status suricata.service 2> /dev/null | wc -l)
                if [ $serviceexist2 -eq 0 ] || [ $serviceexist3 == "not-found" ]; then
                    # Suricata NO existe.
                    echo "[+] Suricata no parece estar en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Suricata SÍ está en el sistema:
                    echo "[+] Suricata sí está instalado en el sistema."
                    sleep 1
                    echo "[+] Actualizando reglas..."
                    sudo suricata-update > /dev/null 2> /dev/null
                    if [ $? == 0 ]; then
                        # La actualización fue bien:
                        echo "[+] Las reglas se actualizaron correctamente!!"
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    else
                        # La actualización NO se pudo realizar:
                        echo "[+] Las reglas NO se pudieron actualizar..."
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    fi 
                fi
            ;;

            4)
                # Añadir fichero con reglas:
                echo "[+] Comprobando si está instalado Suricata..."
                sleep 2
                # Primero compruebo si suricata está instalado o no:
                serviceexist3=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3 )
                serviceexist2=$(systemctl status suricata.service 2> /dev/null | wc -l)
                if [ $serviceexist2 -eq 0 ] || [ $serviceexist3 == "not-found" ]; then
                    # Suricata NO existe.
                    echo "[+] Suricata no parece estar en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Suricata SÍ está en el sistema:
                    echo "[+] Suricata sí está instalado en el sistema."
                    sleep 1
                    read -p "[-] ¿Qué fichero con reglas quiere añadir al archivo de configuración?: " file 
                    echo "[+] Comprobando si existe el fichero proporcionado..."
                    sleep 2
                    # Compruebo si el fichero existe:
                    if [ -f $file ]; then
                        # El fichero existe:
                        echo "[+] El fichero existe en el sistema."
                        sleep 1
                        # Copio el fichero de dónde esté a /etc/suricata/rules:
                        newfile=$(echo $file | rev | cut -d"/" -f1 | rev)
                        sudo cp $file /etc/suricata/rules/$newfile
                        echo "[+] Moviendo el fichero a la ruta correcta de Suricata..."
                        sleep 2
                        if [ $? == 0 ]; then
                            # Fichero copiado correctamente:
                            echo "[+] El fichero se copió correctamente al repositorio correcto."
                            sleep 1
                            # Modifico suricata.yaml
                            echo "[+] Copiando el archivo de configuración de Suricata para que incluya ese fichero..."
                            sleep 2
                            newfile=$(echo $file | rev | cut -d"/" -f1 | rev)
                            # Agrego línea debajo de suricata.rules:
                            sed -i  "/- suricata.rules/a \ \ - $newfile" /etc/suricata/suricata.yaml 
                            # Compruebo si ha funcionado:
                            if [ $? == 0 ]; then
                                # Si añadió la línea:
                                echo "[+] Se ha añadido el fichero al archivo de configuración!!"
                                sleep 1
                                echo "[+] Reiniciando el servicio..."
                                sleep 2
                                sudo systemctl restart suricata.service
                                sudo suricata-update 2> /dev/null > /dev/null
                                if [ $? == 0 ]; then
                                    # Se reinició bien:
                                    echo "[+] El servicio se reinició correctamente!"
                                    sleep 1
                                    echo "[+] Volviendo al menú..."
                                    sleep 1
                                else
                                    # NO se reinició bien:
                                    echo "[+] El servicio NO se pudo reiniciar correctamente!"
                                    sleep 1
                                    echo "[+] Volviendo al menú..."
                                    sleep 1
                                fi
                            else
                                # No añadió la línea:
                                echo "[+] No se pudo añadir el fichero al archivo de configuración..."
                                sleep 1
                                echo "[+] Volviendo al menú..."
                                sleep 1
                            fi 

                        else
                            # Fichero no se pudo copiar:
                            echo "[+] No se pudo copiar el fichero a la ruta adecuada..."
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1
                        fi 
                    else
                        # El fichero NO existe.
                        echo "[+] El fichero NO parece existir..."
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    fi 
                fi
            ;;

            5)
                # Quitar fichero con reglas:
                echo "[+] Comprobando si está instalado Suricata..."
                sleep 2
                # Primero compruebo si suricata está instalado o no:
                serviceexist3=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3 )
                serviceexist2=$(systemctl status suricata.service 2> /dev/null | wc -l)
                if [ $serviceexist2 -eq 0 ] || [ $serviceexist3 == "not-found" ]; then
                    # Suricata NO existe.
                    echo "[+] Suricata no parece estar en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Suricata SÍ está en el sistema:
                    echo "[+] Suricata sí está instalado en el sistema."
                    sleep 1
                    read -p "[-] ¿Qué fichero de reglas quieres quitar?: " file
                    echo "[+] Comprobando si el fichero existe en los repositorios de Suricata..."
                    sleep 2
                    fileexists=$(find /etc/suricata/rules/ -type f -name $file 2> /dev/null | wc -l)
                    # Compruebo si existe el fichero:
                    if [ $fileexists -eq 0 ]; then
                        # El fichero NO existe:
                        echo "[+] El fichero NO existe en el repositorio..."
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    else
                        # El fichero SI existe:
                        echo "[+] El fichero sí existe en los repositorios..."
                        sleep 1
                        echo "[+] Borrando el fichero de reglas..."
                        sleep 1
                        # Borro el fichero del archivo de configuración de Suricata:
                        sudo sed -i "/- $file/d" /etc/suricata/suricata.yaml
                        sudo rm -rf /etc/suricata/rules/$file
                        if [ $? ==  0 ]; then
                            # Se eliminó la línea:
                            echo "[+] He eliminado el fichero de reglas correctamente!"
                            sleep 1
                            # Reinicio servicio:
                            echo "[+] Reiniciando el servicio..."
                            sleep 2
                            sudo systemctl restart suricata.service
                            sudo suricata-update 2> /dev/null > /dev/null
                            if [ $? == 0 ]; then
                                # Se reinició bien:
                                echo "[+] El servicio se reinició correctamente!"
                                sleep 1
                                echo "[+] Volviendo al menú..."
                                sleep 1
                            else
                                # NO se reinició bien:
                                echo "[+] El servicio NO se pudo reiniciar correctamente!"
                                sleep 1
                                echo "[+] Volviendo al menú..."
                                sleep 1
                            fi
                        else
                            # No se pudo eliminar
                            echo "[+] No he podido eliminar el fichero de reglas..."
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1
                        fi 
                    fi
                fi 
            ;;

            6)
                # Ver el estado de Suricata como servicio
                echo "[+] Mostrando estado de Suricata..."
                sleep 1
                res=$(systemctl status suricata.service 2> /dev/null | wc -l)
                res1=$(systemctl status suricata.service 2>/dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3)
                if [ $res -eq 0 ] || [ $res1 == "not-found" ]; then
                    # Suricata no está instalado en el sistema:
                    echo "[+] Suricata no parece estar instalado en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Suricata sí está instalado en els sistema:
                    echo ""
                    systemctl status suricata.service
                    echo ""
                    echo "[+] Volviendo al menú..."
                    sleep 1
                fi 
            ;;

            7)
                # Levantar servicio
                echo "[+] Comprobando si está instalado Suricata..."
                sleep 2
                # Primero compruebo si suricata está instalado o no:
                serviceexist3=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3 )
                serviceexist2=$(systemctl status suricata.service 2> /dev/null | wc -l)
                if [ $serviceexist2 -eq 0 ] || [ $serviceexist3 == "not-found" ]; then
                    # Suricata NO existe.
                    echo "[+] Suricata no parece estar en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Suricata SÍ está en el sistema:
                    echo "[+] Suricata sí está instalado en el sistema."
                    sleep 1
                    echo "[+] Comprobando estado de Suricata..."
                    sleep 2
                    estado=$(systemctl status suricata.service | head -3 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3)
                    # Compruebo si Suricata está ya levantado:
                    if [ $estado == "inactive" ]; then
                        echo "[+] Suricata está inactivo."
                        sleep 1
                        # Está inactivo Suricata y lo levanto:
                        echo "[+] Levantando servicio..."
                        sleep 1
                        systemctl start suricata.service
                        if [ $? == 0 ]; then
                            # Se levanta bien:
                            echo "[+] Suricata se ha levantado correctamente!"
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1
                        else
                            # Fallo al levantar el servicio:
                            echo "[+] Suricata NO se ha podido levantar!"
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1
                        fi 
                    else
                        echo "[+] Suricata ya está levantado."
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    fi
                fi
            ;;

            8)
                # Parar Servicio:
                echo "[+] Comprobando si Suricata está en el sistema..."
                sleep 2
                # Comprobar si Suricata está instalado en el sistema:
                serviceexist3=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3 )
                serviceexist2=$(systemctl status suricata.service 2> /dev/null | wc -l)
                if [ $serviceexist2 -eq 0 ] || [ $serviceexist3 == "not-found" ]; then
                    # No instalado:
                    echo "[+] Suricata no parece estar en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Sí instalado:
                    echo "[+] Suricata sí está instalado en el sistema."
                    sleep 1
                    echo "[+] Comprobando estado de Suricata..."
                    sleep 2
                    # Comprobar estado de Suricata
                    estado=$(systemctl status suricata.service | head -3 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3)
                    if [ $estado != "inactive" ]; then
                        echo "[+] Suricata parece estar activo..."
                        sleep 1
                        # Está activo Suricata y lo paro:
                        echo "[+] Parando servicio..."
                        sleep 1
                        systemctl stop suricata.service
                        if [ $? == 0 ]; then
                            # Se paró bien:
                            echo "[+] Suricata se ha parado correctamente!"
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1
                        else
                            # Fallo al levantar el servicio:
                            echo "[+] Suricata NO se ha podido parar!"
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1
                        fi 
                    else
                        echo "[+] Suricata ya está parado."
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    fi
                fi 
            ;;

            9)
                # Reiniciar el Servicio:
                echo "[+] Comprobando si Suricata está en el sistema..."
                sleep 2
                # Comprobar si Suricata está instalado en el sistema:
                serviceexist3=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3 )
                serviceexist2=$(systemctl status suricata.service 2> /dev/null | wc -l)
                if [ $serviceexist2 -eq 0 ] || [ $serviceexist3 == "not-found" ]; then
                    # No instalado:
                    echo "[+] Suricata no parece estar en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Sí instalado:
                    echo "[+] Suricata sí está instalado en el sistema."
                    sleep 1
                    echo "[+] Reiniciando el servicio..."
                    # Reinicio el sistema
                    sleep 2
                    sudo systemctl restart suricata.service
                    if [ $? == 0 ]; then
                        # Se reinició bien:
                        echo "[+] El servicio se reinició correctamente!"
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    else
                        # NO se reinició bien:
                        echo "[+] El servicio NO se pudo reiniciar correctamente!"
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    fi 
                fi
            ;;

            10)
                # Devolver X número de logs:
                read -p "¿Cuántos logs quieres ver?: " cantidad
                echo ""
                echo "[+] Comprobando si Suricata está en el sistema..."
                sleep 2
                # Comprobar si Suricata está instalado en el sistema:
                serviceexist3=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3 )
                serviceexist2=$(systemctl status suricata.service 2> /dev/null | wc -l)
                if [ $serviceexist2 -eq 0 ] || [ $serviceexist3 == "not-found" ]; then
                    # No instalado:
                    echo "[+] Suricata no parece estar en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Sí instalado:
                    echo "[+] Suricata sí está instalado en el sistema."
                    sleep 1
                    echo "[+] Cargando logs..."
                    sleep 2
                    # Compruebo si fast.log tiene contenido:
                    contenido=$(cat /var/log/suricata/fast.log | wc -l)
                    if [ $contenido -eq 0 ]; then
                        # NO hay logs:
                        echo "[+] No hay ningún log registrado..."
                        sleep 1
                        echo "[+] Volviendo al menú..."
                    else
                        # Si hay logs:
                        # Compruebo si hay más de $cantidad logs:
                        if [ $contenido -gt $cantidad ]; then
                            echo "[+] Te muestro los últimos $cantidad logs:"
                            tail -"$cantidad" /var/log/suricata/fast.log
                            echo ""
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1
                        else
                            echo "[+] No hay tantos logs. Te muestro los $contenido logs que he encontrado:"
                            tail -"$cantidad" /var/log/suricata/fast.log
                            echo ""
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1 
                        fi 
                    fi 
                fi
            ;;

            11)
                # Restablecer backup:
                echo "[+] Comprobando si Suricata está en el sistema..."
                sleep 2
                # Comprobar si Suricata está instalado en el sistema:
                serviceexist3=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3 )
                serviceexist2=$(systemctl status suricata.service 2> /dev/null | wc -l)
                if [ $serviceexist2 -eq 0 ] || [ $serviceexist3 == "not-found" ]; then
                    # No instalado:
                    echo "[+] Suricata no parece estar en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Sí instalado:
                    echo "[+] Suricata sí está instalado en el sistema."
                    sleep 1
                    # A hacer back up
                    echo "[+] Comprobando si existe el fichero back up..."
                    sleep 2
                    # Compruebo si existe:
                    backupexiste=$(find /etc/suricata/ -type f -name backup_suricata.yaml 2> /dev/null | wc -l)
                    if [ $backupexiste -ne 0 ]; then
                        # Si existe back up:
                        echo "[+] He encontrado un back up!"
                        sleep 1
                        echo "[+] Restaurando back up..."
                        sleep 2
                        sudo rm -rf /etc/suricata/suricata.yaml
                        sudo cp /etc/suricata/backup_suricata.yaml /etc/suricata/suricata.yaml
                        # Compruebo si se realizó bien:
                        if [ $? == 0 ]; then
                            echo "[+] El backup se restauró correctamente!!"
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1
                        else
                            echo "[+] El backup NO se pudo restaurar..."
                            sleep 1
                            echo "[+] Volviendo al menú..."
                            sleep 1
                        fi 
                    else
                        # No existe back up:
                        echo "[+] No existe ningún back up..."
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    fi
                fi
            ;;

            12)
                # Desinstalar Suricata del sistema
                # Compruebo si Suricata está instalado
                echo "[+] Comprobando si Suricata está instalado en el sistema..."
                sleep 2
                serviceexist1=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3)
                serviceexist=$(systemctl status suricata.service 2> /dev/null | wc -l)
                if [ $serviceexist -eq 0 ] || [ $serviceexist1 == "not-found" ]; then
                    # Suricata NO existe.
                    echo "[+] Suricata NO está instalado en el sistema..."
                    sleep 1
                    echo "[+] Volviendo al menú..."
                    sleep 1
                else
                    # Suricata SÍ existe.
                    echo "[+] Suricata está instalado."
                    sleep 1
                    # Borrar servicio:
                    echo "[+] Desinstalando Suricata..."
                    sleep 1
                    sudo apt remove --purge suricata -y > /dev/null 2> /dev/null
                    sudo rm -rf /etc/suricata 2> /dev/null
                    serviceexist3=$(systemctl status suricata.service 2> /dev/null | head -2 | tail -1 | sed -E "s/(\s|\t){1,}/;/g" | cut -d";" -f3 )
                    serviceexist2=$(systemctl status suricata.service 2> /dev/null | wc -l)
                    if [ $serviceexist2 -eq 0 ] || [ $serviceexist3 == "not-found" ]; then
                        # Suricata se borró
                        echo "[+] Suricata se borró del sistema correctamente."
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    else
                        # Suricata NO se pudo borrar
                        echo "[+] Hubo un problema en la desinstalación..."
                        sleep 1
                        echo "[+] Volviendo al menú..."
                        sleep 1
                    fi
                fi 
            ;;

            13)
                # Cierro el Programa:
                echo "[+] Cerrando el programa..."
                sleep 1
            ;;

            *)
                # Opción no contemplada en el CASE
                echo "[+] Opción NO contemplada..."
                sleep 1
            ;;
        esac
        echo ""; echo ""
    done
fi
