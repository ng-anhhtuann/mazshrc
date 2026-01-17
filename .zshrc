export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/bin/python3.10:$PATH"
export PATH="/bin:/usr/bin:/usr/local/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/morphibius/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

alias dockercomposeup='docker compose up'
alias dockercomposedown='docker compose down -v'
alias dockercomposebuild='docker compose build'
alias dockerdeletenonetag='docker container stop $(docker container ls -aq);docker container rm $(docker container ls -aq);docker image prune -f'
alias dockerbuild='docker build -t app .'

alias gitb='git branch'
alias gits='git status'
alias gitl='git log'
alias gitc='git checkout'
alias gitcb='git checkout -b'
alias gitcm='git commit'
alias gitcmm='git commit -m'
alias gitf='git fetch --all'
alias gitpull='git pull'
alias gitcl='git clone'
alias gitremote='git remote -v'
alias gitchangeremote='git remote set-url origin'
alias gitpfwl='git push --force-with-lease'
alias gitp='git push'

alias sourcezsh='source ~/.zshrc'

alias cdssh='cd ~/.ssh'
alias sshgen='ssh-keygen -t rsa -b 4096 -C "nguyenanhtuan1232@gmail.com"'
alias sshadd='ssh-add'

alias portlisten='sudo lsof -i -P -n | grep LISTEN'
alias killpid='sudo kill -9'
alias whichzombie='ps aux | grep Z'
alias whichzombiemore='ps -el | grep Z'