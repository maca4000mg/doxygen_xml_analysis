#!/bin/bash

if [ $# -ne 1 ]; then
    echo input doxygen-xml directory path.
fi

get_parent_classes() {
    local class=$1
    local xmldir=$2

    get_parent_class $class $xmldir
    echo $class
}

get_parent_class() {
    local class=$1
    local xmldir=$2
    local parent=$(parent_class $class $xmldir)
    if [ -z $parent ]; then
        return
    fi
    get_parent_class $parent $xmldir
    echo $parent
}

parent_class() {
    local class=$1
    local xmldir=$2
    local parent=$(echo "cat /doxygen/compounddef/basecompoundref" \
        | xmllint --shell --noblanks --format ${xmldir}/class${class}.xml \
        | grep "basecompoundref" \
        | perl -pi -e 's/\<.*\>(\w+)\<.*\>/$1/g')
    echo $parent
}

get_child_classes() {
    local class=$1
    local xmldir=$2
    local res=$(echo "cat /doxygen/compounddef/derivedcompoundref" \
        | xmllint --shell --noblanks --format ${xmldir}/class${class}.xml \
        | grep "derivedcompoundref" \
        | perl -pi -e 's/\<.*\>(\w+)\<.*\>/$1/g')
    echo $res
}

get_accessable_member() {
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
}

get_accessable_members() {
    local class=$1
    local xmldir=$2
    local class_file=$xmldir/class${1}.xml
    if [ -e $class_file ]; then
        :
    else
        echo $class_file not exist.
        return
    fi

    # 親クラスのメンバを再帰的に出力

    parent=$(parent_class $class $xmldir)
    if [ -z $parent ]; then
        return
    fi
    get_accessable_members $parent $xmldir
    pub_funcs=$(echo 'cat /doxygen/compounddef/sectiondef[@kind="public-func"]/memberdef/name' | xmllint --shell $class_file | grep "\<name\>" | perl -pi -e 's/\<name\>(.*)\<\/name\>/$1/g')
    if [ -n "$pub_funcs" ]; then
        for pub_func in $pub_funcs; do
            echo $class::$pub_func"()"
        done
    fi

    pub_vars=$(echo 'cat /doxygen/compounddef/sectiondef[@kind="public-attrib"]/memberdef/name' | xmllint --shell $class_file | grep "\<name\>" | perl -pi -e 's/\<name\>(.*)\<\/name\>/$1/g')
    if [ -n "$pub_vars" ]; then
        for pub_var in $pub_vars; do
            echo $class::$pub_var
        done
    fi

    pro_funcs=$(echo 'cat /doxygen/compounddef/sectiondef[@kind="protected-func"]/memberdef/name' | xmllint --shell $class_file | grep "\<name\>" | perl -pi -e 's/\<name\>(.*)\<\/name\>/$1/g')
    if [ -n "$pro_funcs" ]; then
        for pro_func in $pro_funcs; do
            echo $class::$pro_func"()"
        done
    fi

    pro_vars=$(echo 'cat /doxygen/compounddef/sectiondef[@kind="protected-attrib"]/memberdef/name' | xmllint --shell $class_file | grep "\<name\>" | perl -pi -e 's/\<name\>(.*)\<\/name\>/$1/g')
    if [ -n "$pro_vars" ]; then
        for pro_var in $pro_vars; do
            echo $class::$pro_var
        done
    fi
}

select_function() {
    local xmldir=$1
    cd $xmldir
    local fzf_res=$(find $xmldir -name "class*.xml" -printf "%f\n" | \
        perl -pi -e 's/^class(.*)\.xml/\1/g' | \
        fzf --ansi --no-sort --expect=ctrl-a,ctrl-d,ctrl-u)

    local key="$(head -1 <<< "$fzf_res")"
    local class="$(head -2 <<< "$fzf_res" | tail -1)"

    case $key in
        "ctrl-a")
            #echo get member of $class
            get_accessable_members $class $xmldir
            ;;
        "ctrl-d")
            #echo get child class of $class
            get_child_classes $class $xmldir
            ;;
        "ctrl-u")
            #echo get parent class of $class
            get_parent_classes $class $xmldir
            ;;
        *)
            echo nop
            ;;
esac
}

cd $(dirname $0)
select_function $1

