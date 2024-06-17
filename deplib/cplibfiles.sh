#! /bin/sh
dependList=$(ldd $1 | awk '{if (match($3,"/")){ print $3}}')
printf "\n=-=-=-=  Copy Lib Files  =-=-=-=\n"

while read lib_file; do
    if [ -n "$lib_file" ]; then
        printf "copy - ${lib_file}  >  ${var_destdir}${lib_file} \n" 
        cp -L -n ${lib_file} $2
    fi
done << END
    $dependList
END
printf "\n"
