#!/bin/bash
#for i in `df -h|awk '{print $NF}'|sed '1d'|grep -v '/$'`;do [ `df -B 1g $i|awk '{print $(NF-2)}'|tail -1` -gt 400 ] && [ `df -h $i|tail -1|awk '{print $(NF-1)}'|sed 's/%//'` -lt 10 ] && [ `find $i -type f -ctime -30 2>/dev/null|wc -l` -eq 0 ] &&  echo -e " 内核版本:`uname -r` \n主机名:`hostname` \n文件系统名称:`df $i|awk '{print $1}'|tail -1`\n文件系统大小: `df -B 1g $i|awk '{print $2}'|tail -1`G\n目前使用率:`df -h $i|tail -1|awk '{print $(NF-1)}'`";done



for i in `df -h|awk '{print $NF}'|sed '1d'|grep -v '/$'`
do
    if [ `df -B 1g $i|awk '{print $(NF-2)}'|tail -1` -gt 400 ];then
        if [ `df -h $i|tail -1|awk '{print $(NF-1)}'|sed 's/%//'` -lt 10 ];then
            if [ `find $i -type f -ctime -30 2>/dev/null|wc -l` -eq 0 ];then
                echo -e " 内核版本:`uname -r` \n主机名:`hostname` \n文件系统名称:`df $i|awk '{print $1}'|tail -1`\n文件系统大小: `df -B 1g $i|awk '{print $2}'|tail -1`G\n目前使用率:`df -h $i|tail -1|awk '{print $(NF-1)}'`"

            fi
        fi
     fi
done


