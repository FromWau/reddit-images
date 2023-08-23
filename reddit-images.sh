#!/bin/bash

print_usage() {
	echo "Usage: $0 [--limit <value>] [--minsize <value>] [--include-animated] [--output-dir <directory>] <subreddit1> [<subreddit2> ...]"
	echo "Options:"
	echo "  --limit             Set the limit value (default: 2000)"
	echo "  --minsize           Set the minsize value (default: 300)"
	echo "  --include-animated  Include animated content (default: false)"
	echo "  --output-dir        Set the output directory for saving images (default: ~/Pictures/wallpapers/reddits)"
	echo "  --help              Display this help message"
	echo "Subreddits:"
	echo "  One or more subreddit names must be provided"
}

debug_echo() {
	if [[ "$log_level" == "debug" ]]; then
		echo "$@"
	fi
}

process_subreddit() {
	local log_level="$1"
	local subreddit="$2"
	local limit="$3"
	local minsize="$4"
	local include_animated="$5"
	local output_dir="$6"
	local subreddit_dir="$output_dir/$subreddit"

	debug_echo "Processing subreddit: $subreddit"

	# Check if subreddit exists
	sub_exits=$(
		curl --silent --header "User-agent: 'Bot'" https://www.reddit.com/r/$subreddit.json\?limit=1 |
			jq >/dev/null 2>&1
		echo "$?"
	)

	[[ ! "$sub_exits" -eq "0" ]] &&
		debug_echo "unknown subreddit $subreddit" &&
		continue

	# Create reddit dir if not exists

	[[ ! -d "$subreddit_dir" ]] &&
		debug_echo "Creating $subreddit_dir directory" &&
		mkdir -p "$subreddit_dir"

	# curl the data
	data=$(curl --silent --header "User-agent: 'Bot'" https://www.reddit.com/r/"$subreddit".json\?limit=$limit |
		jq -r ".data.children" | jq -r ".[] | @base64")

	for item in $data; do

		# needed for json array to bash array
		_jq() {
			echo "${item}" | base64 --decode | jq -r "${1}"
		}

		url=$(_jq '.data.url_overridden_by_dest')

		if [[ "$url" == "null" ]]; then
			debug_echo "Skipping null entry"
			continue
		fi

		case $url in

		*".png" | *".jpg" | *".jpeg" | *".webp" | *".gif")
			if [[ "$include_animated" == "false" && "$url" == *".gif" ]]; then
				debug_echo "Ignoring animated content: $url"
				continue
			fi

			source_width=$(_jq ".data.preview.images" | jq ".[0].source.width")
			source_height=$(_jq ".data.preview.images" | jq ".[0].source.height")

			if [[ "$minsize" -gt "$source_height" || "$minsize" -gt "$source_width" ]]; then
				debug_echo "Ignoring $url due to low resolution [ $source_width x $source_height ]"
				continue
			fi

			debug_echo "Downloading $url [ $source_width x $source_height ]"
			curl --remote-name --progress-bar "$url" --output-dir "$subreddit_dir"
			;;

		*)
			debug_echo "Ignoring $url due to unknown format"
			;;
		esac

	done
}

minsize=2000
limit=300
include_animated="false"
subreddits=()
output_dir=~/Pictures/wallpapers/reddits
log_level="info"

while [[ $# -gt 0 ]]; do
	case "$1" in
	--limit)
		if [[ $# -gt 1 && "$2" =~ ^[0-9]+$ ]]; then
			limit="$2"
			shift 2
		else
			echo "Error: Invalid or missing value for --limit."
			exit 1
		fi
		;;
	--minsize)
		if [[ $# -gt 1 && "$2" =~ ^[0-9]+$ ]]; then
			minsize="$2"
			shift 2
		else
			echo "Error: Invalid or missing value for --minsize."
			exit 1
		fi
		;;
	--include-animated)
		include_animated="true"
		shift
		;;
	--output-dir)
		if [[ $# -gt 1 ]]; then
			output_dir="$2"
			shift 2
		else
			echo "Error: Invalid or missing value for --output-dir."
			exit 1
		fi
		;;
	--help)
		print_usage
		exit 0
		;;
	*)
		subreddits+=("$1")
		shift
		;;
	esac
done

# Expand ~ using eval and then convert to absolute path
output_dir=$(eval "echo $output_dir")
output_dir=$(realpath "$output_dir")

if [[ ${#subreddits[@]} -eq 0 ]]; then
	echo "Error: At least one subreddit is required."
	exit 1
fi

if [[ -n "$limit" ]]; then
	debug_echo "Limit set to: $limit"
fi

if [[ -n "$minsize" ]]; then
	debug_echo "Minsize set to: $minsize"
fi

for subreddit in "${subreddits[@]}"; do
	process_subreddit "$log_level" "$subreddit" "$limit" "$minsize" "$include_animated" "$output_dir"
done
