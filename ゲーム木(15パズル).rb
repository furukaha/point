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
    #@n = $stdin.gets.chomp.to_i
    #@t=[]; @n.times {@t << $stdin.gets.chomp.split.map(&:to_i)}
    @t=$stdin.read.split("\n").map{|a|a.split}
    # score,tile_number,[x,y],"open",count,old_key
    @que = { @t=>[ Float::INFINITY,nil,[nil,nil],"open", 0, nil ] }
    @close_que={}
  end
  def run
    10000.times do |n|
      state,score = run_loop
      #pppp(state,score)
      break if score==0
    end
    finish
  end
  def run_loop
    key,value = pop_que # 一番可能性の高い状態を取り出す
    (puts "ng";exit)  if key==nil # 検証可能な状態なし
    state=key
    score=value[0]
    count=value[4]
    sim(state,count) if score>0  # スコアゼロ＝完成
    close_que!(state)
    return state,score
  end
  def sim(state,count)
    state.freeze
    table = Table.new(state)
    patterns = table.move_patterns
    patterns.each do |xy|
      table.recover!
      new_state =table.move!(*xy)
      score = table.calc_score
      tail_number = state[xy[1]][xy[0]]
      next if @close_que[new_state] 
      @que[new_state] ||= [ score, tail_number, xy, "open", count+1, state ]
    end
  end
  def finish
    key,value = @close_que.select{|k,v|v[0]==0.0}.to_a[0]
    tiles=[]
    until value[1]==nil do
      tiles << value[1]
      key=value[5]
      value=@close_que[key]
    end
    puts tiles.reverse
  end
  def pop_que
    #key,value=@que.select{|k,v|v[3]=="open"}&.min_by{|k,v|v[0]}
    key,value=@que.min_by{|k,v|v[0]}
  end
  def close_que!(key)
    # クローズしたキューは別キューに移すことで高速化を計る
    @que[key][3]="close"
    value = @que[key]
    @close_que[key] = value
    @que.delete(key)
  end
  def pppp(state,msg="")
    puts "---------- : #{msg}"
    state.each do |arr|
      puts str = "%2s %2s %2s %2s" % arr
    end
  end
end

class Table
  V = Array::V8
  def initialize(t)
    @t=t
    @x,@y=find("*")
    @w,@h=4,4
    @anspos=[ [nil,nil] ]
    @h.times do |y|
      @w.times do |x|
        @anspos << [x,y]
      end
    end
    @init_t = @t.deep_dup
    @init_x,@init_y=@x,@y
  end
  def move_patterns
    patterns=[]
    0.step(6,+2) do |n|
      nx=@x-V[n][0]; ny=@y-V[n][1]
      next if nx<0 or ny<0 or nx>=@w or ny>=@h
      patterns << [nx,ny]
    end
    return patterns
  end
  def recover!
    @t = @init_t.deep_dup
    @x,@y=@init_x,@init_y
  end
  def move!(x,y)
    val=@t[y][x]
    @t[@y][@x]=val
    @t[y][x]="*"
    @x,@y=x,y
    return @t.deep_dup
  end
  def calc_score
    # 各タイルと本来あるべき場所のマンハッタン距離の総和 ＋ 3 * S 
    # S = 下記すべての総和
    # 自分が中央のタイル（四方にタイルが存在する）なら 1
    # 自分が正しいタイル、もしくは隣のタイルが自分の正しいタイルなら 0
    g,s = calc_all_tile
    return g + 3*s
  end
  def calc_all_tile
    distances=Array.new(@w*@h+1)
    possibilities=Array.new(@w*@h+1)
    @h.times do |fy|
      @w.times do |fx|
        val=@t[fy][fx]
        val = val=="*" ? 16 : val.to_i
        tx,ty=@anspos[val]
        distances[val] = distance(fx,fy,tx,ty)
        # 正しい位置にあるか、隣が正しい位置であればゼロ
        possibility = case distances[val]
                      when 0; 0
                      when 1; 0
                      else; 2
                      end
        # 中央のタイル（四方にタイルが存在する位置）であれば 1
        possibility = 1 if center_tile?(fx,fy)
        # しかし、正しいタイルであればゼロ
        possibility = 0 if distances[val]==0
        #
        possibilities[val] = possibility
        #p "[#{fx},#{fy}] : #{val} : #{center_tile?(fx,fy)}"
      end
    end
    return [distances.compact.sum,possibilities.compact.sum]
  end
  def center_tile?(x,y)
    center_pos = []
    center_pos.push( *@anspos[6..7] )
    center_pos.push( *@anspos[10..11] )
    return true if center_pos.index([x,y])
    return false
  end
  def all_possibility
    arr=[]
    @h.times do |y|
      @w.times do |x|
        val=@t[y][x]
        tx,ty=@anspos[val.to_i]
         arr << distance(fx,fy,tx,ty)
      end
    end
    return arr
  end
  def distance(fx,fy,tx,ty)
    Math.sqrt( (fx-tx).abs**2 + (fy-ty).abs**2 )
  end
  def find(c)
    @t.each_with_index do |a,y|
      x=a.index(c)
      return [x,y] if x
    end
  end
end


inputs = <<_EOS
1 2 3 4 
5 6 7 8 
9 10 * 11 
13 14 15 12
%
2 3 4 * 
1 5 6 7 
10 11 12 8 
9 13 14 15
_EOS

inputs.split("%\n").each do |input|
#inputs.split("%\n")[0,1].each do |input|
  $stdin = StringIO.new(input)
  Code.new.run
end
