#!/usr/bin/env ruby1.9.3

class Elections
  def initialize input_file, separator="\t"
    @input_file = input_file
    @separator = separator
  end

  def sort_by_closeness
    hashes = parse
    hashes.sort{|h1,h2|
      slimmest_difference(h1) <=> slimmest_difference(h2)
    }
  end

  def slimmest_difference hash
    nums = numbers hash
    nums[0] - nums[1]
  end

  def numbers hash
    hash.values.collect {|v| 
      begin; v.to_f; rescue; nil; end;
    }.find_all{|v| !v.nil?}.sort.reverse
  end

  def results margin=4
    hashes = parse
    puts "Parsed #{hashes.size} ridings"
    winners = hashes.map{|h| 
      ordered = h.sort_by{|k,v| if is_number?(v); 0 - v.to_f; else; 0; end}
      if ordered[0][1].to_f - ordered[1][1].to_f < margin
        [ordered[0][0], ordered[1][0]].sort.join("/")
      else
        ordered[0][0]
      end
    }.group_by(&:to_s).map{|k,v| [k, v.length]}.sort{|a1,a2| a1[1] <=> a2[1]}.reverse
  end

  private
  def parse
    File.open(@input_file){|f|
      lines = f.readlines
      lines.shift while lines[0].start_with?("#") or lines[0] =~ /^$/

      header_line = lines.shift
      headers = tokenize(header_line)

      lines.map{|line|
        tokens = tokenize(line)
        headers.inject({}){|hash, header| hash[header] = tokens.shift; hash}
      }
    }
  end

  def tokenize line
    line.split(@separator).map{|s| s.strip.chomp}
  end

  def is_number?(object)
      true if Float(object) rescue false
  end
end

if __FILE__ == $0
  input_file = ARGV[0] || "input.txt"
  separator = ARGV[1]
  p Elections.new(input_file, separator).results
end
