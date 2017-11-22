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

export LIBEVENT = event
export EVENT = $(DEPS_DIR)/libevent-2.1.8-stable
export EVENT_INC =

export LIBZLIB = zlib
export ZLIB = $(DEPS_DIR)/zlib-1.2.11
export ZLIB_INC =

export LIBTOR = tor
export TOR = $(DEPS_DIR)/tor-master
export TOR_INC = $(TOR)/src

export COMMON_INC = $(CWD)/common
export COMMON_SRC = $(wildcard $(COMMON_INC)/*.c)

export CC = gcc
export DBGFLAGS = -DDEBUG -D_DEBUG -ggdb3 -O0

CFLAGS = 
#-I$(COMMON_INC) -I$(LIBRESSL_INC) -D_GNU_SOURCE
LDFLAGS = 
#-lpthread -ldl -lm -L$(LIB) -l$(LIBSSL) -l$(LIBTLS) -l$(LIBCRYPTO)

STRIPFLAGS = --strip-all --remove-section=.comment --remove-section=.note

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
	@echo $(TOR_INC)

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
	
	if [ ! -d "$(ZLIB)" ]; then						\
		echo " [-] Extracting ZLIB";							\
		tar -xf	deps/zlib-1.2.11.tar.gz -C deps/;		\
		echo " [+] Done extracting ZLIB";							\
	fi
	
	if [ ! -d "$(TOR)" ]; then								\
		echo " [-] Extracting TOR";							\
		unzip deps/tor-master.zip -d deps/;						\
		echo " [+] Done extracting TOR";						\
	fi
	# Building
	###
	if [ ! -f "$(EVENT)/.libs/libevent.a" ]; then					\
		echo " [-] Building EVENT";							\
		cd $(EVENT) && ./configure --host=x86_64-pc-linux-gnu \
			 --enable-static --enable-shared --prefix=$(BUILD_DIR) && \
			make && make install					\
		cp $(BUILD_DIR)/lib/libevent*.a $(LIB);				\
		echo " [+] Done building EVENT";						\
	else											\
		echo " [*] Skipping building EVENT";						\
	fi
	
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
		echo " [-] Building ZLIB";									\
		cd $(ZLIB) && ./configure --shared --prefix=$(BUILD_DIR) && 	\
			make && make install;							\
		cd $(ZLIP) && ./configure --static --prefix=$(BUILD_DIR) &&		\
			make && make install;										\
		cp $(ZLIB)/lib/libz.a $(LIB)/libz.a;				\
		echo " [+] Done building ZLIB";						\
	else											\
		echo " [*] Skipping building ZLIB";						\
	fi
	
	if [ ! -f "$(BUILD_DIR)/bin/tor" ]; then						\
		echo " [-] Building TOR";							\
		cd $(TOR) && ./autogen.sh && ./configure --host=x86_64-pc-linux-gnu			\
			--enable-static-libevent --enable-static-openssl --enable-static-zlib \
			--with-libevent-dir=$(EVENT) --with-openssl-dir=$(LIBRESSL) --with-zlib-dir=$(ZLIB)		\
			--disable-asciidoc --disable-system-torrc --prefix=$(BUILD_DIR) &&		\
			sed -e 's|libevent-2.1.8-stable/libevent.a|libevent-2.1.8-stable/.libs/libevent.a|' \
				-e 's|libressl-2.6.3/libssl.a|libressl-2.6.3/ssl/.libs/libssl.a|' \
				-e 's|libressl-2.6.3/libcrypto.a|libressl-2.6.3/crypto/.libs/libcrypto.a|' Makefile > Makefile.sed && \
			mv Makefile.sed Makefile && make && make install;																			\
		cp $(TOR)/src/or/libtor.a $(LIB)/libtor.a;				\
		cp $(BUILD_DIR)/bin/tor* $(BIN);						\
		echo " [+] Done building TOR";						\
	else											\
		echo " [*] Skipping building TOR";						\
	fi
	
	@echo " [-] Building dnstunnel"
	@make -C dnstunnel linux-x86_64
	@echo " [+] Done building dnstunnel"
	@echo " [-] Building hivenet"
	@make -C hivenet linux-x86_64
	@echo " [+] Done building hivenet"
	@echo " [-] Linking objects to final build"
	$(CC) $(CFLAGS) $(DBGFLAGS) \
		$(OBJ)/dnstunnel-$@-*-dbg.o \
		$(OBJ)/hivenet-$@-*-dbg.o \
		$(LDFLAGS) \
		-o $(BIN)/hivenet-$@-dbg
	@strip $(STRIPFLAGS) $(BIN)/hivenet-$@-dbg
	$(CC) $(CFLAGS) \
		$(OBJ)/dnstunnel-$@-*-rel.o \
		$(OBJ)/hivenet-$@-*-rel.o \
		$(LDFLAGS) \
		-o $(BIN)/hivenet-$@
	@strip $(STRIPFLAGS) $(BIN)/hivenet-$@
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
	@echo
