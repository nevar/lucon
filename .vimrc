" Режим совместимости выключен
set nocompatible

" Кодировка по умолчанию
set encoding=utf-8

" Изменение режима автодополения в командной строке
set wildmenu

" Хранение временных файлов и бесконечный UNDO
set undofile
set undodir=~/tmp/
set directory=~/tmp/

set ttyfast

" Подсветка поиска
set hls

" Распознавать списки, дополнять комментарии,
" не переносить строку после односимвольного слова
set formatoptions=qrn1tl

" Максимальная ширина текста
set textwidth=80

set rnu
set autoindent
set ruler
set incsearch
"set scrolljump=7 scrolloff=7
set novisualbell t_vb=
set hidden
set mousehide
set backspace=indent,eol,start whichwrap+=<,>,[,]

set noexpandtab

set shiftwidth=4
set softtabstop=4
set tabstop=4


"set list
"set lcs=tab:\|_

imap {<CR> {<CR>}<Esc>O
imap [ []<Esc>i
imap ( ()<Esc>i

imap <C-j> <C-O><C-D>
nmap <C-j> <C-D>

imap <C-k> <C-O><C-U>
nmap <C-k> <C-U>

imap <C-h> <Esc>gTa
nmap <C-h> gT
imap <C-l> <Esc>gta
nmap <C-l> gt

imap <C-n> <Esc><C-w>ni
nmap <C-n> <C-w>n

"imap <C-w> <Esc><C-w>qa
"nmap <C-w> <C-w>q

imap <C-t> <Esc>:tabnew <bar> :FufCoverageFile<CR>
nmap <C-t> :tabnew <bar> :FufCoverageFile<CR>

imap <F2> <Esc>:w<CR>i
nmap <F2> :w<CR>

nmap <PageUp> <C-U>
imap <PageUp> <C-O><C-U>

nmap <PageDown> <C-D>
imap <PageDown> <C-O><C-D>

filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'L9'
Bundle 'FuzzyFinder'
Bundle 'tpope/vim-fugitive'
Bundle 'altercation/vim-colors-solarized'
Bundle 'nevar/erlang-syntax'
Bundle 'scrooloose/syntastic'
Bundle 'sjl/gundo.vim'
Bundle 'pydave/AsyncCommand'

filetype plugin indent on
set nofoldenable

syntax enable
let g:solarized_termtrans=1
let g:solarized_hitrail=1
set background=dark
colorscheme solarized

let g:fuf_coveragefile_exclude = '\v\~$|\.(o|so|exe|dll|bak|orig|swp|beam|pyc|app)$|\.eunit/|doc/|\.gitignore|erl_crash\.dump'

" disable arrow keys
map  <up>    <nop>
map  <down>  <nop>
map  <left>  <nop>
map  <right> <nop>
imap <up>    <nop>
imap <down>  <nop>
imap <left>  <nop>
imap <right> <nop>

let g:spell_executable="aspell"
let g:spell_language="ru"
