#include <am.h>
#include <nemu.h>

#define KEYDOWN_MASK 0x8000
#define KEY_CODE_MASK 0x7FFF

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  uint32_t key_data = inl(KBD_ADDR);
  kbd->keydown = (key_data&KEYDOWN_MASK)!=0;
  kbd->keycode = key_data&KEY_CODE_MASK;
}
