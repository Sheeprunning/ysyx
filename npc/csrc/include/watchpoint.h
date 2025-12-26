#ifndef __WP_H__
#define __WP_H__

typedef struct watchpoint {
  int NO;
  struct watchpoint *next;

  /* TODO: Add more members if necessary */
  char *wp_exp;
  int value;
} WP;

void init_wp_pool() ;
void new_wp(char *args);
void free_wp(int NO);
WP* compare_watchpoint(bool *success,int *change);
void show_watchpoint();


#endif