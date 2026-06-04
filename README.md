In case it all breaks...
```bash
sudo systemctl enable $(pwd)/Jamulus@.service
sudo systemctl daemon-reload
systemctl list-unit-files 'Jamulus@*'   ;# check that the service is enabled
for x in 1 2 3 4 5 6 7 8; do sudo systemctl enable --now Jamulus@Directory$x; done
for x in drealm-asia server wip; do sudo systemctl enable --now Jamulus@$x; done
```



To see scheduling priorities in ascending order:
```
#ps axwwH -eo user,pid,cpuid,spid,class,pri,ni,pcpu,nlwp,comm,args | grep '^USER\|^Jamulus' | sort +5n
ps wwH -U Jamulus -u Jamulus -o user,pid,cpuid,spid,class,pri,ni,pcpu,nlwp,comm,args | sort +5n
```
Stuff about memory:
```
#ps H -eo user,ppid,pid,spid,drs,rss,vsz,class,pri,ni,nlwp,cpuid,pcpu,comm,args | grep '^Jamulus\|^USER'
ps -U Jamulus -u Jamulus -o user,pid,vsz,rss,args | sort -k 6
```
