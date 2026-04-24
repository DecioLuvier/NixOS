choice=$(gum choose "🐍 Python" "💻 C" --header "Ambiente")
[ -z "$choice" ] && exit

case "$choice" in
  *Python*) target="python" ;;
  *C*)      target="c" ;;
  *)        exit ;;
esac

folder=$(find ~ -type d -maxdepth 3 2>/dev/null \
  | sed "s|$HOME|~|" \
  | gum filter --placeholder "Digite para filtrar..." --header "Pasta")
[ -z "$folder" ] && exit

folder="${folder/#\~/$HOME}"
nix run .#$target -- "$folder"