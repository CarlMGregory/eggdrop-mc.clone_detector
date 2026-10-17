##
# Clone Detector v2.0
#  by MC_8 - Carl M. Gregory <mc8@purehype.net>
#  This script will only run on eggdrop 1.5.5 or greater.
#
#    R.I.P. Mom, To always be remembered; Nancy Marie Gregory.
#
# My SVS Website - http://mc.purehype.net:81/
# Have a bug?  http://mc.purehype.net:81/bugzilla/
##

##
# This script will watch over any given channels to ensure that excessive clones are
# not sitting in the channel.
##

##
# History has been moved to the bottom of the file.
##

##
# Commands
##
# DCC:
#  chanset <#channel> mc.cd.clones <number>
#     Change this to the number of clones not allowed in the specific channel.
#     Setting this to 0, default, will disable the script for the specific channel.
#     Note, 3 users on the same host/ip is not considered 3 clones.  It's considered
#     2 clones, and 1 original user.
#
#  chanset <#channel> mc.cd.warn <number>
#     Change this to the number of warnings you want to give the user if clones is
#     greater than or equal to mc.cd.clones.  Set this to 0, default, to give no
#     warnings.
#
#  chanset <#channel> mc.cd.warn.time <number>
#     If mc.cd.warn isn't set to 0, set this to the number of min's you want to give
#     the user before you do a re scan to see if he has clones in the channel.  By
#     setting this to 0, default, you will disable re scan -- meaning the only way
#     the script can proceed to a further punishment or another warning (if more
#     warnings available for the user) is if the user brings in yet another clone.
##

##
# Settings
##

# [0=no/1=yes] Do you want to exempt users that are op'd, +o, from this script?  The
# user must gain op status within 5 seconds of join'n.
set mc_cd(exempt:op) 0

# [0=no/1=yes] Do you want to exempt users that are voiced, +v, from this script?
# The user must gain voice status within 5 seconds of join'n.
set mc_cd(exempt:voice) 0

# What flagged users are exempt from this script?  Set this to "" to disable this
# function.  Flag structure: <global>|<channel>
set mc_cd(exempt:flag) "bmno|mno"

# Upon warning a user for excessive clones, what do you want the warning message to
# the user (and clones) to say?  The first word should be the message type, such as
# NOTICE or PRIVMSG.  Set this to "" to disable this function.
# Replacment variables:
#      %channel = The channel in which the user is in.
#         %nick = IRC nickname of the user that is in violation of idle.
#        %ident = Ident of the user that is in violation of idle.
#         %host = Hostname of the user that is in violation of idle.
#       %clones = The clone limit for the channel.
#        %clone = Number of clones the user has in the channel.
#       %rescan = Min's before rescan.
#     %warnings = Maximum number of warnings allowed.
#      %warning = Current number of warnings the user has received, counting this
#                 one.
set mc_cd(warn:msg) "PRIVMSG You have %clone clones in %channel, the clone limit is %clones.  You have %rescan min's to resolve this.  Warning %warning or %warnings!"

# [0=no/1=yes/2] Upon warning the user for excessive clones, do you want to kick the
# user and all of his/her clones from the channel?  The kick message will be pulled
# from the above setting, mc_cd(warn:msg).  If mc_cd(warn:msg) is set to "",
# disabled, the kick message will default to "Clone Detector".
# Note:  If you set this to 2, it will kick all of the users' clones but not the
#        user.
set mc_cd(warn:kick) 0

# After warnings have been exceeded for the user due to excess clones, what do you
# want the message to the user (and clones) to say?  The first word should be the
# message type, such as NOTICE or PRIVMSG.  Set this to "" to disable this function.
# Replacment variables:
#      %channel = The channel in which the user is in.
#         %nick = IRC nickname of the user thats in violation of idle.
#        %ident = Ident of the user thats in violation of idle.
#         %host = Hostname of the user thats in violation of idle.
#       %clones = The clone limit for the channel.
#        %clone = Number of clones the user has in the channel.
#       %rescan = Min's before rescan.
#     %warnings = Maximum number of warnings allowed.
#      %warning = Current number of warnings the user has received, counting this
#                 one.
set mc_cd(msg) "PRIVMSG You have %clone clones in %channel, the clone limit is %clones.  You were already warned %warnings times."

# [0=no/1=yes/2] After warnings have been exceeded for the user due to excess clones,
# do you want to kick the user and all of his/her clones from the channel?  The kick
# message will be pulled from the above setting, mc_cd(msg).  If mc_cd(msg) is set to
# "", disabled, the kick message will default to "Clone Detector".
# Note:  If you set this to 2, it will kick all of the users' clones but not the
#        user.
set mc_cd(kick) 2

# After warnings have been exceeded for the user due to excess clones, how long do
# you want the user to be banned?
#  -1 = Don't ban.
#   0 = Server ban, not an actual ban entry in the bot.
#  >0 = Any number above 0 is considered the number of min's the user is banned in
#       the bot's banlist.
#  Put an '!' in front of the number to make the ban sticky, ie set mc_cd(ban) !30
#  Put an '@' at the end of the number to show that you only want to ban the clones
#  and not the user, ie set mc_cd(ban) !30@
set mc_cd(ban) 1440@

# If you have chosen to ban the user in violation of excess clones, the above
# setting, then how do you want to mask the ban?
#      0 - *!user@host.domain
#      1 - *!*user@host.domain
#      2 - *!*@host.domain
#      3 - *!*user@*.domain
#      4 - *!*@*.domain
#      5 - nick!user@host.domain
#      6 - nick!*user@host.domain
#      7 - nick!*@host.domain
#      8 - nick!*user@*.domain
#      9 - nick!*@*.domain
#     You can also specify a type of 10 to 19 which correspond to masks 0 to 9.  But
#     if the host.domain is a;
#       hostname = Instead of using a * wildcard to replace portions of the
#                  host.domain, it replaces the numbers in the host.domain with a '?'
#                  (question mark) wildcard.
#       ip       = It will mask as normal, with no '?' (question mark) replacements
#                  as does hostname.
set mc_cd(banmask) 3


## SVS Client (Script Version Service) v3.0.1 ##
# Once a day, the SVS Client will connect to MC_8's SVS Server to determine if there
# is a newer version of this script available.  This will only notify users of the ne
# version via a note.  It's up to the owner of the bot to download, adjust settings
# then install the script.

# If a newer version is found, whom do you want to notify?  The notification is sent
# via a note.  Seperate each user with a space, or set this to "" to disable SVS
# notification.  For those whom know TCL; do not put this in list format, keep it in
# string format.
set mc_cd(svs:notify) "MC_8"

# Would you like to restrict the concept of a new version to stable releases only?
#   0 = No, inform of both stable and beta release versions.
#   1 = Yes, inform of only stable release versions.
set mc_cd(svs:mode) 0


##
# TCL Coding below, do not proceed.
##

#Script:mc_cd

set mc_cd(script)      "Clone Detector"
set mc_cd(version)     "v2.0"
set mc_cd(svs:script)  "clonedetector"
set mc_cd(svs:version) "002000000000"
set mc_cd(svs:server)  "mc.purehype.net"
set mc_cd(svs:port)    "81"
set mc_cd(svs:get)     "/svs_client_interface.tcl"
set mc_cd(svs:query)   "svs=$mc_cd(svs:script)&version=$mc_cd(svs:version)"

catch {unset temp}
if {![info exists numversion] || ($numversion < "1050500")} {
	set temp(tag) "$mc_cd(script) $mc_cd(version)"
	putlog "$temp(tag) by MC_8 will only work on eggdrop 1.5.5 or greater."
	putlog "$temp(tag)  will not work with eggdrop $version."
	putlog "$temp(tag)  not loaded."
	return 1
}

setudef int mc.cd.clones
setudef int mc.cd.warn
setudef int mc.cd.warn.time


# Error system, v3.0
proc mc:cd:error {command error arg} {
	global mc_cd version lastbind errorInfo
	putlog "Error in script $mc_cd(script) $mc_cd(version)."
	putlog "    Error System: v3.0"
	putlog "       Last Bind: [expr {[info exists lastbind] ? $lastbind : "-NULL-"}]"
	putlog "         Command: $command"
	putlog "       Arguments: $arg"
	putlog "       Error Msg: $error"
	putlog "    Egg. Version: [expr {[info exists version] ? $version : "-NULL-"}]"
	putlog "     TCL Version: [info tclversion]"
	putlog "  TCL Patchlevel: [info patchlevel]"
	putlog "*** Please submit this bug so MC_8 can fix it.  Visit"
	putlog "*** http://mc.purehype.net:81/bugzilla/ to properly report the bug."
	putlog "*** Please include ALL info. in the bug report, including the next(s)."
	error $errorInfo
}

proc mc:cd:errchk {command arg} {
	if {![catch {eval $command $arg} return]} {return $return}
	mc:cd:error $command $return $arg
	return 0
}
# ^


bind join - * mc:cd:join
proc mc:cd:join {nick uhost hand chan {a 0}} {
	return [mc:cd:errchk mc:cd:join_ [list $nick $uhost $hand $chan $a]]
}
proc mc:cd:join_ {nick uhost hand chan {a 0}} {
	global botnick
	if {($a) && ([onchan $nick $chan])} {mc:cd:list add $nick $uhost $chan} \
	elseif {[isbotnick $nick]} {
		mc:cd:list reset_channel * * $chan
		set temp(chanlist) [chanlist $chan]
		set temp(lsearch) [lsearch -exact $temp(chanlist) $botnick]
		foreach nick [lreplace $temp(chanlist) $temp(lsearch) $temp(lsearch)] {
			mc:cd:join $nick [getchanhost $nick $chan] [nick2hand $nick $chan] $chan
		}; unset temp
	} elseif {[onchan $nick $chan]} {
		utimer 5 [list mc:cd:join $nick $uhost $hand $chan 1]
	}
}

bind rejn - * mc:cd:rejn
proc mc:cd:rejn {nick uhost hand chan} {mc:cd:join $nick $uhost $hand $chan}

bind part - * mc:cd:part
proc mc:cd:part {nick uhost hand chan msg} {mc:cd:list remove $nick $uhost $chan}

bind sign - * mc:cd:sign
proc mc:cd:sign {nick uhost hand chan reason} {mc:cd:list remove $nick $uhost $chan}

bind kick - * mc:cd:kick
proc mc:cd:kick {nick uhost hand chan target reason} {
	mc:cd:list remove $target [getchanhost $target $chan] $chan
}

bind nick - * mc:cd:nick
proc mc:cd:nick {nick uhost hand chan newnick} {
	mc:cd:list remove $nick $uhost $chan
	mc:cd:list add $newnick $uhost $chan
}

bind splt - * mc:cd:splt
proc mc:cd:splt {nick uhost hand chan} {mc:cd:list remove $nick $uhost $chan}

proc mc:cd:list {function nick uhost chan {a ""} {b ""} {c ""}} {
	return [mc:cd:errchk mc:cd:list_ [list $function $nick $uhost $chan $a $b $c]]
}
proc mc:cd:list_ {function nick uhost chan {a ""} {b ""} {c ""}} {
	global mc_cd botnick
	set temp(split) [split $uhost @]
	set ident [join [lrange $temp(split) 0 [expr [llength $temp(split)]-2]] @]
	set host [lindex $temp(split) [expr [llength $temp(split)]-1]]; unset temp
	set cache(lhost) [string tolower $host]
	set cache(lchan) [string tolower $chan]
	set cache(list:array) ::list::$cache(lhost)::$cache(lchan)::
	set cache(warn:array) ::warn::$cache(lhost)::$cache(lchan)::
	switch -- $function {
		add {
			lappend mc_cd(::list::$cache(lhost)::$cache(lchan)::) $nick
			mc:cd:list eval $nick $uhost $chan
			return 1
		}
		remove {
			if {(![info exists mc_cd($cache(list:array))]) ||
			    ([set temp() [lsearch -exact $mc_cd($cache(list:array)) $nick]] == "-1")} {
				return 0
			}
			set mc_cd($cache(list:array)) \
				[lreplace $mc_cd($cache(list:array)) $temp() $temp()]
			return 1
		}
		reset_channel {
			foreach temp(name) [array names mc_cd ::list::*::$cache(lchan)::] {
				unset mc_cd($temp(name))
			}
			foreach temp(name) [array names mc_cd ::warn::*::$cache(lchan)::] {
				unset mc_cd($temp(name))
			}
			return 1
		}
		number_of_clones {
			catch {set temp(clones) [expr [llength $mc_cd($cache(list:array))]-1]}
			if {(![info exists temp(clones)]) || ($temp(clones) == "-1")} {
				set temp(clones) 0
			}
			return $temp(clones)
		}
		number_of_warnings {
			if {![info exists mc_cd($cache(warn:array))]} {return 0}
			return $mc_cd($cache(warn:array))
		}
		add_warning {
			if {![info exists mc_cd($cache(warn:array))]} {set mc_cd($cache(warn:array)) 0}
			return [incr mc_cd($cache(warn:array))]
		}
		get_nicks {
			if {![info exists mc_cd($cache(list:array))]} {return ""}
			return $mc_cd($cache(list:array))
		}
		msg_all {
			if {$a == ""} {return 0}
			foreach nick [mc:cd:list get_nicks $nick $uhost $chan] {
				set uhost [getchanhost $nick $chan]
				set temp(split) [split $uhost @]
				set ident [join [lrange $temp(split) 0 [expr [llength $temp(split)]-2]] @]
				set host [lindex $temp(split) [expr [llength $temp(split)]-1]]
				putserv "$a $nick :[mc:cd:replace $b \
					[list %channel  $chan \
				        %nick     $nick \
				        %ident    $ident \
				        %host     $host \
				        %clones   [mc:cd:chanint $chan mc.cd.clones] \
				        %clone    [mc:cd:list number_of_clones $nick $uhost $chan] \
				        %rescan   [mc:cd:chanint $chan mc.cd.warn.time] \
				        %warnings [mc:cd:chanint $chan mc.cd.warn] \
				        %warning  [mc:cd:list number_of_warnings $nick $uhost $chan]]]"
			}; return 1
		}
		kick_all {
			if {!$a} {return 0}
			set temp(temp) [mc:cd:list get_nicks $nick $uhost $chan]
			if {$a == "2"} {
				foreach user $temp(temp) {
					lappend temp2 [list $user [getchanidle $user $chan]]
				}
				set temp(temp) [lrange [lsort -index 1 -dictionary $temp2] 1 end]
				unset temp2; set temp3 ""
				foreach temp2 $temp(temp) {lappend temp3 [lindex $temp2 0]}
				set temp(temp) $temp3; unset temp2 temp3
			}
			if {$b == ""} {set b $mc_cd(script)}
			foreach nick $temp(temp) {
				set uhost [getchanhost $nick $chan]
				set temp(split) [split $uhost @]
				set ident [join [lrange $temp(split) 0 [expr [llength $temp(split)]-2]] @]
				set host [lindex $temp(split) [expr [llength $temp(split)]-1]]
				# Using putquick because it goes thew the mode queue.  Were going to use
				# pushmode for the ban, another mode queue.  Good to keep kick and ban on the
				# same queue.
				putquick "KICK $chan $nick :[mc:cd:replace $b \
					[list %channel  $chan \
					      %nick     $nick \
					      %ident    $ident \
					      %host     $host \
					      %clones   [mc:cd:chanint $chan mc.cd.clones] \
					      %clone    [mc:cd:list number_of_clones $nick $uhost $chan] \
					      %rescan   [mc:cd:chanint $chan mc.cd.warn.time] \
					      %warnings [mc:cd:chanint $chan mc.cd.warn] \
					      %warning  [mc:cd:list number_of_warnings $nick $uhost $chan]]]"
			}; return 1
		}
		ban_all {
			if {[string trim $a !@] == "-1"} {return 0}
			if {[string match !* $a]} {
				set a [string range $a 1 end]; set option sticky
			} else {set option none}
			set temp(temp) [mc:cd:list get_nicks $nick $uhost $chan]
			if {[regexp -- {@$} $a]} {
				set a [string range $a 0 [expr [string length $a]-2]]
				foreach user $temp(temp) {
					lappend temp2 [list $user [getchanidle $user $chan]]
				}
				set temp(temp) [lrange [lsort -index 1 -dictionary $temp2] 1 end]
				unset temp2; set temp3 ""
				foreach temp2 $temp(temp) {lappend temp3 [lindex $temp2 0]}
				set temp(temp) $temp3; unset temp2 temp3
			}
			if {$b == ""} {set b $mc_cd(script)}; set already_banned ""
			foreach nick $temp(temp) {
				set uhost [getchanhost $nick $chan]
				set temp(split) [split $uhost @]
				set ident [join [lrange $temp(split) 0 [expr [llength $temp(split)]-2]] @]
				set host [lindex $temp(split) [expr [llength $temp(split)]-1]]
				set banmask [mc:cd:maskhostbytype $nick!$uhost $c]
				if {[lsearch -exact $already_banned $banmask] != "-1"} {continue}
				lappend already_banned $banmask
				set b [mc:cd:replace $b \
					[list %channel  $chan \
				        %nick     $nick \
				        %ident    $ident \
				        %host     $host \
				        %clones   [mc:cd:chanint $chan mc.cd.clones] \
				        %clone    [mc:cd:list number_of_clones $nick $uhost $chan] \
				        %rescan   [mc:cd:chanint $chan mc.cd.warn.time] \
				        %warnings [mc:cd:chanint $chan mc.cd.warn] \
				        %warning  [mc:cd:list number_of_warnings $nick $uhost $chan]]]
				if {!$a} {pushmode $chan +b $banmask} \
				else {newchanban $chan $banmask CloneDtr $b $a $option}
			}; return 1
		}
		is_exempt {
			foreach nick [mc:cd:list get_nicks $nick $uhost $chan] {
				if {(($mc_cd(exempt:op)) && ([isop $nick $chan])) ||
				    (($mc_cd(exempt:voice)) && ([isvoice $nick $chan])) ||
				    (($mc_cd(exempt:flag) != "") &&
				     ([matchattr [nick2hand $nick $chan] $mc_cd(exempt:flag) $chan]))} {
					return 1
				}
			}; return 0
		}
		eval {
			set cache(ciclones) [mc:cd:chanint $chan mc.cd.clones]
			if {(!$cache(ciclones)) ||
			    ([mc:cd:list number_of_clones $nick $uhost $chan] < $cache(ciclones)) ||
			    ([mc:cd:list is_exempt $nick $uhost $chan]) ||
			    (![onchan $botnick $chan])} {return 0}
			set don ""; set clones [mc:cd:list get_nicks $nick $uhost $chan]
			set temp(:cache:a) [mc:cd:list number_of_warnings $nick $uhost $chan]
			if {$temp(:cache:a) < [mc:cd:chanint $chan mc.cd.warn]} {
				mc:cd:list add_warning $nick $uhost $chan
				if {[set temp(temp) [mc:cd:chanint $chan mc.cd.warn.time]]} {
					timer $temp(temp) [list mc:cd:list eval $nick $uhost $chan]
				}
				unset temp
				set met [lindex [split $mc_cd(warn:msg) " "] 0]
				set msg [join [lrange [split $mc_cd(warn:msg) " "] 1 end] " "]
				if {[mc:cd:list msg_all $nick $uhost $chan $met $msg]} {lappend don messaged}
				if {[mc:cd:list kick_all $nick $uhost $chan $mc_cd(warn:kick) $msg]} {
					lappend don kicked
				}
				set s s; if {[llength $don] == "1"} {set s ""}
				set temp(:cache:a) "[join $clones ", "].  "
				append temp(:cache:a) "Warning action$s taken: [join $don ", "]"
				putlog "$mc_cd(script):  Clones found in $chan: $temp(:cache:a)"
			} else {
				set met [lindex [split $mc_cd(msg) " "] 0]
				set msg [join [lrange [split $mc_cd(msg) " "] 1 end] " "]
				if {[mc:cd:list msg_all $nick $uhost $chan $met $msg]} {lappend don messaged}
				if {[mc:cd:list kick_all $nick $uhost $chan $mc_cd(kick) $msg]} {
					lappend don kicked
				}
				if {[mc:cd:list ban_all $nick $uhost $chan $mc_cd(ban) $msg \
					$mc_cd(banmask)]} {
					lappend don banned
				}
				catch {unset mc_cd($cache(warn:array))}
				set s s; if {[llength $don] == "1"} {set s ""}
				set temp(:cache:a) "[join $clones ", "]."
				append temp(:cache:a) " Post warning action$s taken: [join $don ", "]"
				putlog "$mc_cd(script):  Clones found in $chan:  $temp(:cache:a)"
			}; return 1
		}
	}
}


## More Tools quick procs.
## -- http://mc.purehype.net:81/script_info.tcl?script=moretools

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
	# Were not going to use mc:cd:2list here, don't want to evoke a 'too many nested calls
	# to Tcl_EvalObj' error since 'mc:cd:2list' uses on this proc.
	if {[catch {llength $check_args} llength]} {
		set check_args [split $check_args]
		set llength $check_args
	}

	if {($llength < $check_min) || (($llength != "end") && ($llength > $check_max))} {
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

# chanint <channel> <flag>
#     version:
#       v3.2
proc mc:cd:chanint {{args ""}} {
	mc:cd:badargs $args 2 2 "channel integer_flag"
	mc:cd:unlist $args channel flag

	set flag [string tolower $flag]

	if {![validchan $channel]} {error "no such channel record"}

	# Try the 'channel' commands' 'get' option first, it's faster since it is written
	# in C by the eggdrop development team.
	if {![catch {channel get $channel $flag} output]} {return $output}

	foreach chaninfo [string tolower [channel info $channel]] {
		# Using mc:cd:2list here because it's only in string format.  I told the eggdrop
		# development team of this error, but have yet to see them fix it.
		set chaninfo [mc:cd:2list $chaninfo]

		set name [join [expr {([info tclversion] >= "8.1")?
			[lrange $chaninfo 0 end-1]:
			[lrange $chaninfo 0 [expr [llength $chaninfo]-2]]}]]

		if {$name == $flag} {return [lindex $chaninfo end]}
	}; return -1
}

# maskhostbytype <nick!ident@host.domain> [type]
#     version:
#       v2.0
proc mc:cd:maskhostbytype {{args ""}} {
	mc:cd:badargs $args 1 2 "nick!ident@host.domain ?type?"
	mc:cd:unlist $args nuhost type


	set type [expr {($type == "")?5:$type}]
	if {![regexp -- {^1?[0-9]$} $type]} {
		set valid "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {or 19}"
		error "bad type \"$type\": must be [join $valid ", "]"
	}

	# Define the maximum length the ircd allows for an ident.  Standard is 9, however I
	# made it to a variable incase someone wants to change it up.
	set ident_max-length 9

	# Define the maximum length the ircd allows for a hostname/ ip.  Standard is 63,
	# however I made it to a variable incase someone wants to change it up.
	set host_max-length 63

	if {![regexp -- {^(.*?)!((.*)@(.*))$} $nuhost -> nick uhost ident host]} {
		error "invalid nick!ident@host.domain: $nuhost"
	}

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

	# Previous version used regexp instead of these string matches.  String match in
	# this case is ~3 microseconds faster.
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


## SVS v3.0.1
set mc_cd(svs:client_version) "v3.0.1"
if {![info exists mc_cd(svs:mode)] ||
    ![regexp -- {^(1|0)$} $mc_cd(svs:mode)]} {
	set mc_cd(svs:mode) 0
}
if {![info exists mc_cd(svs:notify)]} {
	if {![info exists owner]} {set owner ""}
	set mc_cd(svs:notify) $owner
}

bind time - "00 00 *" mc:cd:do_svs
proc mc:cd:do_svs {{args ""}} {
	global mc_cd tcl_platform
	if {[catch {
	        socket -async $mc_cd(svs:server) $mc_cd(svs:port)
	           } sid]} {
		putloglev d * "$mc_cd(script): SVS socket error: $sid"
		return 1
	}

	# This block of code is to get a standard User-Agent line of information, as
	# proposed in http://www.mozilla.org/build/revised-user-agent-strings.html
	foreach array_name [list platform os osVersion machine] {
		set temp($array_name) [lindex [array get tcl_platform $array_name] 1]
	}
	switch -- $temp(platform) {
		windows {
			switch -- $temp(os) {
				Windows {set temp(2) Win$temp(osVersion)}
				"Windows 95" {
					if {$temp(osVersion) < "4.10"} {
						set temp(2) Win95
					} else {
						set temp(2) Win98
					}
				}
				"Windows 98" {set temp(2) Win98}
				"Windows NT" {
					if {$temp(osVersion) >= "5.0"} {
						set temp(2) "Windows NT $temp(osVersion)"
					} else {
						set temp(2) WinNT$temp(osVersion)
					}
				}
				default {
					set temp(2) "$temp(os) $temp(osVersion)"
				}
			}
		}
		unix {
			set temp(2) "unix $temp(machine)"
		}
		macintosh {
			set temp(2) $temp(machine)
		}
		default {
			set temp(2) "$temp(os) $temp(osVersion) $temp(machine)"
		}
	}
	set temp(user_agent) "Mozilla/5.001 ($temp(platform); U; $temp(2); en) "
	append temp(user_agent) "Gecko/25250101 $mc_cd(svs:script)/"
	append temp(user_agent) "$mc_cd(svs:version) SVS_Client/"
	append temp(user_agent) "$mc_cd(svs:client_version)"
	# ^

	fconfigure $sid -blocking 0 -buffering line
	set tout [after 60000 "mc:cd:svs_talk $sid timeout"]
	fileevent $sid readable "mc:cd:svs_talk $sid $tout"
	puts $sid "GET $mc_cd(svs:get)?$mc_cd(svs:query) HTTP/1.0\
	         \nHost: $mc_cd(svs:server):$mc_cd(svs:port)\
	         \nUser-Agent: $temp(user_agent)\n"
	flush $sid
}

proc mc:cd:svs_talk {sid tout} {
	global mc_cd
	set array [list svs temp $sid]
	if {$tout == "timeout"} {
		set temp(1) "$mc_cd(svs:server):$mc_cd(svs:port)"
		putloglev d * \
			"$mc_cd(script): SVS Warning: Timed out connecting to $temp(1)."
		catch {unset mc_cd($array)}
		close $sid
		return 0
	}
	if {[eof $sid]} {
		catch {unset mc_cd($array)}
		close $sid
		return 1
	}
	gets $sid get
	after cancel $tout
	if {![info exist mc_cd($array)]} {
		if {$get == ""} {set mc_cd($array) 1}
		return -1
	}
	if {($get == "") || [catch {llength $get}]} {
		return -2
	}
	switch -- [lindex $get 0] {
		003 {
			set temp(reply) [lrange $get 1 end]
			set temp(reply:0) [lindex $temp(reply) 0]
			set temp(reply:1) [lindex $temp(reply) 1]
			set temp(reply:2) [lindex $temp(reply) 2]
			set temp(reply:3) [lindex $temp(reply) 3]
			set temp(reply:4) [lindex $temp(reply) 4]
			set temp(reply:5) [lindex $temp(reply) 5]
			if {$temp(reply:0) != $mc_cd(svs:script)} {
				set temp(1) "wanted $mc_cd(svs:script), got $temp(reply:0)"
				putloglev d * "$mc_cd(script): SVS Error: $temp(1)"
				unset mc_cd($array)
				close $sid
				return -3
			}
			if {$mc_cd(svs:mode)} {
				set temp(svs:version) [string range $mc_cd(svs:version) 0 8]999
			} else {
				set temp(svs:version) [string range $mc_cd(svs:version) 0 11]
			}
			if {$temp(reply:1) > $temp(svs:version)} {
				set temp(note) $temp(reply:5)
				regsub -all -- %0 $temp(note) $temp(reply:0) temp(note)
				regsub -all -- %1 $temp(note) $temp(reply:1) temp(note)
				regsub -all -- %2 $temp(note) $temp(reply:2) temp(note)
				regsub -all -- %3 $temp(note) $temp(reply:3) temp(note)
				regsub -all -- %4 $temp(note) $temp(reply:4) temp(note)
				regsub -all -- %version $temp(note) $mc_cd(version) temp(note)
				foreach temp(to) [split $mc_cd(svs:notify) ",; "] {
					if {[string trim $temp(to)] == ""} {continue}
					regsub -- %nick $temp(note) $temp(to) temp(note2)
					set temp(lunotes) [notes $temp(to) -[notes $temp(to)]]]
					if {[string match *$temp(note2)* $temp(lunotes)]} {
						set temp(found_note) 0
						foreach temp(unote) $temp(lunotes) {
							if {$temp(note2) == [lindex $temp(unote) 2]} {
								set temp(found_note) 1
								break
							}
						}
						if {$temp(found_note)} {continue}
					}
					set temp(error) "sending note to $temp(to) -> "
					switch -- [sendnote SVS $temp(to) $temp(note2)] {
						0 {
							if {![validuser $temp(to)]} {
								append temp(error) "invalid user"
							} else {append temp(error) "unknown error"}
							putloglev d * \
								"$mc_cd(script): SVS sendnote error: $temp(error)"
						}
						3 {
							append temp(error) "notebox too full"
							putloglev d * \
								"$mc_cd(script): SVS sendnote error: $temp(error)"
						}
					}
				}
			}
			unset mc_cd($array)
			close $sid
			return 2
		}
	}
}
## ^

putlog "$mc_cd(script) $mc_cd(version) by MC_8 loaded."

##
# HISTORY  ( <Fixed by> - [Found by] - <Info> )
##
# v2.0 (09.19.02)
#  MC_8 -         - Updated SVS Client.  v1.2 -> v3.0.1
#  MC_8 - awan    - Fixed 'Tcl error [mc:cd:join]: bad option "unset": must be
#                   anymore, donesearch, exists, get, names, nextelement, set, size,
#                   or startsearch'.
#                   Bugzilla number: 90
#  MC_8 -         - Added `2list`.  none -> v1.0
#  MC_8 -         - Added `unlist`.  none -> v1.0
#  MC_8 -         - Added `badargs`.  none -> v1.0
#  MC_8 -         - Added error catching system.  v1.0 -> v3.0
#  MC_8 -         - Upgraded `chanint`.  v2.0 -> v3.2
#  MC_8 -         - Upgraded `masktype`, change to `maskhostbytype`.  v1.0 -> v2.0
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
