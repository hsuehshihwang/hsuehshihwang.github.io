---
layout: post
title:  "Linux Work Queue and Wait Queue Sample Code (1)"
date:   2021-08-11 19:12:00 +0800
tags:
  - driver
  - post
---

DECLARE_WAIT_QUEUE_HEAD(), wait_event_interruptible(), flag, wake_up_interruptible()

alloc_workqueue(), INIT_WORK(), queue_work(), flush_workqueue(), destroy_workqueue()

struct workqueue_struct *, struct work_struct

<!--more-->

```
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/delay.h>
#include <linux/workqueue.h>
#include <linux/wait.h>
#include <linux/sched.h>
#include <linux/delay.h>

struct workqueue_struct *workqueue_test;

struct work_struct work_test;

// #define WORK_LOOP 
#ifdef WORK_LOOP
static int stop = 0; 
#else
static DECLARE_WAIT_QUEUE_HEAD(waitqueue_test);
static char flag = 'n';
#endif

void work_test_func(struct work_struct *work)
{
    printk("%s()\n", __func__);

#ifdef WORK_LOOP
    mdelay(5000);

    if(!stop) queue_work(workqueue_test, &work_test);

#else
    printk("Blocking...\n");

    // wait for flag and event
    wait_event_interruptible(waitqueue_test, flag == 'y');
    
    printk("Leave blocking...\n");

#endif

}


static int test_init(void)
{
    printk("Hello,world!\n");

    // alloc workqueue
    workqueue_test = alloc_workqueue("workqueue_test", 0, 0);
    
    // init work
    INIT_WORK(&work_test, work_test_func);
    
    // append work into workqueue
    queue_work(workqueue_test, &work_test);
    
    return 0;

}

static void test_exit(void)
{
    printk("Goodbye,cruel world!\n");
    flag = 'y'; 
    wake_up_interruptible(&waitqueue_test);
#ifdef WORK_LOOP
    stop = 1; 
#endif
    flush_workqueue(workqueue_test);
    destroy_workqueue(workqueue_test);
}

module_init(test_init);
module_exit(test_exit);

MODULE_AUTHOR("Ralph Wang<enhanceralph@gmail.com>");
MODULE_LICENSE("Dual BSD/GPL");


```

