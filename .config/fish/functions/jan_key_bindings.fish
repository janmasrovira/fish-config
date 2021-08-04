# hint: use fish_key_reader to get the code of a keybinding
function jan_key_bindings
    fish_vi_key_bindings
    bind --mode insert --sets-mode default fd backward-char repaint

    bind --mode insert \ck history-search-backward
    bind --mode insert \cj history-search-forward

    bind --mode visual --sets-mode default \cG end-selection repaint
    bind --mode visual --sets-mode default fd end-selection repaint

    for mode in insert default
        bind --mode $mode \cf accept-autosuggestion
    end
end
