## AVRのFUSE設定

**ATmega328p FUSE : Low, High, Extended.**
FUSES = {0xE2, 0xD9, 0xFF};		

```
Low
    CKDIV8      1       clock divide disable
    CKOUT       1       clock out disable
    SUT         10      high speed rising
    CKSEL       0010    internal RC Osc	 :: default

High
    RSTDIBL     1       PC6 to reset
    DWEN        1       Debug wire disable
    SPIEN       0       SPI programing enable
    WDTON       1       WDT disable
    EESAVE      1       EEPROM is erasable
    BOOTSZ      00      Boot loader size set to 2048 words :: default
    BOOTRST     1       Reset vector set to application section
Ext
    7~3         not use (set 1)
    BODLEVEL    111     Brownout reset disable	
```

**ATmega88/V FUSE : Low, High, Extended.**
FUSES = {0xE2, 0xDF, 0xF9}

