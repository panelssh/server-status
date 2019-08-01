#!/bin/bash

function get_username {
    if [ -z "$1" ]; then
        echo "You must put user name github"
        exit 1
    else
        git init
        git config user.name \"$1\"
    fi
}

function get_useremail {
    if [ -z "$1" ]; then
        echo "You must put user email github"
        remove_git
        exit 1
    else
        git config user.email \"$1\"
    fi
}

function get_repository {
    if [ -z "$2" ]; then
        echo "You must put repository name"
        remove_git
        exit 1
    else
        git add .
        git commit -m "first commit"
        repository="git@github.com-$1:$1/$2.git"
        git remote add origin $repository
    fi
}

function git_push {
    if [ -z "$1" ]; then
        git push -u origin master
    else
        git push -u origin master -f
    fi
}

function remove_git {
    rm -rf .git
}   

case $1 in
    setup)
        remove_git
        get_username $2
        get_useremail $3
        get_repository $2 $4
        git_push $5
    ;;
    remove)
        remove_git
    ;;
esac
