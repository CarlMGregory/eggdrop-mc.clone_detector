##
# Clone Detector v3.0.2
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.6.14 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My Website - http://mc.purehype.net/
# Have a bug, script not working correctly, or just an idea?
#   http://mc.purehype.net/bugzilla/
# Have a question?
#   http://forum.purehype.net/viewforum.php?f=5
##

##
# Description
##
# This script will watch over any given channels to ensure that excessive clones
# are not sitting in the channel.
##

##
# Commands
##
# DCC:
#  chanset <channel> mc.clone_detector.clones <number>
#     Change this to the number of clones not allowed in the specific channel.
#     Setting this to 0, default, will disable the script for the specific
#     channel.
#     Note, 3 users on the same host/ip is not considered 3 clones.  It's
#           considered 2 clones, and 1 original user.
#
#  chanset <channel> mc.clone_detector.warnings <number>
#     Change this to the number of warnings you want to give the user if clones
#     is greater than or equal to mc.clone_detector.clones.  Set this to 0,
#     default, to give no warnings.
#
#  chanset <channel> mc.clone_detector.rescan <number>
#     If mc.clone_detector.warnings isn't set to 0, set this to the number of
#     minutes you want to give the user before you do a re scan to see if he has
#     clones in the channel still.  By setting this to 0, default, you will
#     disable re scan -- meaning the only way the script can proceed to a
#     further punishment or another warning (if more warnings available for the
#     user) is if the user brings in yet another clone.
#
#  chanset <channel> mc.clone_detector.exempt_ops <1/0>
#     This will exempt (+) or not (-) a physical op of the specifiec channel.
#     Default: 0 (no/don't exempt)
#
#  chanset <channel> mc.clone_detector.exempt_voices <1/0>
#     This will exempt (+) or not (-) a physical voice of the specifiec channel.
#     Default: 0 (no/don't exempt)
#
#  chanset <channel> mc.clone_detector.exempt_flags [<global>|<channel>]
#     This will exempt flagged users.  Don't specify the flags, default, to
#     exempt no-one.
##

##
# Configuration
##
#

# Upon warning a user for excessive clones, what do you want to do?  Seperate
# each command with a new line.
# Valid commands are:
#   /msg <nick|channel> <text>
#   /notice <nick|channel> <text>
#   /ban <channel> <nick> [%<time>] [*<banmask_type>] [reason]
#     time:
#       If time is specified;
#         -1 = Server ban.
#          0 = Perm ban.
#         Any number greater than 0 is the ban expiration in min's.
#       If the time specified is not a server ban, the reason will be put into
#       the bot's internal banlist record as the reason for adding the ban.
#       Otherwise the ban is considered a server ban and reason is just ignored.
#       When you specify time, don't forget the % (ie: %20 is 20 minutes). In
#       addition to the time of the ban, you can set it to be sticky (read up
#       on '.help stick'). To make the ban sticky; append the time with a '!'
#       (exclamation point) (ie: %20! is 20 minute sticky ban).
#       This setting is optional, if not given then it will default to -1
#       (server ban).
#     banmask_type:
#       This will mask the users ban to the banmask_type number you
#       give. Don't forget the * when you specify the number (ie: *19 is banmask
#       type number 19).
#       Banmask types are:
#        -1 - nick!*@*
#         0 - *!user@host.domain
#         1 - *!*user@host.domain
#         2 - *!*@host.domain
#         3 - *!*user@*.domain
#         4 - *!*@*.domain
#         5 - nick!user@host.domain
#         6 - nick!*user@host.domain
#         7 - nick!*@host.domain
#         8 - nick!*user@*.domain
#         9 - nick!*@*.domain
#         You can also specify a type of 10 to 19 which correspond to masks 0 to
#         9.
#         But if the host.domain is a;
#           hostname = Instead of using a * wildcard to replace portions of the
#                      host.domain, it replaces the numbers in the host.domain
#                      with a '?' (question mark) wildcard.
#           ip       = It will mask as normal, with no '?' (question mark)
#                      replacements as does hostname.
#       This setting is optional, if not given then it will default to type 3.
#   /kick <channel> <nick> [reason]
#     If no reason is given, the script's name and version will be used.
#   /raw <raw_irc_code>
#     See: http://www.user-com.undernet.org/documents/rfc1459.txt
#     Examples:
#       Deop:    /raw MODE %channel -o %clone_nicks
#       Devoice: /raw MODE %channel -v %clone_nicks
#   /tcl <coding>
# Replacment variables:
#   %channel        - The channel in which the user is in.
#   %clone_nicks    - This will be repleaced with each of the clones' irc
#                     nicknames, the command will loop once per nick if needed
#                     (ie: is the destination for /msg or nick for /ban, etc).
#                     Otherwise, will just be replaced with "nick1, nick2,
#                     nickN".
#   %nick           - IRC nickname of the user that is in violation (last to
#                     trigger evaluation).
#   %clone_limit    - The clone limit for the channel.
#   %clones         - Number of clones the user has in the channel.
#   %rescan         - Minutes before rescan.
#   %warning_limit  - Maximum number of warnings allowed.
#   %warnings       - Current number of warnings the user has received, counting
#                     this one.
set mc_cd(:config:do_warning) {
  /msg %nick Remove your clones from %channel!
  /msg %nick You have %rescan minutes to comply.
}

# After warnings have been exceeded for the user due to excessive clones, what
# do you want to do?  Seperate each command with a new line.  This is processed
# on a per nick basis, so if the user had 30 clones, this will be evaluated 30
# times should you want to /kick each and every one of them.
# Valid commands are:
#   /msg <nick|channel> <text>
#   /notice <nick|channel> <text>
#   /ban <channel> <nick> [%<time>] [*<banmask_type>] [reason]
#     time:
#       If time is specified;
#         -1 = Server ban.
#          0 = Perm ban.
#         Any number greater than 0 is the ban expiration in min's.
#       If the time specified is not a server ban, the reason will be put into
#       the bot's internal banlist record as the reason for adding the ban.
#       Otherwise the ban is considered a server ban and reason is just ignored.
#       When you specify time, don't forget the % (ie: %20 is 20 minutes). In
#       addition to the time of the ban, you can set it to be sticky (read up
#       on '.help stick'). To make the ban sticky; append the time with a '!'
#       (exclamation point) (ie: %20! is 20 minute sticky ban).
#       This setting is optional, if not given then it will default to -1
#       (server ban).
#     banmask_type:
#       This will mask the users ban to the banmask_type number you
#       give. Don't forget the * when you specify the number (ie: *19 is banmask
#       type number 19).
#       Banmask types are:
#        -1 - nick!*@*
#         0 - *!user@host.domain
#         1 - *!*user@host.domain
#         2 - *!*@host.domain
#         3 - *!*user@*.domain
#         4 - *!*@*.domain
#         5 - nick!user@host.domain
#         6 - nick!*user@host.domain
#         7 - nick!*@host.domain
#         8 - nick!*user@*.domain
#         9 - nick!*@*.domain
#         You can also specify a type of 10 to 19 which correspond to masks 0 to
#         9.
#         But if the host.domain is a;
#           hostname = Instead of using a * wildcard to replace portions of the
#                      host.domain, it replaces the numbers in the host.domain
#                      with a '?' (question mark) wildcard.
#           ip       = It will mask as normal, with no '?' (question mark)
#                      replacements as does hostname.
#       This setting is optional, if not given then it will default to type 3.
#   /kick <channel> <nick> [reason]
#     If no reason is given, the script's name and version will be used.
#   /raw <raw_irc_code>
#     See: http://www.user-com.undernet.org/documents/rfc1459.txt
#     Examples:
#       Deop:    /raw MODE %channel -o %clone_nicks
#       Devoice: /raw MODE %channel -v %clone_nicks
#   /tcl <coding>
# Replacment variables:
#   %channel        - The channel in which the user is in.
#   %clone_nicks    - This will be repleaced with each of the clones' irc
#                     nicknames, the command will loop once per nick if needed
#                     (ie: is the destination for /msg or nick for /ban, etc).
#                     Otherwise, will just be replaced with "nick1, nick2,
#                     nickN".
#   %nick           - IRC nickname of the user that is in violation (last to
#                     trigger evaluation).
#   %clone_limit    - The clone limit for the channel.
#   %clones         - Number of clones the user has in the channel.
#   %rescan         - Minutes before rescan.
#   %warning_limit  - Maximum number of warnings allowed.
#   %warnings       - Current number of warnings the user has received, counting
#                     this one.
set mc_cd(:config:do_excessive_warning) {
  /ban %channel %clone_nicks %1440 *3 Excessive clones.
  /kick %channel %clone_nicks Excessive clones.
  /msg %clone_nicks You have %clones clones in %channel.
  /msg %clone_nicks We only allow %clone_limit clones for that channel.
}

## SVS Client (Script Version Service) v4.1.2 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if
# there is a newer version of this script available.  If a newer version is
# found, the script will be auto updated.

# [0=no/1=yes] Do you want to enable auto updating?  If you chose to disable
# auto updating, it will not automatically update the script upon finding a
# newer version.
set mc_cd(:config:svs:enable) 1

#
##

##
# TCL Coding below, do not proceed.
##
#

## SVS insert (pre code)
#Script:mc_cd
catch {unset temp}

foreach temp(bind) [binds mc:cd:*] {
  foreach {temp(1) temp(2) temp(3) temp(4) temp(5)} $temp(bind) break
  catch {unbind $temp(1) $temp(2) $temp(3) $temp(5)}
}

set mc_cd(info:vars) ""
foreach {temp(name) temp(value)} [array get mc_cd :config:*] {
  lappend mc_cd(info:vars) [list $temp(name) $temp(value)]
}
set mc_cd(info:loc) [info script]
array set mc_cd [list \
  script                 "Clone Detector" \
  version                "v3.0.2" \
  svs:script             "clonedetector" \
  svs:version            "003000002000" \
  svs:client_version     "v4.1.2" \
  svs:client_svs_version "004001002000" \
  svs:server             "mc.svs.purehype.net" \
  svs:port               "80" \
  svs:get                "/index.tcl"]
set mc_cd(svs:query)    "svs=$mc_cd(svs:script)&"
append mc_cd(svs:query) "version=$mc_cd(svs:version)&"
append mc_cd(svs:query) \
  "svs_version=$mc_cd(svs:client_svs_version)"

if {![info exists numversion] ||
    ([string range $numversion 0 4] < "10614") ||
    (([string range $numversion 0 4] == "10614") &&
     ([string range $numversion 5 6] != "00"))} {
  set temp(tag) "$mc_cd(script) $mc_cd(version)"
  putloglev o * \
    "$temp(tag) by MC_8 will only work on eggdrop 1.6.14 (stable) or greater."
  putloglev o * "$temp(tag) will not work with eggdrop $version."
  putloglev o * "$temp(tag) not loaded."
  uplevel #0 {
    if {[info exists temp] && ![array exists temp]} {unset temp}
    set temp(svs_return) [list 0 "Need to upgrade eggdrop."]
  }; return 1
}
## ^

setudef int mc.clone_detector.clones
setudef int mc.clone_detector.warnings
setudef int mc.clone_detector.rescan
setudef int mc.clone_detector.exempt_ops
setudef int mc.clone_detector.exempt_voices
setudef str mc.clone_detector.exempt_flags

# Error Catching System (ECS), v4.1.
proc mc:cd:errchk {command args} {

  # Enable (1) or disable (0) auto reporting of bugs to mc8@purehype.net.
  # This setting here for those who want to disable it in fear of privacy
  # violations.
  set enable_auto_reporting 1

  if {![info exists ::lastCommand]} {set ::lastCommand [list]}
  set ::lastCommand \
    "[list [list [clock seconds] $command $args]] $::lastCommand"
  set ::lastCommand [lrange $::lastCommand 0 4]
  if {![catch {eval $command $args} return]} {return $return}
  if {$::errorCode == "mc.ecs.done"} {return -errorcode mc.ecs.done -code error}

  set temp(lastbind) [expr {[info exists ::lastbind]?$::lastbind:"-NULL-"}]
  set temp(eversion) [expr {[info exists ::version]?$::version:"-NULL-"}]
  set message "
    ************************************
    (ECS 4.1) Error found in TCL script.
    --------------
    Script name   : $::mc_cd(script)
    Script version: $::mc_cd(version)
    Egg. Version  : $temp(eversion)
    TCL Version   : [info tclversion] ([info patchlevel])
    --------------
    Last Bind     : $temp(lastbind)
    Last Commands :"
  foreach line $::lastCommand {
    foreach {time command arg} $line break
    append message "\n        ${time}- $command $arg"
  }
  append message "\n    Error stack   :"
  foreach line [split $::errorInfo \n] {
    append message "\n        $line"
  }
  append message "\n    --------------"

  set message [lrange [split $message \n] 1 end]
  set offset [string first * [lindex $message 0]]
  set new_message [list]
  foreach line $message {lappend new_message [string range $line $offset end]}
  set message $new_message

  if {!$enable_auto_reporting ||
      [catch {socket -async mc.purehype.net 80} sid]} {
    foreach line $message {putloglev o * $line}
    putloglev o * "Submit this bug to http://mc.purehype.net/bugzilla/ . If"
    putloglev o * "you are experiencing problems with bugzilla, contact MC_8"
    putloglev o * "via email at mc8@purehype.net. Please include all"
    putloglev o * "information shown here, in this ECS report."
    putloglev o * "************************************"
    return -errorcode mc.ecs.done -code error
  }
  fconfigure $sid -blocking 0 -buffering line

  set query [list]
  # This info is passed should I need to hunt down the bot's owner for more
  # information.
  lappend query "Admin   : [expr {[info exists ::admin]?$::admin:""}]"
  lappend query "Owner   : [expr {[info exists ::owner]?$::owner:""}]"
  lappend query "Botnick : [expr {[info exists ::botnick]?$::botnick:""}]"
  lappend query "Server  : [expr {[info exists ::server]?$::server:""}]"
  lappend query "Channels: [join [lsort -dictionary [channels]] ", "]"
  lappend query ""

  foreach line $message {lappend query $line}
  lappend query "************************************"

  set new_query [list]
  foreach line $query {
    regsub -all -- "(\002|\017|\026|\037)" $line "" line
    regsub -all -- "\003(\[0-9\]\[0-9\]?(,\[0-9\]\[0-9\]?)?)?" $line "" line
    regsub -all {\%} $line "%25" line
    set i [string length $line]
    while {[regexp {[^a-zA-Z0-9%]} $line toh] && ($i >= 0)} {
      scan "$toh" %c dec
      regsub -all -- "\\${toh}" $line "%[format %X $dec]" line
      incr i -1
    }; lappend new_query $line
  }; set query $new_query

  set query "message=[join $query %0a]"
  puts $sid "POST /report_bug.tcl HTTP/1.0\
           \nHost: mc.purehype.net:80\
           \nContent-type: application/x-www-form-urlencoded\
           \nContent-Length: [expr [string length $query] +2]"
  puts $sid \n$query
  close $sid

  foreach line $message {putloglev o * $line}
  putloglev o * "Automatically sending bug report to MC_8."
  putloglev o * "If you have a firewall setup, it may block the sending of this"
  putloglev o * "report. You can check the status of your bug, as soon as MC_8"
  putloglev o * "adds it, at http://mc.purehype.net/bugzilla/ ."
  putloglev o * "************************************"

  return -errorcode mc.ecs.done -code error
}
# ^

bind raw - 315 mc:cd:raw:315
proc mc:cd:raw:315 {from keyword text} {
  return [mc:cd:errchk mc:cd:raw:315 $from $keyword $text]
}
proc mc:cd:raw:315 {from keyword text} {
  global mc_cd
  #text:telnet #abc123 :End of /WHO list.
  foreach {to channel} [split $text] break

  set array ":enable:raw:315:[string tolower $channel]"
  if {![info exists mc_cd($array)] || !$mc_cd($array)} {
    return 0
  }; set mc_cd($array) 0

  if {![isbotnick $to]} {return 0}
  mc:cd:list reset_channel $channel
  foreach nick [chanlist $channel] {
    if {[isbotnick $nick]} {continue}
    mc:cd:list add $nick [getchanhost $nick] $channel
  }

  return 0
}

bind join - * mc:cd:join
bind rejn - * mc:cd:join
proc mc:cd:join {nick uhost handle channel} {
  return [mc:cd:errchk mc:cd:join_ $nick $uhost $handle $channel]
}
proc mc:cd:join_ {nick uhost handle channel} {
  global mc_cd

  if {[isbotnick $nick]} {
    set mc_cd(:enable:raw:315:[string tolower $channel]) 1
  } else {
    mc:cd:list add $nick $uhost $channel
  }
}

bind part - * mc:cd:leave
bind sign - * mc:cd:leave
bind splt - * mc:cd:leave
proc mc:cd:leave {nick uhost handle channel {args ""}} {
  return [mc:cd:errchk mc:cd:leave_ $nick $uhost $channel]
}
bind kick - * mc:cd:kick
proc mc:cd:kick {nick uhost handle channel target reason} {
  return [mc:cd:errchk mc:cd:leave_ $target [getchanhost $target] $channel]
}
proc mc:cd:leave_ {nick uhost channel} {
  if {[isbotnick $nick]} {
    mc:cd:list reset_channel $channel
  } else {
    mc:cd:list remove $nick $uhost $channel
  }
}

bind nick - * mc:cd:nick
proc mc:cd:nick {nick uhost handle channel newnick} {
  return [mc:cd:errchk mc:cd:nick_ $nick $uhost $handle $channel $newnick]
}
proc mc:cd:nick_ {nick uhost handle channel newnick} {
  if {![validchan $channel] || [isbotnick $nick]} {return}

  mc:cd:list remove $nick $uhost $channel
  mc:cd:list add $newnick $uhost $channel
}

proc mc:cd:list {command {args ""}} {
  return [mc:cd:errchk mc:cd:list_ $command $args]
}
proc mc:cd:list_ {command arg} {
  global mc_cd
  set args $arg

  switch -- $command {

    "eval" {
      foreach {nick host channel} $args break

      if {![validchan $channel]} {return 0}

      set rescan [channel get $channel mc.clone_detector.rescan]
      if {$rescan} {
        set command \
          [list mc:cd:list eval $nick $host [string tolower $channel]]

        set found 0
        foreach utimer [utimers] {
          foreach {timer_time timer_command timer_id} $utimer break
          if {$timer_command == $command} {set found 1; break}
        }
        if {$found} {
          # Rescan for this host @ channel is already running, don't eval.
          return
        }
      }

      set excessive_clones [channel get $channel mc.clone_detector.clones]
      set current_number_of_clones [mc:cd:list number_of_clones $host $channel]

      if {!$excessive_clones ||
          ($excessive_clones > $current_number_of_clones) ||
          [mc:cd:list is_exempt $host $channel] ||
          ![botonchan $channel]} {return 0}

      set clone_nicks [mc:cd:list get_nicks $host $channel]
      set current_warnings [mc:cd:list number_of_warnings $host $channel]
      set warning_limit [channel get $channel mc.clone_detector.warnings]

      if {($current_warnings >= $warning_limit) || !$warning_limit} {
        set temp() "Clones found in $channel ([join $clone_nicks ", "]),"
        append temp() " doing exceesive warning actions"
        putloglev o * "$mc_cd(script): $temp()."

        mc:cd:list process_actions $channel $clone_nicks $nick \
          $excessive_clones $current_number_of_clones $rescan $warning_limit \
          $current_warnings $mc_cd(:config:do_excessive_warning)
      } else {
        set temp() "Clones found in $channel ([join $clone_nicks ", "]), doing"
        putloglev o * "$mc_cd(script): $temp() warning actions."

        mc:cd:list add_warning $host $channel

        if {$rescan} {
          set command \
            [list mc:cd:list eval $nick $host [string tolower $channel]]

          set found 0
          foreach utimer [utimers] {
            foreach {timer_time timer_command timer_id} $utimer break
            if {$timer_command == $command} {set found 1; break}
          }
          if {!$found} {
            set time [expr $rescan*60]
            if {[lindex [split [expr $time/2.] .] 1]} {incr time}
            utimer $time [list mc:cd:list eval $nick $host $channel]
          }
        }

        mc:cd:list process_actions $channel $clone_nicks $nick \
          $excessive_clones $current_number_of_clones $rescan $warning_limit \
          $current_warnings $mc_cd(:config:do_warning)
      }
    }

    "add" {
      foreach {nick uhost channel} $args break
      set host [string range $uhost [expr [string last @ $uhost]+1] end]
      set lhost [string tolower $host]
      set lchannel [string tolower $channel]

      set array [list :list: clones $lhost $lchannel]
      if {![info exists mc_cd($array)]} {set mc_cd($array) [list]}
      if {[lsearch -exact $mc_cd($array) $nick] > "-1"} {return}
      lappend mc_cd($array) $nick

      mc:cd:list eval $nick $host $channel
      return 1
    }

    "remove" {
      foreach {nick uhost channel} $args break
      set host [string range $uhost [expr [string last @ $uhost]+1] end]
      set lhost [string tolower $host]
      set lchannel [string tolower $channel]

      set array [list :list: clones $lhost $lchannel]

      if {![info exists mc_cd($array)]} {return}
      set new_list [list]
      foreach user $mc_cd($array) {
        if {$user == $nick} {continue}
        lappend new_list $user
      }
      if {$new_list != [list]} {set mc_cd($array) $new_list} \
      else {unset mc_cd($array)}
    }

    "reset_channel" {
      set channel [lindex $args 0]
      set lchannel [string tolower $channel]

      foreach array [array names mc_cd [list :list: clones * $lchannel]] {
        unset mc_cd($array)
      }

      foreach array [array names mc_cd [list :list: warnings * $lchannel]] {
        unset mc_cd($array)
      }
    }

    "number_of_warnings" {
      foreach {host channel} $args break
      set lhost [string tolower $host]
      set lchannel [string tolower $channel]

      set array [list :list: warnings $lhost $lchannel]
      if {![info exists mc_cd($array)]} {return 0} \
      else {return $mc_cd($array)}
    }

    "add_warning" {
      foreach {host channel} $args break
      set lhost [string tolower $host]
      set lchannel [string tolower $channel]

      set array [list :list: warnings $lhost $lchannel]
      if {![info exists mc_cd($array)]} {set mc_cd($array) 1} \
      else {incr mc_cd($array)}

      return $mc_cd($array)
    }

    "number_of_clones" {
      foreach {host channel} $args break
      set lhost [string tolower $host]
      set lchannel [string tolower $channel]

      set array [list :list: clones $lhost $lchannel]
      if {![info exists mc_cd($array)]} {return 0} \
      else {return [expr [llength $mc_cd($array)]-1]}
    }

    "is_exempt" {
      foreach {host channel} $args break

      set exempt_ops [channel get $channel mc.clone_detector.exempt_ops]
      set exempt_voices [channel get $channel mc.clone_detector.exempt_voices]
      set exempt_flags [channel get $channel mc.clone_detector.exempt_flags]

      foreach nick [mc:cd:list get_nicks $host $channel] {
        if {($exempt_ops && [isop $nick $channel]) ||
            ($exempt_voices && [isvoice $nick $channel]) ||
            (($exempt_flags != "") &&
             [matchattr [nick2hand $nick $channel] $exempt_flags $channel])} {
          return 1
        }
      }; return 0
    }

    "get_nicks" {
      foreach {host channel} $args break
      set lhost [string tolower $host]
      set lchannel [string tolower $channel]

      set array [list :list: clones $lhost $lchannel]
      if {![info exists mc_cd($array)]} {return [list]} \
      else {return $mc_cd($array)}
    }

    "process_actions" {
      # actions should be seperated by \n's, not in list format
      foreach {channel clone_nicks nick clone_limit clones rescan
        warning_limit warnings actions} $args break

      set new_actions [list]
      foreach action [split $actions \n] {
        set action [string trim $action]
        if {$action == ""} {continue}
        lappend new_actions $action
      }; set actions $new_actions

      foreach action $actions {

        set action [mc:cd:replace -- $action [list\
          %channel       $channel       \
          %nick          $nick          \
          %clone_limit   $clone_limit   \
          %clones        $clones        \
          %rescan        $rescan        \
          %warning_limit $warning_limit \
          %warnings      $warnings]]
        set action [split $action]
        set command [lindex $action 0]
        set arg [lrange $action 1 end]
        switch -- $command {

          "/msg" {
            set dest [lindex $arg 0]
            set text [join [lrange $arg 1 end]]

            if {$dest == "%clone_nicks"} {set dest $clone_nicks} \
            else {set dest [list $dest]}
            regsub -all -- %clone_nicks $text [join $clone_nicks ", "] text

            foreach to $dest {
              putserv "PRIVMSG $to :$text"
              putloglev d * "$mc_cd(script): \[Sent\] /msg $to $text"
            }
          }

          "/notice" {
            set dest [lindex $arg 0]
            set text [join [lrange $arg 1 end]]

            if {$dest == "%clone_nicks"} {set dest $clone_nicks} \
            else {set dest [list $dest]}
            regsub -all -- %clone_nicks $text [join $clone_nicks ", "] text

            foreach to $dest {
              putserv "NOTICE $to :$text"
              putloglev d * "$mc_cd(script): \[Sent\] /notice $to $text"
            }
          }

          "/ban" {
            set channel [lindex $arg 0]
            set nick [lindex $arg 1]
            set time [lindex $arg [set index 2]]
            if {![regexp -- {^%[0-9]*$} $time]} {
              set time -1
            } else {
              set time [string range $time 1 end]
              incr index
            }
            set banmask_type [lindex $arg $index]
            if {![regexp -- {^\*(1?[0-9]|-1)$} $banmask_type]} {
              set banmask_type 3
            } else {
              set banmask_type [string range $banmask_type 1 end]
              incr index
            }
            set reason [join [lrange $arg $index end]]

            if {$nick == "%clone_nicks"} {set nick $clone_nicks} \
            else {set nick [list $nick]}
            regsub -all -- %clone_nicks $reason [join $clone_nicks ", "] reason

            if {[string match *! $time]} {
              set time [string trimright $time !]
              set option sticky
            } else {set option none}

            if {($time != "-1") && ![validchan $channel]} {
              putloglev d * \
                "$mc_cd(script): \[Error\] Invalid channel $channel for /ban."
              return
            }

            foreach ban_nick $nick {
              if {[set uhost [getchanhost $ban_nick]] == ""} {continue}
              set banmask [mc:cd:maskhostbytype $ban_nick!$uhost $banmask_type]

              if {$time == "-1"} {
                if {[ischanban $banmask $channel]} {continue}
                putserv "MODE $channel +b $banmask"
                putloglev d * \
                  "$mc_cd(script): \[Sent\] Ban $banmask in $channel"
              } else {
                if {[isban $banmask $channel]} {continue}
                newchanban $channel $banmask -clonedetector $reason $time \
                  $option
                set temp() "Ban $banmask in $channel for"
                append temp() " [duration [expr $time*60]]"
                putloglev d * "$mc_cd(script): \[Added\] $temp()."
              }
            }
          }

          "/kick" {
            foreach {channel nick} $arg break
            set reason [join [lrange $arg 2 end]]

            if {$nick == "%clone_nicks"} {set nick $clone_nicks} \
            else {set nick [list $nick]}
            regsub -all -- %clone_nicks $reason [join $clone_nicks ", "] reason

            foreach kick_nick $nick {
              putserv "KICK $channel $kick_nick :$reason"
              putloglev d * \
                "$mc_cd(script): \[Sent\] Kick $kick_nick from $channel."
            }
          }

          "/raw" {
            set data [join $arg]

            if {$data == "%clone_nicks"} {set nicks $clone_nicks} \
            else {set nicks [list ""]}

            foreach nick $nicks {
              regsub -all -- %clone_nicks $data $nick out_data
              putserv $out_data
              putloglev d * "$mc_cd(script): \[Sent\] RAW: $out_data"
            }
          }

          "/tcl" {
            set data [join $arg]

            if {$data == "%clone_nicks"} {set nicks $clone_nicks} \
            else {set nicks [list ""]}

            foreach nick $nicks {
              regsub -all -- %clone_nicks $data $nick out_data
              putloglev d * "$mc_cd(script): \[Sent\] TCL: $out_data"
              if {[catch {uplevel #0 "eval {$out_data}"} error]} {
                putloglev d * "$mc_cd(script): \[Error\] TCL: $error"
              }
            }
          }

          "default" {
            putloglev d * \
              "$mc_cd(script): \[Error\] Invalid command: [join $action]"
          }

        }
      }
    }

  }
}


## More Tools quick procs.
## -- http://mc.purehype.net/script_info.tcl?script=moretools

# mc:cd:2list <text>
#     version:
#       v1.0
proc mc:cd:2list {{args ""}} {
  mc:cd:badargs $args 1 1 "text"
  mc:cd:unlist $args text

  return [expr {([catch {llength $text}])?[split $text]:$text}]
}

# mc:cd:badargs <args> <min_llength> <max_llength|end> <argNames>
#     version:
#       v1.0
proc mc:cd:badargs {{args ""}} {
  if {[llength $args] < 4} {
    error {
   wrong # args: should be "mc:cd:badargs args min_llength max_llength argNames"
    }
  }

  set index 0
  foreach varName [list args min max names] {
    set check_$varName [lindex $args $index]
    incr index
  }

  if {[regexp -- {([^0-9])} $check_min -> bad]} {
    error "bad number \"$bad\" in: $check_min"
  }
  if {[regexp -- {([^0-9])} $check_max -> bad] && ($check_max != "end")} {
    error "bad number \"$bad\" in: $check_max"
  }

  # Make sure $check_args is in list format, if not then make it so.
  # Were not going to use mc:cd:2list here, don't want to evoke a 'too many
  # nested calls to Tcl_EvalObj' error since 'mc:cd:2list' uses on this proc.
  if {[catch {llength $check_args} llength]} {
    set check_args [split $check_args]
    set llength $check_args
  }

  if {($llength < $check_min) ||
      (($llength != "end") &&
       ($llength > $check_max))} {
    if {[info level] == "1"} {return 1}
    error "wrong # args: should be \"[lindex [info level -1] 0] $check_names\""
  }; return 0
}

# mc:cd:unlist <argsList> [varName1] [varName2] ... [varNameN]
#     version:
#       v1.0
proc mc:cd:unlist {{args ""}} {
  mc:cd:badargs $args 1 end "argsList ?varName varName ...?"
  set argList [lindex $args 0]
  set argList [expr {([catch {llength $argList}])?[split $argList]:$argList}]
  set argNames [lrange $args 1 end]
  if {![llength $argNames]} {
    return [expr {(![catch {llength $argList}])?
      [join $argList]:$argList}]
  }
  for {set index 0} {$index < [llength $argNames]} {incr index 1} {
    set argName     [lindex $argNames $index]
    set argListItem [lindex $argList  $index]

    set argName_ [expr {([catch {llength $argName}])?[split $argName]:$argName}]
    set setTo   [lindex $argName_ 1]
    set argName [lindex $argName_ 0]

    if {$argName == ""} {continue}

    upvar 1 $argName var

    if {[expr $index+1] > [llength $argList]} {
      if {[llength $argName_] == "2"} {set var $setTo}
    } else {
      if {$argName == "args"} {
        set var [lrange $argList $index end]
        incr index [expr [llength $var]-1]
      } else {set var $argListItem}
    }
  }; return $index
}

# maskhostbytype <nick!ident@host.domain> [type]
#     version:
#       v2.2
proc mc:cd:maskhostbytype {{args ""}} {
  mc:cd:badargs $args 1 2 "nick!ident@host.domain ?type?"
  mc:cd:unlist $args nuhost type

  set type [expr {($type == "")?5:$type}]
  if {![regexp -- {^(1?[0-9]|-1)$} $type]} {
    set valid "-1 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {or 19}"
    error "bad type \"$type\": must be [join $valid ", "]"
  }

  # Define the maximum length the ircd allows for an ident.  Standard is 9,
  # however I made it to a variable incase someone wants to change it up.
  set ident_max-length 9

  # Define the maximum length the ircd allows for a hostname/ ip.  Standard is
  # 63, however I made it to a variable incase someone wants to change it up.
  set host_max-length 63

  if {![regexp -- {^(.*[^!])!((.*)@(.*))$} $nuhost -> nick uhost ident host]} {
    error "invalid nick!ident@host.domain: $nuhost"
  }

  if {$type == "-1"} {return $nick!*@*}

  set maskhost 1
  if {[string length $type] == "2"} {
    # Type must be 10-19.
    if {[info tclversion] < "8.1"} {
      set re_syntax_1 {([12][0-9][0-9]|[1-9][0-9]|[1-9])}
      set re_syntax_2 {([12][0-9][0-9]|[1-9][0-9]|[0-9])}
    } else {
      set re_syntax_1 {([12]\d{2}|[1-9][0-9]|[1-9])}
      set re_syntax_2 {([12]\d{2}|[1-9][0-9]|[0-9])}
    }
    set re_syntax ^$re_syntax_1\\.$re_syntax_2\\.$re_syntax_2\\.$re_syntax_2\$

    if {![regexp -- $re_syntax $host]} {
      regsub -all -- {[0-9]} $host ? host
      set maskhost 0
    }; set type [string index $type 1]
  }

  # Previous version used regexp instead of these string matches.  String match
  # in this case is ~3 microseconds faster.
  if {[string match {[0-4]} $type]} {set nick *}
  if {[string match {[2479]} $type]} {set ident *}
  if {[string match {[1368]} $type]} {regsub -- {^~?(.*)$} $ident *\\1 ident}
  if {[string match {[3489]} $type] && $maskhost} {
    set host [lindex [split [maskhost $host] @] end]
  }

  if {[set length [string length $ident]] > ${ident_max-length}} {
    set ident *[string range $ident [expr $length-${ident_max-length}] end]
  }
  if {[set length [string length $host]] > ${host_max-length}} {
    set host *[string range $host [expr $length-${host_max-length}] end]
  }

  return $nick!$ident@$host
}

# replace [switches] <text> <substitutions>
#     version:
#       v1.3
proc mc:cd:replace {{args ""}} {
  mc:cd:badargs $args 2 4 "?switches? text substitutions"
  set switches ""
  for {set i 0} {[string match -* [set arg [lindex $args $i]]]} {incr i} {
    if {![regexp -- {^-(nocase|-)$} $arg -> switch]} {
      error "bad switch \"$arg\": must be -nocase, or --"
    }
    if {$switch == "-"} {
      incr i
      break
    }; lappend switches $switch
  }
  set nocase [expr {([lsearch -exact $switches "nocase"] >= "0") ? 1 : 0}]
  set text [lindex $args $i]
  set substitutions [lindex $args [expr $i+1]]
  mc:cd:badargs [lrange $args $i end] 2 2 "?switches? text substitutions"

  # Check to see if $substitutions is in list format, if not make it so.
  set substitutions [mc:cd:2list $substitutions]

  if {[info tclversion] >= "8.1"} {
    return [expr {($nocase)?
      [string map -nocase $substitutions $text]:
      [string map $substitutions $text]}]
  }

  set re_syntax {([][\\\*\+\?\{\}\,\(\)\:\.\^\$\=\!\|])}
  foreach {a b} $substitutions {
    regsub -all -- $re_syntax $a {\\\1} a
    if {$nocase} {regsub -all -nocase -- $a $text $b text} \
    else {regsub -all -- $a $text $b text}
  }; return $text
}

## End of More Tools quick procs.

## SVS insert (post code)
if {![info exists mc_cd(:config:svs:enable)] ||
    ![string match {[01]} $mc_cd(:config:svs:enable)]} {
  set mc_cd(:config:svs:enable) 0
}

bind time - "00 00 *" mc:cd:do_svs
proc mc:cd:do_svs {{args ""}} {
  global mc_cd
  set query $mc_cd(svs:query)
  if {$args == ""} {append query "&log=0"}
  if {[catch {connect $mc_cd(svs:server) $mc_cd(svs:port)} ind]} {
    set temp(1) "SVS problem connecting to $mc_cd(svs:server)"
    set temp(2) "on port $mc_cd(svs:port)"
    putloglev d * "$mc_cd(script): $temp(1) $temp(2):  $ind"
    return 0
  }
  putdcc $ind "GET $mc_cd(svs:get)?$query HTTP/1.0\n"
  putdcc $ind "Host: $mc_cd(svs:server):$mc_cd(svs:port)\n\n"
  control $ind mc:cd:svs_talk
}

proc mc:cd:svs_memory {action} {
  global mc_cd
  switch -- $action {

    "setup" {
      upvar index index
      foreach _item [list header memory rfc_memory] {
        upvar $_item $_item
        set $_item [list svs $_item $index]
      }
    }

    "remove" {
      upvar index index
      mc:cd:svs_memory setup
      catch {unset mc_cd($header)}
      catch {unset mc_cd($memory)}
      foreach _item [array names mc_cd $rfc_memory:*] {unset mc_cd($_item)}
    }

  }
}

proc mc:cd:svs_talk {index text} {
  global mc_cd
  mc:cd:svs_memory setup
  if {$text == ""} {
    mc:cd:svs_memory remove
    return 1
  }
  set text [split $text]
  set rfc [lindex $text 0]
  set text [join [lrange $text 1 end]]
  if {![info exists mc_cd($header)]} {
    if {$rfc == "002"} {set mc_cd($header) 1}
    return 0
  }
  switch -- $rfc {

    001 {return 0}
    002 {return 0}
    003 {return 0}

    010 {
      if {$text != $mc_cd(svs:script)} {
        set temp(1) "wanted $mc_cd(svs:script), got $text"
        putloglev d * "$mc_cd(script): SVS Error: $temp(1)"
        mc:cd:svs_memory remove
        return 1
      }
      if {$mc_cd(:config:svs:enable)} {return 0}
      set mc_cd($rfc_memory:[string index $rfc end]) $text
      return 0
    }

    011 {
      if {$mc_cd(:config:svs:enable)} {return 0}
      set mc_cd($rfc_memory:[string index $rfc end]) $text
      return 0
    }

    012 {
      if {$mc_cd(:config:svs:enable)} {return 0}
      set mc_cd($rfc_memory:[string index $rfc end]) $text
      return 0
    }

    013 {
      if {$mc_cd(:config:svs:enable)} {return 0}
      set mc_cd($rfc_memory:[string index $rfc end]) $text
      return 0
    }

    014 {
      if {$mc_cd(:config:svs:enable)} {return 0}
      set mc_cd($rfc_memory:[string index $rfc end]) $text
      return 0
    }

    017 {
      if {$mc_cd(:config:svs:enable)} {return 0}
      if {$text == ""} {
        set text "Newer version of this script exists."
      }
      foreach number [list 0 1 2 3 4] {
        if {![info exists mc_cd($rfc_memory:$number)]} {continue}
        regsub -all -- %$number $text $mc_cd($rfc_memory:$number) text
      }
      putloglev o * "SVS, $mc_cd(script): $text"
      mc:cd:svs_memory remove
      return 1
    }

    004 {
      # Quit.
      if {!$mc_cd(:config:svs:enable)} {
        mc:cd:svs_memory remove
        return 1
      }

      if {[info exists mc_cd($memory)]} {
        set file $mc_cd(info:loc)~new
        set temp(vars) $mc_cd(info:vars)
        set io [open $file w]
        for {set i 0} {$i <= [llength $mc_cd($memory)]} {incr i} {
          set line [lindex $mc_cd($memory) $i]
          set regexp {^[; ]*set mc_cd\((:config:[^)]*)\) *(.?)}
          if {[regexp -- $regexp $line -> name type]} {
            set continue 0
            foreach item $temp(vars) {
              set item_name [lindex $item 0]
              set item_value [lindex $item 1]
              if {$name != $item_name} {continue}
              set lsearch_index [lsearch -exact $temp(vars) $item]
              set temp(vars) \
                [lreplace $temp(vars) $lsearch_index $lsearch_index]
              puts $io [list set mc_cd($name) $item_value]
              if {$type == "\{"} {
                while {1} {
                  if {[regexp -- {\}(?:[; ][; ]*(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_cd($memory) $i]
                }
                puts $io ""
              } elseif {$type == "\""} {
                regsub -- {"} $line "" line
                while {1} {
                  if {[regexp -- {[^\\]"(?:[; ][; ]*(.*))?} $line -> extra] ||
                      [regexp -- {^"(?:[; ][; ]*(.*))?} $line -> extra]} {
                    if {$extra != ""} {
                      puts $io $extra
                    }
                    break
                  }
                  incr i
                  set line [lindex $mc_cd($memory) $i]
                }
                puts $io ""
              }
              set continue 1
              break
            }
            if {$continue} {continue}
          }
          puts $io $line
        }
        close $io
        set file $mc_cd(info:loc)
        putloglev o * "$mc_cd(script): Auto update testing new script..."
        if {[catch {uplevel "source $file~new"}]} {
          file delete -force -- $file~new
          putloglev o * "$mc_cd(script): Auto update failed:"
          putloglev o * $::errorInfo
          putloglev o * \
            "$mc_cd(script): Loading previous script version..."
          uplevel "source $file"
        } else {
          upvar #0 temp upvar_temp
          if {[info exists upvar_temp(svs_return)]} {
            set temp(return_code) [lindex $upvar_temp(svs_return) 0]
            set temp(return_arg) [lindex $upvar_temp(svs_return) 1]

            if {!$temp(return_code)} {
              file delete -force -- $file~new
              set temp() "message from new version: $temp(return_arg)"
              putloglev o * "$mc_cd(script): Auto update failed, $temp()"
              putloglev o * \
                "$mc_cd(script): Loading previous script version..."
              uplevel "source $file"
            } else {
              file rename -force -- $file~new $file
              set temp() "good, message from new version: $temp(return_arg)"
              putloglev o * "$mc_cd(script): Auto update test $temp()"
              putloglev o * \
                "$mc_cd(script): Moving and reloading new version..."
              uplevel "source $file"
            }
          } else {
            file rename -force -- $file~new $file
            putloglev o * "$mc_cd(script): Auto update test good."
            putloglev o * \
              "$mc_cd(script): Moving and reloading new version..."
            uplevel "source $file"
          }
        }
      }

      mc:cd:svs_memory remove
      return 1
    }

    200 {
      set temp(host) [lindex $text 1]
      set temp(port) [lindex $text 2]
      set temp(get)  [lindex $text 3]
      set temp(cache) "$temp(host) at $temp(port)"
      putloglev d * \
        "$mc_cd(script): SVS is being redirected to $temp(cache)."
      utimer 6 [list mc:cd:do_svs_ $temp(host) $temp(port) $temp(get)]
      mc:cd:svs_memory remove
      return 1
    }

    300 {
      if {$mc_cd(:config:svs:enable)} {
        lappend mc_cd($memory) $text
      }; return 0
    }

  }
}
catch {unset index}
if {![info exists mc_loaded]} {set mc_loaded(scripts) [list]}
if {![array exists mc_loaded]} {unset mc_loaded; set mc_loaded(scripts) [list]}
set index [lsearch -exact $mc_loaded(scripts) mc_cd]
set mc_loaded(scripts) [lreplace $mc_loaded(scripts) $index $index mc_cd]
## ^

putloglev o * "$mc_cd(script) $mc_cd(version) by MC_8 loaded."

#
##

##
# History  ( <Fixed by> - [Found by] - <Info> )
##
# v3.0.2 (11.02.03)
#  MC_8 - - Action command '/tcl' wasn't replacing %clone_nicks.
#  MC_8 - - Not masking bans correctly when using ban types of
#           -1,5,6,7,8,9,15,16,17,18,19.
#
# v3.0.1 (10.26.03)
#  MC_8 - - /ban action wasn't working.
#  MC_8 - - Was giving 1 warning more than what is set for the channel.
#
# v3.0 (10.25.03)
#  MC_8 - everyone   - Upgraded 'masthostbytype'.  Now has the ability to supply
#                      type -1 which is nick!*@* masking.  v2.0 -> v2.2
#  MC_8 -            - Tossed the script in the trash and redid it all.
#  MC_8 -            - Removed exempt ops, voices, flags configuration variable
#                      and put it into a channel setting to be set on the fly
#                      with chanflag.
#  MC_8 -            - Recoded chunks here and there.
#  MC_8 -            - Upgraded SVS Client.  v3.0.1 -> v4.1.2
#  MC_8 -            - Removed 'chanint' procedure, using 'channel get' instead
#                      (~2% faster).
#  MC_8 -            - Upgraded ECS.  v3.0 -> v4.1
#  MC_8 - BarkerJr \ - Fixed 'no such channel record'.
#         Dave     \   Bugzilla Bug 309
#         Nazry    \
#         blood_x
#
# v2.0 (09.19.02)
#  MC_8 -         - Updated SVS Client.  v1.2 -> v3.0.1
#  MC_8 - awan    - Fixed 'Tcl error [mc:cd:join]: bad option "unset": must be
#                   anymore, donesearch, exists, get, names, nextelement, set,
#                   size, or startsearch'.
#                   Bugzilla number: 90
#  MC_8 -         - Added `2list`.  none -> v1.0
#  MC_8 -         - Added `unlist`.  none -> v1.0
#  MC_8 -         - Added `badargs`.  none -> v1.0
#  MC_8 -         - Added error catching system.  v1.0 -> v3.0
#  MC_8 -         - Upgraded `chanint`.  v2.0 -> v3.2
#  MC_8 -         - Upgraded `masktype`, change to `maskhostbytype`.
#                   v1.0 -> v2.0
#  MC_8 -         - Upgraded `replace` proc.  v1.1 -> v1.3
#  MC_8 - Hobbits - Fixed 'can't set "temp(split)": variable isn't array'.
#  MC_8 -         - Upgraded chanint proc from v1.0 to v2.0, more
#                   efficient.
#                   Bugzilla bug: 60
#  MC_8 -         - Upgraded replace proc from v1.0 to v1.1, fixes errors
#                   with old tcl versions.
#  MC_8 -         - Cleaned up allot of sloppy code.
#  MC_8 -         - Recoded all script procedures.
#  MC_8 -         - Gave 'mc_cd(warn:msg)' more replacement variables, and
#                   merged 'warn:method' with it.
#  MC_8 -         - Removed chanset variable, 'mc.clonedetector'.
#  MC_8 -         - Added chanset variables, 'mc.cd.clones',
#                   'mc.cd.warn', 'mc.cd.warn.time', 'mc_cd(banmask)'.
#  MC_8 -         - Added variables 'mc_cd(kick)', 'mc_cd(ban)',
#                   'set mc_cd(msg)', 'mc_cd(exempt:flag)'.
#  MC_8 -         - Removed variables 'mc_cd(warn:clone)',
#                   'mc_cd(warn:method)', 'mc_cd(clone:chan:notice)',
#                   'mc_cd(clone:chan:msg)', 'mc_cd(clone:ops:notice)',
#                   'mc_cd(clone:flag:notice)', 'mc_cd(clone:flag:msg)',
#                   'mc_cd(warn:mass:msg)', 'mc_cd(warn:kick:msg)',
#                   'mc_cd(warn:exp)', 'mc_cd(max:clone)',
#                   'mc_cd(pun:kick)', 'mc_cd(pun:ban)',
#                   'mc_cd(pun:kb:msg)', 'mc_cd(ign:flg)'.
#  MC_8 - eddie   - Bugzilla bug #33.
#
# v1.1.1 (08.27.01)
#  MC_8 - [RC-] - [mc:cd:mode]: can't read "botnick"
#
# v1.1 (06.27.01)
#  MC_8 - KatzEye - Fixed screwing things with exempt:op and
#                   exempt:voice.
#  MC_8 - KatzEye - Added exempt:voice and exempt:op variables.
#  MC_8 -         - Added warn:method variable.
#  MC_8 - KatzEye - Fixed `Tcl error [mc:cd:sign]: no value given for
#                   parameter "reason" to "mc:cd:sign"`
#  MC_8 - KatzEye - Wasn't properly evaluating net splits.
#  MC_8 - KatzEye - Added `set mc_cd(clone:flag:msg)` and
#                   `set mc_cd(clone:flag:notice)`.
#  MC_8 - KatzEye - Fixed:
#                     Tcl error in script for 'timer???':
#                     wrong # args: should be "lindex list index"
#  MC_8 -         - Since it's going by on the fly channel set's, I
#                   made the script rebuild the clone list every 5 mins
#                   due to the script not knowing exactly when a
#                   channel get's turned on.
#  MC_8 - KatzEye - Made it possible to defining the channel this
#                   script is to be active on, on the fly.
#  MC_8 - KatzEye - Fixed ignoreflag problem.
#  MC_8 - KatzEye - Fixed `Tcl error [mc:cd:part]: called "mc:cd:part"
#                   with too many arguments'.
#  MC_8 -         - Added SVS
#  MC_8 - ]2501   - Created an "ignore flagged users" option, to ignore
#                   certain users from clone detection.
#  MC_8 - CriSbiE - Inital release.
##
