" Minimal .vimrc for Git Bash on Windows.
" Main job: make yank copy to the Windows clipboard even though Git Bash's
" vim is built without +clipboard.

set nocompatible
set encoding=utf-8

" Sensible baseline
syntax on
filetype plugin indent on
set number
set ruler
set showcmd
set incsearch hlsearch ignorecase smartcase
set backspace=indent,eol,start
set hidden
set laststatus=2
set wildmenu
set mouse=a
set ttimeoutlen=50

" Indent
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent

" --- Windows clipboard bridge ---
" After any yank, pipe the yanked text to clip.exe. Works for y, yy, yiw,
" visual-mode y, etc. Requires vim >= 8.0 (Git Bash's vim is fine).
if executable('clip.exe') && exists('##TextYankPost')
  augroup WindowsClipboardYank
    autocmd!
    autocmd TextYankPost *
      \ if v:event.operator ==# 'y'
      \ |   call system('clip.exe', join(v:event.regcontents, "\n"))
      \ | endif
  augroup END
endif

" Paste from Windows clipboard: <leader>p (default leader is \)
" Reads clipboard into the buffer at the cursor.
if executable('powershell.exe')
  nnoremap <silent> <leader>p :read !powershell.exe -NoProfile -Command Get-Clipboard<CR>
endif
