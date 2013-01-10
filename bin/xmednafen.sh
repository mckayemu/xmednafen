#!/bin/sh
# -*- coding: utf-8 -*-
#*************************************************************************
#
#   Emulation VENENUX-xmednafenv suit by PICCORO
#
#   massenkoh edition, template launcher for EMULATOR
#
#   $Revision: 3.0 $ initial release, sebb help to detect x, pty, console 2009/01/20 17:02:48 -0430
#   $Revision: 3.1 $ improbe detection of X server 2010/01/20 17:02:48 -0430
#   $Revision: 3.2 $ change for use on live cd, short 2010/01/20 17:02:48 -0430
#   $Revision: 4.0 $ redesign, use once script and handle all commands by name program, for now mednafen
#   $Revision: 4.1 $ with redesign, use extension file for determine emulator 2012/02/12 22:50:45 -0430
#   $Revision: 4.2 $ autodetection of emulator command to use based on extension 2012/03/02 22:50:45 -0430
#
#   last change: $Author: PICCORO $ $Date: 2012/02/12 22:50:45 $
#
#*************************************************************************
# =============================== LICENSE ===============================
# VENENUX&MASSENKOH's  launch script based on emulaucher utilities utilities
# written by PICCORO Lenz McKAY <mckaygerhard@gmail.com> for Debian/VENENUX based systems
# release under triple license CC-BY-NSA/ZLIB and GPL license, resume on that:
#	Important notes about licenses:
# * U must not remove any of all header comments and authors,
#   so u must cite this and refletcs.
# ->Tu no debes remover todo el encabezado comentado ni los
#   autores, entonces debes citarlos si lo modificas aqui o en derivados productos
# * The origin of this software must not be misrepresented; you must not
#   claim that you wrote the original software. If you use this software
#   in a product, an acknowledgment in the product documentation would be
#   appreciated due altered source versions must be plainly marked as such,
#   and must not be misrepresented as being the original software.
# * This notice/license may not be removed or altered from any source distribution.


# this script could be bad programed, u can improved
# current state:
# working:
# * detect X or console, if ROMFILEARG its given, launch directly
# * detect DESKTOP, and lauch a proper lib based depend dialog
# * if console detect, choose beetwen dialog or whiptail
# * MAYOR IMPROVE over roms selection, extrac extension and use for set system emulation
# * offers row browser file dialog chooser
# *
# TODO:
# * PRIORITARY: refuse autoloading savestates not stored on trusted host, i mean not of installation computer
# * PRIORITARY: Multiple-CD Games , this only can be done by loading a m3u file cd list, must be
# * ...generated automaticaly the m3u file and laoding first disk
# * support for options and parse options
# * added support for dialog, gtkdialog and gdialog, and remove zenity depend
# * support for autodetect emulators by disponibility in system
# * i18n support
# * support for forcing emulator by extension, for improve mednafen

######## PART 1 ######### init values toma de variables de entorno basicas
MSGEMUCONSOLE="VENENUX emulators launchers; launcher usage is: \"launchername options ... option filename.ext\""
DESKTOP=$(echo $DESKTOP_SESSION)	# detectando el tipo de escritorio
DISPLAY=$(echo $DISPLAY)		# detectando si hay X o pts o es terminal serial tty pura
EMULATOR=mednafen		# se manejaran varios emuladores, inicialmente por defecto el mas portable
SCALESCR=2			# scalado a 2x, idea: antes de jugar con xrandr cambiar para mejor rendimiento
SPECIAL=2xsai			# este escalado esta presente en todos los emuladores, pero prefiero nn2x mejor rendimiento
INVOKENAME=$0			# programa de invocacion, por este y la extension sabremos que emulador usar

######## PART 2 #################### establecimiento de las variables segun lo inicial

for ARGUMENTS in "$@"; do
	paramarg=${ARGUMENTS%=*}
	valuearg=${ARGUMENTS#*=}
	patharg=${ARGUMENTS%/*}
	filearg=${ARGUMENTS##*/}
	namearg=${filearg%%.*}
	extarg=${filearg#*.}
	case $paramarg in
		"--help")	echo "${MSGEMUCONSOLE}\n USE:\n  $INVOKENAME <ROMFILEARG.ext>"; exit 0 ;;
		"--gui")	LAUNCHGUI="SI" ;;
	esac
		#	All the work and documentat5ion are based on fceu, hugo and mednafen work, specaly struct MDFNGI Emulated<module> and KnowExtensions complex types
done

if  [ "x$1" = "x" ] || [ "x$1" = "x--gui" ]  ; then
	ROMFILEARG="" # no se paso parametros, es decir nisiquiera un parametro (el minimo debe ser el rom)
	LAUNCHGUI="SI" # si no pasaron parametro, se lanza la gui, porque seguro se lanzo desde menu
else
	ROMFILEARG="${patharg}/${filearg}"  # si pasaron algun parametro, ya se extrajo arriba en el bucle
fi

######## PART 3 #################### deteccion de soporte grafico (X: xorg xfree86) o consola real
# si hay una consola real no importa lo anterior, es un programa para X y se lanza una advertencia

if  [ "x$DISPLAY" = "x" ]  ; then
	XMESSAGE=whiptail
	OPTSINDEX=0
			OPTSTYPEINFO=--msgbox
			OPTSTEXT="25 45"
			OPTSFILEDIALOG=
			OPTSFILEFILTER=
else

# por ahora solo tenemos  kdialog para qt4/kde y zenity para qt4/gtk, espero salga algo para qt4 sin kde
versiongtk=$(zenity --help-file-selection | grep file-filter)
versionkde=$(kdialog --help-kde | grep filter)

	if [ "x$DESKTOP" = "xKDE" ] || [ "$DESKTOP" = "KDE4" ] ; then
		XMESSAGE=kdialog
		OPTSINDEX=1
			OPTSTYPEINFO='--msgbox'
			OPTSTEXT=
			OPTSFILEDIALOG='--getopenfilename /var/emulation/roms '
			OPTSFILEFILTER=
			OPTSTITLE='--caption KMednafen'
			OPTSICON='--icon /usr/share/pixmaps/mednafen-icon.xpm'
	else
		XMESSAGE=zenity
		OPTSINDEX=2
			OPTSTYPEINFO='--info'
			OPTSTEXT='--text'
			OPTSFILEDIALOG='--file-selection'
			if [ "x$versiongtk" = "x" ] ; then 		# if too older zenity version no filter of rom only files
			OPTSFILEFILTER=
			else
			OPTSFILEFILTER='--file-filter='
			fi
			OPTSTITLE='--title=GMednafen'
			OPTSICON='--window-icon=/usr/share/pixmaps/mednafen-icon.xpm'
	fi
fi

# TODO i18n detection, future version support include files for dialogs
MSG_CONSOLE_INFO='Running xmednafen '
msg_welcome_common='\nSi quieres saber mas de emuladores y como poder jugarlos mejor, consula al guru ZERO. de ti depende encontrarlo.'
msg_welcome_nox='Esto es un emulador de consola de videojuego, y al parecer se ejecuto en una consola serial pura. \n\nPara jugar debes usar este programa con graficos X o en cosola grafica y siempre contra un archivo (rom) asi:\n - comando juego.rom - \n\nLos controles son w(arriba), s(abajo), a(derecha), d(izquierda), y los botones en g,h,j,y, opcionalmente tambien t,u. '
msg_welcome_noargs='Esto es '$EMULATOR', emulador de consola de videojuego. \n\nLos controles son w(arriba), s(abajo), a(derecha), d(izquierda), y los botones en g,h,j,y, opcionalmente tambien t,u. \n\nPara jugar debes usar este programa siempre contra un archivo (rom).. a continuacion procede a escoger uno'
msg_finalize='..gracias por usar Venenux y sus emuladores.'

######## PART 4 #################### suficiente info ya, ahora configuremos o ofescamos cargar un rom
# si hay una consola real no importa lo anterior, es un programa para X y se lanza una advertencia

# if no X are detected show warining info and exit..
if  [ "x$DISPLAY" = "x" ]  ; then
	$XMESSAGE $OPTSICON $OPTSTITLE $OPTSTYPEINFO "${msg_welcome_nox} ${msg_welcome_common}" $OPTSTEXT
	exit 1
else
	# else if X are running detec console type
	if [ "x${ROMFILEARG}" = "x" ] ; then
		if [ "x$LAUNCHGUI" = "xSI" ] ; then
			$XMESSAGE $OPTSICON $OPTSTITLE $OPTSTYPEINFO $OPTSTEXT "${msg_welcome_noargs} ${msg_welcome_common}"
			cd /var/emulation/roms
			ROMFILEARG=$($XMESSAGE $OPTSICON $OPTSTITLE $OPTSFILEDIALOG $OPTSFILEFILTER*.pce\ *.tgx\ *.ngc\ *.ngp\ *.nes\ *.nez\ *.fds\ *.sms\ *.sgg\ *.gg\ *.gb\ *.gbc\ *.sgb\ *.cgb\ *.gba\ *.agb\ *.ws\ *.wsc\ *.sfc\ *.swc\ *.smc\ *.smd\ *.md\ *.psx )
			cd
		fi
	fi
fi

# ROM BASED CONFIGURATION, a este punto tenemos el rom sea por el dialogo o por parametro
# this bucle must be joined/rdone with arguments bucle, for optimun programing
# este bucle debe ser juntado/rehecho con el bucle de argumentos, para programacion optima
# optimun bucle, if no rom choosen, only one for bucle its same as fi/else decision shell!!!! JIJIJI
for testrom in "${ROMFILEARG}"; do
	patharg=${ROMFILEARG%/*}
	filearg=${ROMFILEARG##*/}
	namearg=${filearg%%.*}
	extarg=${filearg#*.}
	case $extarg in
		# res 224x144 - cpu 8bit - stereo 11000 - handled - multibutton - multiaxys
		"ws") 	
			echo "Handled Wonder Swan			WS: WonderSwan Rom Image format"; 
			SYSTEMEMU="wswan"
			;;
		"wsc") 	
			echo "Handled Wonder Swan			WS: WonderSwan Color Rom format";
			SYSTEMEMU="wswan";;
		"wsr") 	
			echo "Handled Wonder Swan			WS: WonderSwan Riped music format"; 
			SYSTEMEMU="wswan"; 
			SYTEMRIPMUSIC="1";;
		# res 160x152 - cpu 8bit - stereo 22050 - handled
		"ngp") 		echo "Neo Geo Pocket System			NGP: NeoGeo Pocket Rom format"; SYSTEMEMU="ngp";;
		"ngc") 		echo "Neo Geo Pocket Color System	NGP: NeoGeo Pocket Color Rom format"; SYSTEMEMU="ngp";;
		# res 160x102 - cpu 4bit - mono - handled - bios need
		"lnx") 			echo "Handled Atary LYNX			LNX: Atary Lynx Rom image format"; SYSTEMEMU="lynx";;
		# res 160x144 - cpu 8bit - stereo 10000 - handled
		"gg"|"sgg") 	echo "SEGA Game Gear		SGG: Game Gear ROM image"; SYSTEMEMU="gg";;
		# res 256x240 - cpu 8bit - stereo 11000
		"sms") 			echo "SEGA Master System		SMS: SEGA Mark III rom format"; SYSTEMEMU="sms";;
		# res 288/320 x 224/240 Gens/MD - cpu 16bit - stereo 22050 - multibutton - multigame disk
		"sg"|"sgr") 	echo "SEGA Genesys 16bit (3 button)		SG: Super Magic drive format"; SYSTEMEMU="md";;
		"md"|"smd") 	echo "SEGA Mega Drive (6 button)		SMD: Multi Game Doctor format"; SYSTEMEMU="md";;
		# res 256x240 - cpu 8bit - mono 11000
		"nes"|"nez") 	echo "Nintendo Entertaiment System 		NES: iNES format"; SYSTEMEMU="nes";;
		"fds") 			echo "Family computer Disk System 		NES: Famicom Disk System image format"; SYSTEMEMU="nes";;
		"nsf") 			echo "Family computer Disk System 		NES: Nintendo Sound File format"; SYSTEMEMU="nes"; SYTEMRIPMUSIC="1";;
		"nsfe") 		echo "Family computer Disk System 		NES: Nintendo Sound File Extended format"; SYSTEMEMU="nes"; SYTEMRIPMUSIC="1";;
		# res 256x240 - cpu 16bit - stereo 22050
		"smc") 			echo "Super Famicom Computer System	 	SNES: Super Magicom Cardridge format"; SYSTEMEMU="snes";;
		"sfc"|"fig")	echo "Super Family Computer System		SNES: Super Family Cartridge format"; SYSTEMEMU="snes";;
		"swc") 			echo "Super Nintendo Entertaimen System		SNES: Super Wilcard Cardridge format"; SYSTEMEMU="snes";;
		"st") 			echo "Super Nintendo Entertaimen System		SNES: Sufami Turbo Cardridge format"; SYSTEMEMU="snes";;
		# res 160x144 - cpu 4bit - mono 11000 - handled
		"gb")			echo "Nintendo Game Boy			GB: GameBoy Rom raw format"; SYSTEMEMU="gb";;
		"gbc"|"cgb") 	echo "Nintendo Game Boy Color	GB: GameBoyColor Rom raw format"; SYSTEMEMU="gb";;
		"sgb") 			echo "Nintendo Super Game Boy	GB: Super/Color GameBoy Rom format"; SYSTEMEMU="gb";;
		# res 240x160 - cpu 32bit - stereo 22050 - handled
		"gba"|"agb") 	echo "Nintendo Game Boy Advance	GB: GameBoy Advance Rom raw format"; SYSTEMEMU="gba";;
		"gsf") 			echo "Nintendo Game Boy Advance	GB: GameBoy Sound Format ripped"; SYSTEMEMU="gba"; SYTEMRIPMUSIC="1";;
		"minigsf") 		echo "Nintendo Game Boy Advance	GB: Mini GameBoy Sound Format ripped"; SYSTEMEMU="gba"; SYTEMRIPMUSIC="1";;
		# res x2 384x256 - cpu x2 32bit - stereo 44100 - handled
		"vb")			echo "Nintendo Virtual Boy		VB: VirtualBoy Rom raw format"; SYSTEMEMU="vb";;
		"vboy") 		echo "Nintendo Virtual Boy		VB: VirtualBoy Rom+Ram raw format"; SYSTEMEMU="vb";;
		# res 320x232* - cpu 16bit - stereo 44100 - cdrom - multibutton
		"pce") 		echo "PC Engine System				PCE: PCEngine Rom disk format"; SYSTEMEMU="pce";;
		"sgx") 		echo "Super GraFX or Core GraFX I 	PCE: PCEngine SuperGraFX image format"; SYSTEMEMU="pce_fast";; # here we load a file, not a disk, so fast module lader will loaded
		"tgx") 		echo "Turbo GraFX 16				PCE: PCEngine TurboGraFX image format"; SYSTEMEMU="pce_fast";; # here we load a file, not a disk, so fast module lader will loaded
		"hes") 		echo "PC Engine System				PCE: PCEngine Riped music format"; SYSTEMEMU="pce"; SYTEMRIPMUSIC="1";;
		# res 288x240 - cpu x2 16bit - stereo 44100 - cdrom only
		"ex") 		echo "PC FX Computer System			PCFX: PC-FX HuEXE format"; SYSTEMEMU="pcfx";;
		# res 306x240* - cpu 32bit - stereo 44100 - cdrom - bios need
		"psx") 		echo "Sony PlayStation / PSOne		PSX: PS-X PlayStation Xecutable ormat"; SYSTEMEMU="psx";; # psx still experimental
		"psf") 		echo "Sony PlayStation / PSOne		PSX: Playstation Sound File format"; SYSTEMEMU="psx"; SYTEMRIPMUSIC="1";;
		"minipsf") 	echo "Sony PlayStation / PSOne		PSX: Mini Playstation Sound File format"; SYSTEMEMU="psx"; SYTEMRIPMUSIC="1";;
	esac
done

# now lets setup and lauch emulator with the rom
# automatization configuration of emulator based: (for now medanefen only)

#DETECTING OF HDMI ALSA OR JACK ENVIROMENT
sounddriver=alsa
# TODO hdmi oos4 and jack support, no me gusta jack ni oss4 pero vere como le meto

#DETECTING 3D opengl VIDEO ACELERATION
videogltype=$(glxinfo | grep Indirect  >> /dev/null)
if [ "x$videogltype" = "x" ]; then
videodriver=opengl
else
videodriver=sdl
fi


#only permite once instance, if machine if enouch powerfully use config option

emupid=$(pidof $EMULATOR)
if [ "x$emupid" = "x" ]; then
	 sleep 0
else
	kill -9 $emupid
fi

# TODO must detect extension , autoset emulator event superset the command
emunine=$(${EMULATOR} | grep "0.9")
if [ "x$emunine" = "x" ] ; then
SYSTEM=
SPECIAL=nn2x
else
SYSTEM='-force_module '$SYSTEMEMU
fi

SCALINGFX='-'$SYSTEMEMU'.special '$SPECIAL''
if [ "x$SYSTEMEMU" = "xwswan" ] || [ "x$SYSTEMEMU" = "xgb" ] || [ "x$SYSTEMEMU" = "xgba" ] || [ "x$SYSTEMEMU" = "xngp" ] || [ "x$SYSTEMEMU" = "xgg" ] || [ "x$SYSTEMEMU" = "xlynx" ] || [ "x$SYSTEMEMU" = "vb" ] ; then
#echo "ver"
#	if [ "x$SCALESCR" = "x2"]; then
		SCALESCR=3
#		echo "ver2"
#	fi
fi
SCALING='-'$SYSTEMEMU'.xscale '$SCALESCR' -'$SYSTEMEMU'.yscale '$SCALESCR''


if [ "x$DISPLAY" = "x" ] ; then
	$XMESSAGE $OPTSICON $OPTSTITLE $OPTSTYPEINFO "${msg_welcome_nox} ${msg_welcome_common}" $OPTSTEXT
	exit 1
else
# si no se escogio rom, no hacer nada, ni las gracias porque aun no disfruto
	if [ "x${ROMFILEARG}" = "x" ]; then
	$XMESSAGE $OPTSICON $OPTSTITLE $OPTSTYPEINFO $OPTSTEXT "${msg_finalize}"
		exit 0
	else
echo $MSG_CONSOLE_INFO' en '$DESKTOP' emulando '$SYSTEM' with '$videodriver' '$SCALING' '$SCALINGFX' and '$sounddriver' using '$EMULATOR' identify by '$emupid''
		$EMULATOR $SYSTEM -vdriver $videodriver $SCALING $SCALINGFX -sounddriver $sounddriver "${ROMFILEARG}"
echo $MSG_CONSOLE_INFO' en '$DESKTOP' emulando '$SYSTEM' with '$videodriver' '$SCALING' '$SCALINGFX' and '$sounddriver' using '$EMULATOR' identify by '$emupid''
	fi
fi

