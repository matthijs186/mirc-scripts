; Undocumented JSON parser made by Kin
; irc.geekshed.net #Script-Help

alias jsonparse {
  var %h $1
  var %json $2-
  var %jsonpattern /"([^"]+)":("[^"]*"|[^"{][^,}]+)/g
  var %matches $regex(jsonparse,%json,%jsonpattern)
  ; load up a hash table with our item:data pairs
  while (%matches > 0) {
    var %item $regml(jsonparse,$calc((%matches * 2) - 1))
    var %data $regml(jsonparse,$calc(%matches * 2))
    if ("*" iswm %data) { %data = $mid(%data,2,$calc($len(%data) - 2)) }
    hadd -m %h %item %data
    dec %matches
  }
  if ($hget(%h,0).item > 0) { return %h }
  else { return $null }
}
