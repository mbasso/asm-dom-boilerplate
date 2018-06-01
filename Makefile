# if you are using windows, please comment line 3 and uncomment line 4
SRCDIR := src
SRCS := $(shell find $(SRCDIR) -name "*.cpp")
#SRCS := $(shell FORFILES /P $(SRCDIR) /S /M *.cpp /C "CMD /C ECHO @relpath")

# additional headers to include
HEADERS = \
	node_modules/asm-dom/cpp/asm-dom.hpp

# additional files to compile
FILES = \
	node_modules/asm-dom/cpp/asm-dom.cpp

# options used to compile the C++ code
CFLAGS = \
	-O3 \
	-Wall \
	-Werror \
	-Wall \
	-Wno-deprecated \
	-Wno-parentheses \
	-Wno-format

# this on top of MakeFile after CPPFLAGS
START_PREREQUISITES = \
	dist/wasm \
	dist/asmjs


# C++ => .wasm options
WASM_OPTIONS = \
	-O3 \
	--bind \
	--memory-init-file 1 \
	--llvm-lto 3 \
	--llvm-opts 3 \
	--js-opts 1 \
	--closure 1 \
	-s MODULARIZE=1 \
	-s ALLOW_MEMORY_GROWTH=1 \
	-s AGGRESSIVE_VARIABLE_ELIMINATION=1 \
	-s ABORTING_MALLOC=1 \
	-s NO_EXIT_RUNTIME=1 \
	-s NO_FILESYSTEM=1 \
	-s DISABLE_EXCEPTION_CATCHING=2 \
	-s BINARYEN=1 \
	-s EXPORTED_RUNTIME_METHODS=[\'UTF8ToString\'] \
	-s BINARYEN_TRAP_MODE=\'allow\'

# C++ => .asm.js options
ASMJS_OPTIONS = \
	-O3 \
	--bind \
	--memory-init-file 1 \
	--llvm-lto 3 \
	--llvm-opts 3 \
	--js-opts 1 \
	--closure 1 \
	-s MODULARIZE=1 \
	-s AGGRESSIVE_VARIABLE_ELIMINATION=1 \
	-s ELIMINATE_DUPLICATE_FUNCTIONS=1 \
	-s ABORTING_MALLOC=1 \
	-s NO_EXIT_RUNTIME=1 \
	-s NO_FILESYSTEM=1 \
	-s DISABLE_EXCEPTION_CATCHING=2 \
	-s EXPORTED_RUNTIME_METHODS=[\'UTF8ToString\']

####### internals #######

OBJDIR := temp/o
DEPDIR := temp/dep
BC := temp/app.bc

INCLUDES := $(HEADERS:%=-include %)
GCCXSRCS := $(SRCS:%.cpp=%.cc)
OBJS     := $(SRCS:$(SRCDIR)/%.cpp=$(OBJDIR)/%.o)
DEPS     := $(SRCS:$(SRCDIR)/%.cpp=$(DEPDIR)/%.d)
TREE     := $(sort $(patsubst %/,%,$(dir $(OBJS))))

CPPFLAGS = -MMD -MP -MF $(@:$(OBJDIR)/%.o=$(DEPDIR)/%.d)

.PHONY: all clean install start

all: dist

clean:
	npx rimraf dist temp $(GCCXSRCS)

install:
	npm install

$(BC): $(OBJS) $(FILES)
	emcc \
		$(CFLAGS) \
		--bind \
		$(INCLUDES) \
		$(OBJS) \
		$(FILES) \
		-o $(BC)

dist/wasm: $(BC)
	npx mkdirp dist/wasm
	emcc \
		$(WASM_OPTIONS) \
		$(BC) \
		-o dist/wasm/app.js

dist/asmjs: $(BC)
	npx mkdirp dist/asmjs
	emcc \
		$(ASMJS_OPTIONS) \
		$(BC) \
		-o dist/asmjs/app.asm.js

dist: dist/wasm dist/asmjs
	npx cross-env NODE_ENV=production parcel build index.html --public-url /

# this replace the current "start" command
# -p, -n and -c just add some colors and information about the commands runned by concurrently
# I've set a timer of 1.5s by default
start: $(START_PREREQUISITES)
	npx concurrently \
		-p "[{name}]" \
		-n "Parcel,Make" \
		-c "bgGreen.bold,bgBlue.bold" \
		"npx cross-env NODE_ENV=development parcel index.html --open" \
		"nodemon --exec \"make $(START_PREREQUISITES)\""

$(SRCDIR)/%.cc: $(SRCDIR)/%.cpp
	npx gccx $< -o $@

.SECONDEXPANSION:
$(OBJDIR)/%.o: $(SRCDIR)/%.cc | $$(@D)
	emcc \
		$(CFLAGS) \
		--bind \
		$(CPPFLAGS) \
		$(INCLUDES) \
		-c $< \
		-o $@
	npx rimraf $<

$(TREE): %:
	npx mkdirp $@
	npx mkdirp $(@:$(OBJDIR)%=$(DEPDIR)%)

ifeq "$(MAKECMDGOALS)" ""
-include $(DEPS)
endif
