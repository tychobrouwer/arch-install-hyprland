## Get data
COVER="$HOME/.cache/music_cover.jpg"

## Get status
get_status() {
	local STATUS=$(playerctl -p ncspot status)

	if [[ $STATUS == "Paused" ]]; then
		echo ""
	else
		echo ""
	fi
}

## Get song
get_song() {
	local song=$(playerctl -p ncspot metadata xesam:title)

	echo "$song"
}

## Get artist
get_artist() {
	local artists=$(playerctl -p ncspot metadata xesam:artist)

	echo "$artists"
}

## Get time
get_time() {
	local current_time=$(playerctl -p ncspot metadata --format "{{ position }}")
	local total_time=$(playerctl -p ncspot metadata mpris:length)

	if [ -z "$current_time" ] || [ -z "$total_time" ] || [ "$total_time" -eq 0 ]; then
		echo 0
	else
		local progress=$((100 * current_time / total_time))
		echo "$progress"
	fi
}

## Get cover
get_cover() {
	local url=$(playerctl -p ncspot metadata mpris:artUrl)

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
--update) echo "update" ;;
--song) get_song ;;
--artist) get_artist ;;
--status) get_status ;;
--summary) summary ;;
--time) get_time ;;
# --ctime) get_ctime ;;
# --ttime) get_ttime ;;
--cover) get_cover ;;
esac
