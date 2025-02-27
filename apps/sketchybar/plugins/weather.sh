CACHE_FILE="/tmp/weather_cache.json"

sketchybar --set "$NAME" \
  label="Loading..." \
  icon.color="$BLACK"

LOCATION="Nyköping"
LANG="sv"

# Fetch weather data
WEATHER_JSON=$(curl -s "https://wttr.in/$LOCATION?0pq&format=j1&lang=$LANG")

if [ -z "$WEATHER_JSON" ]; then
  # If the fetch fails, check if the cache file exists
  if [ -f "$CACHE_FILE" ]; then
    WEATHER_JSON=$(cat "$CACHE_FILE")
  else
    sketchybar --set "$NAME" label="$LOCATION"
    return
  fi
fi

# Check if the response indicates an unknown location
if [[ "$WEATHER_JSON" == *"Unknown location"* ]]; then
  # Use cached data if available
  if [ -f "$CACHE_FILE" ]; then
    WEATHER_JSON=$(cat "$CACHE_FILE")
  else
    sketchybar --set "$NAME" label="$LOCATION"
    exit
  fi
fi

# Save the successful response to the cache file
echo "$WEATHER_JSON" >"$CACHE_FILE"

# Extract temperature and weather description
TEMPERATURE=$(echo "$WEATHER_JSON" | jq '.current_condition[0].temp_C' | tr -d '"')
RAW_WEATHER_DESCRIPTION=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherDesc[0].value' |
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
