ENTRY(_start)
/* PHDRS { text PT_LOAD; data PT_LOAD; } */
MEMORY {
  /* mrom(rx) : ORIGIN = 0x20000000, LENGTH = 4K */
  flash(rx) : ORIGIN = 0x30000000, LENGTH = 256M
  psram(rwx): ORIGIN = 0x80000000, LENGTH = 4M
  sram(rwx) : ORIGIN = 0x0f000000, LENGTH = 8K
}
SECTIONS {
  . = ORIGIN(flash);
  .start : {
    *(entry)
  } >flash AT > flash

  . = ORIGIN(sram);

  .copy : {
    _scopy = .;
    *(copy)
    _ecopy = .;
  } > sram AT> flash
  _lscopy = LOADADDR(.copy);

  .boot : {
    _sboot = .;
    *(boot)
    _eboot = .;
  } > sram AT> flash
  _lsboot = LOADADDR(.boot);

  . = ORIGIN(sdram);
  .text : {
    _stext = .;
    *(.text*)
    _etext = .;
  } > sdram AT> flash
  _lstext = LOADADDR(.text);
  etext = .;
  
  .rodata : {
    _srodata = .;
    *(.rodata*)
    _erodata = .;
  } > sdram AT > flash
  _lsrodata = LOADADDR(.rodata);

  .data : {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > sdram AT> flash
  _lsdata = LOADADDR(.data);

  _data = .;

  .bss (NOLOAD) : {
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
    . = ORIGIN(psram) + LENGTH(psram);
    _heap_end = .;
  }>sdram

  
  
}
