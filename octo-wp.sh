#!/bin/bash -x
#
# Octo for WordPress
# Automatize your WordPress management
#
# Created by @bibzz (alexandre.berrebi@businessagile.eu)
# Inspired by @maximebj (maxime@smoothie-creative.com)
# 
# $1 : WordPress directory 


# VARS 
# Set on which directory 
wp_dir=$1

# date of today
today=$(date +%g%m%d)

# Branch prefix
branch_prefix="octo-update"

# Branch name
branch_name="${branch_prefix}/${today}"

# end VARS ---


#  ===============
#  = Fancy Stuff =
#  ===============
# not mandatory at all

# Stop on error
set -e

# colorize and formatting command line
# You need iTerm and activate 256 color mode in order to work : http://kevin.colyar.net/wp-content/uploads/2011/01/Preferences.jpg
green='\x1B[0;32m'
cyan='\x1B[1;36m'
blue='\x1B[0;34m'
grey='\x1B[1;30m'
red='\x1B[0;31m'
bold='\033[1m'
normal='\033[0m'

# Jump a line
function line {
  echo " "
}

# Octo begin a new subject
function bot_title {
  line
  echo -e "${blue}${bold}(Octo)  $1 ${normal}"
}

# Octo has something to say
function bot_text {
  echo -e "${blue}        $1 ${normal}"
}

#  ==============================
#  = The show is about to begin =
#  ==============================

# Welcome !
bot_title "Hi there! I'm Octo. Something for me today?"

# Check if WordPress is installed
if ! $(wp core is-installed 2> /dev/null);
then
	bot_title "Sorry dude! I can't work if WordPress isn't installed."
	bot_text "I quit!"
	exit
fi

# Listing of core, themes and plugins data
core_data=($(wp core check-update --path=$wp_dir))
theme_data=($(wp theme list --update=available --path=$wp_dir))
plugin_data=($(wp plugin list --update=available --path=$wp_dir))
# Test if maintenances actions are available
# Test 1: Is there core update? (core_data will always output something, so we test which output is)
# Test 2: Is there theme update?
# Test 3: Is there plugin update?
if [ ${core_data[0]} == "Success:" ] && [ -z ${theme_data[4]} ] && [ -z ${plugin_data[4]} ]
then
	# If there's nothing to do, say goodbye!
	bot_title "Great! Your WordPress is perfectly updated (I'm probably a part of this wonderful success)"
else
	# If there's some updates, begin octo's work
	bot_title "There's some updates in the pipe. Don't worry I'm here for that! Here we go!"

	# check if project is git
	bot_title "First, I create a new git branch to protect your amazing code"
	if [ ! -d $wp_dir/.git ]
	then
		# If wordpress directory isn't under git yet, initialize git
		bot_text "Wait, wait, wait.... YOU DON'T HAVE GIT YOUR PROJECT YET?"
		bot_text "Don't worry, I fix this right now!"
		cd $wp_dir
		git init
		cd -
		bot_text "Git initialisation done!"
	fi
	# create a new branch from master
	bot_text "To take a good start, I start our updates branch from master"
	git --git-dir=$wp_dir/.git --work-tree=$wp_dir checkout -q master
	bot_text "Ready to create updates branch"
	git --git-dir=$wp_dir/.git --work-tree=$wp_dir checkout -qB $branch_name
	bot_text "Updates branch is ready. Let's go for your WordPress maintenance"

	# CORE MAINTENANCE
	if [ ${core_data[0]} != "Success:" ]
	then
		bot_title "Let's begin with WordPress core operations"
		# set up local variables
		let "updates_left=${#core_data[*]}/3-1"
		let "current_update_index=1"
		# Octo announce how many updates will be applied
		if [ $updates_left -gt 0 ]
		then
			bot_text "I'll apply $updates_left updates"
		else
			bot_text "I'll apply update"
		fi
		# Apply updates
		while [ $current_update_index -le $updates_left ]
		do
			# Update core
			current_version=$(wp core version --path=$wp_dir)
			next_version=${core_data[$current_update_index*3]}
			update_type=${core_data[$current_update_index*3+1]}
			bot_text "Apply WordPress core $update_type update ($current_version=>$next_version)"
			wp core upgrade --version=$next_version --path=$wp_dir --quiet
			bot_text "Commit this update in git"
			git --git-dir=$wp_dir/.git --work-tree=$wp_dir add . && git --git-dir=$wp_dir/.git --work-tree=$wp_dir commit -qm "[Octo] Update of WordPress Core from version $current_version to version $next_version"
			let "current_update_index+=1"
			bot_text "Great! What's next?"
		done
	fi
	bot_text "WordPress core is now up to date"

	# THEMES MAINTENANCE
	if [ -n ${theme_data[4]} ]
	then
		# update themes
		bot_title "Let's continue with themes operations"
		for theme in $(wp theme list --path=$wp_dir --update=available --field=name)
			do
				data=($(wp theme update $theme --path=$wp_dir --dry-run))
				theme=${data[7]}
				status=${data[8]}
				current_version=${data[9]}
				next_version=${data[10]}
				bot_text "I update $theme (status:$status) from version $current_version to version $next_version"
				wp theme update $theme --path=$wp_dir --quiet
				bot_text "Commit this update in git"
				git --git-dir=$wp_dir/.git --work-tree=$wp_dir add . && git --git-dir=$wp_dir/.git --work-tree=$wp_dir commit -qm "[Octo] Update of $theme theme from version $current_version to version $next_version"
				bot_text "Great! What's next?"
		done
	fi

	# PLUGINS MAINTENANCE
	if [ -n ${plugin_data[4]} ]
	then
		# update plugins
		bot_title "Let's finish with plugins operations"
		for plugin in $(wp plugin list --path=$wp_dir --update=available --field=name)
			do
				data=($(wp plugin update $plugin --path=$wp_dir --dry-run))
				plugin=${data[7]}
				status=${data[8]}
				current_version=${data[9]}
				next_version=${data[10]}
				bot_text "I update $plugin (status:$status) from version $current_version to version $next_version"
				wp plugin update $plugin --path=$wp_dir --quiet
				bot_text "Commit this update in git"
				git --git-dir=$wp_dir/.git --work-tree=$wp_dir add . && git --git-dir=$wp_dir/.git --work-tree=$wp_dir commit -qm "[Octo] Update of $plugin plugin from version $current_version to version $next_version"
				bot_text "Great! What's next?"
		done
	fi
fi

# Bye Bye
bot_title "It was a big day today... And we handle it together like heroes!"