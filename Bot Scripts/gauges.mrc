/* gauges.mrc v1.0b
* Visit http://steamgaug.es for more info.
* irc.geekshed.net #Script-Help
*/

on 1:TEXT:!gauges:#:{
  if ($sock(gauges)) sockclose gauges
  sockopen gauges steamgaug.es 80
  sockmark gauges notice $nick
}
on *:SOCKOPEN:gauges:{
  if ($sockerr) $sock($sockname).mark Socket error: $sock($sockname).wsmsg
  sockwrite -nt $sockname GET /api/ HTTP/1.1
  sockwrite -nt $sockname Host: $sock($sockname).addr
  sockwrite -nt $sockname Connection: close
  sockwrite -nt $sockname
}
on *:SOCKREAD:gauges:{
  var &sg
  sockread $sock($sockname).rq &sg
  var %dat $bvar(&sg,1,$sockbr).text
  set -e %steam $jsonparse(steam,%dat)
}
on *:SOCKCLOSE:gauges:{
  $sock($sockname).mark Steam Client is $gaugret($hget(%steam,ISteamClient)) $+ , Steam Friends is $gaugret($hget(%steam,ISteamFriends)) $+ .
  $sock($sockname).mark Dota 2 Game Coordinator is $gaugret($hget(%steam,ISteamGameCoorindator_570)) $+ , Team Fortress 2 Game Coordinator is $gaugret($hget(%steam,ISteamGameCoorindator_440)) $+ .
  $sock($sockname).mark Source: http://steamgaug.es
  hfree %steam | unset %steam
}
alias gaugret {
  if ($1 == -1) return 7unknown
  elseif ($1 == 0) return 3online
  elseif ($1 == 1) return 4offline
  elseif ($1 == 2) return 7internal server error
  elseif ($1 == 3) return 7empty response
  elseif ($1 == 4) return 7not found
  elseif ($1 == 5) return 7timeout
  elseif ($1 == 6) return 7other error
  else return $1
}

alias jsonparse {
  var %h $1
  var %json $2-
  var %jsonpattern /"([^"]+)"\s*:\s*("[^"]*"|[^"{][^,}]+)/g
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
