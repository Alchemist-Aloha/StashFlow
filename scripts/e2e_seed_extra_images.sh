#!/usr/bin/env bash
# Adds AVIF and JPEG XL images to a running stash-test-server, whose fixture
# only ships JPEG/PNG/WebP/GIF, so e2e tests can cover those decoders.
# Usage: STASH_URL=... STASH_API_KEY=... e2e_seed_extra_images.sh <dir>
# Needs ffmpeg with libaom-av1 and libjxl encoders, curl and python3.
set -euo pipefail

dir="$(mkdir -p "$1" && cd "$1" && pwd)"
ffmpeg -v error -y -f lavfi -i "testsrc2=s=640x480" -frames:v 1 \
  -c:v libaom-av1 -still-picture 1 "$dir/e2e-avif.avif"
ffmpeg -v error -y -f lavfi -i "mandelbrot=s=640x480" -frames:v 1 \
  -c:v libjxl "$dir/e2e-jxl.jxl"

gql() {
  curl -sf "$STASH_URL/graphql" -H "ApiKey: $STASH_API_KEY" \
    -H 'content-type: application/json' --data-binary @-
}
json() { python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$1"; }

stashes="$(printf '{"query":"{configuration{general{stashes{path excludeVideo excludeImage}}}}"}' |
  gql | python3 -c '
import json, sys
s = json.load(sys.stdin)["data"]["configuration"]["general"]["stashes"]
s = [x for x in s if x["path"] != sys.argv[1]]
s.append({"path": sys.argv[1], "excludeVideo": True, "excludeImage": False})
print(json.dumps(s))' "$dir")"
printf '{"query":"mutation($s:[StashConfigInput!]){configureGeneral(input:{stashes:$s}){imageExtensions}}","variables":{"s":%s}}' \
  "$stashes" | gql >/dev/null

job="$(printf '{"query":"mutation($p:[String!]){metadataScan(input:{paths:$p})}","variables":{"p":[%s]}}' \
  "$(json "$dir")" | gql | python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["metadataScan"])')"
for _ in $(seq 120); do
  status="$(printf '{"query":"{findJob(input:{id:\\"%s\\"}){status}}"}' "$job" |
    gql | python3 -c 'import json,sys; j=json.load(sys.stdin)["data"]["findJob"]; print(j and j["status"] or "FINISHED")')"
  [[ "$status" == FINISHED ]] && break
  [[ "$status" == FAILED || "$status" == CANCELLED ]] && { echo "scan $status" >&2; exit 1; }
  sleep 1
done

count="$(printf '{"query":"{findImages(image_filter:{path:{value:\\"e2e-\\",modifier:INCLUDES}}){count}}"}' |
  gql | python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["findImages"]["count"])')"
[[ "$count" == 2 ]] || { echo "expected 2 AVIF/JXL images, found $count" >&2; exit 1; }
echo "seeded AVIF and JPEG XL images from $dir"
