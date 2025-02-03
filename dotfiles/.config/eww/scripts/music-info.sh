#!/bin/sh

## Get data
CACHE_FILE="$HOME/.cache/music_info.json"
COVER="/tmp/.music_cover.jpg"
CACHE_FILE_TMP="${CACHE_FILE}.tmp"

## Get status
get_status() {
	local cache_age=$(($(date +%s%3N) - $(stat -c %.3Y "$CACHE_FILE" | awk '{print $1 * 1000}')))

	if [[ $cache_age -ge 500 ]]; then
		PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

		if [[ $(echo $PLAYBACK_DATA | jq -r ".is_playing") == "null" ]]; then
			PLAYBACK_DATA=$(cat "$CACHE_FILE")
		elif [[ "$(echo $PLAYBACK_DATA | jq -r .is_playing)" != "$(cat "$CACHE_FILE" | jq -r .is_playing)" ]]; then
			echo "$PLAYBACK_DATA" >"$CACHE_FILE_TMP" && mv "$CACHE_FILE_TMP" "$CACHE_FILE"
		fi
	else
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi

	local STATUS=$(echo $PLAYBACK_DATA | jq -r .is_playing)

	if [[ $STATUS == "false" ]]; then
		echo ""
	else
		echo ""
	fi
}

## Get song
get_song() {
	local cache_age=$(($(date +%s%3N) - $(stat -c %.3Y "$CACHE_FILE" | awk '{print $1 * 1000}')))

	if [[ $cache_age -ge 500 ]]; then
		PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

		if [[ $(echo $PLAYBACK_DATA | jq -r ".item.name") == "null" ]]; then
			PLAYBACK_DATA=$(cat "$CACHE_FILE")
		elif [[ "$(echo $PLAYBACK_DATA | jq -r .item.name)" != "$(cat "$CACHE_FILE" | jq -r .item.name)" ]]; then
			echo "$PLAYBACK_DATA" >"$CACHE_FILE_TMP" && mv "$CACHE_FILE_TMP" "$CACHE_FILE"
		fi
	else
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi

	local song=$(echo $PLAYBACK_DATA | jq -r .item.name)
	echo "$song"
}

## Get artist
get_artist() {
	local cache_age=$(($(date +%s%3N) - $(stat -c %.3Y "$CACHE_FILE" | awk '{print $1 * 1000}')))

	if [[ $cache_age -ge 500 ]]; then
		PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

		if [[ $(echo $PLAYBACK_DATA | jq -r ".item.artists[].name") == "null" ]]; then
			PLAYBACK_DATA=$(cat "$CACHE_FILE")
		elif [[ "$(echo $PLAYBACK_DATA | jq -r .item.artists[].name)" != "$(cat "$CACHE_FILE" | jq -r .item.artists[].name)" ]]; then
			echo "$PLAYBACK_DATA" >"$CACHE_FILE_TMP" && mv "$CACHE_FILE_TMP" "$CACHE_FILE"
		fi
	else
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi

	local artists=$(echo $PLAYBACK_DATA | jq -r .item.artists[].name | tr '\n' ' ')
	echo "$artists"
}

## Get time
get_time() {
	local cache_age=$(($(date +%s%3N) - $(stat -c %.3Y "$CACHE_FILE" | awk '{print $1 * 1000}')))

	if [[ $cache_age -ge 500 ]]; then
		PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

		if [[ $(echo $PLAYBACK_DATA | jq -r ".progress_ms") == "null" && $(echo $PLAYBACK_DATA | jq -r ".item.duration_ms") == "null" ]]; then
			PLAYBACK_DATA=$(cat "$CACHE_FILE")
		elif [[ "$PLAYBACK_DATA" != "$(cat "$CACHE_FILE")" ]]; then
			echo "$PLAYBACK_DATA" >"$CACHE_FILE_TMP" && mv "$CACHE_FILE_TMP" "$CACHE_FILE"
		fi
	else
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi

	local current_time=$(echo $PLAYBACK_DATA | jq -r .progress_ms)
	local total_time=$(echo $PLAYBACK_DATA | jq -r .item.duration_ms)

	if [ -z "$current_time" ] || [ -z "$total_time" ] || [[ "$total_time" == "null" ]] || [[ "$current_time" == "null" ]] || [ "$total_time" -eq 0 ]; then
		echo 0
	else
		local progress=$((100 * current_time / total_time))
		echo "$progress"
	fi
}

# get_ctime() {
# 	local cache_age=$(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}')))

# 	if [[ $cache_age -ge 500 ]]; then
# 		PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

# 		if [[ $(echo $PLAYBACK_DATA | jq -r ".progress_ms") == "null" ]]; then
# 			PLAYBACK_DATA=$(cat "$CACHE_FILE")
# 		elif [[ "$PLAYBACK_DATA" != "$(cat "$CACHE_FILE")" ]]; then
# 			echo "$PLAYBACK_DATA" >"$CACHE_FILE"
# 		fi
# 	else
# 		PLAYBACK_DATA=$(cat "$CACHE_FILE")
# 	fi

# 	local current_time=$(echo $PLAYBACK_DATA | jq -r .progress_ms)
# 	local ctime=$(date -d@$(($current_time / 1000)) -u +%M:%S)
# 	echo "$ctime"
# }

# get_ttime() {
# 	local cache_age=$(($(date +%s%3N) - $(echo $(stat -c %.3Y "$CACHE_FILE") | awk '{print $1 * 1000}')))

# 	if [[ $cache_age -ge 500 ]]; then
# 		PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

# 		if [[ $(echo $PLAYBACK_DATA | jq -r ".item.duration_ms") == "null" ]]; then
# 			PLAYBACK_DATA=$(cat "$CACHE_FILE")
# 		elif [[ "$PLAYBACK_DATA" != "$(cat "$CACHE_FILE")" ]]; then
# 			echo "$PLAYBACK_DATA" >"$CACHE_FILE"
# 		fi
# 	else
# 		PLAYBACK_DATA=$(cat "$CACHE_FILE")
# 	fi

# 	local total_time=$(echo $PLAYBACK_DATA | jq -r .item.duration_ms)
# 	local ttime=$(date -d@$(($total_time / 1000)) -u +%M:%S)
# 	echo "$ttime"
# }

## Get cover
get_cover() {
	local cache_age=$(($(date +%s%3N) - $(stat -c %.3Y "$CACHE_FILE" | awk '{print $1 * 1000}')))

	if [[ $cache_age -ge 500 ]]; then
		PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

		if [[ $(echo $PLAYBACK_DATA | jq -r ".item.album.images[]") == "null" ]]; then
			PLAYBACK_DATA=$(cat "$CACHE_FILE")
		elif [[ "$PLAYBACK_DATA" != "$(cat "$CACHE_FILE")" ]]; then
			echo "$PLAYBACK_DATA" >"$CACHE_FILE_TMP" && mv "$CACHE_FILE_TMP" "$CACHE_FILE"
		fi
	else
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi

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

# get_cover_next() {
# 	local nextsong=$(spotify_player get key queue 2>/dev/null | jq -r ".queue[0]")
# 	local url=$(echo $nextsong | jq -r "[.album.images[] | select(.height > 150)][0].url")
# 	if [ -z "$url" ]; then
# 		echo "images/music.png"
# 		return
# 	fi

# 	curl -s "$url" >"$COVER"

# 	if [ $? -eq 0 ]; then
# 		echo "$COVER"
# 	fi
# }

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
# --ctime) get_ctime ;;
# --ttime) get_ttime ;;
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
