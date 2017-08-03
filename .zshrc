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

alias ls='ls -F --color=auto'

alias editzsh='vim ~/.zshrc'
alias editvim='vim ~/.vimrc'
alias source=source' ~/.zshrc'

alias androidstudio='sh ~/programs/android-studio/bin/studio.sh'
alias gogland='sh ~/programs/gogland/bin/gogland.sh'
alias udk='~/programs/unrealengine/Engine/Binaries/Linux/UE4Editor'

###############################
#                             #
#    Environment Variables    #
#                             #
###############################

export UPORTAL_HOME=/home/$USER/uportal/mysail #default
export PATH=$PATH:$UPORTAL_HOME

export GRADLE_HOME=/opt/gradle/gradle-4.0.1/bin
export PATH=$GRADLE_HOME:$PATH

export M2_HOME=/home/$USER/uportal/maven
export M2=$M2_HOME/bin
export PATH=$M2:$PATH

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
export PATH=%JAVA_HOME/bin:$PATH

export ANDROID_HOME=${HOME}/Android/sdk
export PATH=${PATH}:${ANDROID_HOME}/tools
export PATH=${PATH}:${ANDROID_HOME}/platform-tools

export ANT_HOME=/home/$USER/uportal/ant
export PATH=$PATH:$ANT_HOME/bin

export TOMCAT_HOME=/home/$USER/uportal/tomcat
export PATH=$PATH:$TOMCAT_HOME
export CATALINA_HOME=$TOMCAT_HOME
export PATH=$PATH:$CATALINA_HOME

export GOPATH=${HOME}/go
export PATH=$PATH:$GOPATH

########################
#                      #
#    Custom Scripts    #
#                      #
########################

# Update everything, and don't ask about it
function update {
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get dist-upgrade -y
	sudo apt autoremove -y
}

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

# Switches maven repo between public and internal
function switchMaven {
	FILE_ACTIVE=/home/$USER/.m2/settings.xml
	FILE_BACKUP=/home/$USER/.m2/settings_ou.xml
	if [ -f $FILE_BACKUP ]; then
			# Overwrite settings with the backup
			mv $FILE_BACKUP $FILE_ACTIVE

			# Set uPortal directory to apereo
			export UPORTAL_HOME=/home/$USER/uportal/apereo
			export PATH=$PATH:$UPORTAL_HOME

			echo "Successfully switched to the internal repository."
	else
			# Backup the internal settings, then remove them
			cp $FILE_ACTIVE $FILE_BACKUP
			rm $FILE_ACTIVE

			# Set uPortal directory to mysail
			export UPORTAL_HOME=/home/$USER/uportal/mysail
			export PATH=$PATH:$UPORTAL_HOME

			echo "Successfully switched to the external repository."
	fi
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
	cd ~/uportal/uportal
	for i in "$@"; do
		grep $i . -r -l --exclude-dir=target
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

# Delete, reclone, and rebuild Apereo's uPortal
function bigredbutton {
	read "response?Push the big red button? [y/N] "
	if [[ $response =~ ^(yes|y)$ ]] then
		cd ~
		echo "Killing Tomcat..."
		t kill
		echo "Clearing Tomcat logs..."
		t clean && t cleanlogs
		echo "Cleaning gradle and .m2..."
		rm -rf ~/.gradle
		rm -rf ~/.m2/repository
		echo "Moving configuration files to a safe place..."
		mkdir ~/bigredbutton
		cp ~/uportal/uportal/build.properties ~/bigredbutton/build.properties
		cp ~/uportal/uportal/build.local.properties ~/bigredbutton/build.local.properties
		cp ~/uportal/uportal/pom.xml ~/bigredbutton/pom.xml
		cp ~/uportal/uportal/uportal-db/pom.xml ~/bigredbutton/pom-db.xml
		cp ~/uportal/uportal/filters/local.properties ~/bigredbutton/local.properties
		echo "Deleting uPortal..."
		rm -rf ~/uportal/uportal
		echo "Recloning uPortal..."
		git clone https://github.com/jasig/uPortal.git ~/uportal/uportal
		echo "Restoring configuration files..."
		cp ~/bigredbutton/build.properties ~/uportal/uportal/build.properties
		cp ~/bigredbutton/build.local.properties ~/uportal/uportal/build.local.properties
		cp ~/bigredbutton/pom.xml ~/uportal/uportal/pom.xml
		cp ~/bigredbutton/pom-db.xml ~/uportal/uportal/uportal-db/pom.xml
		cp ~/bigredbutton/local.properties ~/uportal/uportal/filters/local.properties
		rm -rf ~/bigredbutton
		echo "Building uPortal..."
		cd ~/uportal/uportal
		ant clean initportal
		echo "Starting Tomcat..."
		t start
		sleep 10
		echo "Complete! Launching uPortal."
		xdg-open http://localhost:8080/uPortal
	else
		echo "Abort."
	fi
}
