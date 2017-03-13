#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo " Usage:"
    echo '  $1 class name'
    echo '  $2 doxygen xml directory path'
    exit 1
fi

cd $(dirname $0)
xmldir=$2
cd $xmldir

class=$1
res=$(echo "cat /doxygen/compounddef/basecompoundref" \
    | xmllint --shell --noblanks --format class${class}.xml \
    | grep "basecompoundref" \
    | perl -pi -e 's/\<.*\>(\w+)\<.*\>/$1/g')
echo $res

