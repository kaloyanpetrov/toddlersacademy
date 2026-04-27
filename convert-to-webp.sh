#!/usr/bin/env bash
# Converts all gallery images to WebP at 85% quality and updates HTML references.
set -e

QUALITY=85

# Install cwebp if missing
if ! command -v cwebp &>/dev/null; then
    echo "Installing webp tools..."
    sudo apt-get install -y -q webp
fi

GALLERY_DIRS=(
    "assets/images/gallery/q-center-gallery"
    "assets/images/gallery/the-bells-galery"
    "assets/images/extra-activities-gallery/art"
    "assets/images/extra-activities-gallery/dance"
    "assets/images/extra-activities-gallery/sports"
    "assets/images/extra-activities-gallery/yoga"
    "assets/images/teams-gallery/q-center-team"
    "assets/images/teams-gallery/bells-team"
)

converted=0
skipped=0

for dir in "${GALLERY_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        echo "  Skipping missing dir: $dir"
        continue
    fi

    find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | while read -r img; do
        webp_path="${img%.*}.webp"
        # Skip if webp already exists and is newer
        if [[ -f "$webp_path" && "$webp_path" -nt "$img" ]]; then
            echo "  SKIP (already converted): $img"
            continue
        fi
        echo "  Converting: $img -> $webp_path"
        cwebp -q "$QUALITY" "$img" -o "$webp_path"
        rm "$img"
        converted=$((converted + 1))
    done
done

echo ""
echo "--------------------------------------"
echo "Conversion done. Updating HTML references..."

# Replace image extensions in HTML files
for html in *.html; do
    # Replace .jpg, .jpeg, .JPG, .JPEG, .png, .PNG inside src= attributes with .webp
    sed -i \
        -e 's|\(assets/images/gallery/[^"]*\)\.\(jpg\|jpeg\|JPG\|JPEG\|png\|PNG\)|\1.webp|g' \
        -e 's|\(assets/images/extra-activities-gallery/[^"]*\)\.\(jpg\|jpeg\|JPG\|JPEG\|png\|PNG\)|\1.webp|g' \
        -e 's|\(assets/images/teams-gallery/[^"]*\)\.\(jpg\|jpeg\|JPG\|JPEG\|png\|PNG\)|\1.webp|g' \
        "$html"
    echo "  Updated: $html"
done

echo ""
echo "All done!"
