" spinner.vim : fast buffer switching plugin with only 3 keys.
" Maintainer:   OMI TAKU
" Version:      0.5
" Last Change:  2009/12/02 19:00:00
"
" Introduction:
" a basic idea is easy pressable key,
" and quickly switchable search type .
"
" Basic Usage:
" Default defined key map is
"     <C-CR>     open next item .
"     <S-CR>     open previous item .
"     <C-S-CR>   switch spinner.vim search mode .
"
" spinner.vim search mode is switching, when you press <C-S-CR>.
" Defined search mode is
"     1. open next/previous buffer (initial) .
"     2. open next/previous file in currently opened file directory .
"     3. open next/previous most recently edited file (last 10 files) .
"     4. open next/previous tab .
"     5. open next/previous window .
"     6. open next/previous quickfix line .
"     7. open next/previous quickfix file .
"
" Spinner Search Mode Details:
" 1.open next/previous buffer (initial) .
"     <C-CR> open next buffer.
"     <S-CR> open previous buffer.
"   same with :bnext, :bNext .
"
" 2.open next/previous file in currently opened file directory .
"     <C-CR> open alphabetically next file.
"     <S-CR> open alphabetically previous file .
"   opening files are searched in currently opened file directory.
"
"   current test version use code from
"   nextfile : open the next or previous file
"   (vimscript #2605)
"
" 3.open next/previous most recently edited file (last 10 files) .
"     <C-CR> open alphabetically next file.
"     <S-CR> open alphabetically previous file .
"
"   recently edited file path are stored at openinig file (limit 10 item).
"   stored file is placed at
"       $HOME/.vim_spinner_mru_files , or
"       $VIM/.vim_spinner_mru_files , or
"       $USERPROFILE/_vim_spinner_mru_files .
"
"   current test version use code from
"   mru.vim : Plugin to manage Most Recently Used (MRU) files
"   (vimscript #521)
"
" 4.open next/previous tab .
"     <C-CR> go to next tab.
"     <S-CR> go to previous tab.
"   same with :tabnext, :tabNext .
"
" 5.open next/previous window .
"     <C-CR> move cursor to next splitted window.
"     <S-CR> move cursor to previous splitted window.
"
" 6.open next/previous quickfix line .
"     <C-CR> go to next error in quickfix list.
"     <S-CR> go to previous error in quickfix list.
"   same with :cnext, :cNext .
"
" 7.open next/previous quickfix file .
"     <C-CR> go to next error file in quickfix list.
"     <S-CR> go to previous error file in quickfix list.
"   same with :cnfile, :cNfile .
"
" Other Usage:
" switch search mode with number.
"     1<C-S-CR>  set switch spinner.vim mode to buffer type.
"     2<C-S-CR>  set switch spinner.vim mode to same_directory_file type.
"     3<C-S-CR>  set switch spinner.vim mode to most_recently_edited type.
"     4<C-S-CR>  set switch spinner.vim mode to tab type.
"     5<C-S-CR>  set switch spinner.vim mode to window type.
"     6<C-S-CR>  set switch spinner.vim mode to quickfix type.
"     7<C-S-CR>  set switch spinner.vim mode to quickfix_file type.
"
" this key map display current spinner search mode.
"     <A-CR>     display current spinner mode .
"     <M-CR>     display current spinner mode .
"
" Configurations:
" Action Key Map:
"     let g:spinner_nextitem_key = {mapping}
"     let g:spinner_previousitem_key = {mapping}
"     let g:spinner_switchmode_key = {mapping}
"     let g:spinner_displaymode_key = {mapping}
"
"     for example,
"     let g:spinner_nextitem_key = ',n'
"     let g:spinner_previousitem_key = ',p'
"     let g:spinner_switchmode_key = ',s'
"     let g:spinner_displaymode_key = ',d'
"
" Initial Search Type:
"   let g:spinner_initial_search_type = {seach type number}
"
"   for example,
"   let g:spinner_initial_search_type = 2
"
"       1 : buffer (default)
"       2 : same_directory_file
"       3 : most_recently_edited
"       4 : tab
"       5 : window
"       6 : quickfix
"       7 : quickfix_file
"
" Install Details:
" Unzip spinner.zip, and drop your $HOME/.vim directory (unix),
" or drop $HOME/vimfiles directory (Windows).

if &cp || exists("g:loaded_spinner")
    finish
endif
let g:loaded_spinner = 1

let s:save_cpo = &cpo
set cpo&vim

let s:modes = [
            \    'buffer',
            \    'same_directory_file',
            \    'most_recently_edited',
            \    'tab',
            \    'window',
            \    'quickfix',
            \    'quickfix_file',
            \ ]
let s:mode_count = len(s:modes)

" initial type
if exists('g:spinner_initial_search_type')
    let s:current_mode = g:spinner_initial_search_type - 1
else
    let s:current_mode = 0
endif

" mapping
if exists('g:spinner_nextitem_key')
    let s:nextitem_map = g:spinner_nextitem_key
else
    let s:nextitem_map = '<c-cr>'
endif

if exists('g:spinner_previousitem_key')
    let s:previousitem_map = g:spinner_previousitem_key
else
    let s:previousitem_map = '<s-cr>'
endif

if exists('g:spinner_switchmode_key')
    let s:switchmode_map = g:spinner_switchmode_key
else
    let s:switchmode_map = '<c-s-cr>'
endif

if exists('g:spinner_displaymode_key')
    let s:displaymode_maps = [ g:spinner_displaymode_key ]
else
    let s:displaymode_maps = [
                \ '<m-cr>',
                \ '<a-cr>',
                \ '<d-cr>',
                \ ]
endif


let s:next_cmd = ""
let s:previous_cmd = ""

" set custom mapping
execute 'nnoremap ' . s:nextitem_map .     ' :<c-u>call g:NextSpinnerItem()<cr>'
execute 'nnoremap ' . s:previousitem_map . ' :<c-u>call g:PreviousSpinnerItem()<cr>'
execute 'nnoremap ' . s:switchmode_map .   ' :<c-u>call g:SwitchSpinnerMode(v:count)<cr>'
for i in s:displaymode_maps
    execute 'nnoremap ' . i . ' :<c-u>call g:DisplayCurrentSpinnerMode()<cr>'
endfor

function! g:SwitchSpinnerMode(count)
    if a:count > 0
        let s:current_mode = a:count - 1
    else
        let s:current_mode += 1
    endif

    if s:current_mode < s:mode_count
    else
        let s:current_mode = 0
    endif

    call s:SwitchSpinnerModeTo(s:current_mode)
    echohl None | echo 'switch spinner mode to [' . s:modes[s:current_mode] . '].' | echohl None
endfunction
function! s:SwitchSpinnerModeTo(mode)
    let s:next_cmd = 'call spinner#' . s:modes[a:mode] . '#next()'
    let s:previous_cmd = 'call spinner#' . s:modes[a:mode] . '#previous()'
endfunction

function! g:NextSpinnerItem()
    execute s:next_cmd
endfunction
function! g:PreviousSpinnerItem()
    execute s:previous_cmd
endfunction

function! g:CurrentSpinnerMode()
    return s:modes[s:current_mode]
endfunction
function! g:DisplayCurrentSpinnerMode()
    echohl None | echo 'switch spinner mode [' . s:modes[s:current_mode] . '].' | echohl None
endfunction

function! s:InitializeSpinner()
    call s:SwitchSpinnerModeTo(s:current_mode)
endfunction
call s:InitializeSpinner()

let &cpo = s:save_cpo
finish

==============================================================================
spinner.vim : fast buffer switching plugin with only 3 keys.
------------------------------------------------------------------------------
$VIMRUNTIMEPATH/plugin/spinner.vim
$VIMRUNTIMEPATH/autoload/spinner/buffer.vim
$VIMRUNTIMEPATH/autoload/spinner/most_recently_edited.vim
$VIMRUNTIMEPATH/autoload/spinner/quickfix.vim
$VIMRUNTIMEPATH/autoload/spinner/quickfix_file.vim
$VIMRUNTIMEPATH/autoload/spinner/same_directory_file.vim
$VIMRUNTIMEPATH/autoload/spinner/tab.vim
$VIMRUNTIMEPATH/autoload/spinner/window.vim
==============================================================================
author  : OMI TAKU
url     : http://nanasi.jp/
email   : mail@nanasi.jp
version : 2009/12/02 19:00:00
==============================================================================
" vim: set ff=unix et ft=vim nowrap :
