# 1. Search for text in files using Ripgrep
# 2. Interactively restart Ripgrep with reload action
#    * Press alt-enter to switch to fzf-only filtering
# 3. Open the file in Vim
function rr
  set RG_PREFIX "rg --multiline --column --line-number --no-heading --color=always --smart-case "
  set INITIAL_QUERY "$argv"

  fzf --ansi --disabled --query "$INITIAL_QUERY" \
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
