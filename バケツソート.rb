# coding: Shift_JIS

class Array
  #      U:0           R:2         D:4          R:6
  V8 = [ [0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1] ]
  D8 = [ "U",   "UR",  "R",  "RD", "D",  "DL",  "L",   "LU" ]
  def self.new2d(y,x,v=nil) return Array.new(y).map{Array.new(x){v}} end
  def puts2d(c="") self.each{|r| puts r.join(c)} end
  def sum2d(arr2d) total=0; arr2d.each do |r| total+=r.sum end; return total end
  def ave2d(arr2d,n) total=0; arr2d.each do |r| total+=r.sum end; return total/n end
  def sum() return self.inject(:+) end
  def deep_dup() return Marshal.load(Marshal.dump(self)) end
  def to_i() return self.map(&:to_i) end
  def to_f() return self.map(&:to_f) end
end


class Code
  def initialize
    @n = $stdin.gets.to_i
    @books = $stdin.gets.split.map(&:to_i)
    #@edges=[]; @n.times {@edges << $stdin.gets.chomp.split.map(&:to_i)}
  end
  def run
    # バケツソート
    # 予めバケツ（入れ物）を用意しておき、そこにインデックスを入れておく
    # インデックスを操作することで、リストを総ナメしなくて済むので速い
    set_index
    #
    cnt=0
    @n.times do |n|
      i=@idx[n+1]
      next if i.nil?
      next if i==n
      
      # インデックス位置と値を入れ替える
      @books[i],@books[n]=@books[n],@books[i]
      # インデックスも書き換える
      v=@books[i]
      @idx[n+1]=n; @idx[v]=i
      cnt+=1
    end
    p cnt
  end
  def set_index
    @idx={}
    @books.each_with_index do |n,i|
      next if n==i+1
      @idx[n]=i
    end
  end
end
def run() Code.new.run end

arr = *(1..100000)
inputs = <<_EOS
5
5 4 3 2 1
%
10
8 7 9 1 5 6 2 10 4 3
%
100000
#{arr.reverse.join(" ")}
_EOS

inputs.split("%\n").each do |input|
#inputs.split("%\n")[0,1].each do |input|
  $stdin = StringIO.new(input)
  Code.new.run
end
