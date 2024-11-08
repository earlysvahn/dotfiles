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

control_light_brightness() {
    # Ensure that the required environment variables are set
    if [[ -z "$HA_CLITOKEN" || -z "$HA_LOCAL_URL" ]]; then
        echo "Error: HA_CLITOKEN or HA_LOCAL_URL environment variables are not set."
        return 1
    fi

    # Fetch the list of light entities
    local lights_json
    lights_json=$(curl -s -X GET -H "Authorization: Bearer $HA_CLITOKEN" \
        -H "Content-Type: application/json" \
        "$HA_LOCAL_URL/api/states" | jq -r '.[] | select(.entity_id | startswith("light.")) | .entity_id')

    # Use fzf (or gum) to select a light
    local selected_light
    selected_light=$(echo "$lights_json" | fzf --prompt="Select a light: ")
    # Alternative with gum (if installed):
    # selected_light=$(echo "$lights_json" | gum choose --prompt="Select a light: ")

    # Exit if no light was selected
    if [[ -z "$selected_light" ]]; then
        echo "No light selected."
        return 1
    fi

    # Prompt for brightness percentage
    local brightness
    brightness=$(gum input --placeholder "Enter brightness percentage (0-100): ")
    # Alternatively, use read if gum is not installed:
    # read -p "Enter brightness percentage (0-100): " brightness

    # Validate brightness input
    if ! [[ "$brightness" =~ ^[0-9]+$ ]] || ((brightness < 0 || brightness > 100)); then
        echo "Invalid brightness percentage. Please enter a number between 0 and 100."
        return 1
    fi

    # Decide between turning the light on or off based on brightness level
    if [[ "$brightness" -eq 0 ]]; then
        # Turn off the light
        curl -s -X POST -H "Authorization: Bearer $HA_CLITOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"entity_id\": \"$selected_light\"}" \
            "$HA_LOCAL_URL/api/services/light/turn_off"
        echo "Turned off $selected_light."
    else
        # Convert percentage to Home Assistant brightness scale (0-255)
        local ha_brightness=$((brightness * 255 / 100))

        # Turn on the light with specified brightness
        curl -s -X POST -H "Authorization: Bearer $HA_CLITOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"entity_id\": \"$selected_light\", \"brightness\": $ha_brightness}" \
            "$HA_LOCAL_URL/api/services/light/turn_on"
        echo "Set brightness of $selected_light to $brightness%."
    fi
}
