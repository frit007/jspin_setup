# Install jSpin on windows with WSL installed
Running jSpin through WSL will be slower than just running everything through windows. However the installation is hopefully slightly easier.

# Requirements
Please make sure you have WSL installed(https://learn.microsoft.com/en-us/windows/wsl/install)
You need WSL version 2 if you want to run the jSpin through WSL. The scripts assume you are using Ubuntu.

# Two options
You have the option to run the application. Either run jSpin through windows or run it through WSL. Each option comes with its own drawbacks.

# (Recommended) Windows jSpin 
Copy spin_mix_setup.sh to a folder that does not have any spaces in its name. And run
```
wsl ./spin_mix_setup.sh
```
Click the bat script to start the jSpin

## Windows jSpin known drawbacks
- You must place your programs in a folder that contains the wsl-pan.bat script. We have created the folder jspin/programs for this purpose.
- We have to handle paths in a special way in bat scripts, since otherwise the programs run it WSL won't be able to handle windows paths. If something breaks look at the jspin/wsl-bat.exe script for inspiration how it could be handled
- You cannot move the folder after it has been generated because we have to reference scripts using absolute paths

# WSL jSpin
Copy spin_setup.sh to a folder that does not have any spaces in its name. And run
```
wsl ./spin_setup.sh
```
Click the bat script to start the jSpin

## WSL jSpin known drawbacks
- Interactive does not work
- UI bugs, on one computer if you minimize the window you cannot open it again.
