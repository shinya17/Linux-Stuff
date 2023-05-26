words=("elephant" "bud-frogs" "bunny" "eyes" "milk" "turkey" "cheese" "fox" "moose" "turtle" "cock" "tux" "gnu" "unipony" "daemon" "hellokitty" "default" "kangaroo" "dragon" "dragon-and-cow" "koala" "duck" "stegosaurus")

get_random_element() {
  length=${#words[@]}

  index=$((RANDOM % length))

  echo "${words[index]}"
}

random_element=$(get_random_element)

cowsay -f "$random_element" $(fortune) | lolcat
