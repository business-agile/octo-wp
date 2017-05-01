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

# Listing of ocre, themes and plugins data
core_data=($(wp core check-update --path=$wp_dir))
theme_data=($(wp theme list --update=available --path=$wp_dir))
plugin_data=($(wp plugin list --update=available --path=$wp_dir))
# Test if maintenances actions are available
if [ -z ${core_data[3]} ] && [ -z ${theme_data[4]} ] && [ -z ${plugin_data[4]} ]
then
	bot_title "Great! Your WordPress is perfectly updated (I'm probably a part of this wonderful success"
else
	bot_title "Some updates are in the pipe. Don't worry I'm here for that! Here we go!"

	# create a new branch from master
	bot_title "First, I create a new git branch to protect your amazing code"
	bot_text "To take a good start, I start our updates branch from master"
	git checkout -q master
	bot_text "Ready to create updates branch"
	git checkout -qB $branch_name
	bot_text "Updates branch is ready. Let's go for your WordPress maintenance"

	if [ -n ${core_data[3]} ]
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
			git add . && git commit -qm "[Octo] Update of $theme theme from version $current_version to version $next_version"
			let "current_update_index+=1"
			bot_text "Great! What's next?"
		done
	fi
	bot_text "WordPress core is now up to date"

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
				git add . && git commit -qm "[Octo] Update of $theme theme from version $current_version to version $next_version"
				bot_text "Great! What's next?"
		done
	fi

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
				git add . && git commit -qm "[Octo] Update of $plugin plugin from version $current_version to version $next_version"
				bot_text "Great! What's next?"
		done
	fi
fi
