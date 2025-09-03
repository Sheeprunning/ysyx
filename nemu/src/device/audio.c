/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <common.h>
#include <device/map.h>
#include <SDL2/SDL.h>

enum {
  reg_freq,
  reg_channels,
  reg_samples,
  reg_sbuf_size,
  reg_init,
  reg_count,
  nr_reg
};

static uint8_t *sbuf = NULL;
static uint32_t *audio_base = NULL;

static uint32_t sbuf_rpos = 0;

static void audio_callback(void* userdata, Uint8* stream, int len){
  uint32_t count =audio_base[reg_count];
  
  if (count == 0) {
    memset(stream, 0, len);
    return;
  }

  uint32_t bytes_to_read = (len < count) ? len : count;
  int bytes_remain=sbuf_rpos+bytes_to_read-CONFIG_SB_SIZE;
  if(bytes_remain>0){
    memcpy(stream, sbuf + sbuf_rpos, bytes_to_read-bytes_remain);
    memcpy(stream + bytes_to_read-bytes_remain, sbuf, bytes_remain);
  }else{
    memcpy(stream, sbuf + sbuf_rpos, bytes_to_read);
  }
  
  sbuf_rpos = (sbuf_rpos + bytes_to_read) % CONFIG_SB_SIZE ;
  audio_base[reg_count] -= bytes_to_read;

  if (bytes_to_read < len) {
    memset(stream + bytes_to_read, 0, len - bytes_to_read);
  }
}

static void init_SDL_Audio(){
  SDL_AudioSpec s = {};
  s.format = AUDIO_S16SYS;  // 假设系统中音频数据的格式总是使用16位有符号数来表示
  s.userdata = NULL;        // 不使用
  s.freq = audio_base[reg_freq];
  s.channels = audio_base[reg_channels];
  s.samples = audio_base[reg_samples];
  s.callback = audio_callback;
  SDL_InitSubSystem(SDL_INIT_AUDIO);
  SDL_OpenAudio(&s, NULL);
  SDL_PauseAudio(0);
}

static void audio_io_handler(uint32_t offset, int len, bool is_write) {
  if (!is_write)return ;
  int index = offset / 4;
  if (is_write){
    switch (index){
      case reg_init:
        audio_base[reg_count]=0;
        sbuf_rpos = 0;
        init_SDL_Audio();
        break;
    }    
  }

}


void init_audio() {
  uint32_t space_size = sizeof(uint32_t) * nr_reg;
  audio_base = (uint32_t *)new_space(space_size);
  audio_base[reg_sbuf_size]=CONFIG_SB_SIZE;
#ifdef CONFIG_HAS_PORT_IO
  add_pio_map ("audio", CONFIG_AUDIO_CTL_PORT, audio_base, space_size, audio_io_handler);
#else
  add_mmio_map("audio", CONFIG_AUDIO_CTL_MMIO, audio_base, space_size, audio_io_handler);
#endif

  sbuf = (uint8_t *)new_space(CONFIG_SB_SIZE);
  add_mmio_map("audio-sbuf", CONFIG_SB_ADDR, sbuf, CONFIG_SB_SIZE, NULL);
}
