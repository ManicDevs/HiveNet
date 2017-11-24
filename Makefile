export OS = $(shell uname)
export CWD = $(shell pwd)
export ARCH = $(shell uname -m)

export LIB = $(CWD)/lib
export BIN = $(CWD)/bin
export OBJ = $(CWD)/obj

export DEPS_DIR = $(CWD)/deps
export BUILD_DIR = $(DEPS_DIR)/build

export LIBSSL = ssl
export LIBTLS = tls
export LIBCRYPTO = crypto
export LIBRESSL = $(DEPS_DIR)/libressl-2.6.3
export LIBRESSL_INC = $(LIBRESSL)/include

export LIBSYSTEMD = systemd
export SYSTEMD = $(DEPS_DIR)/systemd-221
export SYSTEMD_INC =

export LIBEVENT = event
export EVENT = $(DEPS_DIR)/libevent-2.1.8-stable
export EVENT_INC =

export LIBZLIB = zlib
export ZLIB = $(DEPS_DIR)/zlib-1.2.11
export ZLIB_INC =

export LIBTOR = tor
export TOR = $(DEPS_DIR)/tor-master
export TOR_INC = $(TOR)/src
export TORINSTANCE_SRC = $(CWD)/torinstance

export COMMON_INC = $(CWD)/common
export COMMON_SRC = $(wildcard $(COMMON_INC)/*.c)

export CC = gcc
export DBGFLAGS = -DDEBUG -D_DEBUG -ggdb3

export STRIPFLAGS = --strip-all --strip-unneeded -g -R .eh_frame -R .eh_frame_hdr -R.comment -R .note

CFLAGS = -Wall -fomit-frame-pointer
LDFLAGS = -L$(LIB) -ltor -lor -lor-ctime -lor-crypto -lor-event -lor-trunnel -lcurve25519_donna -led25519_ref10 -led25519_donna -lkeccak-tiny \
	-levent -lssl -lcrypto -lpthread -lm -lz -lcap -llzma -lseccomp
	
DBG_LDFLAGS = -L$(LIB) -ltor-testing -lor-testing -lor-ctime-testing -lor-crypto-testing -lor-event-testing \
	-lor-trunnel-testing -lcurve25519_donna -led25519_ref10 -led25519_donna -lkeccak-tiny \
	-levent -lssl -lcrypto -lpthread -lm -lz -lcap -llzma -lseccomp

ifndef VERBOSE
.SILENT:
endif

default:
	@echo
	@echo " HiveNet - Land of the bees!"
	@echo
	@echo " General build tasks¬"
	@echo "  make all		-- Build for every distro"
	@echo "  make linux-x86_64	-- Build for linux-x86_64"
	@echo
	@echo " Administrative tasks¬"
	@echo "  make clean		-- Clean Hivenet Environ"
	@echo "  make clean-deps 	-- Clean Depends Environ"
	@echo

.PHONY: all
all: linux-x86_64

linux-x86_64: $(wildcard obj/*-$@-*.o)
	@echo
	@echo " [-] Started build for $@"
	# Extracting
	###
	if [ ! -d "$(EVENT)" ]; then									\
		echo " [-] Extracting LIBEVENT";							\
		tar -xf deps/libevent-2.1.8-stable.tar.gz -C deps/;			\
		echo " [+] Done extracting LIBEVENT";						\
	fi
	
	if [ ! -d "$(LIBRESSL)" ]; then									\
		echo " [-] Extracting LIBRESSL";							\
		tar -xf deps/libressl-2.6.3.tar.gz -C deps/;			\
		echo " [+] Done extracting LIBRESSL";						\
	fi
	
	#if [ ! -d "$(SYSTEMD)" ]; then									\
	#	echo " [-] Extracting LIBSYSTEMD";							\
	#	tar -xf deps/systemd-235.tar.xz -C deps/;			\
	#	echo " [+] Done extracting LIBSYSTEMD";						\
	#fi
	
	if [ ! -d "$(ZLIB)" ]; then						\
		echo " [-] Extracting LIBZLIB";							\
		tar -xf	deps/zlib-1.2.11.tar.gz -C deps/;		\
		echo " [+] Done extracting LIBZLIB";							\
	fi
	
	if [ ! -d "$(TOR)" ]; then								\
		echo " [-] Extracting LIBTOR";							\
		unzip deps/tor-master.zip -d deps/;						\
		echo " [+] Done extracting LIBTOR";						\
	fi
	# Building
	###
	if [ ! -f "$(EVENT)/.libs/libevent.a" ]; then					\
		echo " [-] Building LIBEVENT";							\
		cd $(EVENT) && ./configure --host=x86_64-pc-linux-gnu \
			 --enable-static --enable-shared --prefix=$(BUILD_DIR) && \
			make && make install					\
		cp $(BUILD_DIR)/lib/libevent*.a $(LIB);				\
		echo " [+] Done building LIBEVENT";						\
	else											\
		echo " [*] Skipping building LIBEVENT";						\
	fi
	
	#if [ ! -f "$(SYSTEMD)/build/src/libsystemd/libsystemd.a" ]; then					\
	#	echo " [-] Building LIBSYSTEMD";							\
	#	cd $(SYSTEMD) && ./configure --prefix=$(BUILD_DIR) -Drootprefix=$(BUILD_DIR)/usr -D -Dlibcryptsetup=false -Dpam=false -Dima=false -Dseccomp=false -Dsmack=false -Dzlib=false -Dxz=false -Dlz4=false -Dbzip2=false -Dacl=false -Dgcrypt=false -Dqrencode=false -Dgnutls=false -Dlibcurl=false -Didn=false -Dlibidn=false -Dnss-systemd=false -Dhostnamed=false -Dtimedated=false -Dtimesyncd=false -Dlocaled=false -Dnetworkd=false -Dresolve=false -Dcoredump=false -Dpolkit=false -Defi=false -Dkmod=false -Dxkbcommon=false -Dblkid=false -Ddbus=false -Dglib=false -Dmyhostname=false -Dhwdb=false -Dtpm=false -Dman=false -Dutmp=false -Dldconfig=false -Dhibernate=false -Dadm-group=false -Dwheel-group=false -Dgshadow=false -Dlibiptc=false -Delfutils=false -Dbinfmt=false -Dvconsole=false -Dquotacheck=false -Dtmpfiles=false -Denvironment-d=false -Dsysusers=false -Dfirstboot=false -Drandomseed=false -Dbacklight=false -Drfkill=false -Dlogind=false -Dmachined=false &&		\
	#		CFLAGS=-static make && DEST_DIR=$(BUILD_DIR) make install
	#	cp $(BUILD_DIR)/lib/libevent*.a $(LIB);				\
	#	echo " [+] Done building LIBSYSTEMD";						\
	#else											\
	#	echo " [*] Skipping building LIBSYSTEMD";						\
	#fi
	
	if [ ! -f "$(LIBRESSL)/ssl/.libs/libssl.a" ]; then					\
		echo " [-] Building LIBRESSL";									\
		cd $(LIBRESSL) && ./configure --host=x86_64-pc-linux-gnu 		\
			--enable-static --enable-shared --prefix=$(BUILD_DIR) && 	\
			make && make install-strip;							\
		cp $(BUILD_DIR)/lib/libssl.a $(LIB)/libssl.a;				\
		cp $(BUILD_DIR)/lib/libtls.a $(LIB)/libtls.a;			\
		cp $(BUILD_DIR)/lib/libcrypto.a $(LIB)/libcrypto.a;			\
		echo " [+] Done building LIBRESSL";						\
	else											\
		echo " [*] Skipping building LIBRESSL";						\
	fi
	
	if [ ! -f "$(ZLIB)/libz.a" ]; then					\
		echo " [-] Building LIBZLIB";									\
		cd $(ZLIB) && ./configure --shared --prefix=$(BUILD_DIR) && 	\
			make && make install;							\
		cd $(ZLIP) && ./configure --static --prefix=$(BUILD_DIR) &&		\
			make && make install;										\
		cp $(BUILD_DIR)/lib/libz.a $(LIB)/libz.a;				\
		echo " [+] Done building LIBZLIB";						\
	else											\
		echo " [*] Skipping building LIBZLIB";						\
	fi
	
	if [ ! -f "$(TOR)/src/or/tor" ]; then						\
		echo " [-] Building LIBTOR";							\
		cd $(TOR) && ./autogen.sh && ./configure --host=x86_64-pc-linux-gnu			\
			--enable-static-libevent --enable-static-openssl --enable-static-zlib \
			--with-libevent-dir=$(EVENT) --with-openssl-dir=$(LIBRESSL) --with-zlib-dir=$(ZLIB)		\
			--disable-asciidoc --disable-systemd --disable-system-torrc --prefix=/tmp &&		\
			sed -e 's|libevent-2.1.8-stable/libevent.a|libevent-2.1.8-stable/.libs/libevent.a|' \
				-e 's|libressl-2.6.3/libssl.a|libressl-2.6.3/ssl/.libs/libssl.a|' \
				-e 's|libressl-2.6.3/libcrypto.a|libressl-2.6.3/crypto/.libs/libcrypto.a|' Makefile > Makefile.sed && \
			mv Makefile.sed Makefile && make;																			\
		cp $(TOR)/src/or/libtor*.a $(LIB);				\
		cp $(TOR)/src/common/libor*.a $(LIB);				\
		cp $(TOR)/src/common/libcurve25519_donna.a $(LIB);				\
		cp $(TOR)/src/trunnel/libor-trunnel*.a $(LIB);				\
		cp $(TOR)/src/ext/ed25519/ref10/libed25519_ref10.a $(LIB);				\
		cp $(TOR)/src/ext/ed25519/donna/libed25519_donna.a $(LIB);				\
		cp $(TOR)/src/ext/keccak-tiny/libkeccak-tiny.a $(LIB);				\
		cp $(TOR)/src/or/tor* $(BIN);						\
		echo " [+] Done building LIBTOR";						\
	else											\
		echo " [*] Skipping building LIBTOR";						\
	fi
	
	@echo " [-] Building torinstance"
	@make -C torinstance linux-x86_64
	@echo " [+] Done building torinstance"
	@echo " [-] Building dnstunnel"
	@make -C dnstunnel linux-x86_64
	@echo " [+] Done building dnstunnel"
	@echo " [-] Building hivenet"
	@make -C hivenet linux-x86_64
	@echo " [+] Done building hivenet"
	@echo " [-] Linking objects to final build"
	$(CC) $(CFLAGS) $(DBGFLAGS) \
		-D"memset_s(W,WL,V,OL)=memset(W,V,OL)" \
		$(OBJ)/torinstance-$@-torinstance-dbg.o \
		$(OBJ)/dnstunnel-$@-dnstunnel-dbg.o \
		$(OBJ)/hivenet-$@-hivenet-dbg.o \
		$(DBG_LDFLAGS) -o $(BIN)/hivenet-$@-dbg
	$(CC) -s -O3 -Os $(CFLAGS) \
		$(OBJ)/torinstance-$@-torinstance-rel.o \
		$(OBJ)/dnstunnel-$@-dnstunnel-rel.o \
		$(OBJ)/hivenet-$@-hivenet-rel.o \
		$(LDFLAGS) -o $(BIN)/hivenet-$@
	#@strip $(STRIPFLAGS) $(BIN)/hivenet-$@
	@echo " [+] Done linking ojects to final build"
	@echo " [+] Done build for $@"
	@echo

.PHONY: clean-obj
clean-obj:
	@rm -f obj/*.o
	@rm -f obj/*.md5

.PHONY: clean-bin
clean-bin:
	@rm -rf bin/hivenet-*

.PHONY: clean-lib
clean-lib:
	@rm -rf lib/*.a

.PHONY: clean-deps
clean-deps: clean-lib
	@echo
	@echo " [-] Started clean for all dependencies"
	@echo " [-] Cleaning TOR"
	@rm -rf $(TOR)
	@echo " [+] Done cleaning TOR"
	@echo " [-] Cleaning ZLIB"
	@rm -rf $(ZLIB)
	@echo " [+] Done cleaning ZLIB"
	@echo " [-] Cleaning LIBRESSL"
	@rm -rf $(LIBRESSL)
	@echo " [+] Done cleaning LIBRESSL"
	@echo " [-] Cleaning LIBEVENT"
	@rm -rf $(EVENT)
	@echo " [+] Done cleaning LIBEVENT"
	@echo " [-] Cleaning BUILD environment"
	@rm -rf $(BUILD_DIR)
	@echo " [+] Done cleaning BUILD environment"
	@echo " [+] Done clean for all dependencies"
	@echo

.PHONY: clean
clean: clean-obj clean-bin
	@echo
	@echo " [-] Started clean for all builds"
	@echo " [-] Cleaning hivenet"
	@make -C hivenet clean
	@echo " [+] Done cleaning hivenet"
	@echo " [-] Cleaning dnstunnel"
	@make -C dnstunnel clean
	@echo " [+] Done cleaning dnstunnel"
	@echo " [-] Cleaning torinstance"
	@make -C torinstance clean
	@echo " [+] Done cleaning torinstance"
	@echo
