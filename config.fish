#!/usr/bin/env fish

# git removing ALL local branches which do no longer exist on the remote (git fetch --prune is not engough!)

function git-prune-branches-dry-run
	bash -c 'git fetch -p ; git branch -r | awk \'{print $1}\' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk \'{print $1}\''
end

function git-prune-branches
	git-prune-branches-dry-run | xargs git branch -D
end



# colima (similar to WSL2 but for macos)

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

#mysql tools
fish_add_path /opt/homebrew/opt/mysql-client/bin

# add all binaries installed with homebrew
fish_add_path -a /usr/local/bin
fish_add_path -a /opt/homebrew/bin

alias ku="kubectl"
alias kx="kubectx"

# nvm has been replaced with fnm
#load_nvm
# use the latest lts release as the default
#nvm alias default "lts/*"

# image helper functions


function to64x64png
	sips -z 64 64 "$argv[1]" --out "$argv[1].64x64.png"
end



# kubernetes helper functions

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


# change ctrl+c to whatever you want to trigger the interrupt
stty intr '^f'

# upgrade all tools installed through homebrew including gui tools, even if the gui tools provide auto updates
alias uu="fnm install --lts && brew update && brew outdated && brew upgrade && brew upgrade --cask --greedy"

function rm
	echo "dont use rm, use trash-put instead!"
end

alias uuidv4="uuidgen | tr '[:upper:]' '[:lower:]'"


# nvm update aliases

#function upgrade-node
#	set current_node (node --version)
#	nvm use node
#	nvm install node --latest-npm --reinstall-packages-from=node
#	nvm use "$current_node"
#end

#function upgrade-node-lts
#	load_nvm
#	set current_node (node --version)
#	echo "$current_node"
#	nvm use --lts
#	nvm install "lts/*" --reinstall-packages-from=(nvm current)
#	echo "$current_node"
#	nvm use "$current_node"
#end

# git aliases 


alias gst="git status"
alias gaa="git add -A :/"
alias glog="git log"

function gdiff
	if not set -q argv[1]
		git diff
	else
		git diff "$argv[1]"
	end
end




function gdiffs
	if not set -q argv[1]
		git diff --staged
	else
		git diff --staged "$argv[1]"
	end
end



function greset
	if not set -q argv[1]
		git reset
	else
		git reset "$argv[1]"
	end
end


function gcomm
	echo "$argv[1]"
end

function grollback
	git reset "$argv[1]"
	git restore "$argv[1]"
end

/opt/homebrew/bin/direnv hook fish | source
kubectl completion fish | source

set -gx PATH $PATH $HOME/.krew/bin
