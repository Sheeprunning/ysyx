ENTRY(_start)
/* PHDRS { text PT_LOAD; data PT_LOAD; } */
MEMORY {
  /* mrom(rx) : ORIGIN = 0x20000000, LENGTH = 4K */
  flash(rx) : ORIGIN = 0x30000000, LENGTH = 256M
  /* psram(rwx): ORIGIN = 0x80000000, LENGTH = 4M */
  sram(rwx) : ORIGIN = 0x0f000000, LENGTH = 8K
}
SECTIONS {
  . = ORIGIN(flash);
  .boot : {
    *(entry)
    
  } >flash AT > flash

  . = ORIGIN(sram);
  .text : {
    _stext = .;
    *(.text*)
    _etext = .;
  } > sram AT> flash
  _lstext = LOADADDR(.text);
  etext = .;
  
  .rodata : {
    _srodata = .;
    *(.rodata*)
    _erodata = .;
  } > sram AT > flash
  _lsrodata = LOADADDR(.rodata);

  .data : {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > sram AT> flash
  _lsdata = LOADADDR(.data);

  _data = .;

  .bss (NOLOAD) : {
    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  }>sram

  .heap (NOLOAD) :{
    . = ALIGN(4);
    _heap_start = .;
    . = . + 0x1000;
    _heap_end = .;
  }>sram

  .stack (NOLOAD) :{
    . = ALIGN(4);
    _stack_top = .;
    _stack_pointer = ORIGIN(sram) + LENGTH(sram);
    . = _stack_pointer;
  }>sram
  end = .;
  _end = .;
  
}
