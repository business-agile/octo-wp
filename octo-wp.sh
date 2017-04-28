#!/bin/bash
#
# Octo for WordPress
# Automatize your WordPress management
#
# Created by @bibzz (alexandre.berrebi@businessagile.eu)
# Inspired by @maximebj (maxime@smoothie-creative.com)
#


# VARS 
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
bot_title "${blue}${bold}Bonjour ! Je suis Octo.${normal}"
bot_title "Regardons si votre site a besoin que j'intervienne : ${cyan}$2${normal}"

# Listing of ocre, themes and plugins data
core_data=($(wp core check-update))
theme_data=($(wp theme list --update=available))
plugin_data=($(wp plugin list --update=available))
# Test if maintenances actions are available
if [ -z ${core_data[3]} ] && [ -z ${theme_data[4]} ] && [ -z ${plugin_data[4]} ]
then
	bot_title"Excellent! Votre site est parfaitement à jour. Au revoir"
else
	bot_title"Des mises à jour sont disponibles! Je vous les installe immédiatement!"

	# create a new branch from master
	bot_title"Je me positionne sur la branche master"
	git checkout -q master
	bot_title"Je crée la branche git qui contiendra les mises à jour"
	git checkout -qB $branch_name

	if [ -n ${core_data[3]} ]
	then
		let "updates_left=${#core_data[*]}/3-1"
		let "current_update_index=1"
		while [ $current_update_index -le $updates_left ]
		do
			# Update core
			current_version=$(wp core version)
			next_version=${core_data[$current_update_index*3]}
			update_type=${core_data[$current_update_index*3+1]}
			bot_title"Apply WordPress core $update_type update ($current_version=>$next_version)"
			wp core upgrade --version=$next_version --quiet
			git add . && git commit -qm "[Octo] Update of $theme theme from version $current_version to version $next_version"
			let "current_update_index+=1"
		done
	fi

	if [ -n ${theme_data[4]} ]
	then
		# update themes
		bot_title"Je vérifie que vos thèmes sont à jour"
		for theme in $(wp theme list --update=available --field=name)
			do
				data=($(wp theme update $theme --dry-run))
				theme=${data[7]}
				status=${data[8]}
				current_version=${data[9]}
				available_version=${data[10]}
				bot_title"Je mets à jour $theme (status:$status) from version $current_version to version $available_version"
				wp theme update $theme --quiet
				git add . && git commit -qm "[Octo] Update of $theme theme from version $current_version to version $available_version"
		done
	fi

	if [ -n ${plugin_data[4]} ]
	then
		# update plugins
		bot_title"Je vérifie que vos plugins sont à jour"
		for plugin in $(wp plugin list --update=available --field=name)
			do
				data=($(wp plugin update $plugin --dry-run))
				plugin=${data[7]}
				status=${data[8]}
				current_version=${data[9]}
				available_version=${data[10]}
				bot_title"Je mets à jour $plugin (status:$status) from version $current_version to version $available_version"
				wp plugin update $plugin --quiet
				git add . && git commit -qm "[Octo] Update of $plugin plugin from version $current_version to version $available_version"
		done
	fi
fi
