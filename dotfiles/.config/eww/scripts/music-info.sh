#!/bin/bash

## Get data
STATUS="$(playerctl status)"
PLAYBACK_DATA=$(playerctl get key playback | jq -r .)
COVER="/tmp/.music_cover.jpg"

## Get status
get_status() {
	if [[ $STATUS == "Playing" ]]; then
		echo ""
	else
		echo ""
	fi
}

## Get song
get_song() {
	local song=$(echo $PLAYBACK_DATA | jq -r .item.title)
	echo "${song:-Offline}"
}

## Get artist
get_artist() {
	local artists=$(echo $PLAYBACK_DATA | jq -r .item.artists[].name | tr '\n' ' ')
	echo "${artists:-Offline}"
}

## Get time
get_time() {
	local current_time=$(echo $PLAYBACK_DATA | jq -r .progress_ms)
	local total_time=$(echo $PLAYBACK_DATA | jq -r .item.duration_ms)
	local progress=$((100 * current_time / total_time))
	echo "${progress:-0}"
}

get_ctime() {
	local current_time=$(echo $PLAYBACK_DATA | jq -r .progress_ms)
	local ctime=$(date -d@$(($current_time / 1000)) -u +%M:%S)
	echo "${ctime:-0:00}"
}

get_ttime() {
	local total_time=$(echo $PLAYBACK_DATA | jq -r .item.duration_ms)
	local ttime=$(date -d@$(($total_time / 1000)) -u +%M:%S)
	echo "${ttime:-0:00}"
}

## Get cover
get_cover() {
	local url=$(echo $PLAYBACK_DATA | jq -r "[.item.album.images[] | select(.height > 150)][0].url")
	if [ -z "$url" ]; then
		echo "images/music.png"
		return
	fi

	curl -s "$url" > "$COVER"

	if [ $? -eq 0 ]; then
		echo "$COVER"
	else
		echo "images/music.png"
	fi
}

## Execute accordingly
case "$1" in
	--song) get_song ;;
	--artist) get_artist ;;
	--status) get_status ;;
	--time) get_time ;;
	--ctime) get_ctime ;;
	--ttime) get_ttime ;;
	--cover) get_cover ;;
	--toggle) spotify_player playback play-pause ;;
	--next) spotify_player playback next; get_cover ;;
	--prev) spotify_player playback previous; get_cover ;;
esac
