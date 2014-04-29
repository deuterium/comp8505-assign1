#!/usr/bin/env ruby
#
#


require 'socket'

s = UDPSocket.new
s.send "test", 0, "142.232.164.121", 6666
