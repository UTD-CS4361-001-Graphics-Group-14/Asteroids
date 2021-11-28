SRCS=assets/* entities/* lib/* states/* conf.lua main.lua README.md

LOVE_WIN_PATH ?= /mnt/c/Program\ Files/LOVE/love.exe

OUTDIR=out
ZIP=$(OUTDIR)/Asteroids.zip
WIN=$(OUTDIR)/Asteroids.exe

all: $(WIN)

$(WIN): $(ZIP)
	cat $(LOVE_WIN_PATH) $(ZIP) > $(WIN)

$(ZIP): $(SRCS)
	@mkdir -p $(OUTDIR)
	zip -9 -r $@ $(SRCS)

clean:
	rm -f $(ZIP) $(WIN)
