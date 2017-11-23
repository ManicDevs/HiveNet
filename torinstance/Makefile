export SERVER_BASENAME = torinstance
export TORINSTANCE_BASENAME = $(SERVER_BASENAME)-linux-$(ARCH)

.PHONY: all
all: linux-x86_64

linux-x86_64:
	@make -f Makefile.linux-x86_64

.PHONY: clean-objs
clean-objs:
	@rm -f ../obj/$(SERVER_BASENAME)-*-*.o
	@rm -f ../obj/$(SERVER_BASENAME)-*-*.md5

.PHONY: clean
clean: clean-objs