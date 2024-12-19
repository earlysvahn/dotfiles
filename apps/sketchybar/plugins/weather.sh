sketchybar --set "$NAME" \
  label="Loading..." \
  icon.color="$BLACK"

LOCATION="Nyköping"
LANG="sv"

WEATHER_JSON=$(curl -s "https://wttr.in/$LOCATION?0pq&format=j1&lang=$LANG")

if [ -z "$WEATHER_JSON" ]; then
  sketchybar --set "$NAME" label="$LOCATION"
  return
fi

if [ -z "$WEATHER_JSON" ] || [[ "$WEATHER_JSON" == *"Unknown location"* ]]; then
  sketchybar --set "$NAME" label="$LOCATION"
  exit
fi

TEMPERATURE=$(echo "$WEATHER_JSON" | jq '.current_condition[0].temp_C' | tr -d '"')
RAW_WEATHER_DESCRIPTION=$(curl -s "https://wttr.in/Nyk�ping?0pq&format=j1&lang=sv" |
  jq -r '.current_condition[0].weatherDesc[0].value' |
  tr '[:upper:]' '[:lower:]' |
  sed -E 's/^[[:space:]]+|[[:space:]]+$//g' |
  tr -d '\r')

WEATHER_DESCRIPTION="${RAW_WEATHER_DESCRIPTION:0:16}..."
if [ "${#RAW_WEATHER_DESCRIPTION}" -le 16 ]; then
  WEATHER_DESCRIPTION="$RAW_WEATHER_DESCRIPTION"
fi

case $WEATHER_DESCRIPTION in
"clear" | "sunny") ICON="􀆮" ;;
"partly cloudy") ICON="􀇕" ;;
"cloudy") ICON="􀇃" ;;
"overcast") ICON="􀇣" ;;
"mist" | "fog" | "patches of fog") ICON="􀇋" ;;
"patchy rain possible" | "light rain" | "patchy light rain" | "patchy rain nearby") ICON="􀇅" ;;
"moderate rain" | "heavy rain") ICON="􀇇" ;;
"patchy light snow" | "light snow") ICON="􀇥" ;;
"moderate snow" | "heavy snow") ICON="􀇏" ;;
"thundery outbreaks possible" | "moderate or heavy rain with thunder") ICON="􀇟" ;;
"blizzard") ICON="􀇦" ;;
"freezing fog") ICON="􀇫" ;;
*) ICON="􀁝" ;;
esac

sketchybar --set "$NAME" \
  label="$TEMPERATURE$(echo '°') $ICON"
