#include "types.h"
#include "x86.h"
#include "defs.h"
#include "date.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
  return fork();
}

int
sys_exit(void)
{
  exit();
  return 0;  // not reached
}

int
sys_wait(void)
{
  return wait();
}

int
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
  return kill(pid);
}

int
sys_getpid(void)
{
  return proc->pid;
}

int
sys_sbrk(void)
{
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = proc->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

int
sys_sleep(void)
{
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(proc->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
  uint xticks;
  
  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
int
sys_date(rtcdate)
{

 struct rtcdate *d;
 argptr(0, (void*)&d, sizeof(*d));
cmostime(d);

return 0;

}
int
sys_timem(void)
{
return 0;

}


int
sys_getuid(void)
{

  return proc->uid;

}
int
sys_getgid(void)
{
  return proc->gid;

}

int
sys_getppid(void)
{
  return proc->parent->pid;

}

int
sys_setuid(void)
{
  int fuid;

  if(argint(0, &fuid) < 0)
    return -1;
proc->uid=fuid;
return 0;

}
int
sys_setgid(void)
{
  int fgid;

  if(argint(0, &fgid) < 0)
    return -1;
proc->gid=fgid;
return 0;
}

int
sys_getprocs(void)
{
int max;
struct uproc *table;

if (argint(0, (void*)&max) < 0) {
return -1;
}

if (argptr(1, (void*)&table, sizeof(*table)) < 0) {
return -1;
}

return getProcInfo(max, table);
}


int
sys_setpriority(void)
{
int pid;
int priority;
if (argint(0, &pid) < 0)
return -1;
if (argint(1, &priority) < 0)
return -1;
return setpriority(pid,priority);
}