#include "watchpoint.h"
#define NR_WP 32

static WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
    wp_pool[i].wp_exp=NULL;
    wp_pool[i].value=0;
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */

void sort(){
  WP *wp=head;
  int i=0;
  while (wp!=NULL){
    wp->NO = i;
    i++;
    wp=wp->next;
  }
}
void new_wp(char *args){
  
  assert(free_ != NULL);
  WP *wp;
  
  bool success=true;
  int data=expr(args,&success);
  if(success){
    wp = free_;
    free_ = free_->next;
    wp -> next = head;
    head = wp;
    wp->wp_exp = strdup(args);
    wp->value=data;
  }
  //sort();
  return;
}

void free_wp(int NO){
  WP *wp=head,*temp;
  if (head == NULL) {
        printf("Error: No active watchpoints to free!\n");
        return;
    }
  if (head->NO == NO) {
        head = head->next;  // 从head链表中移除
        wp->next = free_;   // 回收至free_链表头
        free_ = wp;
        free(free_->wp_exp);//原本保存的表达式释放
        //sort();
        return;
    }
  while(wp->next!=NULL&&wp->next->NO!=NO){
    wp=wp->next;
  }
  if(wp->next){
    temp=wp->next;
    wp->next=wp->next->next;
    temp->next = free_;
    free_ = temp;
    free(free_->wp_exp);
    //sort();
    return;
  }else{
    printf("WP not found in the active list!"); 
    return;
  } 
}

WP* compare_watchpoint(bool *success,int *change){
  WP * wp = head;
  if(!wp)return NULL;
  printf("Comparing the watchpoint...!\n");
  while(wp != NULL){
    *change=expr(wp->wp_exp,success);
    if(!success){//计算表达式错误
      return NULL;
    }
    if(*change!=wp->value){
      return wp;//输出第一个改变的wp
    }
    wp=wp->next;
  }
  return NULL;//无变化
}

void show_watchpoint(){
  if(head==NULL){
    printf("There is not watchpoint!\n");
    return ;
  }
  printf("--NO-- --EXP-- --VALUE--\n");
  WP * wp = head;
  while(wp != NULL){
    printf("%-8d %-7s %-#8x\n",wp->NO,wp->wp_exp,wp->value);
    wp=wp->next;
  }
}