#!/bin/bash
set -e
set -x
echo "usage: your-binary 2>&1 | $0 output-file-name keep-file-numbers max_file_size"
echo "E.g $0 mylogger 4 10241024"
if [ $# -lt 1 ];then
  echo "miss output-file-name" && exit 1
fi

output=$1
max_keep_file_num=${2-1}
if [ $max_keep_file_num -lt 1 ];then
  max_keep_file_num=1
fi
max_file_size=${3-102410240}
if [ $max_keep_file_num -lt 1 ];then
  max_keep_file_num=1
fi
set +x

echo > $output
output=`readlink -f $output`
fdir=`dirname $output`
num=1
while read line;do
  fsize=`stat --printf=%s $output`
  strlen=${#line}
  sum=$((fsize+strlen))

  # split output into like xxx.1 xxx.2 if size over threshold
  if [ $sum -gt $max_file_size ];then
    set -x
    mv $output $output.$num.$(date "+%Y-%m-%d_%H:%M:%S")

    # remove old output files
    n=$((num - max_keep_file_num + 1))
    if [ $n -gt 0 ];then
      flist=`find $fdir -type f -regex "$output.[1-9][0-9]*\..*"`
      for fname in $flist;do
        f_num=`echo -ne $fname | awk -F "$output." '{print $2}' |  cut -d '.' -f 1`
        if [ $f_num -le $n ];then
          rm -rf $fname
        fi
      done
    fi
    num=$((num+1))
    set +x
  fi
  echo $line >> $output
done
