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

g_class=$1

# parent : public, protected members
get_accessable_members () {
    local class_file=$xmldir/class${1}.xml
    if [ -e $class_file ]; then
        :
    else
        echo $class_file not exist.
        return
    fi

    echo 'public-func:'
    echo 'cat /doxygen/compounddef/sectiondef[@kind="public-func"]/memberdef/name' | xmllint --shell $class_file | grep "\<name\>" | perl -pi -e 's/\<name\>(.*)\<\/name\>/$1/g'
    echo 

    echo 'public-attrib:'
    echo 'cat /doxygen/compounddef/sectiondef[@kind="public-attrib"]/memberdef/name' | xmllint --shell $class_file | grep "\<name\>" | perl -pi -e 's/\<name\>(.*)\<\/name\>/$1/g'
    echo 

    echo 'protected-func:'
    echo 'cat /doxygen/compounddef/sectiondef[@kind="protected-func"]/memberdef/name' | xmllint --shell $class_file | grep "\<name\>" | perl -pi -e 's/\<name\>(.*)\<\/name\>/$1/g'
    echo 

    echo 'protected-attrib:'
    echo 'cat /doxygen/compounddef/sectiondef[@kind="protected-attrib"]/memberdef/name' | xmllint --shell $class_file | grep "\<name\>" | perl -pi -e 's/\<name\>(.*)\<\/name\>/$1/g'
    echo 
}

get_accessable_members $1

