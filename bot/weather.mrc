; weather.mrc v1.0 (http://openweathermap.org)
; Requires Kin's JSON parser because of API format.
; irc.geekshed.net #Script-Help

on 1:TEXT:!weather *:%main:{
  set %w.city $replace($2-,$chr(32),$+(%,20))
  if ($sock(weather)) { sockclose weather }
  sockopen weather api.openweathermap.org 80
  sockmark weather msg $chan
}

on *:SOCKOPEN:weather:{
  if ($sockerr) { $sock(weather).mark Socket error: $sock(weather).wsmsg }
  sockwrite -nt $sockname GET $+(/data/2.5/weather?q=,%w.city,&units=metric) HTTP/1.1
  sockwrite -nt $sockname Host: $sock($sockname).addr
  sockwrite -nt $sockname Connection: close
  sockwrite -nt $sockname
}

on *:SOCKREAD:weather:{
  var &sr
  sockread $sock($sockname).rq &sr
  var %dat $bvar(&sr,1,$sockbr).text
  set -e %w.hash $jsonparse(weath,%dat)
}

on *:SOCKCLOSE:weather:{
  if ($hget(%w.hash,cod) == 404) { $sock(weather).mark No results.
  else { $sock(weather).mark $hget(%w.hash,name) ( $+ $hget(%w.hash,country) $+ ):  $lower($hget(%w.hash,description)) [ $+ $hget(%w.hash,temp) $+ °C] }
  hfree %w.hash | unset %w.*
}
