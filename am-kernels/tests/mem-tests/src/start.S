.section .text
.global _start
_start:
    # 初始化栈指针（如果需要）
    # la sp, _stack_poniter
    
    # 跳转到 C 主函数
    call main
    
    # 如果 main 返回，进入死循环
1:
    j 1b