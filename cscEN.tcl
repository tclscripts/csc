######################################################
#
# Csc EN TCL 1.1
#
# Check the status of an existing channel aplication
# through CService on UnderNet.
# Originaly wroted by BaRDaHL
#
# .chanset #chan +csc | .set +csc
#
# Syntax: .csc <chan>
#
#			BLaCkShaDoW ProductionS
######################################################

package require http

bind pub -|- .csc checkcsc
setudef flag csc

proc checkcsc {nick host hand chan arg} {

        set valchan [lindex [split $arg] 0]
if {![channel get $chan csc]} {
	return
}

if { $valchan == "#" } { 
               puthelp "NOTICE $nick :\[CService\] - Please use proper format: .csc <channelname>"
	return 
}

if { $valchan == "" } { 
               puthelp "NOTICE $nick :\[CService\] - Please use proper format: .csc <channelname>"
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
                puthelp "NOTICE $nick :$valchan: No applications matched that channel."
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
	  set status "$status"
        } elseif {[string equal -nocase $status "incoming"]} {
          set status "$status"
        } elseif {[string equal -nocase $status "rejected"]} {
	  set status "$status"
	} elseif {[string equal -nocase $status "accepted"]} {
	  set status "$status"
        } elseif {[string equal -nocase $status "ready for review"]} {
	  set status "$status"
        } elseif {[string equal -nocase $status "cancelled by the applicant"]} {
	  set status "$status"
        }
	if {$decision == "NONE"} { set decision "n/a" }
	putserv "NOTICE $nick :\[CService\] - Channel: \#$valchan\ | Status: $status | Applicant: $byuser | Date: $date | Objections: $objections | Comments: $decision | URL: $link"
	putserv "NOTICE $nick :\[CService\] - Description: $desc"
      
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


putlog "Csc EN TCL 1.1 by BLaCkShaDoW Loaded (Originaly wroted by BaRDaHL)"
