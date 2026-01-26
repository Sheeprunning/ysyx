#ifndef _SDB_H_
#define _SDB_H_

/* 核心函数 */
void sdb_set_batch_mode(void);
void sdb_mainloop(void);
void init_sdb() ;

/* 数组长度计算宏 */
#define ARRLEN(arr) (sizeof(arr) / sizeof(arr[0]))




#endif