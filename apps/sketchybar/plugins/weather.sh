sketchybar --set $NAME \
  label="Loading..." \
  icon.color=$BLACK

# fetch weather data
LOCATION="Nyköping"
REGION=""
LANG="sv"

# Line below replaces spaces with +
WEATHER_JSON=$(curl -s "https://wttr.in/$LOCATION?0pq&format=j1&lang=$LANG")

# Fallback if empty
if [ -z $WEATHER_JSON ]; then
  sketchybar --set $NAME label="$LOCATION"
  return
fi

if [ -z "$WEATHER_JSON" ] || [[ "$WEATHER_JSON" == *"Unknown location"* ]]; then
  sketchybar --set $NAME label="$LOCATION"
  exit
fi

TEMPERATURE=$(echo $WEATHER_JSON | jq '.current_condition[0].temp_C' | tr -d '"')
WEATHER_DESCRIPTION=$(echo $WEATHER_JSON | jq '.current_condition[0].weatherDesc[0].value' | tr -d '"' | tr '[:upper:]' '[:lower:]' | sed 's/\(.\{16\}\).*/\1.../')

# Mapping wttr weather descriptions to SF Symbols
case $WEATHER_DESCRIPTION in
"clear" | "sunny") ICON="􀆮" ;;                 # Clear weather
"partly cloudy") ICON="􀇕" ;;                   # Partly Cloudy
"cloudy") ICON="􀇃" ;;                          # Cloudy
"overcast") ICON="􀇣" ;;                        # Overcast
"mist" | "fog" | "patches of fog") ICON="􀇋" ;; # Mist or fog
"patchy rain possible" | "light rain" | "patchy light rain") ICON="􀇅" ;;
"moderate rain" | "heavy rain") ICON="􀇇" ;;
"patchy light snow" | "light snow") ICON="􀇥" ;;                                    # Light snow
"moderate snow" | "heavy snow") ICON="􀇏" ;;                                        # Heavy snow
"thundery outbreaks possible" | "moderate or heavy rain with thunder") ICON="􀇟" ;; # Thunderstorms
"blizzard") ICON="􀇦" ;;                                                            # Blizzard
"freezing fog") ICON="􀇫" ;;                                                        # Freezing fog
*) ICON="􀁝" ;;                                                                     # Fallback for unknown conditions
esac

sketchybar --set $NAME \
  label="$TEMPERATURE$(echo '°')C $ICON"
