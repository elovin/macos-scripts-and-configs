#!/usr/bin/env fish

#--------------------------------------------------------------------------------------------------------------------
#### Encryption custom funcations / Special (function) Aliases

function encrypt-using-7z
	7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mhe=on encrypted-content $argv -p
end

#--------------------------------------------------------------------------------------------------------------------
#### Process handling

function force-kill-all-by-name
	kill -KILL (ps -x | grep "$argv[1]" | awk '{print $1}')
end

function gracefull-kill-all-by-name
	kill -TERM (ps -x | grep "$argv[1]" | awk '{print $1}')
end

#--------------------------------------------------------------------------------------------------------------------
#### Colima (similar to WSL2 but for macos) custom funcations / Special (function) Aliases

alias docker-stop-all='docker stop (docker ps -a -q)'

function docker	
	echo "Starting colima if its not running yet ..."
	colima start
	
	echo "Now running your docker command (function from $USER)"
	/opt/homebrew/bin/docker $argv	
end


function docker-compose
	echo "Starting colima if its not running yet ..."
	colima start

	echo "Now running your docker-compose command (function from $USER)"	
	/opt/homebrew/bin/docker-compose $argv
end


#--------------------------------------------------------------------------------------------------------------------
#### Image custom funcations / Special (function) Aliases


function to64x64png
	sips -z 64 64 "$argv[1]" --out "$argv[1].64x64.png"
end

#--------------------------------------------------------------------------------------------------------------------
#### azure-cli custom funcations / Special (function) Aliases

function az-get-aks-config --wraps="az aks get-credentials" 
	az aks get-credentials --overwrite-existing $argv
end

complete -c az-get-aks-config -a "az aks get-credentials"

#--------------------------------------------------------------------------------------------------------------------
#### Kubernetes custom funcations / Special (function) Aliases

function switch-context --wraps="kubectl config use-context" 
	kubectl config use-context $argv
end

complete -c switch-context -a "kubectl config use-context"



function use-context --wraps="kubectl config use-context" 
	kubectl config use-context $argv
end

complete -c use-context -a "kubectl config use-context"



function show-contexts --wraps="kubectl config get-contexts" 
	kubectl config get-contexts $argv
end

complete -c show-contexts -a "kubectl config get-contexts"



function list-contexts --wraps="kubectl config get-contexts" 
	kubectl config get-contexts $argv
end

complete -c list-contexts -a "kubectl config get-contexts"


function get-logs --wraps="kubectl logs"
      	if not set -q argv[1]; or not set -q argv[2]
                echo "use this fnc like this: get-logs DEPLOYMENT_NAME NAMESPACE_NAME (you can add more args if you want, e.g. --since=3h --previous=true ...)"
                return 1
        end	

	kubectl logs deployment/"$argv[1]" --namespace="$argv[2]" --all-containers=true --timestamps=true $argv[3..-1]
end

complete -c get-logs -a "kubectl logs"


function pod-logs
	if not set -q argv[1]; or not set -q argv[2]
		echo "use this fnc like this: pod-logs POD_NAME_SUBSTRING NAMESPACE_NAME"
		return 1
	end
	kubectl logs (kubectl get pods -o wide -n "$argv[2]" | grep "$argv[1]" | awk '{print $1}') -n "$argv[2]"
end



function describe-pod
	if not set -q argv[1]; or not set -q argv[2]
		echo "use this fnc like this: desribe-pod POD_NAME_SUBSTRING NAMESPACE_NAME"
		return 1
	end
	kubectl describe pod (kubectl get pods -o wide -n "$argv[2]" | grep "$argv[1]" | awk '{print $1}') -n "$argv[2]"
end


#--------------------------------------------------------------------------------------------------------------------
#### RM custom funcations / Special (function) Aliases
function rm --description 'do not use it, use trash-put!'
	echo "dont use rm, use trash-put instead!"
	echo "WARNING, passing your args to trash-put!"
	echo "you have 5 seconds to interrupt this command!"
	sleep 5
	trash-put --verbose $argv
	echo "use trash-list and/or trash-restore to restore the file/dir"
end

#--------------------------------------------------------------------------------------------------------------------
#### Git custom funcations / Special (function) Aliases

function git-status --wraps="git status"
	git status $argv
end

function git-stash-rm-all --description 'stashes everything and then CLEARS the stash!'
	git add -A :/ && git stash && git stash clear
end


function git-stash-push-all --description 'git add all then stash'
	git add -A :/ && git stash
end


function git-stash-pop --description 'git stash apply'
	git stash apply
end

# git removing ALL local branches which do no longer exist on the remote (git fetch --prune is not engough!)
function git-prune-branches-dry-run
	bash -c 'git fetch -p ; git branch -r | awk \'{print $1}\' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk \'{print $1}\''
end

function git-prune-branches
	git-prune-branches-dry-run | xargs git branch -D
end

function git-diff-all --description 'show all changes compared to last commit'
	if not set -q argv[1]
		git diff
	else
		git diff "$argv[1]"
	end
end


function git-diff-added --description='only include files added to staging (git add ...)'
	if not set -q argv[1]
		git diff --staged
	else
		git diff --staged "$argv[1]"
	end
end


#--------------------------------------------------------------------------------------------------------------------
#### Simple aliases

alias gst="git status"
alias gaa="git add -A :/"
alias glog="git log"

# service from a red hat developer to check your ip
alias myip="curl -4 icanhazip.com"

alias ni="npm ci"

alias uuidv4="uuidgen | tr '[:upper:]' '[:lower:]'"

alias ku="kubectl"
alias kx="kubectx"

#--------------------------------------------------------------------------------------------------------------------
#### Update commands

# upgrade all tools installed through homebrew including gui tools, even if the gui tools provide auto updates
function uu
	fish -c "fnm install --lts && fnm use lts-latest && fnm default (node --version) && brew update && brew outdated && brew upgrade && brew cu -a"
end

#--------------------------------------------------------------------------------------------------------------------
#### Special settings


# change ctrl+c to whatever you want to trigger the interrupt
stty intr '^c'

#--------------------------------------------------------------------------------------------------------------------
#### Add FISH Completions


starship init fish | source
/opt/homebrew/bin/direnv hook fish | source
kubectl completion fish | source

#--------------------------------------------------------------------------------------------------------------------
#### PATHS and ENV variables

# install GUI AKA CASK tools to home folder to avoid sudo which causes lots of problems with admin by request
set -xg HOMEBREW_CASK_OPTS "--appdir=~/Applications"

# set colima docker to default context
set -xg DOCKER_HOST "unix://$HOME/.colima/default/docker.sock"

# kubernetes plugins
set -gx PATH $PATH $HOME/.krew/bin

# add rust to path using fish
set -gx PATH "$HOME/.cargo/bin" $PATH;

# webstorm cli tool
fish_add_path ~/Applications/WebStorm.app/Contents/MacOS

# mysql tools
fish_add_path /opt/homebrew/opt/mysql-client/bin

# add all binaries installed with homebrew
fish_add_path -a /usr/local/bin
fish_add_path -a /opt/homebrew/bin
#--------------------------------------------------------------------------------------------------------------------
