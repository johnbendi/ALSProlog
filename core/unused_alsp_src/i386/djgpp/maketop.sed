/VPATH.*=/ s/:/;/g
s/@srcdir@/pathsrc/g
s/@ARCH@/i386/g
s/@CC@/gcc -Ipathsrc\/..\/i386\/djgpp/
s/@MACH_OS@/djgpp/
s/@OS@/djgpp/
s/@SOS@/djgpp/
s/@LIBS@/pathsrc\/..\/i386\/djgpp\/libregex.a -lm/
s/@TARGET@/djgpp/
s/@X_CFLAGS@/-DX_DISPLAY_MISSING/
s/@X_LIBS@//
s/@X_EXTRA_LIBS@//
s/@LIBOBJS@/fileblocks.o/

s/cd \(.*\); $(MAKE)/$(MAKE) -C \1/g
s/^	(\(.*\))$/	\1/g
s/^	-(\(.*\))$/	\1/g
s/include $(srcdir)\/generic\/generic.mkf/include ..\/generic.mkf/

s/^	.\//	go32 /
s/^	alspro/	go32 alspro/g

s/.h.proto//g

s/^include.*generic\.mkf/include \.\.\/generic\.mkf/
