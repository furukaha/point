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
  V = Array::V8
  WALL="#"
  def initialize
    @w,@h = $stdin.gets.chomp.split.to_i
    @b =[]; @h.times do |n| @b<<  $stdin.gets.chomp.split("") end
    @start_xy = find("s")
    @goal_xy = find("g")
    @init_b = @b.deep_dup
    @que=[]
    # 実移動コスト、推定コスト（未使用）、訪問済みか否か、移動元座標
    @scores = { @start_xy => [0,0,"open",[nil,nil]] }
  end
  def run
    display_field(*@start_xy,"START")
    jadge = run_loop
    display_field(*@goal_xy,"GOAL")
    puts jadge ? @scores[ @goal_xy ][0] : "Fail"
  end
  def run_loop
    # ゴールに達するか、分岐先がなくなるまで繰り返す
    # ゴールに達したら完了 true を返す
    # 分岐先すらなければ未了 false を返す
    x,y=@start_xy
    until goto_goal(x,y) do
      # 次の分岐先を末尾直近分岐先から取り出す
      x,y = @que.pop
      return false if x.nil? # 次の分岐先（キュー）なし＝ゴールなし
    end
    return true
  end
  def goto_goal(x,y)
    # ゴールに達するか行き止まりまで前進する
    # 周囲4マスの座標を取り出す。ゴール座標なら完了 true を返す
    # 行き止まりなら未了 false を返す
    until goal?(x,y) do
      # 訪問済みにする
      close!(x,y)
      # 周囲4マスをリスト化して取り出す
      positions = look_around(x,y)
      return false if positions==[]
      # なにも考えずに次に進む
      calc_score(positions, from: [x,y])
      x,y = positions.shift
      # 分岐していたら分岐先座標をキューに保存する（ノード始点の座標のみ）
      stuck_que(positions) if node?(positions)
    end
    return true
  end
  def close!(x,y)
    # 訪問済みに更新
    @scores[ [x,y] ][2] = "close"
    display_field(x,y,"closing")
    return x,y
  end
  def calc_score(positions,from:)
    positions.each do |pos|
      cost=@scores[from][0] + 1
      @scores[pos]=[cost, 0, "open", from]
    end
  end
  def stuck_que(positions)
    @que.push(*positions)
  end
  def look_around(x,y)
    # 周囲4マスの座標を返す。壁・外であったら除外。訪問済み座標は除外
    positions=[]
    0.step(6,+2) do |n|
      nx = x+V[n][0]; ny = y+V[n][1]
      next if nx < 0 or ny < 0 or nx >= @w or ny >= @h
      next if @b[ny][nx] == WALL 
      next if @scores[[nx,ny]]
      positions << [nx,ny]
    end
    return positions
  end
  def node?(positions)
    return positions.size > 0
  end
  def goal?(x,y)
    return [x,y] == @goal_xy
  end
  #
  def find(c)
    # 該当Charの座標を返す
    @h.times do |y|
      x = @b[y].index(c)
      return [x,y] if x != nil
    end
  end
  def display_field(x,y,msg="")
    flush!(@h+1) if msg != "START"
    printf "[ %3d , %3d ] : %-100s \n",x,y,msg
    @b[y][x]="*"
    @b[y][x]="S" if [x,y]==@start_xy
    @b[y][x]="G" if [x,y]==@goal_xy
    set_route if @scores[@goal_xy]
    @b.each do |a| puts a.join end
    sleep 0.01
  end
  def set_route
    @b = @init_b.deep_dup
    x,y=@goal_xy
    until x==nil do
      x,y = @scores[ [x,y] ][3]
      @b[y][x]="*" if x!=nil and [x,y]!=@start_xy
    end
  end
  def flush!(n)
    # 標準出力のカーソル位置を変更して flush する / A:U B:D C:R D:L
    printf "\e[#{n}A"
    $stdout.flush
  end
end


inputs = <<_EOS
4 5
.s.#
..#.
.##.
..#g
....
%
15 12
.#.s#.#.##.#...
...##......##.#
.###g.###.###.#
....###.#..#...
#.#......#...#.
..#.##.#..#.##.
..##...#.#..##.
..###.#...#...#
.####...#####.#
####..##..#....
###.#.##.#..##.
###.........#..
%
15 12
s..............
..#############
...............
..#############
...............
..#####.#######
...............
..#############
...............
..#############
...............
..#####.######g
_EOS

inputs.split("%\n").each do |input|
  $stdin = StringIO.new(input)
  Code.new.run
end
