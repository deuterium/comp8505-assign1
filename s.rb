#!/usr/bin/env ruby
#
#


require 'socket'

s = UDPSocket.new
s.bind("0.0.0.0", 6666)

loop {
	hi = s.recvfrom(20)
	puts hi
}
