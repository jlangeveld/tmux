#!/usr/bin/env bash

set -e
$BUILD_ROOT/logit.sh
logit tmux prefix_highlight

# Place holder for status left/right
place_holder="\#{prefix_highlight}"

# Possible configurations
fg_color_config='@prefix_highlight_fg_color'
bg_color_config='@prefix_highlight_bg_color'

output_prefix='@prefix_highlight_output_prefix'
output_suffix='@prefix_highlight_output_suffix'
show_copy_config='@prefix_highlight_show_copy_mode'

default_attr_config='@prefix_highlight_default_attr'
prefix_attr_config='@prefix_highlight_prefix_attr'
suffix_attr_config='@prefix_highlight_suffix_attr'
copy_attr_config='@prefix_highlight_copy_mode_attr'

default_fg='colour231'
default_bg='colour04'

tmux_option() {
	logit tmux_option
    local -r value=$(tmux show-option -gqv "$1")
    local -r default="$2"

    if [ ! -z "$value" ]; then
        echo "$value"
    else
        echo "$default"
    fi
}

highlight() {
	logit highlight
    local -r \
        status="$1" \
        prefix="$2" \
        default_highlight="$3" \
        show_copy_mode="$4" \
        copy_highlight="$5" \
        output_prefix="$6" \
		prefix_highlight="$7" \
        output_suffix="$8" \
		suffix_highlight="$9" \
        copy="Copy"

    local -r status_value="$(tmux_option "$status")"

	local -r \
		value_mark_prefix="#{?client_prefix,$output_prefix,}" \
		value_mark="#{?client_prefix, $prefix ,}" \
		value_mark_suffix="#{?client_prefix,$output_suffix,}"

    if [[ "on" = "$show_copy_mode" ]]; then
		local -r \
			value_copy_prefix="#{?pane_in_mode,$output_prefix,}" \
			value_copy="#{?pane_in_mode, $copy ,}" \
			value_copy_suffix="#{?pane_in_mode,$output_suffix,}"
    else
		local -r \
			value_copy_prefix="" \
			value_copy="" \
			value_copy_suffix="" \
			highlighted_copy=""
    fi

	local -r \
		highlighted_mark="$prefix_highlight$value_mark_prefix$default_highlight$value_mark$suffix_highlight$value_mark_suffix" \
		highlighted_copy="$prefix_highlight$value_copy_prefix$default_highlight$value_copy$suffix_highlight$value_copy_suffix"

	local -r highlight_on_prefix="$highlighted_mark$highlighted_copy#[default]"

    tmux set-option -gq "$status" "${status_value/$place_holder/$highlight_on_prefix}"
}

main() {
	logit main
    local -r \
        prefix=$(tmux_option prefix) \
		default_attr=$(tmux_option "$default_attr_config" "fg=$default_fg,bg=$default_bg") \
        show_copy_mode=$(tmux_option "$show_copy_config" "off") \
        output_prefix=$(tmux_option "$output_prefix" " ") \
        output_suffix=$(tmux_option "$output_suffix" " ")

    local -r short_prefix=$(
        echo "$prefix" | tr "[:lower:]" "[:upper:]" | sed 's/C-/\^/'
    )

    local -r \
		prefix_attr=$(tmux_option "$prefix_attr_config" "$default_attr") \
		suffix_attr=$(tmux_option "$suffix_attr_config" "$default_attr") \
        copy_attr=$(tmux_option "$copy_attr_config" "$default_attr")

	local -r \
		default_highlight="#[$default_attr]" \
        prefix_highlight="#[$prefix_attr]" \
        suffix_highlight="#[$suffix_attr]" \
        copy_highlight="#[$copy_attr]"

    highlight "status-right" \
              "$short_prefix" \
              "$default_highlight" \
              "$show_copy_mode" \
              "$copy_highlight" \
              "$output_prefix" \
			  "$prefix_highlight" \
              "$output_suffix" \
			  "$suffix_highlight"

    highlight "status-left" \
              "$short_prefix" \
              "$default_highlight" \
              "$show_copy_mode" \
              "$copy_highlight" \
              "$output_prefix" \
			  "$prefix_highlight" \
              "$output_suffix" \
			  "$suffix_highlight"
}

main
