## Get data
CACHE_FILE="$HOME/.cache/music_info.json"
CACHE_FILE_TMP="${CACHE_FILE}.tmp"
COVER="$HOME/.cache/music_cover.jpg"

get_update() {
	local cache_age=99999
	if [ ! -f "$CACHE_FILE" ]; then
		cache_age=$(($(date +%s%3N) - $(stat -c %.3Y "$CACHE_FILE" | awk '{print $1 * 1000}')))
	fi

	if [[ $cache_age -ge 500 ]]; then
		PLAYBACK_DATA=$(spotify_player get key playback 2>/dev/null | jq -r .)

		if [[ "$(echo $PLAYBACK_DATA | jq -r .)" != "$(cat "$CACHE_FILE" | jq -r .)" ]]; then
			if [[ "$(echo $PLAYBACK_DATA | jq -r .item.name)" != "$(cat "$CACHE_FILE" | jq -r .item.name)" ]]; then
				get_cover 2>&1 >/dev/null
			fi

			echo "$PLAYBACK_DATA" >"$CACHE_FILE_TMP" && mv "$CACHE_FILE_TMP" "$CACHE_FILE"
		fi
	fi

	if [[ "$(echo $PLAYBACK_DATA | jq -r .is_playing)" == "true" ]]; then
		echo true
	else
		echo false
	fi
}

## Get status
get_status() {
	PLAYBACK_DATA=$(cat "$CACHE_FILE")
	local STATUS=$(echo $PLAYBACK_DATA | jq -r .is_playing)

	if [[ $STATUS == "false" ]]; then
		echo ""
	else
		echo ""
	fi
}

## Get song
get_song() {
	PLAYBACK_DATA=$(cat "$CACHE_FILE")
	local song=$(echo $PLAYBACK_DATA | jq -r .item.name)

	echo "$song"
}

## Get artist
get_artist() {
	PLAYBACK_DATA=$(cat "$CACHE_FILE")
	local artists=$(echo $PLAYBACK_DATA | jq -r .item.artists[].name | tr '\n' ' ')

	echo "$artists"
}

## Get time
get_time() {
	PLAYBACK_DATA=$(cat "$CACHE_FILE")
	local current_time=$(echo $PLAYBACK_DATA | jq -r .progress_ms)
	local total_time=$(echo $PLAYBACK_DATA | jq -r .item.duration_ms)

	if [ -z "$current_time" ] || [ -z "$total_time" ] || [ "$total_time" -eq 0 ]; then
		echo 0
	else
		local progress=$((100 * current_time / total_time))
		echo "$progress"
	fi
}

## Get cover
get_cover() {
	if [ -z "$PLAYBACK_DATA" ]; then
		PLAYBACK_DATA=$(cat "$CACHE_FILE")
	fi
	local url=$(echo $PLAYBACK_DATA | jq -r "[.item.album.images[] | select(.height > 150)][0].url")

	touch "$COVER"

	if [ -z "$url" ]; then
		cat "images/music.png" >"$COVER"
	else
		curl -s "$url" >"$COVER"
	fi

	echo "$COVER"
}

summary() {
	echo "$(get_status) $(get_song) - $(get_artist)"
}

## Execute accordingly
case "$1" in
--update) get_update ;;
--song) get_song ;;
--artist) get_artist ;;
--status) get_status ;;
--summary) summary ;;
--time) get_time ;;
# --ctime) get_ctime ;;
# --ttime) get_ttime ;;
--cover) get_cover ;;
esac
