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

# �A���S���Y�� �F A*Star �ŗǌo�H�T��
class Code
  V = Array::V8
  WALL="#"
  def initialize
    @w,@h = $stdin.gets.chomp.split.to_i
    @b =[]; @h.times do |n| @b<<  $stdin.gets.chomp.split("") end
    @start_xy = find("s")
    @goal_xy = find("g")
    # ���ړ��R�X�g�A����R�X�g�i�}���n�b�^�������j�A�K��ς݂��ۂ��A�i�K�v�Ȃ�ړ������W�j
    @scores = { @start_xy => [0,0,"open",[nil,nil] ] }
    @que = {@start_xy =>  0}
    @init_b = @b.deep_dup
  end
  def run
    display_field(*@start_xy,"START")
    x,y = run_loop
    display_field(*@goal_xy,"GOAL")
    puts @scores[@goal_xy] ? @scores[ @goal_xy ][0] : "Fail" #cost
  end
  def run_loop
    # A*Star
    loop do
      # �ŏ��̃X�R�A�����o��
      xy,score = min_score #[[1, 0], [0, 0, "open"]]
      # �X�R�A���Ȃ����S�[���ɓ��B���Ă�����I���
      return nil if xy.nil?
      @que.delete(xy)
      x,y=xy
      return true if @b[y][x] == "g"
      # �S�[���ɒB���邩�s���~�܂�܂�
      return true if goto_goal(x,y)
    end
    return nil
  end
  def goto_goal(x,y)
    # �S�[���ɒB���邩�s���~�܂肩����_�܂�
    until goal?(x,y) do
      # �K��ς݂ɂ���
      close!(x,y)
      # ����4�}�X�����X�g�����Ď��o��
      positions = look_around(x,y)
      return false if positions==[]
      # debug
      display_field(x,y)
      # �ړ��\�ȃ}�X�ɂ��ăX�R�A�v�Z
      calc_score(positions,x,y)
      stuck_que(positions,x,y)
      # ����_�Ȃ�A��
      return false if positions.size >= 2
      x,y = positions.shift
    end
    return true
  end
  def stuck_que(positions,x,y)
    positions.each do |pos|
      cost = @scores[pos][1] + distance(*pos)
      @que[pos] = cost
    end
  end
  def look_around(x,y)
    # ����4�}�X�̍��W��Ԃ�
    # �ǁE�O�ł������珜�O
    positions=[]
    0.step(6,+2) do |n|
      nx = x+V[n][0]; ny = y+V[n][1]
      next if nx < 0 or ny < 0 or nx >= @w or ny >= @h
      next if @scores[[nx,ny]]
      positions << [nx,ny] if @b[ny][nx] != WALL
    end
    return positions
  end
  def calc_score(positions,px,py)
    # [ cost, score, "open/close" ]
    positions.each do |xy|
      next if @scores[xy] # �Čv�Z���Ȃ�
      cost = @scores[ [px,py] ][0] + 1
      #score = distance(*xy) + cost
      score = 0
      from = [px,py]
      @scores[xy] = [cost,score,"open",from]
    end
  end
  def distance(x,y)
    # �S�[���܂ł̒���������Ԃ��i����R�X�g�j
    ans = Math.sqrt( (@goal_xy[0]-x).abs ** 2 + (@goal_xy[1]-y).abs ** 2 )
    return ans #*10 �}���蒲��
  end
  def min_score
    # �ŏ��X�R�A��Ԃ��i�K��ς݂͏��O�j
    return @que.min_by{|k,v| v}
  end
  def goal?(x,y)
    return [x,y]==@goal_xy
  end
  def close!(x,y)
    # �K��ς݂ɍX�V
    @scores[ [x,y] ][2] = "close"
  end
  def find(c)
    # �Y��Char�̍��W��Ԃ�
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
    sleep 0.1
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
    # �W���o�͂̃J�[�\���ʒu��ύX���� flush ���� / A:U B:D C:R D:L
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
_EOS

inputs.split("%\n").each do |input|
  $stdin = StringIO.new(input)
  Code.new.run
end
