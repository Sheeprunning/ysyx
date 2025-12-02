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
  .boot : {
    _sboot = .;
    *(boot)
    _eboot = .;
  } > sram AT> flash
  _lsboot = LOADADDR(.boot);

  . = ORIGIN(psram);
  .text : {
    _stext = .;
    *(.text*)
    _etext = .;
  } > psram AT> flash
  _lstext = LOADADDR(.text);
  etext = .;
  
  .rodata : {
    _srodata = .;
    *(.rodata*)
    _erodata = .;
  } > psram AT > flash
  _lsrodata = LOADADDR(.rodata);

  .data : {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > psram AT> flash
  _lsdata = LOADADDR(.data);

  _data = .;

  .bss (NOLOAD) : {
    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  }>psram

  .heap (NOLOAD) :{
    /* . = ALIGN(4); */
    _heap_start = .;
    . = . + 0x10000;
    _heap_end = .;
  }>psram

  .stack (NOLOAD) :{
    /* . = ALIGN(4); */
    _stack_top = .;
    _stack_pointer = ORIGIN(sram) + LENGTH(sram);
    . = _stack_pointer;
  }>sram
  end = .;
  _end = .;
  
}
