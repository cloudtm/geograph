#!/bin/bash

declare -A flavors=(
["tiny"]="1"
["small"]="2"
["medium"]="3"
["large"]="4"
["xmedium"]="8"
["medium-tinydisk"]="14"
["multivm-largedisk"]="19"
["multivm"]="16"
["xlarge"]="10"
["xxlarge"]="12"
["xxlarge_small_disk"]="9"
["geo"]="25"
["geo-eph"]="26"
["geo-big"]="27"
["geo-med"]="29"
)


echo -n ${flavors["$1"]}
