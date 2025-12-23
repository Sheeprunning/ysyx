ENTRY(_start)
/* PHDRS { text PT_LOAD; data PT_LOAD; } */
MEMORY {
  /* mrom(rx) : ORIGIN = 0x20000000, LENGTH = 4K */
  flash(rx) : ORIGIN = 0x30000000, LENGTH = 256M
  psram(rwx): ORIGIN = 0x80000000, LENGTH = 4M
  sram(rwx) : ORIGIN = 0x0f000000, LENGTH = 8K
  sdram(rwx) : ORIGIN = 0xa0000000, LENGTH = 0x20000000
}
SECTIONS {
  . = ORIGIN(flash);
  .start : {
    *(entry)
  } >flash AT > flash

  . = ORIGIN(sram);

  .copy : {
    . = ALIGN(4);
    _scopy = .;
    *(copy)
    _ecopy = .;
  } > sram AT> flash
  _lscopy = LOADADDR(.copy);

  .boot : {
    . = ALIGN(4);
    _sboot = .;
    *(boot)
    _eboot = .;
  } > sram AT> flash
  _lsboot = LOADADDR(.boot);

  . = ORIGIN(sdram);
  .text : {
    . = ALIGN(4);
    _stext = .;
    *(.text*)
    _etext = .;
  } > sdram AT> flash
  _lstext = LOADADDR(.text);
  etext = .;
  
  .rodata : AT(ALIGN(LOADADDR(.text) + SIZEOF(.text), 4)) {
    . = ALIGN(4);
    _srodata = .;
    *(.rodata*)
    _erodata = .;
  } > sdram 
  _lsrodata = LOADADDR(.rodata);

  .data : AT(ALIGN(LOADADDR(.rodata) + SIZEOF(.rodata), 4)){
    . = ALIGN(4);
    _sdata = .;
    *(.data*)
    _edata = .;
  } > sdram 
  _lsdata = LOADADDR(.data);

  _data = .;

  .bss (NOLOAD) : {
    . = ALIGN(4);
    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  }>sdram

.stack (NOLOAD) :{
    . = ALIGN(0x4);
    _stack_top = .;
    . = ORIGIN(sram) + LENGTH(sram);
    _stack_pointer = .;
  }>sram

/* .stack (NOLOAD) :{
    . = ALIGN(0x1000);
    _stack_top = .;
    . = . + 0x8000;
    _stack_pointer = .;
  }>psram */

  end = .;
  _end = .;

  .heap (NOLOAD) :{
    . = ALIGN(0x4);
    _heap_start = .;
    . = ORIGIN(sdram) + LENGTH(sdram);
    _heap_end = .;
  }>sdram


}
