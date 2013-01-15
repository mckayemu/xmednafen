X. M.ulti E.mulator D.iN.A.mic F.ederation E.N.gine : X.M.E.D.N.A.F.E.N. 


Its a non-necessary-configurable frontend and emulator manager 
for launch, play and use all videogame console emulators.

This configures all emulators for u and lauch.

Configuration are done automatic, for own setting u must 
use command line or edit the (future) config file.
U must have a debian valid or Venenux system linux.

FEATURES

* autodetection of binary version, mednafen 0.8.X an 0.9.X
* autodetecton of OpenGL support or SDL rasterizer on GPL only system
* autodetection of environment (KDE or LXDE of XFCE only) must depend of kdebin or zenity, if not intalled launch console ncurses. (still experimental)
* autoloading of automatic preconfigure settings at 2x of screen fo 16bit systems and 3x for 8bit and potabl systems (WIP)


#STRUCTURE

![image](https://github.com/mckayemu/xmednafen/blob/master/docs/xmednafen-flujo-1.png?raw=true)


PLANED

* handle others emulators, currently mupen64plus due are now GPL 100% and xmess wrapper fake
* frontend for own personal configuration
* frontend for manage rows and manage the save states (only personals)

This project will integrate the older emuexec and kemuexec for kde3 and lxde.

For historycally issue, see the README.debin file.

This launcher will supresed and recreate in GPL issue th mckaysuite complety.

REQUERIMENTS

* for kde3/Razorqt users kdedialog (WIP)
* for LXDE/XFCE zenity
* bash >= 3.4
* mednafen >= 8.X
* a valid debin derived distribution are only oficially supported

NOTES: winbuntu users please dont right!
