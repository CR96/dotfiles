# Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

alias editzsh='vim ~/.zshrc'
alias editvim='vim ~/.vimrc'
alias source=source' ~/.zshrc'

alias androidstudio='sh /usr/share/applications/android-studio/bin/studio.sh'
alias gogland='sh /usr/share/applications/gogland/bin/gogland.sh'
alias udk='~/unrealengine/Engine/Binaries/Linux/UE4Editor'

export M2_HOME=~/uportal/maven
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
export PATH=%JAVA_HOME/bin:$PATH

export ANT_HOME=~/uportal/ant
export PATH=$PATH:$ANT_HOME/bin

export TOMCAT_HOME=~/uportal/tomcat
export PATH=$PATH:$TOMCAT_HOME

export JAVA_OPTS="-server -XX:MaxPermSize=512m -Xms1024m -Xmx2048m"

# ls after every cd
function cd {
	builtin cd "$@" && ls -F
}

# Soffit Build Script (Serves soffit on port 8090)
function buildsoffit {
	cd ~/soffits/preferredNames
	./gradlew clean build
	java -Dcatalina.home=build -Dserver.port=8090 -jar build/libs/preferredNames-0.0.1-SNAPSHOT.war
}

# Tomcat Script
function t {
    for i in "$@"; do
        if [[ $i == "start" ]]; then
            $TOMCAT_HOME/bin/startup.sh
        elif [[ $i == "stop" ]]; then
            $TOMCAT_HOME/bin/shutdown.sh
            sleep 5
        elif [[ $i == "kill" ]]; then
            pkill -f "tomcat"
        elif [[ $i == "restart" ]]; then
            $TOMCAT_HOME/bin/shutdown.sh
            echo "Restarting..."
            sleep 10
            $TOMCAT_HOME/bin/startup.sh
        elif [[ $i == "clean" ]]; then
            rm -rf $TOMCAT_HOME/webapps/*
            rm -rf $TOMCAT_HOME/work/*
            rm -rf $TOMCAT_HOME/temp/*
        elif [[ $i == "cleanlogs" ]]; then
            rm -rf $TOMCAT_HOME/logs/*
        elif [[ $i == "s" || $i == "status" ]]; then
            ps aux | grep 'tomcat'
        elif [[ $i == "tail" ]]; then
            tail -f $TOMCAT_HOME/logs/catalina.out
        elif [[ $i == "help" || $i == "h" ]]; then
            echo "Tomcat commands:"
            echo "start: starts Tomcat"
            echo "stop: stops Tomcat"
            echo "kill: force stops Tomcat"
            echo "restart: restarts Tomcat"
            echo "clean: clears Tomcat configuration files"
            echo "cleanlogs: clears Tomcat logs"
            echo "status: displays Tomcat status"
            echo "help: displays this help text"
        else
            echo "Unrecognized command. Type \"t help\" for a list of commands."
        fi
    done
}
