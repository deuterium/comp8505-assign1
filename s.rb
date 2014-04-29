#!/usr/bin/env ruby
#
#


require 'socket'

s = UDPSocket.new
s.bind("127.0.0.1", 6666)

loop {
	hi = s.recvfrom(20)
	puts hi
}
