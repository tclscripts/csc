#################################################################
#
# Csc TCL 1.1
#
# Tcl pentru vizualizarea aplicatiilor de inregistrare
#a canalelor pe undernet (Cservice)
#
# Pentru activare : .chanset #canal +csc | .set +csc
#
# .csc <canal>
#
#                       BLaCkShaDoW ProductionS
#      _   _   _   _   _   _   _   _   _   _   _   _   _   _  
#     / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ 
#    ( t | c | l | s | c | r | i | p | t | s | . | n | e | t )
#     \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/
#                                    #TCL-HELP @ Undernet.org
#
#################################################################


package require http

bind pub -|- .csc checkcsc
setudef flag csc

proc checkcsc {nick host hand chan arg} {

        set valchan [lindex [split $arg] 0]
if {![channel get $chan csc]} {
	return
}

if { $valchan == "" } { 
	return 
}

	set dachan [wt:filter $valchan]

if {[regexp {^[\\+!#&]} $valchan]} {
	set valchan [string trim $valchan "#"]
}

	set token [http::config -useragent "lynx"]	
	set ipq [http::geturl "http://cscreg.000webhostapp.com/index.php?channel=https://cservice.undernet.org/live/check_app.php?name=$valchan" -timeout 15000]
	set getipq [http::data $ipq]
	set output [split $getipq "\n"]
	http::cleanup $ipq

if {$getipq == ""} {
                puthelp "PRIVMSG $chan :$valchan: Nu exista nici o aplicatie CService la canalul mentionat."	    
	return
}
	
	set byuser [lindex $output 0]
	set byuser [concat [string map {"&nbsp;" "" } $byuser]]
	set date [lindex $output 1]
	set date [concat [string map {"&nbsp;" ""} $date]]
	set status [lindex $output 2]
	set status [concat [string map {"&nbsp;" ""} $status]]
	set objections [lindex $output 3]
	set decision [lindex $output 4]
	set decision [concat [string map {"&nbsp;" ""} $decision]]
	set desc [lindex $output 5]
	set desc [concat [string map {"&nbsp;" ""} $desc]]
	set link [lindex $output 6]
      
        if {[string equal -nocase $status "pending"]} {
	  set status "\00312$status\003"
        } elseif {[string equal -nocase $status "incoming"]} {
          set status "\00308$status\003"
        } elseif {[string equal -nocase $status "rejected"]} {
	  set status "\00304$status\003"
	} elseif {[string equal -nocase $status "accepted"]} {
	  set status "\00309$status\003"
        } elseif {[string equal -nocase $status "ready for review"]} {
	  set status "\00306$status\003"
        } elseif {[string equal -nocase $status "cancelled by the applicant"]} {
	  set status "\00314$status\003"
        }
	if {$decision == "NONE"} { set decision "n/a" }
	putserv "PRIVMSG $chan :\[\00314CService\003\] - Canal:\00312 \#$valchan\ \003| Stadiu: $status | Username:\00312 $byuser \003| Data:\00312 $date \003| Obiectii:\0034 $objections \003| Comentarii:\00312 $decision \003| URL:\00314 $link \003"
	putserv "PRIVMSG $chan :\[\00314CService\003\] - Descriere: $desc"
      
}

proc wt:filter {x {y ""} } {

        for {set i 0} {$i < [string length $x]} {incr i} {
                switch -- [string index $x $i] {
                        "é" {append y "%E9"}
                        "è" {append y "%E8"}
                        "î" {append y "%CE"}
                        "É" {append y "%E9"}
                        "È" {append y "%E8"}
                        "Î" {append y "%CE"}
                        "&" {append y "%26"}
                        " " {append y "+"}
                        default {append y [string index $x $i]}
                }
        }
        return $y
}


#################################################################################


putlog "Csc TCL 1.1 by BLaCkShaDoW Loaded (Originaly wroted by BaRDaHL)"
