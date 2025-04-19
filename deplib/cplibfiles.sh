#! /bin/sh
mkdir -p $2/lib $2/usr/lib
dependList=$(ldd $1 | awk '{if (match($3,"/")){ print $3}}')
printf "\n=-=-=-=  Copy Lib Files  =-=-=-=\n"

# 添加计数器以显示进度
total=$(echo "$dependList" | wc -l)
count=0

while read lib_file; do
    if [ -n "$lib_file" ]; then
        count=$((count+1))
        printf "[%d/%d] copy - ${lib_file}  >  $2${lib_file} \n" $count $total
        cp -r -L -n ${lib_file} $2${lib_file}
    fi
done << END
    $dependList
END
printf "\nCopied %d library files\n" $count
