#include <am.h>
#include <ysyxsoc.h>
#include <stdio.h>

#define KEYDOWN_MASK 0x8000
#define KEY_CODE_MASK 0x7FFF

uint8_t buf[2] = {0,0};

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  uint8_t key_data = inb(KBD_ADDR);
  buf[1]=buf[0];
  buf[0]=key_data;
  kbd->keydown = buf[1]!=0xf0;
  kbd->keycode = key_code_to_enum[key_data];
}
