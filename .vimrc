set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'rhysd/vim-clang-format'
Plugin 'mxw/vim-jsx'

call vundle#end()
filetype plugin indent on

autocmd FileType java ClangFormatAutoEnable
" for linux only
let g:clang_format#command="clang-format-4.0"

autocmd FileType javascript.jsx,javascript setlocal formatprg=prettier\ --stdin
autocmd BufWritePre *.js :normal gggqG

let g:jsx_ext_required = 0

set number
syntax on
set tabstop=4
set autoindent
