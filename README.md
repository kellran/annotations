# CS2-Annotations

This repository contains utility lineups for Counter-Strike 2, using the built-in annotations feature.

Annotations are to be placed in the following directory:

```text
C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\annotations
```

## Usage

- Git clone this repository in the csgo directory
- Rename the directory from `CS2-annotations` to `annotations`
- Start the game, select *practice*, choose a map, enable 'Load Map Guide' and load the map.
- Start a competitive practice game, with the annotations will be loaded automatically

## Commands for creating annotations

Annotations use the annotation_* commands in the console. Below are some useful commands:

- `annotation_create`: Creates a new lineup, described below. Omit parameters to get help text.
  The below commands can be used in combination to provide a more detailed lineup, with where to stand, where to aim,
  etc.
  - `annotation_create position "text"`: Adds a position on the map with the given text and displayed with a pair of
  boots
  - `annotation_create spot`: Creates two markers/crosshairs where you are looking to help you align your lineup.
  - `annotation_create text "free text" "extra text" float`: Creates a text floating in the air at where you are
  looking. Useful for providing additional information, such as what the lineup is for. the "extra text" parameter is
  optional, and provides a second line of text.
  - `annotation_create text "free text" "extra text" surface`: Similar to the above command, but the text is attached to
  a wall or similar
- `annotation_save <filename>`: Save the current annotations to a file, after doing so copy it back to this repository
