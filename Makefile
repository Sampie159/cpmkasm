SRCDIR = src
OBJDIR = obj

SRCS = $(wildcard $(SRCDIR)/*.s)
OBJS = $(patsubst $(SRCDIR)/%.s, $(OBJDIR)/%.o, $(SRCS))

all: cpmk

install: cpmk
	sudo cp cpmk /usr/local/bin

uninstall: /usr/local/bin/cpmk
	sudo rm /usr/local/bin/cpmk

cpmk: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

$(OBJDIR)/%.o: $(SRCDIR)/%.s $(OBJDIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJDIR):
	mkdir -p $(OBJDIR)
