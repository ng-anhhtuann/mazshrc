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
alias gitrm='git remote -v'
alias gitchangeremote='git remote set-url origin'
alias gitpf='git push --force-with-lease'
alias gitp='git push'
alias gitca='git commit --amend'
alias gitcad='git commit --amend --date'

alias sourcezsh='source ~/.zshrc'

alias cdssh='cd ~/.ssh'
alias sshgen='ssh-keygen -t rsa -b 4096 -C "nguyenanhtuan1232@gmail.com"'
alias sshadd='ssh-add'

alias portlisten='sudo lsof -i -P -n | grep LISTEN'
alias killpid='sudo kill -9'
alias whichzombie='ps aux | grep Z'
alias whichzombiemore='ps -el | grep Z'

alias getdevicesonnetwork='sudo nmap -sn 192.168.1.0/24'

gitpush() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error detect repository"
    return 1
  fi
  
  if [[ -z $(git status -s) ]]; then
    echo "No changes to commit"
    return 0
  fi
  
  echo "Changes detected:"
  git status -s
  echo ""
  
  if [ -z "$1" ]; then
    echo "Enter commit message:"
    read commit_message
  else
    commit_message="$*"
  fi
  
  git add -A
  echo "Staged all changes"
  
  git commit -m "$commit_message"
  echo "Committed changes"
  
  current_branch=$(git branch --show-current)
  git push origin "$current_branch"
  echo "Pushed to origin/$current_branch"
}

gitquickpush() {
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  gitpush "[ng-anhhtuann] update: $timestamp"
}

function _welcome() {
  local start_date="2022-06-20"
  local start_sec=$(date -j -f "%Y-%m-%d" "$start_date" "+%s")
  local now_sec=$(date +%s)
  local total_days=$(( (now_sec - start_sec) / 86400 ))

  local years=$(( total_days / 365 ))
  local remaining=$(( total_days % 365 ))

  local time_str=$(date "+%I:%M %p")
  local date_str=$(date "+%A, %d %B %Y")

  local cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
  local cpu_threads=$(sysctl -n hw.logicalcpu 2>/dev/null || echo "?")
  local processes=$(ps aux | wc -l | tr -d ' ')
  local disk=$(df -h / | awk 'NR==2 {print $2}')
  local disk_used=$(df -h / | awk 'NR==2 {print $3}')
  local macos=$(sw_vers -productVersion)
  local macos_name=$(awk '/SOFTWARE LICENSE AGREEMENT FOR macOS/' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf' 2>/dev/null | awk -F 'macOS ' '{print $NF}' | awk '{print $1}' || echo "")
  local gpu=$(system_profiler SPDisplaysDataType 2>/dev/null | awk -F': ' '/Chipset Model/{print $2; exit}')
  local local_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "No connection")
  local board=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Model Identifier/{print $2}')
  local serial=$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Serial Number/{print $2}')

  local mem_total_bytes=$(sysctl -n hw.memsize)
  local mem_total_gb=$(( mem_total_bytes / 1073741824 ))
  local mem_used=$(vm_stat | awk '
    /Pages active/     { active=$3 }
    /Pages wired/      { wired=$4 }
    /Pages compressed/ { compressed=$3 }
    END {
      used=(active+wired+compressed)*4096/1073741824
      printf "%.1f", used
    }')

  # ── Battery ──
  local batt_info=$(pmset -g batt 2>/dev/null)
  local batt_pct=$(echo "$batt_info" | grep -o '[0-9]*%' | head -1)
  local batt_state=$(echo "$batt_info" | grep -o 'charging\|discharging\|charged\|finishing charge' | head -1)
  local batt_pct_num=${batt_pct%%%}
  local batt_icon="▪"
  if (( batt_pct_num >= 80 )); then batt_icon="🔋"
  elif (( batt_pct_num >= 60 )); then batt_icon="🪫"
  elif (( batt_pct_num >= 40 )); then batt_icon="🪫"
  elif (( batt_pct_num >= 20 )); then batt_icon="🪫"
  fi
  [[ "$batt_state" == "charging" ]] && batt_icon="🔌"
  [[ "$batt_state" == "charged"  ]] && batt_icon="🔋"
  local battery="${batt_icon} ${batt_pct} (${batt_state:-unknown})"

  # ── Weather (HCMC) ──
  local weather=$(curl -s --max-time 3 "wttr.in/Ho+Chi+Minh+City?format=%c+%t+%h+humidity" 2>/dev/null || echo "unavailable")

  printf "\e[38;5;46m$(cat ~/.morphibius)\e[0m\n"

  echo "\033[1;36m${time_str} - ${date_str}\033[0m"
  echo "\033[1;33mday ${total_days} (${years} years, ${remaining} days) as a software engineer\033[0m"
  echo ""

  local left_rows=(
    "CPU|$cpu"
    "CPU Threads|$cpu_threads"
    "Processes|$processes running"
    "Memory|${mem_used}GB used / ${mem_total_gb}GB"
    "Disk|${disk_used} used / ${disk}"
  )
  local right_rows=(
    "GPU|$gpu"
    "macOS|$macos${macos_name:+ ($macos_name)}"
    "Baseboard|$board"
    "Serial|$serial"
    "Local IP|$local_ip"
  )

  local lk=0 lv=0 rk=0 rv=0
  for row in "${left_rows[@]}"; do
    local k="${row%%|*}" v="${row##*|}"
    (( ${#k} > lk )) && lk=${#k}
    (( ${#v} > lv )) && lv=${#v}
  done
  for row in "${right_rows[@]}"; do
    local k="${row%%|*}" v="${row##*|}"
    (( ${#k} > rk )) && rk=${#k}
    (( ${#v} > rv )) && rv=${#v}
  done

  local lcell=$(( 2 + lk + 2 + lv + 2 ))
  local rcell=$(( 2 + rk + 2 + rv + 2 ))

  local title="─ system "
  local top_left=$(printf '─%.0s' $(seq 1 $(( lcell - ${#title} ))))
  local top_right=$(printf '─%.0s' $(seq 1 $rcell))
  local bot_left=$(printf '─%.0s' $(seq 1 $lcell))
  local bot_right=$(printf '─%.0s' $(seq 1 $rcell))

  echo "\033[1;37m  ┌${title}${top_left}┬${top_right}┐\033[0m"
  local n=${#left_rows[@]}
  for (( i=1; i<=n; i++ )); do
    local lrow="${left_rows[$i]}" rrow="${right_rows[$i]}"
    local lrow_k="${lrow%%|*}" lrow_v="${lrow##*|}"
    local rrow_k="${rrow%%|*}" rrow_v="${rrow##*|}"
    local lpad=$(( lv - ${#lrow_v} ))
    local rpad=$(( rv - ${#rrow_v} ))
    printf "\033[1;37m  │\033[0m  \033[0;35m%-${lk}s\033[0m  \033[0;37m%s%${lpad}s\033[0m  \033[1;37m│\033[0m  \033[0;35m%-${rk}s\033[0m  \033[0;37m%s%${rpad}s\033[0m  \033[1;37m│\033[0m\n" \
      "$lrow_k" "$lrow_v" "" "$rrow_k" "$rrow_v" ""
  done

  local total_inner=$(( lcell + 1 + rcell ))
  local batt_str="  ${batt_icon} ${batt_pct} (${batt_state:-unknown})"
  local weather_str="${weather}  "
  local gap=$(( total_inner - ${#batt_str} - ${#weather_str} ))
  echo "\033[1;37m  ├${bot_left}┴${bot_right}┤\033[0m"
  printf "\033[1;37m  │\033[0m\033[0;36m%s%${gap}s%s\033[0m\033[1;37m│\033[0m\n" "$batt_str" "" "$weather_str"
  echo "\033[1;37m  └$(printf '─%.0s' $(seq 1 $total_inner))┘\033[0m"
  echo ""
}
_welcome