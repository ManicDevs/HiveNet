export SERVER_BASENAME = hivenet

.PHONY: all
all: linux-mipsel linux-x86_64

linux-mipsel:
	@make -f Makefile.linux-mipsel

linux-x86_64:
	@make -f Makefile.linux-x86_64

.PHONY: clean-objs
clean-objs:
	@rm -f ../obj/$(SERVER_BASENAME)-*-*.o
	@rm -f ../obj/$(SERVER_BASENAME)-*-*.md5

.PHONY: clean
clean: clean-objs