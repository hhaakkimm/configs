" =============================================================================
"  ~/.vimrc — plugins from "My 11 favourite Vim plugins" (solarwinter.net)
" =============================================================================

set nocompatible
let mapleader = "\<Space>"          " <leader> = Space

" -----------------------------------------------------------------------------
"  Auto-install vim-plug on first launch
" -----------------------------------------------------------------------------
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/autoload/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Must be set BEFORE ALE loads: let CoC handle LSP, ALE handle linting only
let g:ale_disable_lsp = 1

" -----------------------------------------------------------------------------
"  Plugins
" -----------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')

  " General
  Plug 'mhinz/vim-startify'                         " start screen + sessions
  Plug 'preservim/nerdtree'                         " file sidebar
  Plug 'tpope/vim-obsession'                        " auto-save sessions
  Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }

  " Coding
  Plug 'neoclide/coc.nvim', { 'branch': 'release' } " LSP / completion (needs Node)
  Plug 'jreybert/vimagit'                           " magit-style git staging
  Plug 'dense-analysis/ale'                         " async linting

  " Appearance
  Plug 'vim-airline/vim-airline'                    " status line
  Plug 'NLKNguyen/papercolor-theme'
  Plug 'lifepillar/vim-solarized8'
  Plug 'dracula/vim', { 'as': 'dracula' }

call plug#end()
" (plug#end also runs: filetype plugin indent on + syntax enable)

" -----------------------------------------------------------------------------
"  General settings
" -----------------------------------------------------------------------------
set encoding=utf-8
set number relativenumber
set cursorline
set mouse=a
set clipboard=unnamed               " use the macOS clipboard
set hidden                          " switch buffers without saving
set backspace=indent,eol,start
set scrolloff=5
set signcolumn=yes                  " stop text jumping when ALE/CoC add signs
set updatetime=300                  " faster CoC/ALE feedback
set shortmess+=c
set laststatus=2
set noshowmode                      " airline already shows the mode
set wildmenu
set wildmode=longest:full,full
set splitright splitbelow

" Search
set incsearch hlsearch ignorecase smartcase
nnoremap <silent> <leader><space> :nohlsearch<CR>

" Indentation (4 spaces by default)
set expandtab
set tabstop=4 shiftwidth=4 softtabstop=4
set autoindent smartindent

" Keep swap / backup / undo files out of your project folders
for s:dir in ['swap', 'backup', 'undo']
  if !isdirectory(expand('~/.vim/' . s:dir))
    call mkdir(expand('~/.vim/' . s:dir), 'p')
  endif
endfor
set directory=~/.vim/swap//
set backupdir=~/.vim/backup//
set undodir=~/.vim/undo//
set undofile

" -----------------------------------------------------------------------------
"  Colours / themes
" -----------------------------------------------------------------------------
" True colour (Solarized8 looks wrong without it). Older Apple Terminal
" doesn't support it, so it is only enabled elsewhere (iTerm2, kitty, etc.).
if has('termguicolors') && $TERM_PROGRAM !=# 'Apple_Terminal'
  set termguicolors
endif

set background=dark
silent! colorscheme dracula         " silent! = no error before plugins install

" Switch themes / background (from the article)
nnoremap <leader>tp :colorscheme PaperColor<CR>
nnoremap <leader>ts :colorscheme solarized8<CR>
nnoremap <leader>td :colorscheme dracula<CR>
nnoremap <leader>bd :set background=dark<CR>
nnoremap <leader>bl :set background=light<CR>

" -----------------------------------------------------------------------------
"  Startify + Obsession
" -----------------------------------------------------------------------------
let g:startify_session_dir = '~/.vim/session'
let g:startify_session_persistence = 1   " save session on quit / buffer switch
let g:startify_change_to_vcs_root = 1
let g:startify_lists = [
      \ { 'type': 'sessions',  'header': ['   Sessions']       },
      \ { 'type': 'files',     'header': ['   Recent files']   },
      \ { 'type': 'dir',       'header': ['   Recent in '. getcwd()] },
      \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
      \ ]
" :SSave name  -> save session     :SLoad name -> load session
" :Obsess      -> start auto-saving the session, :Obsess! -> stop

" -----------------------------------------------------------------------------
"  NERDTree
" -----------------------------------------------------------------------------
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>
let g:NERDTreeShowHidden = 1
let g:NERDTreeMapHelp = '<F1>'      " frees '?' for backward search in the tree
" Quit Vim if NERDTree is the only window left
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif

" -----------------------------------------------------------------------------
"  Markdown preview
" -----------------------------------------------------------------------------
let g:mkdp_auto_close = 1
nmap <leader>mp <Plug>MarkdownPreviewToggle

" -----------------------------------------------------------------------------
"  Vimagit
" -----------------------------------------------------------------------------
nnoremap <leader>g :Magit<CR>

" -----------------------------------------------------------------------------
"  ALE
" -----------------------------------------------------------------------------
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '▲'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:ale_fix_on_save = 0
let g:ale_fixers = { '*': ['remove_trailing_lines', 'trim_whitespace'] }
nmap <silent> [e <Plug>(ale_previous_wrap)
nmap <silent> ]e <Plug>(ale_next_wrap)
nnoremap <leader>af :ALEFix<CR>

" -----------------------------------------------------------------------------
"  Airline
" -----------------------------------------------------------------------------
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1        " show buffers at the top
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline_powerline_fonts = 0   " set to 1 if you install a Nerd/Powerline font

" -----------------------------------------------------------------------------
"  CoC (completion, go-to-definition, rename, ...)
" -----------------------------------------------------------------------------
" Extensions installed automatically. Add the languages you use, e.g.
" 'coc-tsserver', 'coc-pyright', 'coc-go', 'coc-rust-analyzer', 'coc-css', 'coc-html'
let g:coc_global_extensions = ['coc-json']

" Tab / Shift-Tab to move through completions, Enter to confirm
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1] =~# '\s'
endfunction

" Ctrl-Space to trigger completion manually
inoremap <silent><expr> <c-@> coc#refresh()

" Navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" K = show documentation
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight symbol under cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

nmap <leader>rn <Plug>(coc-rename)
nmap <leader>ca <Plug>(coc-codeaction-cursor)
nmap <leader>qf <Plug>(coc-fix-current)
command! -nargs=0 Format :call CocActionAsync('format')

" -----------------------------------------------------------------------------
"  Editing the vimrc (from the article)
" -----------------------------------------------------------------------------
nnoremap ,v :edit   $MYVIMRC<CR>
nnoremap ,u :source $MYVIMRC<CR>

" Quality of life
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
