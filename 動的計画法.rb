# coding: Shift_JIS

class Array
  #     U:0           R:2         D:4          R:6
  V = [ [0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1] ]
  def self.new2d(y,x,v=nil) return Array.new(y).map{Array.new(x){v}} end
  def puts2d(c="") self.each{|r| puts r.join(c)} end
  def sum2d(arr2d) total=0; arr2d.each do |r| total+=r.sum end; return total end
  def ave2d(arr2d,n) total=0; arr2d.each do |r| total+=r.sum end; return total/n end
  def sum() return self.inject(:+) end
  def deep_dup() return Marshal.load(Marshal.dump(self)) end
  def to_i() return self.map(&:to_i) end
  def to_f() return self.map(&:to_f) end
end


# アルゴリズム ： 動的計画法
class Code
  def initialize
    @m = $stdin.gets.chomp.to_i
    @n = $stdin.gets.chomp.to_i
    @q=[]; @n.times do |n| @q << $stdin.gets.chomp.split.to_i end
  end
  def run
    # 動的計画法
    dp = {0 => 0} # k:人数 v:コスト
    @n.times do |n|
      # すでにある計算結果に対して、「持って行く」か「持って行かないか」
      # 持って行かない場合はそのままなので、「持って行った」場合の計算を行う
      ans = take_or_not(n,dp)
      # 「持って行った場合」と「持って行かない場合」の計算結果をマージする。
      # コストの低い方を優先する。
      # 新しい計算結果が作成され、次のループで新しい計算結果と次のアイテムで検証する
      dp.merge!(ans){|k,ov,nv| ov > nv ? nv : ov}
      p dp
    end
    dp.select!{|k,v| k>=@m} # 必要人数以上
    puts dp.min_by{|k,v| v}[1] # うち最低コスト

  end
  def take_or_not(n,dp)
    # 渡された計算結果とitems[n]を掛け合わせた結果を返す
    ans={}
    dp.each do |k,v|
      # 人数            コスト
      ans[k+@q[n][0]] = v + @q[n][1]
    end
    return ans
  end
end

inputs = <<_EOS
60 
3 
40 4300 
30 2300 
20 2400 
%
250 
5 
35 3640 
33 2706 
98 9810 
57 5472 
95 7790
_EOS

inputs.split("%\n").each do |input|
  $stdin = StringIO.new(input)
  Code.new.run
end
