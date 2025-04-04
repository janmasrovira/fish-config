# * Search for text in files using Ripgrep
# * Interactively restart Ripgrep with reload action
#    * Press alt-enter to switch to fzf-only filtering
# * Open the file in Emacs
# Example usages:
# 1) rr            # search in all files
# 2) rr '-g *.txt' # only search in .txt files
function rr
  set extra_rg_opts "$argv"
  set RG_PREFIX "rg --multiline --column --line-number --no-heading --color=always --smart-case $extra_rg_opts"

  fzf --ansi --disabled \
      --bind "start:reload:$RG_PREFIX {q}" \
      --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --bind "alt-enter:unbind(change,alt-enter)+change-prompt(2. fzf> )+enable-search+clear-query" \
      --color "hl:-1:underline,hl+:-1:underline:reverse" \
      --prompt '1. rg> ' \
      --delimiter : \
      --preview 'bat --color=always {1} --highlight-line {2}' \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
      --bind 'enter:execute(emacsclient +{2}:{3} {1})'
end
