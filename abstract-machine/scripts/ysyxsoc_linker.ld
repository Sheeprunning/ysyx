ENTRY(_start)
/* PHDRS { text PT_LOAD; data PT_LOAD; } */
MEMORY {
  mrom(rx) : ORIGIN = 0x20000000, LENGTH = 4K
  sram(rwx) : ORIGIN = 0x0f000000, LENGTH = 8K
}
SECTIONS {
  . = ORIGIN(mrom);
  .text : {
    *(entry)
    *(.text*)
  } > mrom AT> mrom
  etext = .;
  _etext = .;

  .rodata : {
    *(.rodata*)
    
  }

  .data : {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > sram AT> mrom
  _lsdata = LOADADDR(.data);

  _data = .;
  .bss : {
	  _bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
    _bss_end = .;
  }>sram
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
