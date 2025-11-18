# countdowntimer
This is a Powershell app that runs on Windows without installation

****************************************************
You may copy the entire folder (Counter) to use.

*********************************************************
```text
      /\_/\
     ( >.< )   Meow!
      > ^ <
    ~~~~~~~~~~~
  ███████╗  █████╗  ███╗   ██╗ ██╗ ███████╗ ███████╗ ████████╗ ██████╗
  ╚══███╔╝ ██╔══██╗ ████╗  ██║ ██║ ██╔════╝ ██╔════╝ ╚══██╔══╝ ██╔══██╗
    ███╔╝  ███████║ ██╔██╗ ██║ ██║ █████╗   ███████╗    ██║    ██████╔╝
   ███╔╝   ██╔══██║ ██║╚██╗██║ ██║ ██╔══╝   ╚════██║    ██║    ██╔══╝
  ███████╗ ██║  ██║ ██║ ╚████║ ██║ ███████╗ ███████║    ██║    ██║
  ╚══════╝ ╚═╝  ╚═╝ ╚═╝  ╚═══╝ ╚═╝ ╚══════╝ ╚══════╝    ╚═╝    ╚═╝

*********************************************************

  This countdown app allowing the user to create a countdown with minimum fuss - no installation required.

  It runs on .\counter\

  The files are

  config.txt
  faveicon.ico
  countdown.ps1 ===> main program

  you may start with a batch file with the following command

  powershell -f ".\countdown.ps1"

.SYNOPSIS
A reusable, resizable countdown timer with a stable, hideable interface.

.DESCRIPTION
This script launches an input form to set a countdown. The countdown window
features a stable horizontal layout, hideable side panels, and an auto-scaling font.

.NOTES
To use:
1. Save this code as a PowerShell script file (e.g., countdown_timer.ps1).
2. (Optional) Create a 'config.txt' file for window appearance.
3. (Optional) Place a 'default.wav' file in the same folder for a custom sound.
4. Run the script: .\countdown_timer.ps1
#>
  
