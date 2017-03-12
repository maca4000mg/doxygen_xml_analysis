#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo " Usage:"
    echo '  $1 doxygen xml directory path'
    exit 1
fi

cd $(dirname $0)
xmldir=$2
cd $xmldir

classes=$(find $xmldir -name class*.xml | perl -pi -e  's/.*class(\w+)\.xml/$1/g')
echo $classes

