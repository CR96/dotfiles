###################
#                 #
#    Zsh Setup    #
#                 #
###################

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

#################
#               #
#    Aliases    #
#               #
#################

alias ls='ls -F --color=auto'

alias editzsh='vim ~/.zshrc'
alias editvim='vim ~/.vimrc'
alias source=source' ~/.zshrc'

alias androidstudio='sh /usr/share/applications/android-studio/bin/studio.sh'
alias gogland='sh /usr/share/applications/gogland/bin/gogland.sh'
alias udk='~/unrealengine/Engine/Binaries/Linux/UE4Editor'

###############################
#                             #
#    Environment Variables    #
#                             #
###############################

export M2_HOME=~/uportal/maven
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
export PATH=%JAVA_HOME/bin:$PATH

export ANT_HOME=~/uportal/ant
export PATH=$PATH:$ANT_HOME/bin

export TOMCAT_HOME=~/uportal/tomcat
export PATH=$PATH:$TOMCAT_HOME

########################
#                      #
#    Custom Scripts    #
#                      #
########################

# ls after every cd
function cd {
	builtin cd "$@" && ls
}

# Deploys soffit on port 8090
function deploysoffit {
    for i in "$@"; do
	  cd $i
	  ./gradlew clean build
	  java -Dcatalina.home=build -Dserver.port=8090 -jar build/libs/*.war
	done
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
