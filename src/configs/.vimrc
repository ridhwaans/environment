syntax enable

set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set expandtab       " tabs are spaces
set cursorline      " highlight current line
set incsearch       " search as characters are entered
set hlsearch        " highlight search matches
set lazyredraw      " redraw only when we need to.
set showmatch       " highlight matching [{()}]
set number          " show current line number
set relativenumber  " show relative line numbers
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

let g:mapleader=' '

nnoremap <leader>w :w<CR> 
nnoremap <leader>q :q<CR>

" jump half-page up/down with cursor in middle-of-page
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" edit vimrc in a new tab
nnoremap evi :tabedit $MYVIMRC<CR>
" reload vimrc
nnoremap rvi :source $MYVIMRC<CR>
" goto tab by index
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
" tabs
nnoremap th  :tabfirst<CR>
nnoremap tk  :tabnext<CR>
nnoremap tj  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnext<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>
nnoremap tn  :tabnew<CR>
" panes
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>sh :split<CR>

" add a new buffer
nnoremap <leader>sn<left>  :topleft  vnew<CR>
nnoremap <leader>sn<right> :botright vnew<CR>
nnoremap <leader>sn<up>    :topleft  new<CR>
nnoremap <leader>sn<down>  :botright new<CR>

try
  execute 'colorscheme ' . g:colorscheme
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry

" vim-airline status bar theme
let g:airline_theme = g:colorscheme
