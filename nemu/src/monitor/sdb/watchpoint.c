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

#include "sdb.h"

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
void new_wp(char *args){
  assert(free_ != NULL);
  WP *wp;
  wp = free_;
  free_ = free_->next;
  wp -> next = head;
  head = wp;

  bool success=true;
  int data=expr(wp->wp_exp,&success);
  if(success){
    wp->wp_exp=args;
    wp->value=data;
  }
  return;
}
void free_wp(WP *wp){
  assert(wp!=NULL);
  WP *temp=head;
  if (head == NULL) {
        printf("Error: No active watchpoints to free!\n");
        return;
    }
  if (head == wp) {
        head = head->next;  // 从head链表中移除
        wp->next = free_;   // 回收至free_链表
        free_ = wp;
        return;
    }
  while(temp->next!=wp&&temp->next!=NULL){
    temp=temp->next;
  }
  if(temp->next){
    temp->next=temp->next->next;
    wp->next = free_;
    free_ = wp;
    return;
  }else{
    printf("WP not found in the active list!"); 
    return;
  } 
}

WP* compare_watchpoint(bool *success){
  WP * wp = head;
  int data;
  while(wp != NULL){
    data=expr(wp->wp_exp,success);
    if(!success){
      return NULL;
    }
    if(data!=wp->value){
      return wp;
    }
    wp=wp->next;
  }
  return NULL;//无变化
}

void show_watchpoint(){
  if(head==NULL){
    printf("There is not watchpoint!");
    return ;
  }
  WP * wp = head;
  while(wp != NULL){
    printf("NO.%d exp:%s value:%#x\n",wp->NO,wp->wp_exp,wp->value);
  }
}