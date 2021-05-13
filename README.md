To see scheduling priorities in ascending order:
```
ps axwwH -eo user,pid,cpuid,spid,class,pri,ni,pcpu,nlwp,comm,args | sort +5n | grep '^USER\|^Jamulus'
```
Stuff about memory:
```
ps H -eo user,ppid,pid,spid,drs,rss,vsz,class,pri,ni,nlwp,cpuid,pcpu,comm,args | grep '^Jamulus\|^USER'
```
