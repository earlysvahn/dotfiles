#!/bin/bash

scene() {
    if [[ "$1" == "off" ]]; then
        echo "Turning off all entities controlled by scenes..."

        entities_json=$(curl -s -X GET -H "Authorization: Bearer $HA_CLITOKEN" \
            -H "Content-Type: application/json" \
            "$HA_LOCAL_URL/api/states")

        # Extract entities controlled by scenes and check which ones are "on"
        entities_to_turn_off=$(echo "$entities_json" | jq -r '.[] | select(.entity_id | startswith("light.") or startswith("switch.")) | select(.state == "on") | .entity_id')

        # Check if any entities are found to turn off
        if [ -z "$entities_to_turn_off" ]; then
            echo "No entities are currently on. Exiting..."
            return 0
        fi

        # Iterate over each entity and turn it off
        while IFS= read -r entity_id; do
            echo "Turning off $entity_id..."
            curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" \
                -d "{\"entity_id\": \"$entity_id\"}" \
                "$HA_LOCAL_URL/api/services/homeassistant/turn_off" >/dev/null 2>&1
        done <<<"$entities_to_turn_off"

        echo "All active entities have been turned off."
        return 0
    fi

    # Fetch the list of scenes from Home Assistant
    scenes_json=$(curl -s -X GET -H "Authorization: Bearer $HA_CLITOKEN" \
        -H "Content-Type: application/json" \
        "$HA_LOCAL_URL/api/states" | jq -r '.[] | select(.entity_id | startswith("scene.")) | .entity_id')

    # Check if scenes were found
    if [ -z "$scenes_json" ]; then
        echo "No scenes found in Home Assistant. Exiting..."
        return 1
    fi

    # Format the scene names
    formatted_scenes=$(echo "$scenes_json" | sed 's/scene\.//' | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')

    # Use choose to select a scene
    choice=$(echo "$formatted_scenes" | choose)

    # If no choice is made, exit
    if [ -z "$choice" ]; then
        echo "No selection made. Exiting..."
        return 1
    fi

    # Activate the selected scene
    entity_id="scene.$(echo "$choice" | awk '{print tolower($0)}')"
    echo -e "\e[32mYou selected $entity_id.\e[0m"

    # Make the API call to activate the selected scene
    response=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" \
        -d "{\"entity_id\": \"$entity_id\"}" "$HA_LOCAL_URL/api/services/scene/turn_on" >/dev/null 2>&1)

    # Check if the call was successful
    if [ -z "$response" ]; then
        echo -e "\e[32mScene set successfully.\e[0m"
    else
        echo -e "\e[31mFailed to set scene.\e[0m"
    fi
}

office() {
    local brightness=20
    local color_name=""

    if [[ "$1" == "off" ]]; then
        curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" \
            -d "{\"entity_id\": \"light.upstairs_office_lights\"}" \
            "$HA_LOCAL_URL/api/services/light/turn_off" >/dev/null 2>&1

        curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" \
            -d "{\"entity_id\": \"switch.monitor_backlight_switch\"}" \
            "$HA_LOCAL_URL/api/services/switch/turn_off" >/dev/null 2>&1

        return
    fi

    if [[ "$1" =~ ^[0-9]+$ ]]; then
        brightness=$1
        color_name=${2:-""}
    else
        color_name=$1
        brightness=${2:-20}
    fi

    if [[ -z "$color_name" ]]; then
        r=255
        g=160
        b=0
    else
        case "$color_name" in
        "green")
            r=106
            g=127
            b=87
            ;;
        "blue")
            r=75
            g=103
            b=137
            ;;
        "yellow")
            r=179
            g=140
            b=83
            ;;
        "red")
            r=163
            g=82
            b=82
            ;;
        "purple")
            r=132
            g=97
            b=124
            ;;
        "orange")
            r=174
            g=109
            b=68
            ;;
        *)
            r=255
            g=160
            b=0
            ;;
        esac
    fi

    curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" \
        -d "{\"entity_id\": \"light.upstairs_office_lights\", \"brightness_pct\": $brightness, \"rgb_color\": [$r, $g, $b]}" \
        "$HA_LOCAL_URL/api/services/light/turn_on" >/dev/null 2>&1

    curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $HA_CLITOKEN" \
        -d "{\"entity_id\": \"switch.monitor_backlight_switch\"}" \
        "$HA_LOCAL_URL/api/services/switch/turn_on" >/dev/null 2>&1
}
