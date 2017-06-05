let mapleader = "\<Space>"
" plugins {{{

" plug begin{{{
if &compatible
  set nocompatible
endif

if has('nvim')
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
    silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')
" }}}

" misc {{{
Plug 'NLKNguyen/papercolor-theme'
Plug 'jemaw/vim-noctwo'
Plug 'tpope/vim-commentary'
Plug 'wellle/targets.vim'
Plug 'airblade/vim-gitgutter'

Plug 'ludovicchabant/vim-gutentags'
    let g:gutentags_ctags_tagfile = ".tags"
Plug 'MarcWeber/vim-addon-local-vimrc'
    let g:local_vimrc = {'names':['.lvimrc']}
" }}}

" Autocompletion {{{
Plug 'Shougo/deoplete.nvim'
    autocmd InsertLeave * if pumvisible() == 0 | pclose | endif
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#enable_smart_case = 1
    let g:deoplete#auto_completion_start_length = 2
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

Plug 'zchee/deoplete-jedi',{'for' : 'python'}
    let deoplete#sources#jedi#show_docstring=1

Plug 'Shougo/neoinclude.vim'
if executable('clang')
    " use .lvimrc with let g:deoplete#sources#clang#flags = ['-I/path/to/include']
    Plug 'zchee/deoplete-clang',{'for': ['cpp','c']} 
        let g:deoplete#sources#clang#libclang_path = '/usr/lib/libclang.so'
        let g:deoplete#sources#clang#clang_header = '/usr/lib/clang'
endif

if executable("gocode")
    Plug 'zchee/deoplete-go', {'do' : 'make'}
endif
if executable("racer")
    Plug 'sebastianmarkow/deoplete-rust'
    let g:deoplete#sources#rust#racer_binary='/usr/bin/racer'
    let g:deoplete#sources#rust#rust_source_path='/home/jean/packages/rust/src'
endif

" }}}

" Snippets  {{{

Plug 'SirVer/ultisnips' ", {'on_i':1}
    set rtp+=~/.config/nvim/snippets
    let g:UltiSnipsSnippetsDir="~/.config/nvim/snippets/UltiSnips"
    let g:UltiSnipsExpandTrigger="<c-l>"
    let g:UltiSnipsJumpForwardTrigger="<c-l>"
    let g:UltiSnipsJumpBackwardTrigger="<c-b>"

Plug 'honza/vim-snippets' ", {'on_i':1}

" }}}

" Language Specific {{{
Plug 'google/vim-ft-bzl'
Plug 'octol/vim-cpp-enhanced-highlight',{'for': 'cpp'}
Plug 'mitsuhiko/vim-python-combined', {'for' : 'python'}
Plug 'fatih/vim-go', {'for' : 'go'}
    " let g:go_fmt_command = "goimports"
    let g:go_fmt_fail_silently = 1
    let g:go_fmt_experimental = 1
    let g:go_fmt_autosave = 0
    let g:go_metalinter_autosave = 0
    let g:go_snippet_engine = "ultinsips"
    let g:go_metalinter_autosave_enabled = []
    let g:go_metalinter_enabled = []
    let g:go_asmfmt_autosave = 0
Plug 'rust-lang/rust.vim'

" }}}

" Formatting {{{
Plug 'Chiel92/vim-autoformat'
    let g:formatdef_clang = '"clang-format -style=\"{BasedOnStyle: llvm, IndentWidth: 4, PointerAlignment: Left}\""'
    let g:formatters_cpp = ['clang']
    nnoremap <buffer><Leader>af :<C-u>Autoformat<CR>
    vnoremap <buffer><Leader>af :Autoformat<CR>
    " only autoformat for Specific filetypes
    let fts = ['cpp', 'go']
    au BufWrite * if index(fts, &filetype) != -1 |:Autoformat| endif
" }}}

" file and buffer switching {{{

Plug 'junegunn/fzf', {'do': './install --all'}
Plug 'junegunn/fzf.vim'
    nnoremap <Leader>o :FZF<CR>
    nnoremap <Leader>g :GFiles<CR>
    nnoremap <Leader>p :Buffer<CR>
    nnoremap <Leader>/ :Ag<CR>
    autocmd FileType fzf tnoremap <buffer> <C-j> <Down>
    autocmd FileType fzf tnoremap <buffer> <C-k> <Up>

    function! s:fzf_statusline()
        " Override statusline as you like
        highlight fzf1 ctermfg=161 ctermbg=None
        highlight fzf2 ctermfg=7 ctermbg=None
        highlight fzf3 ctermfg=7 ctermbg=None
        setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
    endfunction
    autocmd! User FzfStatusLine call <SID>fzf_statusline() 

" }}}

" Neomake {{{

    Plug 'w0rp/ale'
        " for cpp use .lvimrc to set include dirs with following variable
        " let g:ale_cpp_clang_options='-std=c++14 -Wall -I/folder/to/include'
        " let g:ale_lint_delay = 800
        let g:ale_echo_msg_format = '%linter%: %s'
        let g:ale_linters = {'cpp': ['clang']}

" }}}

" Notes {{{
Plug 'vimwiki/vimwiki'
    let g:vimwiki_table_mappings = 0
    let g:vimwiki_folding = 'expr'
    let g:vimwiki_list = [{
                \ 'path': '$HOME/Mega/wiki',
                \ 'template_path': '$HOME/Mega/wiki/templates',
                \ 'template_default': 'default',
                \ 'template_ext': '.html',
                \ 'auto_export': 1,
                \ 'nested_syntaxes' : {'python': 'python', 'c++': 'cpp'} }]


" }}}

" plug end {{{
call plug#end()
endif " has ('nvim')
filetype plugin indent on
" }}}

" }}}
" Line Wrap {{{

" Soft wraps lines without editing file
set wrap

" Stops words from being cut off during linebreak
set linebreak

" Set textwidth to 80 characters
"set textwidth=80

" }}}
" Searching{{{

 "highlight search
set hlsearch
" Show search results as you type
set incsearch
" Ignore case in searches if query doesn't include capitals
set ignorecase
set smartcase
" This unsets the last search pattern register by hitting return
nnoremap <CR> :noh<CR><CR> 

" preview effects of substitute command
if has('nvim')
    set icm=split
endif


" }}}
" Appearance {{{

syntax on
let term_profile=$TERM_BG
if term_profile == "light"
    set background=light
    try
        colorscheme PaperColor
    catch
        colorscheme ron
    endtry
else
    set background=dark
    try 
        colorscheme noctwo
    catch
        colorscheme desert
    endtry
endif

set number
set relativenumber

set laststatus=2
set noshowmode

" use normal block curosr
set guicursor=

" }}}
" Folding {{{

" no unfold on { movements
set foldopen=hor,mark,percent,quickfix,search,tag,undo
set foldmethod=syntax
set foldnestmax=1
" set foldlevelstart=0
" set foldminlines=1
set foldtext=NeatFoldText()

" }}}
" Indent options{{{

set ts=4 sts=4 sw=4 expandtab

" cindent options
set cino=i0,N-s,g0

set list lcs=tab:\ \ ,extends:›,precedes:‹,nbsp:·,trail:·

" }}}
" Movement {{{
set mouse=a

" Movement in long lines
nnoremap <silent> j gj
nnoremap <silent> k gk

" cursor position stays the same
set nostartofline
set so=10
set sidescroll=1

" }}}
" Mappings {{{

set ttimeoutlen=0
inoremap kj <c-c>`^

" terminal
if has('nvim')
    " jk conflitcts with ranger, esc conflicts with zsh vi mode
    " tnoremap kj <C-\><C-n>
    nnoremap <leader>t :sp<cr>:resize 15<cr>:term<cr>
    tnoremap <C-\> <C-\><C-n>
    tnoremap <C-h> <C-\><C-n><C-w>h
    tnoremap <C-j> <C-\><C-n><C-w>j
    tnoremap <C-k> <C-\><C-n><C-w>k
    tnoremap <C-l> <C-\><C-n><C-w>l
    " tnoremap <Leader>. <C-\><C-n>gt
    " tnoremap <Leader>, <C-\><C-n>gT
    au BufWinEnter,WinEnter term://* startinsert
endif

nnoremap <Space> <NOP>

" easy saving
inoremap <c-s> <esc>:w<cr>
nnoremap <c-s> :w<cr>

" Split moving
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

"Quickly paste from +reg
nnoremap <Leader>v "+p
vnoremap <Leader>v "+p
"Quickly yank to +reg
nnoremap <Leader>c "+y
vnoremap <Leader>c "+y

"easy yank to end of line
nnoremap Y y$

" toglle folds
nnoremap <Leader><Leader> za
vnoremap <Leader><Leader> za

" quick save and exit
nnoremap <leader>q :q<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>wq :wq<CR>

" easy search for visual selection
vnoremap // y/<C-R>"<CR>

" file opening
nnoremap <leader>e :e **/*
nnoremap <leader>f :find *

" source vimrc
nnoremap <leader>ss :so $MYVIMRC<CR>

" }}}
" {{{ Splits 
set splitbelow
set splitright
" }}}
" Buffers  {{{

set hidden
" buffer switching
" nnoremap <leader>p :b <C-d>
" quickswitch
nnoremap <bs> <c-^>

" }}}
" Filetupe {{{

au FileType *       setlocal formatoptions-=c formatoptions-=r formatoptions-=o " Disable comment new line
au FileType c       setlocal commentstring=//\ %s
au FileType cpp     setlocal commentstring=//\ %s
au FileType python  setlocal fdm=indent formatprg=autopep8\ -
" au Filetype python    vnoremap <buffer> gq gq:%retab!<CR>
au FileType vimwiki     setlocal nowrap

au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
au BufRead,BufNewFile *.tf setlocal ts=2 sts=2 sw=2 expandtab

" }}}
" wildmenu {{{

set wildmenu 
set wildmode=full
set wildignore+=*.swp,.tags,*.bak,*.pyc,*.class,*.jar
set wildignore+=*.gif,*.png,*.jpg,*.ico
set wildignore+=*.pdf,*.psd
set wildignore+=node_modules/*

set wildignorecase

" }}}
" Misc {{{

" tag file name
set tags=./tags;,tags;

" automatically change working directory
set autochdir

" }}}
" gui {{{ 

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar
set guicursor+=a:blinkon0
if has("gui_running")
    try
        colorscheme hybrid
    catch /E185/
        colorscheme desert
    endtry
endif
" Fix borders of fullscreen GUI
if has('gui_gtk') && has('gui_running')
  let s:border = synIDattr(synIDtrans(hlID('Normal')), 'bg', 'gui')
  exe 'silent !echo ''style "vimfix" { bg[NORMAL] = "' . escape(s:border, '#') . '" }'''.
              \' > ~/.gtkrc-2.0'
  exe 'silent !echo ''widget "vim-main-window.*GtkForm" style "vimfix"'''.
              \' >> ~/.gtkrc-2.0'
endif

" }}}
" Backup {{{

"ensure directories exist
if empty(glob('~/.config/nvim/backup'))
    silent !mkdir -p ~/.config/nvim/backup
endif
if empty(glob('~/.config/nvim/swap'))
    silent !mkdir -p ~/.config/nvim/swap
endif

set backupdir=~/.config/nvim/backup//
set directory=~/.config/nvim/swap//
" set undodir=~/.vim/undo//
" set undofile

"}}}
" Functions{{{

"find include dir for cpp
function! Findinclude()
    let b:gitfolder = finddir('.git', ',;')
    echo "in findinclude"
    if b:gitfolder =~ ''
        let b:oldpath = &path
        let b:root =  split(b:gitfolder,'/')
        let b:path = join(b:root[0:-2], '/')
        set path=**;b:path
        let b:inc =  finddir('include')
        if b:inc =~ ''
            let b:neomake_cpp_clang_args = [ '-I'. b:inc ]
        endif
        set path=b:oldpath
    endif
endfunction

"Display the numbered registers, press a key and paste it to the buffer
function! Reg()
    reg
    echo "Register: "
    let char = nr2char(getchar())
    if char != "\<Esc>"
        execute "normal! \"".char."p"
    endif
    redraw
endfunction

" Foldtexts {{{
function! FoldText()
    let l:lpadding = &fdc
    redir => l:signs
      execute 'silent sign place buffer='.bufnr('%')
    redir End
    let l:lpadding += l:signs =~ 'id=' ? 2 : 0

    if exists("+relativenumber")
      if (&number)
        let l:lpadding += max([&numberwidth, strlen(line('$'))]) + 1
      elseif (&relativenumber)
        let l:lpadding += max([&numberwidth, strlen(v:foldstart - line('w0')), strlen(line('w$') - v:foldstart), strlen(v:foldstart)]) + 1
      endif
    else
      if (&number)
        let l:lpadding += max([&numberwidth, strlen(line('$'))]) + 1
      endif
    endif

    " expand tabs
    let l:start = substitute(getline(v:foldstart), '\t', repeat(' ', &tabstop), 'g')
    let l:end = substitute(substitute(getline(v:foldend), '\t', repeat(' ', &tabstop), 'g'), '^\s*', '', 'g')

    let l:info = ' (' . (v:foldend - v:foldstart) . ')'
    let l:infolen = strlen(substitute(l:info, '.', 'x', 'g'))
    let l:width = winwidth(0) - l:lpadding - l:infolen

    let l:separator = ' … '
    let l:separatorlen = strlen(substitute(l:separator, '.', 'x', 'g'))
    let l:start = strpart(l:start , 0, l:width - strlen(substitute(l:end, '.', 'x', 'g')) - l:separatorlen)
    " let l:text = l:start . ' … ' . l:end
    let l:text = l:start . '…'
    return l:text . repeat(' ', l:width - strlen(substitute(l:text, ".", "x", "g"))) . l:info
endfunction

function! NeatFoldText()
  let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
  let lines_count = v:foldend - v:foldstart + 1
  let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
  let foldchar = matchstr(&fillchars, 'fold:\zs.')
  let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
  let foldtextend = lines_count_text . repeat(foldchar, 8)
  let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
  return foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction

function! MyFoldText()
    let line = getline(v:foldstart)

    let nucolwidth = &fdc + &number * &numberwidth
    let windowwidth = winwidth(0) - nucolwidth - 3
    let foldedlinecount = v:foldend - v:foldstart

    " expand tabs into spaces
    let onetab = strpart('          ', 0, &tabstop)
    let line = substitute(line, '\t', onetab, 'g')

    let line = strpart(line, 0, windowwidth - 2 -len(foldedlinecount))
    let fillcharcount = windowwidth - len(line) - len(foldedlinecount)
    return line . '…' . repeat(" ",fillcharcount) . foldedlinecount . '…' . ' '
endfunction
" }}}

" }}}
" Commands {{{

"Reg paste
command! -nargs=0 Reg call Reg()
" sudo write
cnoremap w!! w !sudo tee % >/dev/null

" }}}
" vim: fdm=marker:fdl=0:fml=1
