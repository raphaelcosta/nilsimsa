# Nilsimsa hash (build 20050414)
# Ruby port (C) 2005 Martin Pirker
# released under GNU GPL V2 license
#
# inspired by Digest::Nilsimsa-0.06 from Perl CPAN and
# the original C nilsimsa-0.2.4 implementation by cmeclax
# http://ixazon.dynip.com/~cmeclax/nilsimsa.html

class Nilsimsa

  TRAN =
  "\x02\xD6\x9E\x6F\xF9\x1D\x04\xAB\xD0\x22\x16\x1F\xD8\x73\xA1\xAC" <<
  "\x3B\x70\x62\x96\x1E\x6E\x8F\x39\x9D\x05\x14\x4A\xA6\xBE\xAE\x0E" <<
  "\xCF\xB9\x9C\x9A\xC7\x68\x13\xE1\x2D\xA4\xEB\x51\x8D\x64\x6B\x50" <<
  "\x23\x80\x03\x41\xEC\xBB\x71\xCC\x7A\x86\x7F\x98\xF2\x36\x5E\xEE" <<
  "\x8E\xCE\x4F\xB8\x32\xB6\x5F\x59\xDC\x1B\x31\x4C\x7B\xF0\x63\x01" <<
  "\x6C\xBA\x07\xE8\x12\x77\x49\x3C\xDA\x46\xFE\x2F\x79\x1C\x9B\x30" <<
  "\xE3\x00\x06\x7E\x2E\x0F\x38\x33\x21\xAD\xA5\x54\xCA\xA7\x29\xFC" <<
  "\x5A\x47\x69\x7D\xC5\x95\xB5\xF4\x0B\x90\xA3\x81\x6D\x25\x55\x35" <<
  "\xF5\x75\x74\x0A\x26\xBF\x19\x5C\x1A\xC6\xFF\x99\x5D\x84\xAA\x66" <<
  "\x3E\xAF\x78\xB3\x20\x43\xC1\xED\x24\xEA\xE6\x3F\x18\xF3\xA0\x42" <<
  "\x57\x08\x53\x60\xC3\xC0\x83\x40\x82\xD7\x09\xBD\x44\x2A\x67\xA8" <<
  "\x93\xE0\xC2\x56\x9F\xD9\xDD\x85\x15\xB4\x8A\x27\x28\x92\x76\xDE" <<
  "\xEF\xF8\xB2\xB7\xC9\x3D\x45\x94\x4B\x11\x0D\x65\xD5\x34\x8B\x91" <<
  "\x0C\xFA\x87\xE9\x7C\x5B\xB1\x4D\xE5\xD4\xCB\x10\xA2\x17\x89\xBC" <<
  "\xDB\xB0\xE2\x97\x88\x52\xF7\x48\xD3\x61\x2C\x3A\x2B\xD1\x8C\xFB" <<
  "\xF1\xCD\xE4\x6A\xE7\xA9\xFD\xC4\x37\xC8\xD2\xF6\xDF\x58\x72\x4E"

  POPC =
  "\x00\x01\x01\x02\x01\x02\x02\x03\x01\x02\x02\x03\x02\x03\x03\x04" <<
  "\x01\x02\x02\x03\x02\x03\x03\x04\x02\x03\x03\x04\x03\x04\x04\x05" <<
  "\x01\x02\x02\x03\x02\x03\x03\x04\x02\x03\x03\x04\x03\x04\x04\x05" <<
  "\x02\x03\x03\x04\x03\x04\x04\x05\x03\x04\x04\x05\x04\x05\x05\x06" <<
  "\x01\x02\x02\x03\x02\x03\x03\x04\x02\x03\x03\x04\x03\x04\x04\x05" <<
  "\x02\x03\x03\x04\x03\x04\x04\x05\x03\x04\x04\x05\x04\x05\x05\x06" <<
  "\x02\x03\x03\x04\x03\x04\x04\x05\x03\x04\x04\x05\x04\x05\x05\x06" <<
  "\x03\x04\x04\x05\x04\x05\x05\x06\x04\x05\x05\x06\x05\x06\x06\x07" <<
  "\x01\x02\x02\x03\x02\x03\x03\x04\x02\x03\x03\x04\x03\x04\x04\x05" <<
  "\x02\x03\x03\x04\x03\x04\x04\x05\x03\x04\x04\x05\x04\x05\x05\x06" <<
  "\x02\x03\x03\x04\x03\x04\x04\x05\x03\x04\x04\x05\x04\x05\x05\x06" <<
  "\x03\x04\x04\x05\x04\x05\x05\x06\x04\x05\x05\x06\x05\x06\x06\x07" <<
  "\x02\x03\x03\x04\x03\x04\x04\x05\x03\x04\x04\x05\x04\x05\x05\x06" <<
  "\x03\x04\x04\x05\x04\x05\x05\x06\x04\x05\x05\x06\x05\x06\x06\x07" <<
  "\x03\x04\x04\x05\x04\x05\x05\x06\x04\x05\x05\x06\x05\x06\x06\x07" <<
  "\x04\x05\x05\x06\x05\x06\x06\x07\x05\x06\x06\x07\x06\x07\x07\x08"

  def initialize(*data)
    @threshold=0; @count=0
    @acc =Array::new(256,0)
    @lastch0=@lastch1=@lastch2=@lastch3= -1

    data.each do |d| update(d) end  if data && (data.size>0)
  end

  def tran3(a,b,c,n)
    (((TRAN[(a+n)&255].bytes.first^TRAN[b].bytes.first*(n+n+1))+TRAN[(c)^TRAN[n].bytes.first].bytes.first)&255)
    #(((TRAN[(a+n)&255]^TRAN[b]*(n+n+1))+TRAN[(c)^TRAN[n]])&255)
  end

  def update(data)
    data.each_byte do |ch|
      @count +=1
      if @lastch1>-1 then
        @acc[tran3(ch,@lastch0,@lastch1,0)] +=1
      end
      if @lastch2>-1 then
        @acc[tran3(ch,@lastch0,@lastch2,1)] +=1
        @acc[tran3(ch,@lastch1,@lastch2,2)] +=1
      end
      if @lastch3>-1 then
        @acc[tran3(ch,@lastch0,@lastch3,3)] +=1
        @acc[tran3(ch,@lastch1,@lastch3,4)] +=1
        @acc[tran3(ch,@lastch2,@lastch3,5)] +=1
        @acc[tran3(@lastch3,@lastch0,ch,6)] +=1
        @acc[tran3(@lastch3,@lastch2,ch,7)] +=1
      end
      @lastch3=@lastch2
      @lastch2=@lastch1
      @lastch1=@lastch0
      @lastch0=ch
    end
  end

  def digest
    @total=0;
    case @count
      when 0..2 then
      when 3 then @total +=1
      when 4 then @total +=4
      else     
        @total +=(8*@count)-28    
    end
    @threshold=@total/256	

    @code=
           "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00" <<
           "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
    (0..255).each do |i|
      @code[i>>3] = (@code[i>>3].bytes.first + ( ((@acc[i]>@threshold)?(1):(0))<<(i&7) )).chr
      #@code[i>>3] += ( ((@acc[i]>@threshold)?(1):(0))<<(i&7) )
    end

    @code[0..31].reverse
  end

  def hexdigest
    digest.unpack("H*")[0]
  end

  def to_s
    hexdigest
  end

  def <<(whatever)
    update(whatever)
  end

  def ==(otherdigest)
    digest == otherdigest
  end

  def file(thisone)
    File.open(thisone,"rb") do |f|
       until f.eof? do update(f.read(10480)) end
    end
  end

  def nilsimsa(otherdigest)
    bits=0; myd=digest
    (0..31).each do |i|
      bits += POPC[255&myd[i].bytes.first^otherdigest[i].bytes.first].bytes.first
    end
    (128-bits)
  end
  
end

def selftest  
  n1 = Nilsimsa::new;
  n1.update("abcdefgh")
  puts "#{n1.hexdigest}\r\n14c8118000000000030800000004042004189020001308014088003280000078"
  puts "abcdefgh:  #{n1.hexdigest=='14c8118000000000030800000004042004189020001308014088003280000078'}"
  n2 = Nilsimsa::new("abcd","efgh")
  puts "#{n2.hexdigest}\r\n14c8118000000000030800000004042004189020001308014088003280000078"
  puts "abcd efgh: #{n2.hexdigest=='14c8118000000000030800000004042004189020001308014088003280000078'}"

  puts "#{n1}\r\n#{n2}"
  puts "digest:    #{n1 == n2.digest}"

  n1.update("ijk")
  puts "#{n1.hexdigest}\r\n14c811840010000c0328200108040630041890200217582d4098103280000078"
  puts "ijk:       #{n1.hexdigest=='14c811840010000c0328200108040630041890200217582d4098103280000078'}"
  puts "#{n1.nilsimsa(n2.digest)}==109"
  puts "nilsimsa:  #{n1.nilsimsa(n2.digest)==109}"
  puts
end

if __FILE__ == $0 then
  if ARGV.size>0 then
    begin                               # load C core - if available
      require 'nilsimsa_native'
    rescue LoadError => e
      # ignore lack of native module
    end

    ARGV.each do |filename|
      if FileTest::exists?(filename) then
        n = Nilsimsa::new
        n.file(filename)
        puts n.hexdigest+" #{filename}"
      else
        puts "error: can't find '#{filename}'"
      end
    end
  else
    puts 'Running selftest using native ruby version'
    selftest
    begin                               # load C core - if available
      if File.exists?('./nilsimsa_native')
        require './nilsimsa_native'
        puts 'Running selftest using compiled nilsimsa in current dir'
      else 
        require 'nilsimsa_native'
        puts 'Running selftest using compiled nilsimsa'
      end
      selftest
    rescue LoadError => e
      puts "Couldnt run selftest with compiled nilsimsa"
    end
  end
end
