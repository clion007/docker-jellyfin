#! /bin/sh
# Usage: cplibfiles.sh <target_dir> <binary> [<binary>...]
# Collect dynamic library dependencies of the given binaries into <target_dir>,
# preserving their absolute system paths (e.g. /usr/lib/libfoo.so -> <target_dir>/usr/lib/libfoo.so).
target_dir=$1
shift
mkdir -p $target_dir/lib $target_dir/usr/lib
dependList=$(for bin in "$@"; do ldd "$bin"; done | awk '{if (match($3,"/")){ print $3}}')
printf "\n=-=-=-=  Copy Lib Files  =-=-=-=\n"

# 添加计数器以显示进度
total=$(echo "$dependList" | wc -l)
count=0

while read lib_file; do
    if [ -n "$lib_file" ]; then
        count=$((count+1))
        printf "[%d/%d] copy - ${lib_file}  >  ${target_dir}${lib_file} \n" $count $total
        cp -r -L -n ${lib_file} ${target_dir}${lib_file}
    fi
done << END
    $dependList
END
printf "\nCopied %d library files\n" $count
