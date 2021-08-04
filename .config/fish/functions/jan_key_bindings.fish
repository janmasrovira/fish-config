function jan_key_bindings
    fish_vi_key_bindings
    bind --mode insert --sets-mode default fd backward-char force-repaint

    bind --mode insert \ck history-search-backward
    bind --mode insert \cj history-search-forward

    for mode in insert default
        bind --mode $mode \cf forward-char
    end
end
