# include os-specific bash files if they exist
if [[ $(uname -s) == Linux ]]; then
  if [ -f $HOME/.bash_linux ]; then
      . $HOME/.bash_linux
  fi;
fi;

if [[ $(uname -s) == Darwin ]]; then
  if [ -f $HOME/.bash_mac ]; then
      . $HOME/.bash_mac
  fi;
fi;

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export GREP_COLOR='1;37;41'
alias grep='grep --color=auto'
alias ls='ls -l -GFh'
alias lsa='ls -la -GFh'
alias ..='cd ..'
alias cl='clear'
alias ...='cd ../../'
alias home='cd ~'
alias log='tail -f log/development.log'
ql () { qlmanage -p "$*" >& /dev/null; }

# Git aliases
alias commits='git log --graph --decorate --oneline'
alias pushbranch='git push -u origin'
alias newbranch='git checkout -b'
alias branches='git branch'
alias commit='git commit -am'
alias status='git status'

#   lr:  Full Recursive Directory Listing
#   ------------------------------------------
alias lr='ls -R | grep ":$" | sed -e '\''s/:$//'\'' -e '\''s/[^-][^\/]*\//--/g'\'' -e '\''s/^/   /'\'' -e '\''s/-/|/'\'' | less'

#   mans:   Search manpage given in agument '1' for term given in argument '2' (case insensitive)
#           displays paginated result with colored search terms and two lines surrounding each hit.            Example: mans mplayer codec
#   --------------------------------------------------------------------
mans () {
        man $1 | grep -iC2 --color=always $2 | less
}

alias qfind="find . -name "                 # qfind:    Quickly search for file

#   spotlight: Search for a file using MacOS Spotlight's metadata
#   -----------------------------------------------------------
spotlight () { mdfind "kMDItemDisplayName == '$@'wc"; }

#   ---------------------------
#   6. NETWORKING
#   ---------------------------

alias myip='ipconfig getifaddr en0'                    # myip:         Public facing IP Address

#   ---------------------------------------
#   8. WEB DEVELOPMENT
#   ---------------------------------------

alias apacheEdit='sudo edit /etc/httpd/httpd.conf'      # apacheEdit:       Edit httpd.conf
alias restart='sudo /etc/init.d/apache2 restart'           # apacheRestart:    Restart Apache
alias editHosts='sudo edit /etc/hosts'                  # editHosts:        Edit /etc/hosts file
alias herr='tail /var/log/httpd/error_log'              # herr:             Tails HTTP error logs
alias apacheLogs="less +F /var/log/apache2/error_log"   # Apachelogs:   Shows apache error logs
httpHeaders () { /usr/bin/curl -I -L $@ ; }             # httpHeaders:      Grabs headers from web page

# Terminal Prompt with Github Branch and Colorization

function prompt {
  local BLACK="\[\033[0;30m\]"
  local BLACKBOLD="\[\033[1;30m\]"
  local RED="\[\033[0;31m\]"
  local REDBOLD="\[\033[1;31m\]"
  local GREEN="\[\033[0;32m\]"
  local GREENBOLD="\[\033[1;32m\]"
  local YELLOW="\[\033[0;33m\]"
  local YELLOWBOLD="\[\033[1;33m\]"
  local BLUE="\[\033[0;34m\]"
  local BLUEBOLD="\[\033[1;34m\]"
  local PURPLE="\[\033[0;35m\]"
  local PURPLEBOLD="\[\033[1;35m\]"
  local CYAN="\[\033[0;36m\]"
  local CYANBOLD="\[\033[1;36m\]"
  local WHITE="\[\033[0;37m\]"
  local WHITEBOLD="\[\033[1;37m\]"
  local RESETCOLOR="\[\e[00m\]"

if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
	export TERM='gnome-256color';
elif infocmp xterm-256color >/dev/null 2>&1; then
	export TERM='xterm-256color';
fi;

prompt_git() {
	local s='';
	local branchName='';

	# Check if the current directory is in a Git repository.
	if [ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]; then

		# check if the current directory is in .git before running git checks
		if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

			# Ensure the index is up to date.
			git update-index --really-refresh -q &>/dev/null;

			# Check for uncommitted changes in the index.
			if ! $(git diff --quiet --ignore-submodules --cached); then
				s+='+';
			fi;

			# Check for unstaged changes.
			if ! $(git diff-files --quiet --ignore-submodules --); then
				s+='!';
			fi;

			# Check for untracked files.
			if [ -n "$(git ls-files --others --exclude-standard)" ]; then
				s+='?';
			fi;

			# Check for stashed files.
			if $(git rev-parse --verify refs/stash &>/dev/null); then
				s+='$';
			fi;

		fi;

		# Get the short symbolic ref.
		# If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
		# Otherwise, just give up.
		branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
			git rev-parse --short HEAD 2> /dev/null || \
			echo '(unknown)')";

		[ -n "${s}" ] && s=" [${s}]";

		echo -e "${1}${branchName}${2}${s}";
	else
		return;
	fi;
}

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
	userStyle="${REDBOLD}";
else
	userStyle="${RED}";
fi;

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
	hostStyle="${YELLOWBOLD}";
else
	hostStyle="${YELLOW}";
fi;

# Set the terminal title and prompt.
PS1="\[\033]0;\W\007\]"; # working directory base name
PS1+="\[${bold}\]\n"; # newline
PS1+="\[${userStyle}\]\u"; # username
PS1+="\[${WHITE}\] at ";
PS1+="\[${hostStyle}\]\h"; # host
PS1+="\[${WHITE}\] in ";
PS1+="\[${GREEN}\]\w"; # working directory full path
PS1+="\$(prompt_git \"\[${WHITE}\] on \[${PURPLE}\]\" \"\[${BLUE}\]\")"; # Git repository details
PS1+="\[${RESETCOLOR}\]\n"; # newline
PS1+="\[${RED}\]>> \[${RESETCOLOR}\]"; # `$` (and reset color)
export PS1;
}

prompt
