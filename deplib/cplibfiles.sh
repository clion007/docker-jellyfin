#! /bin/sh
mkdir -p $2/lib $2/usr/lib
dependList=$(ldd $1 | awk '{if (match($3,"/")){ print $3}}')
printf "\n=-=-=-=  Copy Lib Files  =-=-=-=\n"

while read lib_file; do
    if [ -n "$lib_file" ]; then
        printf "copy - ${lib_file}  >  $2${lib_file} \n"
        cp -r -L -n ${lib_file} $2${lib_file}
    fi
done << END
    $dependList
END
printf "\n"
