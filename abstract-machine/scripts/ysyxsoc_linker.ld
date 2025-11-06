ENTRY(_start)
MEMORY {
  /*mrom(rx) : ORIGIN = 0x20000000, LENGTH = 4K*/
  flash(rx) : ORIGIN = 0x30000000, LENGTH = 256M
  sram(rwx) : ORIGIN = 0x0f000000, LENGTH = 8K
}
SECTIONS {
  . = ORIGIN(flash);
  .text : {
    *(entry)
    *(.text*)
  } > flash AT> flash
  etext = .;
  _etext = .;

  .rodata : {
    *(.rodata*)
  }

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
  } > sram AT> flash
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
