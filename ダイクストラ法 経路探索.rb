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
    # 路線（エッジ）の数、駅（ノード）の数、目的地番号
    @n,@v,@t = $stdin.gets.chomp.split.map(&:to_i)
    # 駅1，駅2，駅間の運賃（コスト）
    @edges=[]; @n.times {@edges << $stdin.gets.chomp.split.map(&:to_i)}
    @costs={}; @edges.each do |s,e,cost| @costs[ [s,e].sort ] = cost end
    @nodes=Array.new(@v){Float::INFINITY}
  end
  def run
    # ダイクストラ経路探索
    @nodes[0]=0
    changed_nodes = *(0..@v-1)
    # ノードに変化がなくなるまで繰り返す
    until changed_nodes==[] do
      # 変化のあったノード周辺のみ再計算する
      changed_nodes = loop_run(changed_nodes)
      changed_nodes.flatten!.uniq!
      #puts "再計算します：#{changed_nodes}"
    end
    puts @nodes[@t]
  end
  def loop_run(changed_nodes)
    # 前回変化のあったノード周辺のみコスト計算する
    changed=[]
    changed_nodes.each do |n|
      # 接続された周囲のノード一覧を取得する
      nodes = around_nodes(n)
      #puts "#{n} を起点として #{nodes} を計算します"
      # 周囲のノードへの移動コストを計算する
      changed << calc_cost(nodes,n)
      #puts "計算結果：#{@nodes}"
    end
    return changed
  end
  def calc_cost(nodes,from)
    # 各ノードのコストを計算する。より良いコストであれば更新する
    changed=[]
    nodes.each do |n|
      next if n==from
      next if @nodes[from]==Float::INFINITY
      now_cost = @nodes[n] 
      new_cost = @nodes[from]+@costs[ [n,from].sort ]
      #p [n,now_cost,new_cost]
      if now_cost>new_cost 
        @nodes[n]=new_cost
        changed << n
      end
    end
    return changed
  end
  def around_nodes(num)
    # 周囲の接続されたノード番号一覧を返す
    positions = @edges.select{|s,e,cost| s==num or e==num}.map{|s,e,cost| [s,e]}
    positions.flatten!&.uniq!
    positions.delete(num)
    return positions
  end
end
def run() Code.new.run end

inputs = <<_EOS
5 5 3
0 1 200
0 4 500
0 2 200
1 4 200
4 3 300
%
3 6 3
0 1 200
1 3 150
2 4 100
%
1 2 1
0 1 100
_EOS

inputs.split("%\n").each do |input|
#inputs.split("%\n")[0,1].each do |input|
  $stdin = StringIO.new(input)
  Code.new.run
end
