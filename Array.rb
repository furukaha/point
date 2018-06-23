class Array
  def self.new2d(y,x,v=nil) return Array.new(y).map{Array.new(x,v)} end
  def puts2d(c="") self.each{|r| puts r.join(c)} end
  def sum2d(arr2d) total=0; arr2d.each do |r| total+=r.sum end; return total end
  def ave2d(arr2d,n) total=0; arr2d.each do |r| total+=r.sum end; return total/n end
  def sum() return self.inject(:+) end
  def deep_dup() return Marshal.load(Marshal.dump(self)) end
  def to_i() return self.map(&:to_i) end
  def to_f() return self.map(&:to_f) end
  def uniq_c
    hash = self.sort.group_by{|item|item}
    ret_arr = []; hash.each{|k,v| ret_arr << [v.size,k].flatten }
    return ret_arr.sort{|a, b| b <=> a }
  end
end


