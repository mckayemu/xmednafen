# This file was originally written by PICCORO LEnz McKAY and 
# may be modified under GNU GPL v3, CC-BY-NSA and ZLIB based license


	mkdir -p $(DESTDIR)/usr/share/pixmaps
	mkdir -p $(DESTDIR)/usr/bin
	mkdir -p $(DESTDIR)/usr/share/applications
	cp -a debian/Xmednafen.desktop $(DESTDIR)/usr/share/applications
	cp -a bin/xmednafen.sh $(DESTDIR)/usr/bin/xmednafen
	cp -a debian/mednafen-icon.xpm $(DESTDIR)/usr/share/pixmaps
	chmod 755 $(DESTDIR)/usr/bin/xmednafen
#	mkdir -p $(DESTDIR)/var/emulation/general
#	cp -a usr/bin/template* $(CURDIR)/debian/xmednafen/var/emulation/general/templatelaucher


