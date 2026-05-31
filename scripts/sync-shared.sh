#!/usr/bin/env bash
#
# sync-shared.sh — propagate shared references into each skill.
#
# Single source of truth lives in shared/. Each skill ships its own *copy* under
# references/ so it stays self-contained and independently installable (the
# "install the whole folder" model, same as career-skills / nature-skills).
#
# To change a shared file:
#     1) edit it in shared/      2) run this script      3) commit the result
#
#   SHARED_ALL  : carried by EVERY skill.
#   SHARED_SOME : carried only by the listed skills ("asset.md : skillA skillB ...").

set -euo pipefail
cd "$(dirname "$0")/.."   # repo root, regardless of caller's cwd

SHARED_ALL=(no-fabrication.md)

# 暂时单 skill,SHARED_SOME 留空;以后扩展到 coupon-hunter / promo-predictor 时按需添加
SHARED_SOME=()

count=0
put() {  # put <src-file> <skill-dir>
  local src="$1" skill="$2" refs="$2/references"
  [[ -d "$skill" ]] || { echo "  (跳过 $(basename "$skill"):skill 尚不存在)"; return; }
  mkdir -p "$refs"
  cp "$src" "$refs/$(basename "$src")"
  echo "  $(basename "$src") -> $(basename "$skill")"
  count=$((count + 1))
}

for asset in "${SHARED_ALL[@]}"; do
  src="shared/$asset"; [[ -f "$src" ]] || { echo "!! 缺源文件 $src" >&2; exit 1; }
  for skill in skills/*/; do put "$src" "${skill%/}"; done
done

for entry in "${SHARED_SOME[@]}"; do
  asset="${entry%% : *}"; targets="${entry##* : }"
  src="shared/$asset"; [[ -f "$src" ]] || { echo "!! 缺源文件 $src" >&2; exit 1; }
  for name in $targets; do put "$src" "skills/$name"; done
done

echo "synced $count file(s)."
