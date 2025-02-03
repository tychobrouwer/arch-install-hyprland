#!/bin/sh

## Get data
CACHE_FILE="$HOME/.cache/music_info.json"
COVER="/tmp/.music_cover.jpg"

# if (( $(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}'))) > 500 )); then
# 	PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

# 	if [[ $(echo $PLAYBACK_DATA | jq -r '[.is_playing, .item.name, .item.artists[].name] | any(empty)') == "true" ]]; then
# 		PLAYBACK_DATA=$(cat "$CACHE_FILE")
# 	else
# 		echo "$PLAYBACK_DATA" >"$CACHE_FILE"
# 	fi
# else
# 	PLAYBACK_DATA=$(cat "$CACHE_FILE")
# fi

## Get status
get_status() {
	PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

	local cache_age=$(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}')))

	if [[ $(echo $PLAYBACK_DATA | jq -r ".item.artists[].name") == "null" || $cache_age -lt 500 ]]; then
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi
	echo "$PLAYBACK_DATA" >"$CACHE_FILE"

	local STATUS=$(echo $PLAYBACK_DATA | jq -r .is_playing)

	if [[ $STATUS == "false" ]]; then
		echo ""
	else
		echo ""
	fi
}

## Get song
get_song() {
	PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

	local cache_age=$(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}')))

	if [[ $(echo $PLAYBACK_DATA | jq -r ".item.artists[].name") == "null" || $cache_age -lt 500 ]]; then
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi
	echo "$PLAYBACK_DATA" >"$CACHE_FILE"

	local song=$(echo $PLAYBACK_DATA | jq -r .item.name)
	echo "$song"
}

## Get artist
get_artist() {
	PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

	local cache_age=$(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}')))

	if [[ $(echo $PLAYBACK_DATA | jq -r ".item.artists[].name") == "null" || $cache_age -lt 500 ]]; then
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi
	echo "$PLAYBACK_DATA" >"$CACHE_FILE"

	local artists=$(echo $PLAYBACK_DATA | jq -r .item.artists[].name | tr '\n' ' ')
	echo "$artists"
}

## Get time
get_time() {
	PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

	local cache_age=$(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}')))

	if [[ $(echo $PLAYBACK_DATA | jq -r ".item.duration_ms") == "null" || $(echo $PLAYBACK_DATA | jq -r ".progress_ms") == "null" || $cache_age -lt 500 ]]; then
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi
	echo "$PLAYBACK_DATA" >"$CACHE_FILE"

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
	PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

	local cache_age=$(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}')))

	if [[ $(echo $PLAYBACK_DATA | jq -r ".progress_ms") == "null" || $cache_age -lt 500 ]]; then
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi
	echo "$PLAYBACK_DATA" >"$CACHE_FILE"

	local current_time=$(echo $PLAYBACK_DATA | jq -r .progress_ms)
	local ctime=$(date -d@$(($current_time / 1000)) -u +%M:%S)
	echo "$ctime"
}

get_ttime() {
	PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

	local cache_age=$(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}')))

	if [[ $(echo $PLAYBACK_DATA | jq -r ".item.duration_ms") == "null" || $cache_age -lt 500 ]]; then
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi
	echo "$PLAYBACK_DATA" >"$CACHE_FILE"

	local total_time=$(echo $PLAYBACK_DATA | jq -r .item.duration_ms)
	local ttime=$(date -d@$(($total_time / 1000)) -u +%M:%S)
	echo "$ttime"
}

## Get cover
get_cover() {
	PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

	local cache_age=$(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}')))

	if [[ $(echo $PLAYBACK_DATA | jq -r ".item.album.images[]") == "null" || $cache_age -lt 500 ]]; then
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi
	echo "$PLAYBACK_DATA" >"$CACHE_FILE"

	local url=$(echo $PLAYBACK_DATA | jq -r "[.item.album.images[] | select(.height > 150)][0].url")
	if [ -z "$url" ]; then
		echo "images/music.png"
		return
	fi

	curl -s "$url" >"$COVER"

	if [ $? -eq 0 ]; then
		echo "$COVER"
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
	get_cover
	;;
--prev)
	spotify_player playback previous
	get_cover
	;;
esac
