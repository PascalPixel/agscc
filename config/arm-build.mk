# Explicit C frontend, ARM backend and source generators. No configure dispatch.
.DEFAULT_GOAL := all
include ../../config/native-flags.mk
FLAGS := -DCROSS_COMPILE -DIN_GCC $(CFLAGS) -DHAVE_CONFIG_H
INCLUDES := -I. -I$(ROOT)/gcc -I$(ROOT)/gcc/config -I$(ROOT)/gcc/../include
CORE := diagnostic.o toplev.o version.o tree.o print-tree.o stor-layout.o \
    fold-const.o function.o stmt.o except.o expr.o calls.o \
    expmed.o explow.o optabs.o real.o builtins.o intl.o \
    varasm.o rtl.o print-rtl.o rtlanal.o emit-rtl.o genrtl.o \
    dbxout.o sdbout.o dwarfout.o dwarf2out.o xcoffout.o bitmap.o \
    alias.o gcse.o integrate.o jump.o cse.o loop.o \
    doloop.o unroll.o flow.o combine.o varray.o regclass.o \
    regmove.o local-alloc.o global.o reload.o reload1.o caller-save.o \
    insn-peep.o reorg.o haifa-sched.o final.o recog.o reg-stack.o \
    regrename.o insn-opinit.o insn-recog.o insn-extract.o insn-output.o insn-emit.o \
    lcm.o profile.o insn-attrtab.o arm.o convert.o mbchar.o \
    splay-tree.o graph.o sbitmap.o resource.o hash.o predict.o \
    lists.o ggc-common.o ggc-page.o simplify-rtx.o ssa.o bb-reorder.o \
    sibcall.o conflict.o timevar.o ifcvt.o
C_FRONTEND := c-parse.o c-lang.o c-errors.o c-lex.o c-pragma.o c-decl.o \
    c-typeck.o c-convert.o c-aux-info.o c-common.o c-iterate.o c-semantics.o
CPP := cpplib.o cpplex.o cppmacro.o cppexp.o cppfiles.o cpphash.o \
    cpperror.o cppinit.o cppulp.o cppdefault.o mkdeps.o prefix.o \
    version.o mbchar.o
LIB := ../libiberty/libiberty.a
SUPPORT := rtl.o bitmap.o ggc-none.o gensupport.o print-rtl.o errors.o obstack.o
GENERATORS := genconfig genflags gencodes genemit genopinit genrecog genextract genpeep genattr genattrtab genoutput
GEN_HEADERS := genrtl.h tree-check.h insn-config.h insn-flags.h insn-codes.h insn-attr.h
OBJECTS := $(sort $(CORE) $(C_FRONTEND) $(CPP) gcc.o gccspec.o cppmain.o tradcpp.o tradcif.o obstack.o $(SUPPORT) $(addsuffix .o,$(GENERATORS)) gengenrtl.o gencheck.o)
BOOT := gengenrtl.o gencheck.o obstack.o
GEN_OBJECTS := $(SUPPORT) $(addsuffix .o,$(GENERATORS))
NORMAL := $(filter-out $(BOOT) $(GEN_OBJECTS),$(OBJECTS))
.PHONY: all
all: cc1 xgcc cpp0 tradcpp0
cc1: $(CORE) $(C_FRONTEND) obstack.o $(LIB)
	$(CC) $(FLAGS) $(LDFLAGS) -o $@ $(CORE) $(C_FRONTEND) obstack.o $(LIB)
xgcc: gcc.o gccspec.o intl.o prefix.o version.o obstack.o $(LIB)
	$(CC) $(FLAGS) $(LDFLAGS) -o $@ gcc.o gccspec.o intl.o prefix.o version.o obstack.o $(LIB)
cpp0: cppmain.o intl.o libcpp.a obstack.o $(LIB)
	$(CC) $(FLAGS) $(LDFLAGS) -o $@ cppmain.o intl.o libcpp.a obstack.o $(LIB)
tradcpp0: tradcpp.o tradcif.o cppdefault.o version.o intl.o obstack.o $(LIB)
	$(CC) $(FLAGS) $(LDFLAGS) -o $@ tradcpp.o tradcif.o cppdefault.o version.o intl.o obstack.o $(LIB)
libcpp.a: $(CPP)
	rm -f $@
	ar rc $@ $(CPP)
	ranlib $@
gengenrtl: gengenrtl.o obstack.o
	$(CC) $(FLAGS) $(LDFLAGS) -o $@ gengenrtl.o obstack.o
gencheck: gencheck.o obstack.o
	$(CC) $(FLAGS) $(LDFLAGS) -o $@ gencheck.o obstack.o
$(GENERATORS): %: %.o $(SUPPORT)
	$(CC) $(FLAGS) $(LDFLAGS) -o $@ $< $(SUPPORT)
$(filter-out $(BOOT),$(GEN_OBJECTS)): genrtl.h
genextract.o: insn-config.h
$(NORMAL): $(GEN_HEADERS)
$(OBJECTS): config.h hconfig.h tm.h tm_p.h auto-host.h ../../config/arm-build.mk ../../config/native-flags.mk
%.o: $(ROOT)/gcc/%.c
	$(CC) -c $(FLAGS) $(INCLUDES) -MMD -MP $<
%.o: %.c
	$(CC) -c $(FLAGS) $(INCLUDES) -MMD -MP $<
arm.o: $(ROOT)/gcc/config/arm/arm.c
	$(CC) -c $(FLAGS) $(INCLUDES) -MMD -MP $<
obstack.c: $(ROOT)/libiberty/obstack.c
	ln -s $< $@
obstack.o: obstack.c
	$(CC) -c $(FLAGS) $(INCLUDES) -MMD -MP $<
prefix.o: $(ROOT)/gcc/prefix.c
	$(CC) $(FLAGS) $(INCLUDES) -DPREFIX=\"/agscc\" -MMD -MP -c $<
cppdefault.o: $(ROOT)/gcc/cppdefault.c
	$(CC) $(FLAGS) $(INCLUDES) -DGCC_INCLUDE_DIR=\"/agscc/lib/gcc-lib/arm-elf/2.96/include\" -DGPLUSPLUS_INCLUDE_DIR=\"/agscc/lib/gcc-lib/arm-elf/2.96/../../../../include/g++-\" -DLOCAL_INCLUDE_DIR=\"/usr/local/include\" -DCROSS_INCLUDE_DIR=\"/agscc/lib/gcc-lib/arm-elf/2.96/../../../../arm-elf/sys-include\" -DTOOL_INCLUDE_DIR=\"/agscc/lib/gcc-lib/arm-elf/2.96/../../../../arm-elf/include\" -MMD -MP -c $<
gcc.o: $(ROOT)/gcc/gcc.c multilib.h specs.h options.h
	$(CC) $(FLAGS) $(INCLUDES) -DSTANDARD_STARTFILE_PREFIX=\"../../../\" -DSTANDARD_EXEC_PREFIX=\"/agscc/lib/gcc-lib/\" -DDEFAULT_TARGET_VERSION=\"2.96\" -DDEFAULT_TARGET_MACHINE=\"arm-elf\" -DSTANDARD_BINDIR_PREFIX=\"/agscc/bin/\" -DTOOLDIR_BASE_PREFIX=\"../../../../\" -MMD -MP -c $<
multilib.h: $(ROOT)/gcc/genmultilib
	sh $< "" "" "mbig-endian=mbe mlittle-endian=mle" "" "" "" > $@.tmp
	mv $@.tmp $@
tree-check.h: gencheck $(ROOT)/gcc/tree.def
	./gencheck > $@.tmp
	mv $@.tmp $@
genrtl.h: gengenrtl $(ROOT)/gcc/rtl.def
	./gengenrtl -h > $@.tmp
	mv $@.tmp $@
genrtl.c: gengenrtl $(ROOT)/gcc/rtl.def
	./gengenrtl > $@.tmp
	mv $@.tmp $@
insn-config.h: genconfig $(ROOT)/gcc/config/arm/arm.md
	./genconfig $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
insn-flags.h: genflags $(ROOT)/gcc/config/arm/arm.md
	./genflags $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
insn-codes.h: gencodes $(ROOT)/gcc/config/arm/arm.md
	./gencodes $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
insn-emit.c: genemit $(ROOT)/gcc/config/arm/arm.md
	./genemit $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
insn-opinit.c: genopinit $(ROOT)/gcc/config/arm/arm.md
	./genopinit $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
insn-recog.c: genrecog $(ROOT)/gcc/config/arm/arm.md
	./genrecog $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
insn-extract.c: genextract $(ROOT)/gcc/config/arm/arm.md
	./genextract $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
insn-peep.c: genpeep $(ROOT)/gcc/config/arm/arm.md
	./genpeep $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
insn-attr.h: genattr $(ROOT)/gcc/config/arm/arm.md
	./genattr $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
insn-attrtab.c: genattrtab $(ROOT)/gcc/config/arm/arm.md
	./genattrtab $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
insn-output.c: genoutput $(ROOT)/gcc/config/arm/arm.md
	./genoutput $(ROOT)/gcc/config/arm/arm.md > $@.tmp
	mv $@.tmp $@
-include $(OBJECTS:.o=.d)

toplev.o: $(ROOT)/gcc/toplev.c
	$(CC) $(FLAGS) $(INCLUDES) -DTARGET_NAME=\"arm-elf\" -MMD -MP -c $<
intl.o: $(ROOT)/gcc/intl.c
	$(CC) $(FLAGS) $(INCLUDES) -DLOCALEDIR=\"/agscc/share/locale\" -MMD -MP -c $<

splay-tree.c: $(ROOT)/libiberty/splay-tree.c
	ln -s $< $@
splay-tree.o: splay-tree.c
	$(CC) -c $(FLAGS) $(INCLUDES) -MMD -MP $<
