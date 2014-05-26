/* weather.mrc v1.1
* Visit http://openweathermap.org for more info.
* irc.geekshed.net #Script-Help
*/

on 1:TEXT:!weather*:#:{
  if (!$2) notice $nick Usage: !weather <country|city>
  else {
    if ($sock(weather)) sockclose weather
    sockopen weather api.openweathermap.org 80
    sockmark weather $replace($2-,$chr(32),$+(%,20)) msg $chan
  }
}

on *:SOCKOPEN:weather:{
  if ($sockerr) { $sock(weather).mark Socket error: $sock(weather).wsmsg }
  sockwrite -nt $sockname GET $+(/data/2.5/weather?q=,$gettok($sock($sockname).mark,1,32),&units=metric) HTTP/1.1
  sockwrite -nt $sockname Host: $sock($sockname).addr
  sockwrite -nt $sockname Connection: close
  sockwrite -nt $sockname
}

on *:SOCKREAD:weather:{
  var &sr
  sockread $sock($sockname).rq &sr
  var %dat $bvar(&sr,1,$sockbr).text
  set -e %weath $jsonparse(weath,%dat)
}

on *:SOCKCLOSE:weather:{
  if ($hget(%weath,cod) == 404) $gettok($sock($sockname).mark,2-,32) No results.
  else $gettok($sock($sockname).mark,2-,32)  $+ $iif($hget(%weath,name),$v1 ( $+ $hget(%weath,country) $+ ),$hget(%weath,country)) $+ :  $lower($hget(%weath,description)) [ $+ $left($hget(%weath,temp),5) $+ °C]
  hfree %weath | unset %weath
}

; Undocumented JSON parser made by Kin
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
