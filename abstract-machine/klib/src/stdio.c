#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

/*
va_list ap	定义一个指针，用于遍历可变参数列表	类似迭代器 iterator
va_start	初始化 ap，使其指向固定参数（fmt）之后的第一个可变参数,即...的第一个参数。相当于 iter = begin()
va_arg(ap, type)：读取 type 类型的参数，并移动 ap 到下一个参数
va_end	清理 ap 的状态（某些平台需要释放资源）	相当于 iter = end()
*/
static char* itoa(int val, char *buf, int base) {
    static const char digits[] = "0123456789abcdef";
    char *p = buf;
    unsigned abs_val = (val < 0) ? -val : val;
    
    // 处理负数
    if (val < 0 && base == 10) *p++ = '-';
    
    // 从低位开始转换
    char *start = p;
    do {
        *p++ = digits[abs_val % base];
        abs_val /= base;
    } while (abs_val > 0);
    
    // 反转数字顺序
    char *end=p;
    *p-- = '\0';
    while (start < p) {
        char tmp = *start;
        *start++ = *p;
        *p-- = tmp;
    }
    return end;
}

int printf(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  char out[256];
  int len = vsprintf(out, fmt, ap);
  for (char *p = out; *p; p++) {
        putch(*p);  // 逐字符输出
    }
  va_end(ap);
  return len;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  char *start = out;       // 记录起始位置
    while (*fmt) {
        if (*fmt != '%') {
            *out++ = *fmt++; // 普通字符直接复制
            continue;
        }
        
        const char *fmt_start = fmt;

        fmt++; // 跳过'%'
        int width=0;
        int zero_pad=0;
        int left_align=0;

        while(*fmt=='0' || *fmt=='-'){
            if(*fmt=='0')zero_pad=1;
            if(*fmt=='-')left_align=1;
            fmt++;
        }

        while(*fmt>='0'&&*fmt<'9'){
            width = width * 10 + (*fmt - '0');
            fmt++;
        }

        char buffer[32];  // 临时缓冲区用于数字转换
        char *temp_ptr;
        int num, len, padding;
        
        switch (*fmt) {
            case 'd': {
                num = va_arg(ap, int);
                temp_ptr = itoa(num, buffer, 10);
                len = temp_ptr - buffer;
                
                padding = width > len ? width - len : 0;
                
                if (!left_align && padding > 0) {
                    for (int i = 0; i < padding; i++) {
                        *out++ = zero_pad ? '0' : ' ';
                    }
                }

                for (int i = 0; i < len; i++) {
                    *out++ = buffer[i];
                }
                if (left_align && padding > 0) {
                    for (int i = 0; i < padding; i++) {
                        *out++ = ' ';
                    }
                }
                break;
            }
            
            case 's': {
                char *s = va_arg(ap, char *);
                len = strlen(s);
                padding = width > len ? width - len : 0;
                
                if (!left_align && padding > 0) {
                    for (int i = 0; i < padding; i++) {
                        *out++ = ' ';
                    }
                }
                while (*s) *out++ = *s++;
                
                if (left_align && padding > 0) {
                    for (int i = 0; i < padding; i++) {
                        *out++ = ' ';
                    }
                }
                break;
            }
            
            case 'c': {
                char c = va_arg(ap, int);
                padding = width > 1 ? width - 1 : 0;
                
                if (!left_align && padding > 0) {
                    for (int i = 0; i < padding; i++) {
                        *out++ = ' ';
                    }
                }
                
                *out++ = c;
                
                if (left_align && padding > 0) {
                    for (int i = 0; i < padding; i++) {
                        *out++ = ' ';
                    }
                }
                break;
            }
            
            case 'x': {
                uint32_t num = va_arg(ap, uint32_t);
                temp_ptr = itoa(num, buffer, 16);
                len = temp_ptr - buffer;
                padding = width > len ? width - len : 0;
                
                if (!left_align && padding > 0) {
                    for (int i = 0; i < padding; i++) {
                        *out++ = zero_pad ? '0' : ' ';
                    }
                }
                
                for (int i = 0; i < len; i++) {
                    *out++ = buffer[i];
                }
                
                if (left_align && padding > 0) {
                    for (int i = 0; i < padding; i++) {
                        *out++ = ' ';
                    }
                }
                break;
            }
            
            case '%': {
                *out++ = '%';
                break;
            }
            
            default: {
                while (fmt_start <= fmt) {
                    *out++ = *fmt_start++;
                }
                break;
            }
        }
        fmt++;

    }
    *out = '\0';             
    return out - start;      
}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int len = vsprintf(out, fmt, ap);
  va_end(ap);
  return len;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
