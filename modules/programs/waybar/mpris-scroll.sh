#!/usr/bin/env bash

set -u

requested_player="${1-}"
delay=0.2
idle_delay=1
active_delay=0.2
max_len=48
gap="   "

json_escape() {
    local value="${1-}"
    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//$'\n'/\\n}
    value=${value//$'\r'/\\r}
    value=${value//$'\t'/\\t}
    printf '%s' "$value"
}

format_time() {
    local seconds="${1-0}"

    if [[ -z "$seconds" || "$seconds" == "0" || "$seconds" == "0.0" ]]; then
        printf '00:00'
        return
    fi

    seconds=${seconds%.*}
    printf '%02d:%02d' "$((seconds / 60))" "$((seconds % 60))"
}

resolve_player() {
    local available

    available="$(playerctl -l 2>/dev/null)" || return 1
    [[ -z "$available" ]] && return 1

    if [[ -n "$requested_player" ]]; then
        grep -Fxq "$requested_player" <<<"$available" || return 1
        printf '%s\n' "$requested_player"
        return 0
    fi

    head -n1 <<<"$available"
}

emit_json() {
    local text="$1"
    local tooltip="$2"
    local class="$3"

    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
        "$(json_escape "$text")" \
        "$(json_escape "$tooltip")" \
        "$(json_escape "$class")"
}

last_payload=""
scroll_offset=0
scroll_key=""

while true; do
    player="$(resolve_player)"

    if [[ -z "$player" ]]; then
        if [[ -n "$last_payload" ]]; then
            printf '\n'
            last_payload=""
        fi
        scroll_offset=0
        scroll_key=""
        sleep "$idle_delay"
        continue
    fi

    status="$(playerctl -p "$player" status 2>/dev/null)" || status=""
    if [[ "$status" != "Playing" && "$status" != "Paused" ]]; then
        if [[ -n "$last_payload" ]]; then
            printf '\n'
            last_payload=""
        fi
        scroll_offset=0
        scroll_key=""
        sleep "$idle_delay"
        continue
    fi

    artist="$(playerctl -p "$player" metadata xesam:artist 2>/dev/null)"
    title="$(playerctl -p "$player" metadata xesam:title 2>/dev/null)"
    album="$(playerctl -p "$player" metadata xesam:album 2>/dev/null)"
    player_name="$(playerctl -p "$player" metadata mpris:identity 2>/dev/null)"
    length_us="$(playerctl -p "$player" metadata mpris:length 2>/dev/null)"
    position_seconds="$(playerctl -p "$player" position 2>/dev/null)"

    [[ -z "$player_name" ]] && player_name="$player"

    if [[ -n "$artist" && -n "$title" ]]; then
        text="$artist - $title"
    elif [[ -n "$title" ]]; then
        text="$title"
    elif [[ -n "$artist" ]]; then
        text="$artist"
    else
        text="$player_name"
    fi

    total_seconds=0
    if [[ "$length_us" =~ ^[0-9]+$ ]]; then
        total_seconds=$((length_us / 1000000))
    fi

    current="$(format_time "$position_seconds")"
    total="$(format_time "$total_seconds")"

    tooltip="$player_name"
    [[ -n "$title" ]] && tooltip="$tooltip: $title"
    [[ -n "$artist" ]] && tooltip="$tooltip - $artist"
    [[ -n "$album" ]] && tooltip="$tooltip - $album"
    tooltip="$tooltip [$current/$total]"

    case "$status" in
        Playing)
            class="playing"
            icon="$(printf '\uF3B5')"
            ;;
        Paused)
            class="paused"
            icon="$(printf '\uF04C')"
            ;;
    esac

    scroll_source="$text$gap"
    scroll_width=${#text}
    current_key="$player|$status|$text"

    if [[ "$current_key" != "$scroll_key" ]]; then
        scroll_offset=0
        scroll_key="$current_key"
    fi

    if (( scroll_width <= max_len )); then
        out="$text"
        scroll_offset=0
        sleep_for="$active_delay"
    else
        repeated="$scroll_source$text"
        source_len=${#scroll_source}
        out="${repeated:$scroll_offset:$max_len}"
        printf -v out "%-${max_len}s" "$out"
        scroll_offset=$(((scroll_offset + 1) % source_len))
        sleep_for="$delay"
    fi

    payload="$(emit_json "$icon $out" "$tooltip" "$class")"
    if [[ "$payload" != "$last_payload" ]]; then
        printf '%s\n' "$payload"
        last_payload="$payload"
    fi

    sleep "$sleep_for"
done
