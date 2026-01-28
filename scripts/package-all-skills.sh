#!/bin/bash
# Package all skills into .skill files for release

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_DIR="$REPO_ROOT/skills"
DIST_DIR="$REPO_ROOT/dist"
PACKAGER="$SCRIPT_DIR/package_skill.py"

mkdir -p "$DIST_DIR"
rm -f "$DIST_DIR"/*.skill

for skill_dir in "$SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    echo "Packaging $skill_name..."
    python3 "$PACKAGER" "$skill_dir" "$DIST_DIR"
done

# Create all-in-one bundle
BUNDLE="$DIST_DIR/algorand-skills-all.zip"
rm -f "$BUNDLE"
(cd "$DIST_DIR" && zip -q "$BUNDLE" *.skill)

echo "Done! Packaged skills are in $DIST_DIR/"
ls -la "$DIST_DIR"
