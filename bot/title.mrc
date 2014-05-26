; title.mrc v1.1
; Thanks Kin for helping with the regex.
; irc.geekshed.net #Script-Help

on 1:TEXT:*:#:title $1-
alias -l title {
  if ($regex(title,$1-,/(https?)\x3A\/\/([^\s\n\/]++)(\/\S*)?/Si)) {
    var %skiptypes png jpg jpeg txt | var %filetype $gettok($regml(3),-1,46)
    if ($istok(%skiptypes,%filetype,32)) { halt }
    if ($sock(title)) { sockclose title }
    if ($regml(title,1) == http) { sockopen title $regml(title,2) 80 }
    if ($regml(title,1) == https) { sockopen -e title $regml(title,2) 443 }
    sockmark title $iif($regml(title,3),$v1,/) $1
  }
}
on *:SOCKOPEN:title:{
  if ($sockerr) {
    if ($remove($gettok($sock(title).wsmsg,1,32),$chr(91),$chr(93)) == 0) msg $gettok($sock(title).mark,2,32) wat
    else msg $gettok($sock(title).mark,2,32) $sock(title).wsmsg
  }
  else {
    sockwrite -nt $sockname GET $iif($gettok($sock($sockname).mark,1,32),$v1,/) HTTP/1.0
    sockwrite -nt $sockname Host: $sock($sockname).addr
    sockwrite -nt $sockname Connection: close
    sockwrite -nt $sockname
  }
}
on *:SOCKREAD:title:{
  var %titletag | sockread %titletag
  if (Location: isin %titletag) title $gettok($sock(title).mark,2,32) $gettok(%titletag,2,32)
  elseif ($regex(titletag,%titletag,/<title>([^\n<]*+)/i)) {
    if ($regml(titletag,1) == $null) halt
    else msg $gettok($sock(title).mark,2,32)  $+ $left($replace($regml(titletag,1),&amp;,&,&gt,>,&lt,<),100)
    sockclose $sockname
  }
}
