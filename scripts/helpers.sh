#!/usr/bin/env bash
# shellcheck disable=SC2155

# Some general helpers for the Volumio Build system

# Terminal colors if supported
if [[ $TERM == dumb ]]; then
	export TERM=ansi
fi
if test -t; then                                      # if terminal
	ncolors=$(command -v tput >/dev/null && tput colors) # supports colour
	if [[ $ncolors -ge 8 ]]; then
		export termcols=$(tput cols)
		export bold="$(tput bold)"
		export underline="$(tput smul)"
		export standout="$(tput smso)"
		export normal="$(tput sgr0)"
		export black="$(tput setaf 0)"
		export red="$(tput setaf 1)"
		export green="$(tput setaf 2)"
		export yellow="$(tput setaf 3)"
		export blue="$(tput setaf 4)"
		export magenta="$(tput setaf 5)"
		export cyan="$(tput setaf 6)"
		export white="$(tput setaf 7)"
	fi
fi

# Make logging a bit more legible and intuitive
log() {
	local tmp=""
	local char=".."
	if [[ $CHROOT == yes ]]; then
		char="--"
	fi

	[[ -n $3 ]] && tmp="${normal}[${yellow} $3 ${normal}]"

	case $2 in
	err)
		echo -e "[${red} ${bold} error ${normal}]${red} $1 ${normal}$tmp"
		;;

	cfg)
		echo -e "[${cyan} ${bold} cfg ${normal}]${yellow} $1 ${normal}$tmp"
		;;

	wrn)
		echo -e "[${magenta}${bold} warn ${normal}] $1 $tmp"
		;;

	dbg)
		echo -e "[${standout} dbg ${normal}] ${blue} $1 ${normal} $tmp"
		;;

	info)
		echo -e "[${green} $char$char ${normal}]${cyan} $1 $tmp ${normal}"
		;;

	okay)
		echo -e "[${green} o.k. ${normal}]${green} $1 ${normal} $tmp"
		;;

	"")
		echo -e "[${green} $char ${normal}] $1 $tmp"
		;;

	*)
		[[ -n $2 ]] && tmp="[${yellow} $2 ${normal}]"
		echo -e "[${green} $char ${normal}] $1 $tmp"
		;;

	esac
}

time_it() {
	time=$(($1 - $2))
	if [[ $time -lt 60 ]]; then
		TIME_STR="$time sec"
	else
		TIME_STR="$((time / 60)):$((time % 60)) min"
	fi
	export TIME_STR
}

# Reassemble chunked file if .part_* exists
# $1: base file path (without .part_)
# Output: sets $REASSEMBLED_PATH to resulting file path
reassemble_chunks_if_needed() {
	local base="$1"
	local chunks="${base}.part_"
	local reassembled="${base}.reassembled"

	if ls "${chunks}"* 1>/dev/null 2>&1; then
		log "Detected chunked archive at ${chunks}*, reassembling..." "info"
		cat "${chunks}"* > "${reassembled}"
		REASSEMBLED_PATH="${reassembled}"
		if [[ "${KEEP_TMP}" != "1" ]]; then
			trap "rm -f '${reassembled}'" EXIT
		fi
	else
		REASSEMBLED_PATH="${base}"
	fi
}

# Split file if larger than 100MB (or specified limit)
# $1: full path to file
# $2: optional chunk size (default: 50M)
# Output: removes original if split occurs
split_file_if_needed() {
	local filepath="$1"
	local chunksize="${2:-50M}"
	local maxsize=$((100 * 1024 * 1024))

	if [[ -f "$filepath" ]]; then
		local actual_size
		actual_size=$(stat -c %s "$filepath")

		if (( actual_size > maxsize )); then
			log "File $filepath exceeds GitHub limit ($actual_size bytes), splitting..." "warn"
			split -b "$chunksize" "$filepath" "${filepath}.part_"
			rm -f "$filepath"
			log "Split complete, original removed." "info"
		fi
	fi
}
