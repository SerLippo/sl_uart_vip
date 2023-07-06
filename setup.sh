export VCS_RUN=~/Projects/vrun
alias vrun="python3 $VCS_RUN/vrun.py"
export REPO_BASE=~/Projects/sl_uart_vip

alias uart="vrun -cfg $REPO_BASE/sim/vcs.yaml -o $REPO_BASE/out"