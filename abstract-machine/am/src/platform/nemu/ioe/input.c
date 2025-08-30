#include <am.h>
#include <nemu.h>

#define KEYDOWN_MASK 0x8000
#define KEY_CODE_MASK 0x7FFF

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  kbd->keydown = (inl(KBD_ADDR)&KEYDOWN_MASK)!=0;
  kbd->keycode = inl(KBD_ADDR)&KEY_CODE_MASK;
}
