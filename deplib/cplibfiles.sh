#! /bin/bash
dependList=$( ldd $1 | awk '{if (match($3,"/")){ print $3}}' )
cp -L -n $deplist $2