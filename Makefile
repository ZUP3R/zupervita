.PHONY: all vpk

TITLE = zupervita
TITLE_ID = ZUPERVITA
TARGET = Z
VERSION = 00.01

CXX = arm-vita-eabi-g++
STRIP = arm-vita-eabi-strip

SRC = $(foreach dir,src, $(wildcard $(dir)/*.cpp))

CXXWARNINGS = -Wall -Wextra -Wformat=2 -Winit-self -Wmissing-include-dirs \
	-Wunknown-pragmas -Wduplicated-cond
CXXOPTIMATION = -O3
CXXFLAGS = -std=c++17 $(CXXWARNINGS) $(CXXOPTIMATION)
LIBS = -lvita2d -lSceCommonDialog_stub -lSceDisplay_stub -lSceGxm_stub \
	-lSceSysmodule_stub -lScePgf_stub

OUT := out
OBJ := $(addprefix $(OUT)/, $(SRC:src/%.cpp=%.o))

all: vpk
vpk: $(OUT)/$(TARGET).vpk

$(OUT)/$(TARGET).vpk: $(OUT)/eboot.bin $(OUT)/param.sfo
	vita-pack-vpk -s $(OUT)/param.sfo -b $(OUT)/eboot.bin \
		--add sce_sys/icon0.png=sce_sys/icon0.png \
		--add sce_sys/livearea/contents/bg.png=sce_sys/livearea/contents/bg.png \
		--add sce_sys/livearea/contents/startup.png=sce_sys/livearea/contents/startup.png \
		--add sce_sys/livearea/contents/template.xml=sce_sys/livearea/contents/template.xml \
	$@

$(OUT)/eboot.bin: $(OUT)/$(TARGET).velf
	vita-make-fself -c $< $@

$(OUT)/param.sfo:
	vita-mksfoex -d PARENTAL_LEVEL=1 -s APP_VER=$(VERSION) -s VERSION=$(VERSION) \
	-s TITLE_ID=$(TITLE_ID) "$(TITLE)" $@

$(OUT)/$(TARGET).velf: $(OUT)/$(TARGET).elf
	$(STRIP) --strip-unneeded $<
	vita-elf-create $< $@

$(OUT)/$(TARGET).elf: $(OBJ)
	$(CXX) $(CXXFLAGS) -Wl,-q -o $@ $^ $(LIBS)

$(OUT):
	@mkdir -p $@

$(OUT)/%.o : src/%.cpp | $(OUT)
	$(CXX) $(CXXFLAGS) -Wl,-q -c -o $@ $<

clean:
	@rm -rf $(OUT)/

sendvpk: $(OUT)/$(TARGET).vpk
	@curl -T $(OUT)/$(TARGET).vpk ftp://vita:1337/ux0:/
	@echo "SUPER"

send: $(OUT)/eboot.bin
	@curl -T $(OUT)/eboot.bin ftp://vita:1337/ux0:/app/$(TITLE_ID)/
	@echo "Sent to PS Vita."
