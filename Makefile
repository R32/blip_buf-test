
SWC       := libblip.swc
LIB       := libblip.a
OBJDIR    := obj

SOURCE    := blip_buf-1.1.0
INCLUDES  := -I$(SOURCE)

FILES     := blip_buf.c
OBJS      := $(addprefix $(OBJDIR)/, $(FILES:.c=.o))


VPATH     := $(CURDIR) $(SOURCE)

# flash alchemy TOOLS
CC        := gcc
LD        := $(CC)
AR        := ar

CFLAGS    := -Wall -DNODEBUG -O3 -ffast-math
CFLAGS    += $(INCLUDES)

all: $(OBJDIR) $(SWC)

clean:
	@echo clean ...
	@rm -fr $(OBJDIR)/** $(SWC)

.PHONY: all clean

$(OBJDIR):
	mkdir -p $@

$(OBJDIR)/$(LIB): $(OBJS)
	@$(AR) rcs $@ $^
	@echo Archived $@

$(SWC): $(OBJDIR)/glue.o $(OBJDIR)/$(LIB)
	@rm -f "$@"
	$(LD) $< -lblip -L$(OBJDIR) -swc -o $@

$(OBJDIR)/%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo Compile $< TO $@

$(OBJDIR)/glue.o: glue.c
$(OBJDIR)/blip_buf.o: blip_buf.c blip_buf.h