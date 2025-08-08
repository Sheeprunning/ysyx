#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

/*
va_list ap	定义一个指针，用于遍历可变参数列表	类似迭代器 iterator
va_start	初始化 ap，使其指向固定参数（fmt）之后的第一个可变参数	相当于 iter = begin()
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
    *p-- = '\0';
    while (start < p) {
        char tmp = *start;
        *start++ = *p;
        *p-- = tmp;
    }
    return p + 1;
}

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  char *start = out;       // 记录起始位置
    while (*fmt) {
        if (*fmt != '%') {
            *out++ = *fmt++; // 普通字符直接复制
            continue;
        }
        
        fmt++; // 跳过'%'
        switch (*fmt++) {
            case 'd': {      // 处理十进制整数
                int num = va_arg(ap, int);
                out = itoa(num, out, 10);
                break;
            }
            case 's': {      // 处理字符串
                char *s = va_arg(ap, char *);
                while (*s) *out++ = *s++;
                break;
            }
            case 'c': {      // 处理字符
                *out++ = va_arg(ap, int);
                break;
            }
            case 'x': {      // 处理十六进制
                uint32_t num = va_arg(ap, uint32_t);
                out = itoa(num, out, 16);
                break;
            }
            case '%': {      // 处理'%'字面量
                *out++ = '%';
                break;
            }
            default: {       // 无效格式符
                *out++ = '%';
                *out++ = *(fmt-1);
                break;
            }
        }
    }
    *out = '\0';             // 添加字符串终结符
    return out - start;      // 返回写入的字符数（不含'\0'）
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
