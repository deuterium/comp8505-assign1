#!/usr/bin/env ruby
=begin
-------------------------------------------------------------------------------------
--  SOURCE FILE:    s.rb - An UDP server to listen for incoming packets. This server
--                  is different as the payload is not used. Instead, the source port
--                  is extracted and the message is decrepted from it.
--
--  PROGRAM:        s - server
--                ./s.rb 
--
--  FUNCTIONS:      XOR decryption
--
--  DATE:           April 2014
--
--  REVISIONS:      See development repo: https://github.com/deuterium/comp8505-assign1
--
--  DESIGNERS:      Chris Wood - chriswood.ca@gmail.com
--
--  PROGRAMMERS:    Chris Wood - chriswood.ca@gmail.com
--
--  NOTES:          port could probably be a command line argument
--  
---------------------------------------------------------------------------------------
=end

## Variables
CRYPT_KEY = "h"

## Functions

# Decrypts a character with XOR
#
# @param [String] word
# - the character to decrypt
# @return [FixNum]
# - 8 bit signed integer representation of the character
def decrypt(word)
    word.bytes.zip(CRYPT_KEY.bytes).map { |(a,b)| a ^ b}.pack('c*')
end

require 'socket'

## Main
s = UDPSocket.new
s.bind("0.0.0.0", 6666)

loop {
	pkt = s.recvfrom(20)
    dat = pkt[1][1].to_i - 35535
	puts decrypt(Array.new(1) { dat }.pack('c*'))
}
