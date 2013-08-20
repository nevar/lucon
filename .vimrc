map <ESC>[27;5;9~ <C-Tab>
map! <ESC>[27;5;9~ <C-Tab>

map <ESC>[27;6;9~ <C-S-Tab>
map! <ESC>[27;6;9~ <C-S-Tab>

" Кодировка по умолчанию
set encoding=utf-8

set laststatus=2
set noshowmode

" Проверка русского и английского
set spell spelllang=ru_ru,en_us

" Изменение режима автодополения в командной строке
set wildmenu

" Хранение временных файлов и бесконечный UNDO
set undodir=~/tmp/
set directory=~/tmp/
set undofile

set ttyfast

" Подсветка поиска
set hls

" Распознавать списки, дополнять комментарии,
" не переносить строку после односимвольного слова
set formatoptions=qrn1tclj

" Максимальная ширина текста
set textwidth=80
set rnu
set nu
set autoindent
set ruler
set incsearch
set novisualbell t_vb=
set hidden
set mousehide
set backspace=indent,eol,start whichwrap+=<,>,[,]

set noexpandtab

set shiftwidth=4
set softtabstop=4
set tabstop=4

set listchars=tab:\ \ ,trail:·,extends:…,nbsp:‗
set list

set wildignore=*.beam,*.so,*.app,*.o,*/logs/*

imap <C-h> <Esc>gTa
nmap <C-h> gT
imap <C-l> <Esc>gta
nmap <C-l> gt

let mapleader=" "
let maplocalleader=" "

" Настройка для elzr/vim-json
let g:vim_json_syntax_conceal = 0

filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'tpope/vim-fugitive'
Bundle 'altercation/vim-colors-solarized'
Bundle 'sjl/gundo.vim'
Bundle 'nevar/revim'
Bundle 'seletskiy/vim-refugi'
Bundle 'wincent/Command-T'
Bundle 'SirVer/ultisnips'
Bundle 'Valloric/YouCompleteMe'
Bundle 'scrooloose/syntastic'
Bundle 'elzr/vim-json'
Bundle 'bling/vim-airline'

filetype plugin indent on
set nofoldenable

syntax enable
let g:solarized_termtrans=1
let g:solarized_hitrail=1
let g:solarized_underline=1
let g:solarized_visibility='low'
set background=dark
colorscheme solarized

" Настройка air-line
let g:airline_powerline_fonts = 1
let g:airline_theme='solarized'
let g:airline_enable_fugitive=1
let g:airline_enable_syntastic=1
let g:airline_section_z="%3p%%  %3l:%3v"

imap <C-t> <Esc>:CommandT<CR>
nmap <C-t> :CommandT<CR>

let g:CommandTAcceptSelectionTabMap=['<CR>', '<C-t>']
let g:CommandTAcceptSelectionMap='<NUL>'

call system('git rev-parse --git-dir 2> /dev/null')
if v:shell_error == 0
	let g:snips_author = system('git config -z --get user.name')
	let g:snips_author = v:shell_error != 0 ? 'Slava Yurin' : g:snips_author

	let g:snips_author_mail = system('git config -z --get user.email')
	let g:snips_author_mail = v:shell_error != 0 ? 'YurinVV@ya.ru' : g:snips_author_mail
else
	let g:snips_author = "Slava Yurin"
	let g:snips_author_mail = "YurinVV@ya.ru"
endif
let g:UltiSnipsDontReverseSearchPath="1"
let g:UltiSnipsExpandTrigger="<Nop>"
let g:UltiSnipsJumpForwardTrigger="<Nop>"
let g:UltiSnipsJumpBackwardTrigger="<Nop>"

let g:ulti_expand_or_jump_res = 0
fun EOJ()
	call UltiSnips_ExpandSnippetOrJump()
	if g:ulti_expand_or_jump_res == 0
		execute "normal \<PageDown>"
	endif
	return ""
endf

let g:ulti_jump_backwards_res = 0
fun JB()
	call UltiSnips_JumpBackwards()
	if g:ulti_jump_backwards_res == 0
		execute "normal \<PageUp>"
	endif
	return ""
endf

nnoremap <silent> <C-j> :call EOJ()<CR>
inoremap <silent> <C-j> <C-R>=EOJ()<CR>
snoremap <silent> <C-j> <Esc>:call UltiSnips_ExpandSnippetOrJump()<CR>

nnoremap <silent> <C-k> :call JB()<CR>
inoremap <silent> <C-k> <C-R>=JB()<CR>
snoremap <silent> <C-k> <Esc>:call UltiSnips_JumpBackwards()<CR>

nnoremap gs :Gstatus<CR>

nnoremap <silent> <localLeader><localLeader> :nohlsearch<CR>
