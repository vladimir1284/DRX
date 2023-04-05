# Vitis

## Instalación
Esta versión da el siguiente error [000034848 - 2022.2 Vitis: ERROR : Can't read "map": no such variable when trying to launch application on my target
](https://support.xilinx.com/s/article/000034848?language=en_US) que se resuelve siguiendo las instrucciones del fichero [xsct_2022_2_patch.zip](xsct_2022_2_patch.zip)

**Método 1:**
1. NAvegar hasta la ruta del directorio $XILINX_VITIS (Vitis/2022.2/)
2. Extraer el contenido del archivo [xsct_2022_2_patch.zip](xsct_2022_2_patch.zip) sobrescribiendo los archivos de la instalación original de Vitis.

## Corriendo el primero proyecto

Lo primero es tener el [linux corriendo en la Zedboard](../Petalinux/README.md#corriendo-el-linux-en-la-placa).

Luego creamos nuestra plataforma en Vitis y el **Hello World** siguiendo el video 
[Building a Linux Application in the Vitis IDE](https://www.xilinx.com/video/software/building-linux-application-vitis.html)