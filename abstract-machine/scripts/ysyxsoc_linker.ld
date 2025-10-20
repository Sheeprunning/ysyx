ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

SECTIONS {
  /* _pmem_start and _entry_offset are defined in LDFLAGS 修改成了mrom的地址0x20000000*/
  . = _pmem_start + _entry_offset;
  .text : {
    *(entry)
    *(.text*)
  } : text
  etext = .;
  _etext = .;
  .rodata : {
    *(.rodata*)
  }
  .data : {
    *(.data*)
  } : data
  edata = .;
  _data = .;
  .bss : {
	_bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  }
  . = 0x0f000000;
  _heap_start = ALIGN(4);
  . = . + 0x1000;
  _heap_end = .;
  _stack_top = ALIGN(4);
  . = _stack_top + 0x1000;
  _stack_pointer = ALIGN(4);
  end = .;
  _end = .;
  
}
