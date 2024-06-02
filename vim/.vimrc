" Vim is not my default editor. I use Neovim instead. This Vim configuration is
" only used if Neovim can not start. There are Vim to fix the Neovim
" configuration. Because of this, this configuration is minimal.


""" My configurations
set encoding=utf-8
set fileencoding=utf-8
set backup
set undofile

set number
set relativenumber
set cursorline

set hls
set hlsearch

set tabstop=4
set shiftwidth=4
set noexpandtab
set list
set listchars=tab:ꞏꞏ┋

let mapleader = "\\"


""" Maps
nmap <silent> <F1> :tabp <CR>
nmap <silent> <F2> :tabn <CR>

nmap <silent> <F3> :NERDTree <CR>

nmap <C-F> :%s///g<left><left><left>
vmap <C-F> :s///g<left><left><left>

nmap <S-TAB> gv<
nmap <TAB> gv>
vmap <S-TAB> <
vmap <TAB> >

nmap <C-X> <ESC>'<V'>
map <silent> <C-C> :w !xclip -i -selection clipboard <Enter><Enter>


""" Start of Vundle configuration
set nocompatible
filetype off

" Install and configure Vundle
if empty(glob('~/.vim/bundle/Vundle.vim/autoload/vundle.vim'))
	!git clone --depth 1 https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	!echo 'Remember to run ´:BundleInstall´'
endif

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'preservim/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'preservim/nerdcommenter'
Plugin 'jiangmiao/auto-pairs'
Plugin 'mg979/vim-visual-multi'
Plugin 'airblade/vim-gitgutter'
Plugin 'vim-airline/vim-airline'
Plugin 'ryanoasis/vim-devicons'
Plugin 'tpope/vim-fugitive'
Plugin 'junegunn/vim-easy-align'
Plugin 'adelarsq/vim-matchit'
Plugin 'preservim/tagbar'

" Colorschemes
Plugin 'sainnhe/sonokai'

call vundle#end()
filetype plugin indent on
" End of Vundle configuration


""" Configures color schemes
syntax enable
set background=dark
let g:sonokai_enable_italic = 0
let g:sonokai_disable_italic_comment = 1
colorscheme sonokai


""" Configures autopairs
let g:AutoPairsShortcutToggle = '<F5>'
let g:AutoPairsShortcutFastWrap = ''
let g:AutoPairsShortcutJump = ''
let g:AutoPairsShortcutBackInsert = ''


""" Configures Vim-airline

" Fonts
let g:airline_powerline_fonts = 1

" Ailine
let g:airline_right_sep = ''
let g:airline_left_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_left_alt_sep = ''

" Tabline
let g:airline#extensions#tabline#enabled = 1

let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''


""" Configures Vim-Devicons
let g:webdevicons_enable = 1
let g:webdevicons_enable_nerdtree = 1
let g:webdevicons_conceal_nerdtree_brackets = 1
let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_enable_airline_statusline = 1


""" Configures Easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

let g:easy_align_ignore_unmatched = 1


""" Configures Tagbar
let g:tagbar_width = 30

map <F8> :TagbarToggle <CR>
map <F6> :TagbarOpen fj <CR>
