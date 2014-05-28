/* appnews.mrc v0.2b
* irc.geekshed.net #Script-Help
*/

on 1:TEXT:!appnews*:#:{
  if ((!$2) || ($2 !isnum)) notice $nick Usage: !appnews <steam appid>
  else {
    if ($sock(appnews)) sockclose appnews
    sockopen appnews api.steampowered.com 80
    sockmark appnews $2 notice $nick
  }
}
on *:SOCKOPEN:appnews:{
  if ($sockerr) $sock($sockname).mark Socket error: $sock($sockname).wsmsg
  sockwrite -nt $sockname GET $+(/ISteamNews/GetNewsForApp/v0002/?appid=,$gettok($sock($sockname).mark,1,32),&count=1&maxlength=100&format=json) HTTP/1.1
  sockwrite -nt $sockname Host: $sock($sockname).addr
  sockwrite -nt $sockname Connection: close
  sockwrite -nt $sockname
}
on *:SOCKREAD:appnews:{
  var &sn
  sockread $sock($sockname).rq &sn
  var %dat $bvar(&sn,1,$sockbr).text
  set -e %anews $jsonparse(anews,%dat)
}
on *:SOCKCLOSE:appnews:{
  var %s $gettok($sock($sockname).mark,2-,32)
  if (!$hget(%anews,appnews)) %s No news found for appid $gettok($sock($sockname).mark,1,32) $+ .
  else %s $chr(91) $noqt($hget(%anews,title)) $chr(93) $noqt($hget(%anews,url))
  hfree %anews | unset %anews
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
