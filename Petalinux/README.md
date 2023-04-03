# Petalinux

## Instalación

La instalación de petalinux es expedita para la versión 2022.2 sobre ubuntu 20.04 
siguiendo la guía [Getting Started With PetaLinux](https://www.instructables.com/Getting-Started-With-PetaLinux/) 
de [NAEastland](https://www.instructables.com/member/NAEastland/).

## Creando un proyecto

Seguimos las instrucciones para [crear un proyecto usando plantilla](https://docs.xilinx.com/r/en-US/ug1144-petalinux-tools-reference-guide/Creating-an-Empty-Project-from-a-Template).

Luego importamos la configuración de hardware exportada en Vivado (fichero .xsa) en el proyecto siguiendo los pasos de la guía 
[UG1144](https://docs.xilinx.com/r/en-US/ug1144-petalinux-tools-reference-guide/Importing-Hardware-Configuration).

## Corriendo la imagen con QEMU

Usamos el siguiente comando:
`petalinux-boot --qemu --kernel images/linux/zImage`

El usuario es **petalinux** y nos crea automáticamente una contraseña.

Para detener la ejecución del emulador usamos `ctrl+a x`



