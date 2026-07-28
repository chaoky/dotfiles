#!/usr/bin/env bash
# Claude Code statusLine hook: session-state JSON in on stdin, a compact colored
# status line out on stdout (icons + ANSI escapes). Claude refreshes it on each
# message and on the settings refreshInterval.

export LC_NUMERIC=C   # decimal point, not the locale's comma, for printf below
input=$(cat)

# One jq pass -> one raw value per line (fields contain spaces). readarray keeps
# empty lines, so absent optional fields stay in their own slot instead of shifting.
readarray -t F < <(
  printf '%s' "$input" | jq -r '
    .model.display_name // "?",
    .effort.level // "",
    (.thinking.enabled // false | tostring),
    .session_name // "",
    (.context_window.used_percentage // 0 | tostring),
    (.rate_limits.five_hour.used_percentage // "" | tostring),
    (.rate_limits.seven_day.used_percentage // "" | tostring)
  '
)
MODEL=${F[0]}; EFFORT=${F[1]}; THINKING=${F[2]}; TITLE=${F[3]}
CTX=${F[4]}; RATE5=${F[5]}; RATE7=${F[6]}

# Round the numeric bits.
CTX=$(printf '%.0f' "${CTX:-0}")
[ -n "$RATE5" ] && RATE5=$(printf '%.0f' "$RATE5")
[ -n "$RATE7" ] && RATE7=$(printf '%.0f' "$RATE7")

# Nerd Font glyphs (Iosevka Nerd Font Mono — Font Awesome range, stable across versions).
I_MODEL=$''   # microchip
I_THINK=$''   # lightbulb (extended thinking on)
I_EFFORT=$''  # gauge
I_CTX=$''     # pie chart
I_5H=$''      # clock
I_7D=$''      # calendar
I_TITLE=$''   # speech bubble

# ANSI colors.
R=$'\033[0m'; DIM=$'\033[90m'
RED=$'\033[31m'; GRN=$'\033[32m'; YLW=$'\033[33m'; CYN=$'\033[36m'; MAG=$'\033[35m'

# Percentage -> color: green < 50% <= yellow < 80% <= red.
tpc() { if [ "${1:-0}" -ge 80 ]; then printf '%s' "$RED"; elif [ "${1:-0}" -ge 50 ]; then printf '%s' "$YLW"; else printf '%s' "$GRN"; fi; }
case "$EFFORT" in
  low) TEC=$GRN ;; medium) TEC=$CYN ;; high) TEC=$YLW ;; xhigh|max) TEC=$MAG ;; *) TEC=$DIM ;;
esac

# Compact line (single space icon->value, two spaces between groups).
t="${DIM}${I_MODEL} ${CYN}${MODEL}${R}"
[ "$THINKING" = "true" ] && t+=" ${YLW}${I_THINK}${R}"
[ -n "$EFFORT" ] && t+="  ${DIM}${I_EFFORT} ${TEC}${EFFORT}${R}"
t+="  ${DIM}${I_CTX} $(tpc "$CTX")${CTX}%${R}"
[ -n "$RATE5" ] && t+="  ${DIM}${I_5H} $(tpc "$RATE5")${RATE5}%${R}  ${DIM}${I_7D} $(tpc "$RATE7")${RATE7}%${R}"
[ -n "$TITLE" ] && t+="  ${DIM}${I_TITLE} ${DIM}${TITLE}${R}"

printf '%s' "$t"
