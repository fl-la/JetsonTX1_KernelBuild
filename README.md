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
