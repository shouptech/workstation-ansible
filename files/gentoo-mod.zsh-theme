function prompt_char {
	if [ $UID -eq 0 ]; then echo "#"; else echo $; fi
}

# Add kubectl context to prompt
function kube_prompt {
  if [ -f ~/.kube/config ]; then
    CONTEXT=$(cat ~/.kube/config | grep "current-context:" | sed "s/current-context: //")
    if [ -n "$CONTEXT" ]; then
      echo "(k8s: ${CONTEXT})"
    fi
  fi
}

local ret_status="%(?:%{$fg_bold[green]%}✔:%{$fg_bold[red]%}✗)"

PROMPT='${ret_status} %{$fg_bold[blue]%}%(!.%1~.%~) $(git_prompt_info)%_$(kube_prompt)
%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m $(prompt_char)%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=") "
