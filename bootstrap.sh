#!/usr/bin/env bash
# 设置变量值
#################### SETUP PARAMS
app_name='faeli-vim'
[ -z "$APP_PATH" ] && APP_PATH="$HOME/.faeli-vim"
[ -z "$REPO_URI" ] && REPO_URI='https://github.com/faeli/faeli-vim.git'
[ -z "$VUNDLE_URI" ] && VUNDLE_URI='https://github.com/VundleVim/Vundle.vim.git'
debug_mode=1
#################### SETUP tools
msg() {
    printf '%b\n' "$1" >&2
}

success() {
   msg  "\33[32m[✔]\33[0m ${1}${2}"
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    return
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
        msg "An error in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }

    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}

program_must_exist() {
    program_exists $1

    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        error "You must have '$1' installed to continue."
    fi
}

variable_set() {
    if [ -z "$1" ]; then
        error "You must have your $1 environmental variable set to continue."
    fi
}

lnif() {
    if [ -e "$1" ] ; then
        ln -sf "$1" "$2"
    fi
    ret="$?"
    debug
}

# do_backup

do_backup() {
    if [ -e "$1" ] || [ -e "$2" ] || [ -e "$3" ]; then
        msg "Attempting to back up your original vim configuration."
        today=`date +%Y%m%d_%s`
        for i in "$1" "$2" "$3"; do
            [ -e "$i" ] && [ ! -L "$i" ] && mv -v "$i" "$i.$today"
        done
        ret="$?"
        success "You original vim configuration has bean backed up."
    fi

    debug
}

rsync_repo() {
    local repo_path="$1"
    local repo_uri="$2"
    local repo_branch="$3"
    local repo_name="$4"
    
    msg "Trying to update $repo_name"

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone -b "$repo_branch" "$repo_uri" "$repo_path"
        ret="$?"
        success "Successfullly cloned $repo_name"
    else
        cd "$repo_path" && git pull origin "$repo_branch"
        ret="$?"
        success "Successfully updated $repo_name"
    fi

    debug
}

create_symlinks() {
    local source_path="$1"
    local target_path="$2"

    lnif "$source_path/.vimrc"          "$target_path/vimrc"
    lnif "$source_path/.vimrc.bundles"  "$target_path/vimrc.bundles"

    ret="$?"
    success "Setting up vim symlinks."
    debug
}

setup_vundle() {
    local system_shell="$SHELL"
    export SHELL="/bin/sh"
    vim -u "$1" "+set nomore" "+PluginInstall!" "+PluginClean" "+qall"
    export SHELL="$system_shell"
    success "Now updating/installing plugins using Vundle.vim"
    debug
}

################# SETUP

# 1,verify environment
variable_set "$HOME"
# 2,verify program
program_must_exist "vim"
program_must_exist "git"

# 3, backup .vim .vimrc .gvimrc
do_backup   "$HOME/.vimrc" "$HOME/.gvimrc"

# 4, rsync_repo faeli-vim
rsync_repo  "$APP_PATH" "$REPO_URI" "master" "$app_name"

# 5, create symlinks file
create_symlinks "$APP_PATH" "$HOME"

# 6, rsync_repo Vundle.vim
rsync_repo "$HOME/.vim/bundle/Vundle.vim" "$VUNDLE_URI" "master" "Vundle.vim"

# 7, setup vundle
setup_vundle    "$APP_PATH/vimrc"

# 8, show msg
msg             "\nThanks for installing $app_name."
msg             "© `date +%Y` http://vim.faeli.com/"
