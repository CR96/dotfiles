###################
#                 #
#    Zsh Setup    #
#                 #
###################

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Don't ask for confirmation when rm * is used
setopt rm_star_silent

# Use modern completion system
autoload -Uz compinit
compinit

# Show current directory at prompt
export PS1="[%* - %D] %d %% "

#################
#               #
#    Aliases    #
#               #
#################

# Silence system bell when using less pager
alias less='less -Q'
alias man 'man -P "less -Q"'

alias webapp=$UPORTAL_HOME/bin/webapp_cntl.sh

# Video playback in the tty, just for fun
alias play='mpv'
alias playascii='mplayer -vo caca'

alias mute='pactl set-sink-volume 0 0%'
alias volup='pactl set-sink-volume 0 +5%'
alias voldown='pactl set-sink-volume 0 -5%'

# Git enhancements
alias log='git log --graph --decorate --pretty=oneline --abbrev-commit --all'

alias ls='ls -F --color=auto'

alias editzsh='vim ~/.zshrc'
alias editvim='vim ~/.vimrc'
alias source=source' ~/.zshrc'

###############################
#                             #
#    Environment Variables    #
#                             #
###############################

export UPORTAL_HOME=/home/$USER/uportal/uportal-start #default
export PORTAL_HOME=/home/$USER/portal-apereo #default

export PATH=$PATH:$UPORTAL_HOME
export PATH=$PATH:$PORTAL_HOME

export M2_HOME=/home/$USER/uportal/maven
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

export JAVA_HOME=/opt/icedtea-bin-3.8.0/
export PATH=%JAVA_HOME/bin:$PATH

export ANDROID_HOME=/usr/local/android
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/platform-tools

export ANT_HOME=/home/$USER/uportal/ant
export PATH=$PATH:$ANT_HOME/bin

export GOPATH=${HOME}/go
export PATH=$PATH:$GOPATH

########################
#                      #
#    Custom Scripts    #
#                      #
########################

# ls after every cd
function cd {
	builtin cd "$@" && ls
}

# Deploys Maven portlet
function deployMavenPortlet {
	mvn clean package -Dfilters.file=$UPORTAL_HOME/filters/local.properties
	WARPATH=`readlink -f $(find . -name '*.war' -type f)`
	cd $UPORTAL_HOME
	ant deployPortletApp -DportletApp=$WARPATH
	cd -
}

# Deploys Gradle portlet
function deployGradlePortlet {
	if gradle clean build -Dfilters=$UPORTAL_HOME/filters/local.properties; then
		sleep 1
		WARPATH=`readlink -f $(find . -name '*.war' -type f)`
		cd $UPORTAL_HOME
		sleep 1
		ant deployPortletApp -DportletApp=$WARPATH
		echo $WARPATH
		cd -
    fi
}

# Set up environment variables for uPortal 4/5 or MySAIL 4/5
function switchEnv {
	echo "Killing Tomcat to avoid conflicts."
	pkill -f "tomcat"
	for i in "$@"; do
		if [[ $i == "0" ]] then

			echo "Setting UPORTAL_HOME to '~/uportal/uportal-start'."
			export UPORTAL_HOME=/home/$USER/uportal/uportal-start

			echo "Unsetting CATALINA_HOME."
			unset CATALINA_HOME

			echo "Setting PORTAL_HOME to '~/portal-apereo'."
			export PORTAL_HOME=/home/$USER/portal-apereo

			export PATH=$PATH:$UPORTAL_HOME:$PORTAL_HOME
			echo "Successfully switched to uPortal 5 build environment."

		elif [[ $i == "1" ]] then

			echo "Setting UPORTAL_HOME to '~/uportal/mysail-start'."
			export UPORTAL_HOME=/home/$USER/uportal/mysail-start

			echo "Unsetting CATALINA_HOME."
			unset CATALINA_HOME

			echo "Setting PORTAL_HOME to '~/portal-ou'."
			export PORTAL_HOME=/home/$USER/portal-ou

			export PATH=$PATH:$UPORTAL_HOME:$PORTAL_HOME
			echo "Successfully switched to MySAIL 5 build environment."

		elif [[ $i == "2" ]]; then

			echo "Setting UPORTAL_HOME to '~/uportal/uportal'."
			export UPORTAL_HOME=/home/$USER/uportal/uportal

			echo "Setting CATALINA_HOME to '~/uportal/tomcat-uportal4'."
			export CATALINA_HOME=/home/$USER/uportal/tomcat-uportal4

			echo "Unsetting PORTAL_HOME."
			unset PORTAL_HOME

			export PATH=$PATH:$UPORTAL_HOME:$CATALINA_HOME
			echo "Successfully switched to uPortal 4 build environment."

		elif [[ $i == "3" ]]; then

			echo "Setting UPORTAL_HOME to '~/uportal/mysail4'."
			export UPORTAL_HOME=/home/$USER/uportal/mysail4

			echo "Setting CATALINA_HOME to '~/uportal/tomcat-mysail4'."
			export CATALINA_HOME=/home/$USER/uportal/tomcat-mysail4

			echo "Unsetting PORTAL_HOME."
			unset PORTAL_HOME

			export PATH=$PATH:$UPORTAL_HOME:$CATALINA_HOME
			echo "Successfully switched to MySAIL 4 build environment."

		elif [[ $i == "help" ]]; then
			echo "Usage: switchEnv [OPTION]"
			echo "0: uPortal 5"
			echo "1: MySAIL 5"
			echo "2: uPortal 4"
			echo "3: MySAIL 4"
		else
			echo "Unknown build environment. Use 'switchEnv help' for a list."
		fi
	done

}

# Deploys soffit on port 8090
function deploysoffit {
	for i in "$@"; do
		cd $i
		./gradlew clean build
		java -Dcatalina.home=build -Dserver.port=8090 -jar build/libs/*.war
	done
}

# uPortal-specific grep
function s {
	cd $UPORTAL_HOME
	for i in "$@"; do
		grep $i . -r -l --exclude-dir=target
	done
}

# Tomcat Script
function t {
	for i in "$@"; do
		if [[ $i == "start" ]]; then
			$CATALINA_HOME/bin/startup.sh
		elif [[ $i == "stop" ]]; then
			$CATALINA_HOME/bin/shutdown.sh
			sleep 5
		elif [[ $i == "kill" ]]; then
			pkill -f "tomcat"
		elif [[ $i == "restart" ]]; then
			$CATALINA_HOME/bin/shutdown.sh
			echo "Restarting..."
			sleep 10
			$CATALINA_HOME/bin/startup.sh
		elif [[ $i == "clean" ]]; then
			rm -rf $CATALINA_HOME/webapps/*
			rm -rf $CATALINA_HOME/work/*
			rm -rf $CATALINA_HOME/temp/*
		elif [[ $i == "cleanlogs" ]]; then
			rm -rf $CATALINA_HOME/logs/*
		elif [[ $i == "s" || $i == "status" ]]; then
			ps aux | grep 'tomcat'
		elif [[ $i == "tail" ]]; then
			tail -f $CATALINA_HOME/logs/catalina.out
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
