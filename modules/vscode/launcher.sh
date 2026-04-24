#!/usr/bin/env bash
GUM=$1; shift

names=()
paths=()
while [ $# -gt 0 ]; do
  names+=("$1"); paths+=("$2"); shift 2
done

choice=$("$GUM" choose "${names[@]}" --header "Ambiente")
[ -z "$choice" ] && exit

for i in "${!names[@]}"; do
  [ "${names[$i]}" = "$choice" ] && codium="${paths[$i]}" && break
done

folder=$(find ~ -type d -maxdepth 3 2>/dev/null \
  | sed "s|$HOME|~|" \
  | "$GUM" filter --placeholder "Digite para filtrar..." --header "Pasta")
[ -z "$folder" ] && exit

exec "$codium" "${folder/#\~/$HOME}"