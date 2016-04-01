#!/usr/bin/env bash
# 设置变量值
#################### SETUP PARAMS
app_name='faeli-vim'
[ -z "$APP_PATH" ] && APP_PATH="$HOME/.faeli-vim"
[ -z "$REPO_URI" ] && REPO_URI='https://github.com/faeli/faeli-vim.git'
[ -z "$VUNDLE_URI" ] && VUNDLE_URI='https://github.com/VundleVim/Vundle.vim.git'

#################### SETUP tools
msg() {
    printf '%b\n' "$1" >&2
}

success() {
   msg  "\33[32m[✔]\33[0m ${1}${2}"
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
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
        error "You must have your HOME environmental variable set to continue."
    fi
}

msg "ok info"

success "success" " 2 tow"

error "error"
