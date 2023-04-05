# Vitis

## Instalación
Esta versión da el siguiente error [000034848 - 2022.2 Vitis: ERROR : Can't read "map": no such variable when trying to launch application on my target
](https://support.xilinx.com/s/article/000034848?language=en_US) que se resuelve siguiendo las instrucciones del fichero [xsct_2022_2_patch.zip](xsct_2022_2_patch.zip)

**Método 1:**
1. NAvegar hasta la ruta del directorio $XILINX_VITIS (Vitis/2022.2/)
2. Extraer el contenido del archivo [xsct_2022_2_patch.zip](xsct_2022_2_patch.zip) sobrescribiendo los archivos de la instalación original de Vitis.

## Corriendo el primer proyecto

Lo primero es tener el [linux corriendo en la Zedboard](../Petalinux/README.md#corriendo-el-linux-en-la-placa).

Luego creamos nuestra plataforma en Vitis y el **Hello World** siguiendo el video 
[Building a Linux Application in the Vitis IDE](https://www.xilinx.com/video/software/building-linux-application-vitis.html)

## Encendiendo un led desde la línea de comando

Es solo seguir el tutorial [https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841846/AXI+GPIO](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841846/AXI+GPIO).

Los comandos son:

```
sudo su
ls /sys/class/gpio
echo 1016 > /sys/class/gpio/export
ls /sys/class/gpio
echo out > /sys/class/gpio/gpio1016/direction
echo 1 > /sys/class/gpio/gpio1016/value
echo 0 > /sys/class/gpio/gpio1016/value
```