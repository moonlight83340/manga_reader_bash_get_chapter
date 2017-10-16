#!/bin/bash
#Author Gaëtan

# gets the manga
#
# @param string name of manga
# @param string chapter of manga
# @param string target directory in which manga will be stored
# @return number exit status
# @access public
get () {
    local name="$1"
    local chapter=$2
    local directory="${3-$PWD}"
    
    # URI to main page of chapter
    local URL="http://www.mangareader.net/${name}/${chapter}"

    # directory of chapter
    directory="${directory}/${name}/${chapter}"

    init $directory

    echo "Get chapter ${chapter}..."
    getPages $URL $name $chapter $directory
    return $?
}

# @param directory
# @access private
init(){
	local directory=$1
	if [ ! -d "${directory}" ]; then
        mkdir -p "${directory}"
	fi
}

# outputs URL of image of given manga page.
#
# @param string URL of manga page
# @output string
# @access private
getImageUrl () {
    local img_url=$(wget -q "${1}" -O - | grep 'id="img"' | sed 's/.*src="//g' | sed 's/".*//g')
    echo "${img_url}"
}


# returns page count of chapter
# @param string URL of manga page
# @return count
# @access private
getPageCount () {
	local URL=$1
    local pages=$(wget -q "${URL}" -O - | grep '</select> of ' | sed 's#</select> of ##g' | sed 's#</div>##g')
    return $pages;
}

# returns count of chapter
# @param string URL of manga page
# @return count
# @access private
getChapterCount () {
	local URL=$1
    local ChapterCount=$(wget -q "${URL}" -O - | grep -oP 'href="/onepunch-man/[0-9]+"' | tail -1  | grep -oP '[0-9]+')
    return $ChapterCount;
}

# outputs URI of manga page.
#
# @param name chapter page
# @output string URI
# @access private
getPageUrl () {
    echo "http://www.mangareader.net/${1}/${2}/${3}"
}

# downloads all pages
# @param url name chapter directory
# @access private
getPages () {
	local URL=$1
	local name=$2
	local chapter=$3
	local directory=$4
    getPageCount $URL
    local pages=$?
    echo "Found ${pages} pages."

    for (( i=1; i<=$pages; i++ )); do
        URL=$(getPageUrl $name $chapter $i)
        img_url=$(getImageUrl $URL)
        echo -n "Get page ${i} from ${IMAGEURI}... "
        wget -q ${img_url} --directory-prefix=${directory} -nc
        if [ $? -eq 0 ]; then
            echo ":)"
        else
            echo ":( RETRY:"
            wget ${img_url} --directory-prefix=${directory} -nc
            if [ ! $? -eq 0 ]; then
                echo "Could not download page ${img_url}"
                return 1
            fi
        fi
    done;

    return 0
}

usage(){
	echo "Usage: ./manga-reader.sh <name-of-manga> <chapter> [target-dir]";
	exit 1;
}

#main

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "usage" ];then
	usage
	exit 0
fi

if [ ! $# -eq 2 ]; then
	usage
fi
get $1 $2 $3
exit 0
