" 设置文件编码
set fenc=utf-8
set fencs=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936

" 启动语法检查
syntax enable
let mapleader=','

set shiftwidth=2

set autoindent
set smartindent


" enable all the plugin
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.

" General
syntax on
set mouse=
set clipboard=unnamed
set history=1000
autocmd FileType python setlocal et sta sw=4 sts=4
autocmd FileType python setlocal foldmethod=indent
set noswapfile " no create swap file when open file.
set nobackup
set nowritebackup
set modeline
set modelines=5
set autowrite
set autoread

let g:is_posix = 1

" vim gui
set tabpagemax=15
set noshowmode " hide the default mode text (e.g. -- INSERT -- below the statusline)
set cursorline
set shortmess=atI
autocmd InsertLeave * set cul
set scrolloff=3
set showcmd
set incsearch
set hlsearch
nnoremap <leader><space> :nohlsearch<CR>
set wildmenu
set foldenable
set foldlevelstart=10
set foldlevel=99
set foldmethod=indent
nnoremap <space> za

nnoremap j gj
nnoremap k gk

nnoremap B ^
nnoremap E $

nnoremap ^ <nop>
nnoremap $ <nop>

" 显示行号
set number
set relativenumber
set cmdheight=2
set langmenu=none
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

set viminfo+=!
filetype on
filetype indent on

nmap tt :%s/\t/    /g<CR>

" Open new split panes to right and bottom, which feels or natural
set splitbelow
set splitright

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Easy escaping to normal model
inoremap jk <esc>

" Move to the next buffer
nmap <leader>. :bnext<CR>
" Move to the previous buffer
nmap <leader>h :bprevious<CR>
" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <leader>bq :bp <BAR> bd #<CR>
" Show all open buffers and their status
nmap <leader>bl :ls<CR>

" Split window Resize
nnoremap <F7> :vertical resize -5<CR>
nnoremap <F8> :vertical resize +5<CR>
nnoremap <F9> :resize -5<CR>
nnoremap <F10> :resize +5<CR>

" formatting
set nowrap
set autoindent
set shiftwidth=2
set expandtab
set tabstop=2
set softtabstop=2
set matchpairs+=<:>

autocmd Filetype gitcommit setlocal spell textwidth=72

" Key (re)Mappings
nnoremap <leader>sv :source $MYVIMRC<CR>
nnoremap <leader>ev :vsp $MYVIMRC<CR>
nnoremap <leader>ez :vsp ~/.zshrc <CR>

nnoremap <leader>s :mksession<CR>