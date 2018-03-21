#!/bin/sh
alias source=.
source "$HOME/.green_sh_lib"
wampy="/home/jmn/wam.py"

ADDON_SERVER="addons.wesnoth.org"
GAME_VERSION="1.12" #Switching between game versions is not supported.
CACHE_DIR="$HOME/.cache/WAM" #To move around, just change this directory.
ADDON_LIST_DIR="$CACHE_DIR/addon_list"
#ADDONS_DIRECTORY="$HOME/.local/share/wesnoth/1.12/data/add-ons"
ADDONS_DIRECTORY="$( wesnoth --config-path )/data/add-ons"
ADDON_CACHE="$CACHE_DIR/addons"

#Download addon list, parse and store in cache.
refresh_addon_list(){
	if [ -d "$ADDON_LIST_DIR" ] ; then
		rm -r "$ADDON_LIST_DIR"
	fi
	mkdir "$ADDON_LIST_DIR"
	curl "$ADDON_SERVER/$GAME_VERSION/" > "$ADDON_LIST_DIR/html"
	cat "$ADDON_LIST_DIR/html" | grep "\"addon\"" | $wampy parse_titles > "$ADDON_LIST_DIR/titles"
	cat "$ADDON_LIST_DIR/html" | grep "files.wesnoth.org" | $wampy parse_urls > "$ADDON_LIST_DIR/urls"
	cat "$ADDON_LIST_DIR/html" | $wampy parse_descs > "$ADDON_LIST_DIR/descs"
}

#List available addons
list_addons(){
	cat "$ADDON_LIST_DIR/titles" | grep -n ".*"
}

#Search available addons for addon ("$*")
search_addons(){
	cat "$ADDON_LIST_DIR/titles" | grep -in "$*"
}

#List cached addons
list_cached_addons(){
	ls "$ADDON_CACHE/archives" | sed 's/.tar.gz//g' | sed 's/_/\ /g'
}

#Check if addon ($1) is in cache.
check_cache(){
	echo something
}

#Clear addon cache
clear_cache(){
	if [ -d "$ADDON_CACHE" ] ; then
		rm -r "$ADDON_CACHE"
	fi
	mkdir "$ADDON_CACHE"
}

#Get addon url from addon id.
get_addon_url(){
	cat "$ADDON_LIST_DIR/urls" | get_line_at "$1"
}
#Get addon title from addon id.
get_addon_title(){
	cat "$ADDON_LIST_DIR/titles" | get_line_at "$1"
}
addon_filename_from_url(){
	$wampy "file_from_url" "$GAME_VERSION" "$1"
}
get_addon_filename(){
	local url="$( get_addon_url $1 )"
	addon_filename_from_url "$url"
}
#Get addon id from first addon matching title.
id_first_title_match(){
	cat "$ADDON_LIST_DIR/titles" | grep -n -m 1 "$*" | grep -o "[0-9]" | tr -d '\n:'
}

cache_addon(){
	while [ "$1" ] ; do
		if [ ! -f "$ADDON_CACHE/archives/$( get_addon_filename $1 )" ] ; then
			local url=$( get_addon_url $1 )
			printf "URL: $url\n"
			cache_addon_internal "$url"
		fi
		shift
	done
}

cache_addon_internal(){
	local current_dir="$( pwd )"
	if [ ! -d "$ADDON_CACHE/archives" ] ; then
		mkdir "$ADDON_CACHE/archives"
	fi
	cd "$ADDON_CACHE/archives"
	wget "$1" # -O "$( addon_filename_from_url $1 )"
	cd "$current_dir"
	$wampy "file_from_url" "$GAME_VERSION" "$1"
}

parse_dep_file(){
	local dep_string=$( cat "$1" | grep dependencies )
	#$wampy "clean_dependency_string" "$dep_string" | sed s/,/\ /g
	substring "$dep_string" 16 $( expr $( str_length "$dep_string" ) - 1 ) | sed s/,/\ /g
}

#Builds cached addon. Fails if addon is not cached.
build_addon(){
	local current_dir="$( pwd )"
	if [ ! -d "$ADDON_CACHE/build" ] ; then
		mkdir "$ADDON_CACHE/build"
	fi
	cd "$ADDON_CACHE/build"
	printf "Extracting archive...\n"
	tar xf "$ADDON_CACHE/archives/$1"
	#Right about here, we should read the addon's build dependencies and fetch them as well.
	local dir_name=$( echo "$1" | sed 's/\.tar.*//g' )
	local deps=$( parse_dep_file "$ADDON_CACHE/build/$dir_name/_info.cfg" )
	for dirs in $deps ; do
		local entries=$( printf "$dirs" | sed 's/_/ /g' )
		if [ -d "$ADDONS_DIRECTORY/$dirs" -o -d "$ADDON_CACHE/build/$dirs" ] ; then
			printf "" #$entries is installed.\n"
		else
			#Build dependency here.
			printf "Retrieving $entries\n"
			local ids="$( id_first_title_match $entries )"
			printf "ID: $ids\n"
			cache_addon "$ids"
			local file_names="$( get_addon_filename $ids )"
			build_addon "$file_names" "$entries"
		fi
	done
	cd "$current_dir"
}

#Should probably do some checks to see if it's already installed, or if its dependencies are.
install_addon_internal(){
	local title=$( get_addon_title "$1" )
	local file_name=$( get_addon_filename $1 )
	cache_addon "$1"
	build_addon "$file_name"
	mv $ADDON_CACHE/build/* $ADDONS_DIRECTORY
}

install_addon(){
	while [ "$1" ] ; do
		install_addon_internal "$1"
		shift
	done
	printf "Installation complete.\n"
}

help(){
	printf 'Options:\n\trefresh_addon_list, list_addons, check_cache, clear_cache, install_addon'
}

eval "$*"
