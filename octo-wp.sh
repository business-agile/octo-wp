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

# Octo has something to say
function bot {
  line
  echo -e "${blue}${bold}(Octo)  $1 ${normal}"
}

#  ==============================
#  = The show is about to begin =
#  ==============================

# Welcome !
bot "${blue}${bold}Bonjour ! Je suis Octo.${normal}"
echo -e "Regardons si votre site a besoin que j'intervienne : ${cyan}$2${normal}"

# Listing of ocre, themes and plugins data
core_data=($(wp core check-update))
theme_data=($(wp theme list --update=available --dry-run))
plugin_data=($(wp plugin list --update=available --dry-run))
# Test if maintenances actions are available
if [ -z ${core_data[3]} ] && [ -z ${theme_data[4]} ] && [ -z ${plugin_data[4]} ]
then
	bot "Excellent! Votre site est parfaitement à jour. Au revoir"
else
	bot "Des mises à jour sont disponibles! Je vous les installe immédiatement!"

	# create a new branch from master
	bot "Je me positionne sur la branche master"
	git checkout master
	bot "Je crée la branche git qui contiendra les mises à jour"
	git checkout -b $branch_name

	if [ -n ${core_data[3]} ]
	then	
		# Update core
		bot "Je met WordPress est à jour"
		wp core upgrade
	fi

	if [ -n ${theme_data[4]} ]
	then
		# update thêmes
		bot "Je vérifie que vos thêmes sont à jour"
		for theme in $(wp theme list --update=available --field=name)
			do
				data=($(wp theme update $theme --dry-run))
				theme=${data[7]}
				status=${data[8]}
				current_version=${data[9]}
				available_version=${data[10]}
				bot "Je mets à jour $theme (status:$status) from version $current_version to version $available_version"
				wp theme update $theme
				git add . && git commit -m "[Octo] Update of $theme theme from version $current_version to version $available_version"
		done
	fi

	if [ -n ${plugin_data[4]} ]
	then
		# update plugins
		bot "Je vérifie que vos plugins sont à jour"
		for plugin in $(wp plugin list --update=available --field=name)
			do
				data=($(wp plugin update $plugin --dry-run))
				plugin=${data[7]}
				status=${data[8]}
				current_version=${data[9]}
				available_version=${data[10]}
				bot "Je mets à jour $plugin (status:$status) from version $current_version to version $available_version"
				wp plugin update $plugin
				git add . && git commit -m "[Octo] Update of $plugin plugin from version $current_version to version $available_version"
		done
	fi
fi
