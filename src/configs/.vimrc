syntax enable

set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set cursorline      " highlight current line
set incsearch       " search as characters are entered
set hlsearch        " highlight matches
set lazyredraw      " redraw only when we need to.
set showmatch       " highlight matching [{()}]
set number          " show line numbers
set laststatus=2    " display status line

" vim-plug
let g:vim_plug_home = '/usr/local/share/vim/bundle'
let g:vim_plug_colorscheme = "whatyouhide/vim-gotham"
let g:colorscheme = "gotham256"

execute 'source ' . g:vim_plug_home . '/autoload/plug.vim'

call plug#begin(g:vim_plug_home . '/plugged')

Plug g:vim_plug_colorscheme

call plug#end()

map <F1> :set nonumber!<CR>
map <F2> :NERDTreeToggle<CR>
map <F3> :AirlineToggle<CR>

" jump half-page up/down and cursor middle
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

try
  execute 'colorscheme ' . g:colorscheme
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry

" vim-airline status bar theme
let g:airline_theme = g:colorscheme
