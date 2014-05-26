; gauges.mrc v0.2 (http://steamgaug.es)
; Requires Kin's JSON parser because of API format.
; irc.geekshed.net #Script-Help

on 1:TEXT:!gauges:#:{
  if ($sock(gauges)) { sockclose gauges }
  sockopen gauges steamgaug.es 80
  sockmark gauges notice $nick
}
on *:SOCKOPEN:gauges:{
  if ($sockerr) { msg $sock(gauges).mark Socket error: $sock(gauges).wsmsg }
  sockwrite -nt $sockname GET /api/ HTTP/1.0
  sockwrite -nt $sockname Host: $sock($sockname).addr
  sockwrite -nt $sockname Connection: close
  sockwrite -nt $sockname $crlf
}
on *:SOCKREAD:gauges:{
  var &sr
  sockread $sock($sockname).rq &sr
  var %dat $bvar(&sr,1,$sockbr).text
  set -e %g.hash $jsonparse(steam,%dat)
}
on *:SOCKCLOSE:gauges:{
  var %check = 7checking service, %up = 3up, %down = 4down
  $sock(gauges).mark Steam Client: $replace($hget(%g.hash,ISteamClient),-1,%check,0,%up,1,%down) $+ , Steam Friends: $replace($hget(%g.hash,ISteamFriends),-1,%check,0,%up,1,%down) $+ , User Data API: $replace($hget(%g.hash,ISteamUser),-1,%check,0,%up,1,%down) $+ .
  $sock(gauges).mark Team Fortress 2 Items API: $replace($hget(%g.hash,IEconItems_440),-1,%check,0,%up,1,%down) $+ , Team Fortress 2 Game Coordinator: $replace($hget(%g.hash,ISteamGameCoorindator_440),-1,%check,0,%up,1,%down) $+ .
  $sock(gauges).mark Source: http://steamgaug.es
  hfree %g.hash | unset %g.hash
  halt
}
