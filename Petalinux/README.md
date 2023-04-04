# Petalinux

## Instalación

La instalación de petalinux es expedita para la versión 2022.2 sobre ubuntu 20.04 
siguiendo la guía [Getting Started With PetaLinux](https://www.instructables.com/Getting-Started-With-PetaLinux/) 
de [NAEastland](https://www.instructables.com/member/NAEastland/).

## Creando un proyecto

Seguimos las instrucciones para [crear un proyecto usando plantilla](https://docs.xilinx.com/r/en-US/ug1144-petalinux-tools-reference-guide/Creating-an-Empty-Project-from-a-Template).

Luego importamos la configuración de hardware exportada en Vivado (fichero .xsa) en el proyecto siguiendo los pasos de la guía 
[UG1144](https://docs.xilinx.com/r/en-US/ug1144-petalinux-tools-reference-guide/Importing-Hardware-Configuration).

## Creando la imagen

Lo primero es construir la imagen con el comando `petalinux-build`.

Luego empaquetamos con el siguiente comando para obtener el fichero `BOOT.BIN`.
```
cd images/linux
petalinux-package --boot --fsbl zynq_fsbl.elf --u-boot --fpga system.bit --force
```
Todo bien explicado en el artículo [GPIO and Petalinux - Part 3 (Go, UIO, Go!)](https://www.linkedin.com/pulse/gpio-petalinux-part-3-go-uio-roy-messinger/?trk=public_profile_article_view) de [Roy Messinger](https://www.linkedin.com/in/roy-messinger/?lipi=urn%3Ali%3Apage%3Ad_flagship3_pulse_read%3B25TUdg%2BURyyjyPH%2BV0W%2BfA%3D%3D).

## Corriendo la imagen con QEMU

Usamos el siguiente comando:
`petalinux-boot --qemu --kernel images/linux/zImage`

El usuario es **petalinux** y nos crea automáticamente una contraseña.

Para detener la ejecución del emulador usamos `ctrl+a x`


## Corriendo el linux en la placa

Se crean las 2 particiones en la SD:

1. FAT32, Label: BOOT, size: 1GB (espacio libre 4MB al inicio)
2. EXT4, Label: rootfs, size: > 3GB 

Se copian los siguientes ficheros en la partición FAT32:
- BOOT.BIN
- image.ub
- boot.scr

Se extrae el contenido de `rootfs.tar.gz` en la partición EXT4.

Se conecta un terminal serial configurado a 115200 al puerto UART de la placa.

Se configura el **Boot Mode** para **SD Memory Card** como se indica en la siguiente imagen.
![Utils UML diagram](https://raw.githubusercontent.com/vladimir1284/DRX/master/Petalinux/img/boot_mode.png)

Por último se inserta la tarjeta en la placa y se conecta la energía.

