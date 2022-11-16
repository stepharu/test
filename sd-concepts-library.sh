#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
[[ "${TRACE-0}" == "1" ]] && set -o xtrace

HUGGINGFACE_TOKEN="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"

mkdir -p embeddings

index=0

curl -sS "https://huggingface.co/api/models?author=sd-concepts-library" | jq -c ".[]" | while read model; do
  id="$(echo $model | jq -r ".id")"
  name="${id##*/}"
  repo="https://huggingface.co/$id"
  repo_dir="repos/$id"

  # if [[ -d "$repo_dir/.git" ]]; then
  #   (cd "$repo_dir" && git pull --quiet)
  # else
  #   rm -rf "$repo_dir"
  #   git clone --quiet $repo "$repo_dir"
  # fi

  index=$((index+1))

  curl -fsSL \
    -H "Authorization: Bearer $HUGGINGFACE_TOKEN" \
    -o "embeddings/$name.pt" \
    "$repo/resolve/main/learned_embeds.bin" && continue

  curl -fsSL \
    -H "Authorization: Bearer $HUGGINGFACE_TOKEN" \
    -o "embeddings/$name.pt" \
    "$repo/resolve/main/$name.bin" && continue

  echo "FAILED!"
done
