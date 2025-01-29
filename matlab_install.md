# Installing Matlab

## Get MATLAB Installer

1. Go to the [Matlab downloads](https://www.mathworks.com/downloads/) and download the zip file for the version you want to install
2. Make directory ```mkdir ~/Downloads/matlab``` and move the zip file to this directory
3. Unzip the file ```unzip ~/Downloads/matlab/matlab_*.zip -d ~/Downloads/matlab```
4. Create installation directory ```sudo mkdir /opt/MATLAB && sudo chown $USER:$USER /opt/MATLAB```

## Install MATLAB

1. Run installer, ```sudo ./install```
2. Select installation location ```/opt/MATLAB/R2023b```
3. Select products

    - MATLAB
    - Simulink
    - Communications Toolbox
    - Computer Vision Toolbox
    - Control System Toolbox
    - Curve Fitting Toolbox
    - Database Toolbox
    - DSP System Toolbox
    - Embedded Coder
    - Image Acquisition Toolbox
    - Image Processing Toolbox
    - MATLAB Coder
    - MATLAB Compiler
    - MATLAB Compiler SDK
    - Optimization Toolbox
    - Robotics System Toolbox
    - Robust Control Toolbox
    - Signal Processing Toolbox
    - Simulink Coder
    - Simulink Compiler
    - Simulink Control Design
    - Stateflow
    - Symbolic Math Toolbox
    - System Identification Toolbox
    - WLAN Toolbox

4. Create simlink to matlab ```sudo ln -s /opt/MATLAB/R2023b/bin/matlab /usr/local/bin/matlab```
5. Remove simlink ```unlink /opt/MATLAB/R2023b/sys/os/glnxa64/libstdc++.so.6```
6. Create simlink ```ln -s /lib64/libstdc++.so.6 -d /opt/MATLAB/R2023b/sys/os/glnxa64```
7. Change Add-Ons install directory ```/home/me/.MATLAB-Add-Ons```
8. Update Desktop files in ```$HOME/.local/share/applications```
9. Set software rendering ```opengl('save', 'software')```

```ini
[Desktop Entry]
Type=Application
Terminal=false
MimeType=text/x-matlab
Exec=/usr/local/bin/matlab -desktop -nosplash
Name=MATLAB
Icon=matlab
Categories=Development;Math;Science
Comment=Scientific computing environment
StartupNotify=true
```

## Install Compilers

1. Install compatible gcc compiler [compatibility list](https://nl.mathworks.com/support/requirements/supported-compilers-linux.html).
    - ```paru -S gcc11```
2. Install compatible Java JDK [compatibility list](https://nl.mathworks.com/support/requirements/language-interfaces.html).
    - ```sudo pacman -S jdk11-openjdk```
