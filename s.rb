#!/usr/bin/env ruby
#
#

CRYPT_KEY = "h"

def decrypt(word)
    word.bytes.zip(CRYPT_KEY.bytes).map { |(a,b)| a ^ b}.pack('c*')
end

require 'socket'

s = UDPSocket.new
s.bind("0.0.0.0", 6666)

loop {
	pkt = s.recvfrom(20)
    dat = pkt[1][1].to_i - 35535
	puts decrypt(Array.new(1) { dat }.pack('c*'))
}
