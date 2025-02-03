#!/bin/sh

## Get data
CACHE_FILE="$HOME/.cache/music_info.json"
COVER="/tmp/.music_cover.jpg"

if (( $(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}'))) > 500 )); then
	PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

	if [[ $($PLAYBACK_DATA | jq -r .is_playing) = null ]]; then
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	else
		echo "$PLAYBACK_DATA" >"$CACHE_FILE"
	fi
else
	PLAYBACK_DATA=$(cat "$CACHE_FILE")
fi

## Get status
get_status() {
	local STATUS=$(echo $PLAYBACK_DATA | jq -r .is_playing)

	if [[ $STATUS == "false" ]]; then
		echo ""
	else
		echo ""
	fi
}

## Get song
get_song() {
	local song=$(echo $PLAYBACK_DATA | jq -r .item.name)
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

	if [ -z "$current_time" ] || [ -z "$total_time" ] || [[ "$total_time" == "null" ]] || [[ "$current_time" == "null" ]] || [ "$total_time" -eq 0 ]; then
		echo 0
	else
		local progress=$((100 * current_time / total_time))
		echo "$progress"
	fi
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

	curl -s "$url" >"$COVER"

	if [ $? -eq 0 ]; then
		echo "$COVER"
	else
		echo "images/music.png"
	fi
}

get_cover_next() {
	local nextsong=$(spotify_player get key queue | jq -r ".queue[0]")
	local url=$(echo $nextsong | jq -r "[.album.images[] | select(.height > 150)][0].url")
	if [ -z "$url" ]; then
		echo "images/music.png"
		return
	fi

	curl -s "$url" >"$COVER"

	if [ $? -eq 0 ]; then
		echo "$COVER"
	else
		echo "images/music.png"
	fi
}

summary() {
	echo "$(get_status) $(get_song) - $(get_artist)"
}

## Execute accordingly
case "$1" in
--song) get_song ;;
--artist) get_artist ;;
--status) get_status ;;
--summary) summary ;;
--time) get_time ;;
--ctime) get_ctime ;;
--ttime) get_ttime ;;
--cover) get_cover ;;
--toggle) spotify_player playback play-pause ;;
--next)
	spotify_player playback next
	get_cover_next
	;;
--prev)
	spotify_player playback previous
	get_cover_next
	;;
esac
