#include <am.h>
#include <nemu.h>

#define AUDIO_FREQ_ADDR      (AUDIO_ADDR + 0x00)
#define AUDIO_CHANNELS_ADDR  (AUDIO_ADDR + 0x04)
#define AUDIO_SAMPLES_ADDR   (AUDIO_ADDR + 0x08)
#define AUDIO_SBUF_SIZE_ADDR (AUDIO_ADDR + 0x0c)
#define AUDIO_INIT_ADDR      (AUDIO_ADDR + 0x10)
#define AUDIO_COUNT_ADDR     (AUDIO_ADDR + 0x14)

static uint32_t sbuf_rpos = 0;

void __am_audio_init() {
}

void __am_audio_config(AM_AUDIO_CONFIG_T *cfg) {
  cfg->present = true;
  cfg->bufsize=inl(AUDIO_SBUF_SIZE_ADDR);
}

void __am_audio_ctrl(AM_AUDIO_CTRL_T *ctrl) {
  outl(AUDIO_CHANNELS_ADDR,ctrl->channels);
  outl(AUDIO_FREQ_ADDR,ctrl->freq);
  outl(AUDIO_SAMPLES_ADDR,ctrl->samples);
  outl(AUDIO_INIT_ADDR,1);
}

void __am_audio_status(AM_AUDIO_STATUS_T *stat) {
  stat->count = inl(AUDIO_COUNT_ADDR);
}

void __am_audio_play(AM_AUDIO_PLAY_T *ctl) {
  uint8_t *start=(uint8_t*)ctl->buf.start;
  uint8_t *end=(uint8_t*)ctl->buf.end;
  int len=end-start;
  int count=inl(AUDIO_COUNT_ADDR);
  int buf_size=inl(AUDIO_SBUF_SIZE_ADDR);
  while(buf_size - count < len){
    count=inl(AUDIO_COUNT_ADDR);
  }
  for(uint32_t i= 0;i<len;i++){
    outb(AUDIO_SBUF_ADDR+sbuf_rpos,start[i]);
    sbuf_rpos=(sbuf_rpos+1)%buf_size;
  }
  outl(AUDIO_COUNT_ADDR, inl(AUDIO_COUNT_ADDR) + len);
}
