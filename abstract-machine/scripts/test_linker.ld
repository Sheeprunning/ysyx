ENTRY(_start)
/* PHDRS { text PT_LOAD; data PT_LOAD; } */
MEMORY {
  rom(rx) : ORIGIN = 0x20000000, LENGTH = 4k
  sram(rwx) : ORIGIN = 0xf000000, LENGTH = 4k
}
SECTIONS {
  . = ORIGIN(rom);
  .text : {
    *(entry)
    *(.text*)
  } > rom AT> rom
  etext = .;
  _etext = .;

  .rodata : {
    *(.rodata*)
  } > rom

  .bss : {
    _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  }>sram

  .data : {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > sram
  _lsdata = LOADADDR(.data);

  _data = .;
  
  /* _data_size =ABSOLUTE(_edata - _sdata);
  _bss_size = ABSOLUTE(_bss_end - _bss_start); */

  .heap (NOLOAD) :{
    . = ALIGN(4);
    _heap_start = .;
    . = . + 0x1000;
    _heap_end = .;
  }>sram

  .stack (NOLOAD) :{
    _stack_top = ALIGN(4);
    . = ORIGIN(sram) + LENGTH(sram);
    _stack_pointer = ALIGN(4);
  }>sram
  end = .;
  _end = .;
  
}
