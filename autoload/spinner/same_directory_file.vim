
function! spinner#same_directory_file#next()
    call spinner#same_directory_file#open_next_file(1)
endfunction

function! spinner#same_directory_file#previous()
    call spinner#same_directory_file#open_next_file(0)
endfunction


func! spinner#same_directory_file#warn(msg)
    echohl WarningMsg
    echomsg a:msg
    echohl None
endfunc

func! spinner#same_directory_file#get_idx_of_list(lis, elem)
    let i = 0
    while i < len(a:lis)
        if a:lis[i] ==# a:elem
            return i
        endif
        let i = i + 1
    endwhile
    throw "not found"
endfunc

func! spinner#same_directory_file#glob_list(expr)
    let files = split(glob(a:expr), '\n')
    " get rid of '.' and '..'
    call filter(files, 'fnamemodify(v:val, ":t") !=# "." && fnamemodify(v:val, ":t") !=# ".."')
    return files
endfunc

func! spinner#same_directory_file#sort_compare(i, j)
    " alphabetically
    return a:i > a:j
endfunc

func! spinner#same_directory_file#get_files_list(...)
    let glob_expr = a:0 == 0 ? '*' : a:1
    " get files list
    let globed = spinner#same_directory_file#glob_list(expand('%:p:h') . '/' . glob_expr)

    let files = []
    for i in globed
        if isdirectory(i)
            continue
        endif
        if ! filereadable(i)
            continue
        endif

        call add(files, i)
    endfor

    return sort(files, 'spinner#same_directory_file#sort_compare')
endfunc

func! spinner#same_directory_file#get_next_idx(files, advance, cnt)
    try
        " get current file idx
        let tailed = map(copy(a:files), 'fnamemodify(v:val, ":t")')
        let idx = spinner#same_directory_file#get_idx_of_list(tailed, expand('%:t'))
        " move to next or previous
        let idx = a:advance ? idx + a:cnt : idx - a:cnt
    catch /^not found$/
        " open the first file.
        let idx = 0
    endtry
    return idx
endfunc

func! spinner#same_directory_file#open_next_file(advance)
    if expand('%') ==# ''
        return spinner#same_directory_file#warn("current file is empty.")
    endif

    let files = spinner#same_directory_file#get_files_list()
    if empty(files) | return | endif
    let idx   = spinner#same_directory_file#get_next_idx(files, a:advance, v:count1)

    if 0 <= idx && idx < len(files)
        " can access to files[idx]
        execute 'edit ' . fnameescape(files[idx])
    else
        " wrap around
        if idx < 0
            " fortunately recent LL languages support negative index :)
            let idx = -(abs(idx) % len(files))
            " But if you want to access to 'real' index:
            " if idx != 0
            "     let idx = len(files) + idx
            " endif
        else
            let idx = idx % len(files)
        endif
        execute 'edit ' . fnameescape(files[idx])
    endif
endfunc


