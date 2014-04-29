#!/usr/bin/env ruby
#
#


require 'socket'

s = UDPSocket.new
s.send "test", 0, "142.232.187.57", 6666
