# Afilm To Exif

Writes your Afilm frame settings into your scanned image files using exiftool.

## Files
- `Afilm To Exif.bat` — the main script (Windows)
- `Afilm Frames.jq` — jq program used by the script (keep it in the same folder)
- `example/Afilm_data.json` — example Afilm export

## Requirements (Windows)
- [exiftool](https://exiftool.org) in PATH
- [jq](https://jqlang.github.io/jq/download/) in PATH

## How to use
1. Copy both the `.bat` and the `.jq` into the folder with your scans.
2. Put the Afilm export JSON in the same folder (any name — the script uses
   the first `.json` file it finds, alphabetically).
3. Make sure the scanned files are named so that alphabetical order equals
   frame order (e.g. `01.jpg`, `02.jpg`, ... `30.jpg`). One image per frame.
4. Double-click the `.bat` (or run it from cmd or PowerShell).

If there are several `.json` files in the folder, the script warns and uses
only the first one alphabetically — rename or move the others away.

## What gets written (when present in the JSON)
- ISO (roll ISO, top-level)
- Make / Model (cameraName split: first word = Make, rest = Model)
- CreateDate (date/time)
- FNumber (aperture, `f/11` → `11`)
- ExposureTime (shutter speed)
- LensModel (lens)
- GPSLatitude / GPSLongitude (with refs)

Missing data points are skipped for that frame. Frames with no data at all
produce no writes. Images beyond the number of frames are left untouched.
Images are overwritten in place (-overwrite_original), so keep a backup.

## Notes
- Frame n of the JSON maps to the n-th image in alphabetical order. -> If you have some iamges you forgot to write setting for in Afilm,  move them elsewhere to avoid writing to incorrect images.
- Subfolders (like an `ignore` folder) are never touched.
- GPS is written as decimal degrees.
