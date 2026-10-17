##
# Clone Detector v1.1.1 by MC_8 - Carl M. Gregory <gregory@worldinter.net>
#  This script will only work on eggdrop 1.5+ series.
#
# If you have any questions/comments/idea's, please email me!
# ( Include the script name and version in the title, if you do email me. )
#
# My SVS Website - http://mc.purehype.net/
##

##
#  This script will detect clones... nuff said?
##

##
# HISTORY
##
# v1.1.1 (08.27.01)
#  MC_8 - [RC-] - [mc:cd:mode]: can't read "botnick"
#
#  v1.1 (06.27.01)
#   MC_8 - KatzEye - Fixed screwing things with exempt:op and exempt:voice.
#   MC_8 - KatzEye - Added exempt:voice and exempt:op veriables.
#   MC_8 - Added warn:method veriable.
#   MC_8 - KatzEye - Fixed `Tcl error [mc:cd:sign]: no value given for parameter
#                    "reason" to "mc:cd:sign"`
#   MC_8 - KatzEye - Wasn't properly evaluating netsplits.
#   MC_8 - KatzEye - Added `set mc_cd(clone:flag:msg)` and `set mc_cd(clone:flag:notice)`.
#   MC_8 - KatzEye - Fixed:
#                      Tcl error in script for 'timer???':
#                      wrong # args: should be "lindex list index"
#   MC_8 - Since it's going by on the fly channel set's, I made the script
#          rebuild the clone list every 5 mins due to the script not knowing
#          exactly when a channel get's turned on.
#   MC_8 - KatzEye - Made it possible to defining the channel this script is to
#                    be active on, on the fly.
#   MC_8 - KatzEye - Fixed ignoreflag problem.
#   MC_8 - KatzEye - Fixed `Tcl error [mc:cd:part]: called "mc:cd:part"
#                    with too many arguments'.
#   MC_8 - Added SVS
#   MC_8 - ]2501 - Created an "ignore flaged users" option, to ignore certin
#                  users from clone detection.
#   MC_8 - CriSbiE - Inital beta release.
##

##
# Settings
##

# Note:
#  There is a setting you set from dcc chat with the bot using .chanset.
#   +/-mc.clonedetector  -- This will enable the script for the particular channel.
#
#  Example from dcc chat with the bot:
#   .chanset #channel +mc.clonedetector

# How many clones before warning the user?
# NOTE:  3 users on the same host is not 3 clones, it's 2 clones (the third
# is an origional user)
set mc_cd(warn:clone) 1

# What do you want the warning message to say?
# %chan will be replaced with the channel in witch the user is cloned in.
# Set to "" if you don't want to give a warning.
set mc_cd(warn:msg) "I have detected 1 clone of yourself in %chan, you have 3 min's to handle the situation on your own."

# Do you want the above warn:msg to be send to the users in violation a /msg or a /notice?
# 0 = NOTICE
# 1 = MSG
set mc_cd(warn:method) 0

# [0=no/1=yes] Who else do you want to warn...
# Notice to the whole channel?
set mc_cd(clone:chan:notice) 0
# Message to the whole channel?
set mc_cd(clone:chan:msg) 0
# Notice to all the ops?
set mc_cd(clone:ops:notice) 1
# What other flaged users do you want to notice?  Set to "" to to turn this off.
# Flag syntax: <global>|<channel>
set mc_cd(clone:flag:notice) "o|o"
# What other flaged users do you want to message?  Set to "" to to turn this off.
# Flag syntax: <global>|<channel>
set mc_cd(clone:flag:msg) ""

# Upon alearting the mass', what do you want to say?
# %nick will be replaced with the last clone who triggers this script.
# %uhost will be replaced with the last clone's user@host that triggers this script.
set mc_cd(warn:mass:msg) "%nick!%uhost has been detected to have clones in the channel."

# [0=no/1=yes] Do you want to kick upon warning?
# (set to 2 if you want to leave 1 user (kick all but one))
set mc_cd(warn:kick) 0

# What do you want the warning kick message to say?
# %chan will be replaced with the channel in witch the user is cloned in.
set mc_cd(warn:kick:msg) "Mass clones are not acceptable."

# How long before the warning is to be put processed as punishment if the user
# does not part the clones?
# Set to 0 for no timer (aka, no rescan).  Set in min's.
set mc_cd(warn:exp) 3

# How many clones before processing punishment?
# NOTE:  3 users on the same host is not 3 clones, it's 2 clones (the third
# is an origional user)
set mc_cd(max:clone) 5

# [0=no/1=yes] What is the punishment to be?
# Kick all clones?  (set to 2 if you want to leave 1 user (kick all but one))
set mc_cd(pun:kick) 2

# How long do you want a ban on the cloner's ip/host to be active?
# -1 = No ban
#  0 = Server ban, aka doesn't get placed in the bot's banlist... just sent to the server.
#  1 and up = Min's to have the user's ip/host banned.
set mc_cd(pun:ban) 0

# What do you want to set the kick/ban message to?
set mc_cd(pun:kb:msg) "Sup with the clones?"

# What flaged users am I to ignore?
set mc_cd(ign:flg) "bmnoC|mnoC"

# [0=no/1=yes] Do you want to exempt people that are currently voiced
# in the channel?
# ( If the person gain his voice in 2 seconds or less, then he will be
#   evaluated regardless. )
set mc_cd(exempt:voice) 0

# [0=no/1=yes] Do you want to exempt people that are currently opped
# in the channel?
# ( If the person gain his ops in 2 seconds or less, then he will be
#   evaluated regardless. )
set mc_cd(exempt:op) 0

## MC SVS (Script Version Server) v1.2 ##
# Do you want the bot to connection to MC_8's SVS to see if there are newer versions
# of this script avilable?  It will only tell you -- It's up to you to get the newest
# version (I decided not to auto update the code, there may be new features in the
# newest script that may require your attention).
# 0=no/1=yes
set mc_cd(svs:enabled) 1

# Once a day the script will check with the SVS -- this specifies when
# that should happen.  The setting should be the hour (military).
# examples:
#  set mc_cd(svs:check) 0  ;#This is at Midnight
#  set mc_cd(svs:check) 5  ;#This is at 5am
#  set mc_cd(svs:check) 13  ;#This is at 1pm
#  set mc_cd(svs:check) 23  ;#This is at 11pm
set mc_cd(svs:check) 3

# Upon finding a newer version, who do you want to notify via note?
# Only the admin of the bot should really be worried about these notes,
# there the ones that keep everything up to par on the bots.
# Seperate each user with a " " (space).
set mc_cd(svs:notify) "MC_8"

# Do you want even beta version notified to whomever you have set?  Or just
# stable releases of the script?
#  0 = Tell me about all version, even beta versions.
#  1 = Just tell me about new stable versions.
set mc_cd(svs:stableonly) 0



## Coding below

set mc_cd(version) v1.1.1
set mc_cd(svs:script) "clonedetector 001001001000"
set mc_cd(svs:server) "mc.purehype.net 8085"

if {$numversion < "1050000"} {
 putlog "Clone Detector $mc_cd(version) by MC_8 is for eggdrop 1.5+ series only."
 putlog "Clone Detector $mc_cd(version) will not work with eggdrop $version."
 putlog "Clone Detector $mc_cd(version) not loaded."
 return 1
};setudef flag mc.clonedetector

bind rejn - * mc:cd:join:pipe
bind join - * mc:cd:join:pipe
proc mc:cd:join:pipe {nick uhost hand chan} {
 utimer 3 "mc:cd:join [mc:cd:filt $nick] [mc:cd:filt $uhost] [mc:cd:filt $hand] [mc:cd:filt $chan]"
}
proc mc:cd:join {nick uhost hand chan} {
 global mc_cd botnick
 set chan [string tolower $chan]
 if {(![mc:cd:chanflagison $chan mc.clonedetector]) ||
     (![onchan $botnick $chan]) ||
     ([matchattr $hand $mc_cd(ign:flg) $chan]) ||
     (([isvoice $nick $chan]) && ($mc_cd(exempt:voice))) ||
     (([isop $nick $chan]) && ($mc_cd(exempt:op)))} {return 0}
 if {($nick == $botnick) || ($uhost == "")} {
  set i 1
  foreach user [chanlist $chan] {
   if {$user != $botnick} {
    utimer 10 "mc:cd:join [split $user] [getchanhost $user $chan] [split $hand] [split $chan]"
    set i 0
   }
  }
  if {(($i) && ($uhost != "@"))} {
   utimer 20 "mc:cd:join [split $botnick] @ [split $hand] [split $chan]"
  } ; return 0
 }
 set host [string range $uhost [expr [string first @ $uhost]+1] e]
 if {[info exists mc_cd(!$host:$chan)]} {
  incr mc_cd(!$host:$chan) +1
  if {($mc_cd(!$host:$chan) >= $mc_cd(max:clone)) ||
      (($mc_cd(!$host:$chan) >= $mc_cd(warn:clone)) && ($hand == "@"))} {
   switch -- $mc_cd(pun:ban) {
    -1 {}
    default {
     putserv "MODE $chan +b *!*@$host"
     if {$mc_cd(pun:ban)} {
      newchanban $chan *!*@$host Clone-Detect [mc:cd:inter:replace $mc_cd(pun:kb:msg) "%chan $chan"] $mc_cd(pun:ban)
      putlog "Max. Clones Detected, ban'n $nick (*!*@$host) on $chan for $mc_cd(pun:ban) min's."
     } {putlog "Max. Clones Detected, ban'n $nick (*!*@$host) on $chan."}
    }
   }
   if {$mc_cd(pun:kick)} {
    if {$mc_cd(pun:kick) == "2"} {
     set users [lrange [mc:cd:inter:findchanuser *!*@$host $chan] 1 e]
    } {set users [mc:cd:inter:findchanuser *!*@$host $chan]}
    foreach user $users {
     putserv "KICK $chan $user :[mc:cd:inter:replace $mc_cd(pun:kb:msg) "%chan $chan"]"
    } ; putlog "Max. Clones Detected, kicking [join $users ", "] from $chan"
   }
  } {
   if {$mc_cd(!$host:$chan) >= $mc_cd(warn:clone)} {
    set i ""
    if {$mc_cd(warn:msg) != ""} {
     if {$mc_cd(warn:method)} {set method "PRIVMSG"} {set method "NOTICE"}
     foreach user [mc:cd:inter:findchanuser *!*@$host $chan] {
      puthelp "$method $user :[mc:cd:inter:replace $mc_cd(warn:msg) "%chan $chan"]"
      set i "$i $user"
     } ; putlog "Min. Clones Detected on $chan, warning [join $i ", "]."
    }
    if {$mc_cd(clone:chan:notice)} {
     puthelp "NOTICE $chan :[mc:cd:inter:replace $mc_cd(warn:mass:msg) "%nick $nick %uhost $uhost"]"
     putlog "Min. Clones Detected on $chan ([join $i ", "]), notice'n the channel on my findings."
    } elseif {$mc_cd(clone:chan:msg)} {
     puthelp "PRIVMSG $chan :[mc:cd:inter:replace $mc_cd(warn:mass:msg) "%nick $nick %uhost $uhost"]"
     putlog "Min. Clones Detected on $chan ([join $i ", "]), message'n the channel on my findings."
    }
    if {$mc_cd(clone:ops:notice)} {
     if {[isop $botnick $chan]} {
      puthelp "NOTICE @$chan :[mc:cd:inter:replace $mc_cd(warn:mass:msg) "%nick $nick %uhost $uhost"]"
     } {
      foreach user [chanlist $chan] {
       if {[isop $user $chan]} {
        puthelp "NOTICE $user :(OP NOTICE) [mc:cd:inter:replace $mc_cd(warn:mass:msg) "%nick $nick %uhost $uhost"]"
       }
      }
     } ; putlog "Min. Clones Detected on $chan ([join $i ", "]), notice'n the ops on my findings."
    }
    if {$mc_cd(clone:flag:notice) != ""} {
     foreach chan_user [chanlist $chan] {
      if {(![matchattr [nick2hand $chan_user] $mc_cd(clone:flag:notice) $chan]) ||
          (($mc_cd(clone:ops:notice)) && ([isop $chan_user $chan]))} {continue}
      puthelp "NOTICE $chan_user :[mc:cd:inter:replace $mc_cd(warn:mass:msg) "%nick $nick %uhost $uhost"]"
     }
    }
    if {$mc_cd(clone:flag:msg) != ""} {
     foreach chan_user [chanlist $chan] {
      if {![matchattr [nick2hand $chan_user] $mc_cd(clone:flag:msg) $chan]} {continue}
      puthelp "PRIVMSG $chan_user :[mc:cd:inter:replace $mc_cd(warn:mass:msg) "%nick $nick %uhost $uhost"]"
     }
    }
    if {$mc_cd(warn:kick)} {
     if {$mc_cd(warn:kick) == "2"} {
      set users [lrange [mc:cd:inter:findchanuser *!*@$host $chan] 1 e]
     } {set users [mc:cd:inter:findchanuser *!*@$host $chan]}
     foreach user $users {
      puthelp "KICK $chan $nick :[mc:cd:inter:replace $mc_cd(warn:kick:msg) "%chan $chan"]"
     } ; putlog "Min. Clones Detected, kicking [join $users ", "] from $chan"
    }
    if {$mc_cd(warn:exp)} {timer $mc_cd(warn:exp) "mc:cd:inter:warntimer [split $nick] $uhost $host [split $chan]"}
   }
  }
 } {set mc_cd(!$host:$chan) 0}
}

bind mode - * mc:cd:mode
proc mc:cd:mode {nick uhost hand chan mc vic} {
 global mc_cd botnick
 if {((![string match *o $mc]) && (![string match *v $mc])) ||
     (![mc:cd:chanflagison $chan mc.clonedetector]) || 
     (![onchan $botnick $chan])} {return 0}
 set chan [string tolower $chan]
 set uhost [getchanhost $vic $chan]
 set nick $vic
 set host [string range [getchanhost $vic $chan] [expr [string last @ [getchanhost $vic $chan]]+1] e]
 switch -- $mc {
  +o {
   if {$mc_cd(exempt:op) && [info exists mc_cd(!$host:$chan)]} {
    incr mc_cd(!$host:$chan) -1
    if {$mc_cd(!$host:$chan) < "0"} {unset mc_cd(!$host:$chan)}
   }
  }
  +v {
   if {$mc_cd(exempt:voice) && [info exists mc_cd(!$host:$chan)]} {
    incr mc_cd(!$host:$chan) -1
    if {$mc_cd(!$host:$chan) < "0"} {unset mc_cd(!$host:$chan)}
   }
  }
  -o {
   if {([matchattr $hand $mc_cd(ign:flg) $chan]) || 
       ($nick == $botnick) ||
       (([isvoice $nick $chan]) && ($mc_cd(exempt:voice)))} {return 0}
   mc:cd:join $vic $uhost $hand $chan
  }
  -v {
   if {([matchattr $hand $mc_cd(ign:flg) $chan]) || 
       ($nick == $botnick) ||
       (([isop $nick $chan]) && ($mc_cd(exempt:op)))} {return 0}
   mc:cd:join $vic $uhost $hand $chan
  }
 };return 0
}

proc mc:cd:inter:findchanuser {hostmask channel} {
 if {![validchan $channel]} {return -code error "no such channel record"} ; set buffer ""
 foreach user [chanlist $channel] {
  if {[string match $hostmask "$user![getchanhost $user $channel]"]} {set buffer "$buffer $user"}
 } ; return [join [split $buffer] " "]
}

proc mc:cd:inter:warntimer {nick uhost host chan} {
 global mc_cd ; incr mc_cd(!$host:$chan) -1 ; mc:cd:join $nick $uhost @ $chan
}

proc mc:cd:inter:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

bind part - * mc:cd:part
proc mc:cd:part {nick uhost hand chan {reason ""}} {
 global mc_cd botnick
 set chan [string tolower $chan]
 set host [string range $uhost [expr [string first @ $uhost]+1] e]
 if {$nick == $botnick} {
  foreach array [array names mc_cd] {
   if {([string index $array 0] == "!") &&
       ([string tolower [lindex [split $array :] 1]] == $chan)} {
    unset mc_cd($array)
   }
  }
 } {
  if {![info exists mc_cd(!$host:$chan)]} {return 0}
  incr mc_cd(!$host:$chan) -1
 }
}

bind splt - * mc:cd:sign:pipe
proc mc:cd:sign:pipe {nick uhost hand chan} {mc:cd:sign $nick $uhost $hand $chan ""}
bind sign - * mc:cd:sign
proc mc:cd:sign {nick uhost hand chan reason} {
 global mc_cd botnick
 set chan [string tolower $chan]
 set host [string range $uhost [expr [string first @ $uhost]+1] e]
 if {$nick == $botnick} {
  foreach array [array names mc_cd] {
   if {([string index $array 0] == "!") &&
       ([string tolower [lindex [split $array :] 1]] == $chan)} {
    unset mc_cd($array)
   }
  }
 } {
  if {![info exists mc_cd(!$host:$chan)]} {return 0}
  incr mc_cd(!$host:$chan) -1
 }
}

bind kick - * mc:cd:kick
proc mc:cd:kick {knick kuhost khand chan nick reason} {
 global mc_cd botnick
 set chan [string tolower $chan]
 set uhost [getchanhost $nick $chan]
 set host [string range $uhost [expr [string first @ $uhost]+1] e]
 if {$nick == $botnick} {
  foreach array [array names mc_cd] {
   if {([string index $array 0] == "!") &&
       ([string tolower [lindex [split $array :] 1]] == $chan)} {
    unset mc_cd($array)
   }
  }
 } {
  if {![info exists mc_cd(!$host:$chan)]} {return 0}
  incr mc_cd(!$host:$chan) -1
 }
}

bind time - "00 * * * *" mc:cd:time:rescan
bind time - "05 * * * *" mc:cd:time:rescan
bind time - "10 * * * *" mc:cd:time:rescan
bind time - "15 * * * *" mc:cd:time:rescan
bind time - "20 * * * *" mc:cd:time:rescan
bind time - "25 * * * *" mc:cd:time:rescan
bind time - "30 * * * *" mc:cd:time:rescan
bind time - "35 * * * *" mc:cd:time:rescan
bind time - "40 * * * *" mc:cd:time:rescan
bind time - "45 * * * *" mc:cd:time:rescan
bind time - "50 * * * *" mc:cd:time:rescan
bind time - "55 * * * *" mc:cd:time:rescan
proc mc:cd:time:rescan {a b c d e} {
 global mc_cd botnick
 foreach array [array names mc_cd] {
  if {[string match !*:* $array]} {unset mc_cd($array)}
 }
 foreach chan [channels] {
  if {(![mc:cd:chanflagison $chan mc.clonedetector]) || 
      (![onchan $botnick $chan])} {continue}
  foreach nick [chanlist $chan] {
   set hand [nick2hand $nick $chan]
   set uhost [getchanhost $nick $chan]
   set host [string range $uhost [expr [string first @ $uhost]+1] e]
   if {([matchattr $hand $mc_cd(ign:flg) $chan]) || 
       ($nick == $botnick) ||
       (([isvoice $nick $chan]) && ($mc_cd(exempt:voice))) ||
       (([isop $nick $chan]) && ($mc_cd(exempt:op)))} {continue}
   mc:cd:join [split $nick] $uhost [split $hand] [split $chan]
  }
 }
}

proc mc:cd:chanflagison {chan flag} {
 set chan [string tolower $chan]
 foreach info [channel info $chan] {
  if {[string tolower [string range $info 1 e]] == [string tolower $flag]} {
   if {[string index $info 0] == "-"} {
    return 0
   } elseif {[string index $info 0] == "+"} {
    return 1
   } else {return 0}
  }
 };return 0
}

## sindex procedures (by MC_8 & guppy)
proc mc:cd:slength {str} {return [llength $str]}
proc mc:cd:sindex {str index} {return [lindex [split $str] $index]}
proc mc:cd:srange {str s e} {return [lrange [split $str] $s $e]}
proc mc:cd:filt {data} {
 return [join [split [join [split [join [split [join [split [join [split [join [split $data \\] \\\\] \[] \\\[] \]] \\\]] \}] \\\}] \{] \\\{] \"] \\\"]
}
proc mc:cd:unfilt {data} {
 regsub -all -- \\\\\\\[ $data \[ data;regsub -all -- \\\\\\\] $data \] data;regsub -all -- \\\\\\\} $data \} data
 regsub -all -- \\\\\\\{ $data \{ data;regsub -all -- \\\\\\\" $data \" data;regsub -all -- \\\\\\\\ $data \\ data;return $data
}
## sindex end

if {$mc_cd(svs:enabled)} {
 if {($mc_cd(svs:check) > "23") || ($mc_cd(svs:check) < "0")} {set mc_cd(svs:check) 00}
 if {[string length $mc_cd(svs:check)] == "1"} {set mc_cd(svs:check) 0$mc_cd(svs:check)}
 if {$mc_cd(svs:stableonly)} {
  set mc_cd(svs:script) [string range $mc_cd(svs:script) 0 [expr [string length $mc_cd(svs:script)]-4]]999
 }
 catch {unbind time - "00 $mc_cd(svs:oldcheck) * * *" mc:cd:svs:time}
 set mc_cd(svs:oldcheck) $mc_cd(svs:check)
 bind time - "00 $mc_cd(svs:check) * * *" mc:cd:svs:time
 proc mc:cd:svs:time {min hour day month year} {
  global mc_cd
  catch {control [connect [lindex $mc_cd(svs:server) 0] [lindex $mc_cd(svs:server) 1]] mc:cd:svs:interface}
 }
}
proc mc:cd:svs:interface {idx args} {
 global mc_cd;set args [join $args]
 switch -- [lindex $args 0] {
  "" {return 1}
  000 {putdcc $idx q}
  002 {putdcc $idx [lindex $mc_cd(svs:script) 0]}
  003 {
   set args [lrange $args 1 e]
   if {[lindex $args 0] != [lindex $mc_cd(svs:script) 0]} {return 0}
   putdcc $idx q
   if {[lindex $args 1] > [lindex $mc_cd(svs:script) 1]} {
    set note [mc:cd:svs:replace [lindex $args 7] "%0 {[lindex $args 0]} %1 {[lindex $args 1]} %2 {[lindex $args 2]}"]
    set note [mc:cd:svs:replace $note "%3 {[lindex $args 3]} %4 {[lindex $args 4]} %5 {[lindex $args 5]}"]
    set note [mc:cd:svs:replace $note "%6 {[lindex $args 6]} %8 {[lindex $args 8]} %version {$mc_cd(version)}"]
    set note [mc:cd:svs:replace $note "%9 {[lindex $args 9]} %10 {[lindex $args 10]} %11 {[lindex $args 11]}"]
    set note [mc:cd:svs:replace $note "%12 {[lindex $args 12]} %13 {[lindex $args 13]} %14 {[lindex $args 14]}"]
    set note [mc:cd:svs:replace $note "%15 {[lindex $args 15]} %16 {[lindex $args 16]} %17 {[lindex $args 17]}"]
    set note [mc:cd:svs:replace $note "%18 {[lindex $args 18]} %19 {[lindex $args 19]} %20 {[lindex $args 20]}"]
    foreach notify [join [split $mc_cd(svs:notify) ",;"]] {
     set outnote [mc:cd:svs:replace $note "%nick {$notify}"]
     if {[string match "*$outnote*" "[notes $notify -[notes $notify]]"]} {
      set cont 0
      foreach unote [notes $notify -[notes $notify]] {
       if {$outnote == [lindex $unote 2]} {set cont 1;break}
      };if {$cont} {continue}
     }
     switch -- [sendnote SVS $notify $outnote] {
      0 {putlog "MC SVS for [lindex $mc_cd(svs:script) 0] had some errors updating $notify on current version of script; unknown reason!"}
      3 {putlog "MC SVS for [lindex $mc_cd(svs:script) 0] had some errors updating $notify on current version of script; notebox too full!"}
     }
    }
   }
  }
 };return 0
}
proc mc:cd:svs:replace {string subs} {
 if {[llength $subs] == "1"} {set subs [lindex $subs 0]}
 for {set i 0} {[lindex $subs $i] != ""} {incr i 2} {
  regsub -all -- [lindex $subs $i] $string [lindex $subs [expr $i+1]] string
 } ; return $string
}

putlog "Clone Detector $mc_cd(version) by MC_8 loaded."
