# JetsonTX1_KernelBuild

Script to cross-compile the linux kernel out of the Nvidia sources.

The script is based on the script from Jetsonhacks https://github.com/jetsonhacks/buildJetsonTX1Kernel, but is a more simply to use.
Just clone the repo and run the script.

The script does
 - download a linaro compiler for building
 - downloading the kernel sources
 - building the kernel sources and modules
 - packing all the things to the deploy directory
 
The output is a "deploy" directory with kernel modules, the Image and the zImage. 
Placing the Image and zImage in the /boot directory on the TX1 and unpacking the kernel_modules.tar on the / directory. Restart and be happy!

## Installation

After the execution you will have a deploy folder in your local directory. In this folder there is the file `deploy.tar`. Copy this to your TX1 and extract it with `tar -xf deploy.tar`. Do now the following

    sudo cp Image /boot/
    sudo cp zImage /boot/
    sudo tar -xf kernel_modules.tar -C /
    
Now you've installed the new kernel and all kernel modules to the root folder. 
If the kernel name of your old kernel and the kernel name of the kernel is the same, the old kernel will be deleted! So be aware of this. If necessary change the kernel name in the main makefile of the kernel!
