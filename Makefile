export OS = $(shell uname)
export CWD = $(shell pwd)

export LIB = $(CWD)/lib
export BIN = $(CWD)/bin
export OBJ = $(CWD)/obj

ifndef VERBOSE
.SILENT:
endif

default:
	@echo
	@echo " HiveNet - Land of the bees!"
	@echo
	@echo " General build tasks¬"
	@echo "  make linux-mipsel	-- Build for linux-mipsel"
	@echo "  make linux-x86_64	-- Build for linux-x86_64"
	@echo
	@echo " Administrative tasks¬"
	@echo "  make clean		-- Clean Hivenet Environment"
	@echo "  make clean-bin	-- Clean Hivenet Binary"
	@echo "  make clean-obj	-- Clean Hivenet Objects"
	@echo "  make clean-deps 	-- Clean Hivenet Dependencies"
	@echo

linux-mipsel:
	@make -f Makefile.linux-mipsel all

linux-x86_64:
	@make -f Makefile.linux-x86_64 all

.PHONY: clean-obj
clean-obj:
	@rm -f obj/*.o
	@rm -f obj/*.md5

.PHONY: clean-bin
clean-bin:
	@rm -rf bin/hivenet-*

.PHONY: clean-lib
clean-lib:
	@rm -rf $(CWD)/lib/linux-mipsel
	@rm -rf $(CWD)/lib/*.a

.PHONY: clean-deps
clean-deps: clean-lib
	@echo
	@echo " [-] Started clean for all dependencies"
	@echo " [-] Cleaning LINUX-MIPSEL"
	@rm -rf $(CWD)/deps/cross-compilers/mipsel-linux-musl
	@echo " [+] Done cleaning LINUX-MIPSEL"
	@echo " [-] Cleaning BUILD environment"
	@rm -rf $(CWD)/deps/build
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
