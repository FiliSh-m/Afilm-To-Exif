
. as $root |
  ($root.frames | to_entries | sort_by(.key | tonumber)) as $entries |
  ($entries[$n - 1] // {}) as $frame |
  if $frame == {} then empty
  else (
    ($root.iso // empty | select(. != "") | "-ISO=\(.)"),
    ($root.cameraName // empty | select(. != "") | split(" ") | (.[0] | "-Make=\(.)"), (if length>1 then (.[1:] | join(" ") | "-Model=\(.)") else empty end)),
    ($frame.value.date // empty | select(. != "") | sub("T"; " ") | sub("\\..*$"; "") | "-CreateDate=\(.)"),
    ($frame.value.aperture // empty | select(. != "") | sub("^[fF]/"; "") | "-FNumber=\(.)"),
    ($frame.value.shutterSpeed // empty | select(. != "") | "-ExposureTime=\(.)"),
    ($frame.value.lensName // empty | select(. != "") | "-LensModel=\(.)"),
    ($frame.value.location.latitude // empty | select(. != "") | "-GPSLatitude=\(.)", "-GPSLatitudeRef=\(.)"),
    ($frame.value.location.longitude // empty | select(. != "") | "-GPSLongitude=\(.)", "-GPSLongitudeRef=\(.)")
  )
  end
