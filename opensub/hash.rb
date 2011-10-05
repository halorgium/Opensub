module OpenSub
  # taken from
  # http://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes
  class Hasher
    def open_subtitles_hash(filename)
      raise "Need video filename" unless filename
  
      fh = File.open(filename)
      fsize = File.size(filename)
  
      hash = [fsize & 0xffff, (fsize >> 16) & 0xffff, 0, 0]
  
      8192.times { hash = add_unit_64(hash, read_uint_64(fh)) }
  
      offset = fsize - 65536
      fh.seek([0,offset].max, 0)
  
      8192.times { hash = add_unit_64(hash, read_uint_64(fh)) }
  
      fh.close
  
      return uint_64_format_hex(hash)
    end
  
    def read_uint_64(stream)
      stream.read(8).unpack("vvvv")
    end
  
    def add_unit_64(hash, input)
      res = [0,0,0,0]
      carry = 0
  
      hash.zip(input).each_with_index do |(h,i),n|
        sum = h + i + carry
        if sum > 0xffff
          res[n] += sum & 0xffff
          carry = 1
        else
          res[n] += sum
          carry = 0
        end
      end
      return res
    end
  
    def uint_64_format_hex(hash)
      sprintf("%04x%04x%04x%04x", *hash.reverse)
    end
  end
end
