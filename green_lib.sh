#!/bin/sh
#Just some functions to make the code more legible to me.
#It's called "green_lib.sh" because green is my favorite color.

replace_newlines(){
	sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/$2/g' "$1"
}
get_line_at(){
	sed "$1q;d"
}
#substring(){
#	printf "$1" | cut -c "$2-$3"
#}
str_length(){
	printf "$1" | wc -m
}
substring(){
	if [ $(echo "$3" | cut -c "-1") = "-" ] ; then
		end=$( expr $(str_length "$1") + "$3" )
	else
		end="$3"
	fi
	#substring "$1" "$2" "$end"
	printf "$1" | cut -c "$2-$end"
}
