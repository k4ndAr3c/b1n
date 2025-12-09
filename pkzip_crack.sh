#!/usr/bin/env bash

archive="$1"

# select Method Store
test=$(7z l -slt $archive |grep -E 'Path|Method'|grep -B1 --line-buffered Store|awk '{print $3}')

if [ -z "$test" ]; then
  echo "No files with 'Store' method found in the archive."
  exit 
fi

test=$(echo $test|awk '{print $1}')
echo "[+] Found $test !"

ext=${test##*.}

case $ext in
  jpg|jpeg)
	echo "JPEG file detected."
    echo -ne '\xFF\xD8\xFF\xE0\x00\x10\x4A\x46\x49\x46\x00\x01' > header.bin
	;;
  png)
	echo "PNG file detected."
	echo -en '\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52' > header.bin
	;;
  *)
	echo "Unsupported file type: $ext"
	exit 1
	;;
esac

res=$(bkcrack -C $archive -c $test -p header.bin|tail -n1)
echo "[+] Get keys: $res"
bkcrack -C $archive -k $res -U new.zip password


