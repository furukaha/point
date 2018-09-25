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
    # ���ړ��R�X�g�A����R�X�g�i���g�p�j�A�K��ς݂��ۂ��A�ړ������W
    @scores = { @start_xy => [0,0,"open",[nil,nil]] }
  end
  def run
    display_field(*@start_xy,"START")
    jadge = run_loop
    display_field(*@goal_xy,"GOAL")
    puts jadge ? @scores[ @goal_xy ][0] : "Fail"
  end
  def run_loop
    # �S�[���ɒB���邩�A����悪�Ȃ��Ȃ�܂ŌJ��Ԃ�
    # �S�[���ɒB�����犮�� true ��Ԃ�
    # ����悷��Ȃ���Ζ��� false ��Ԃ�
    x,y=@start_xy
    until goto_goal(x,y) do
      # ���̕����𖖔����ߕ���悩����o��
      x,y = @que.pop
      return false if x.nil? # ���̕����i�L���[�j�Ȃ����S�[���Ȃ�
    end
    return true
  end
  def goto_goal(x,y)
    # �S�[���ɒB���邩�s���~�܂�܂őO�i����
    # ����4�}�X�̍��W�����o���B�S�[�����W�Ȃ犮�� true ��Ԃ�
    # �s���~�܂�Ȃ疢�� false ��Ԃ�
    until goal?(x,y) do
      # �K��ς݂ɂ���
      close!(x,y)
      # ����4�}�X�����X�g�����Ď��o��
      positions = look_around(x,y)
      return false if positions==[]
      # �Ȃɂ��l�����Ɏ��ɐi��
      calc_score(positions, from: [x,y])
      x,y = positions.shift
      # ���򂵂Ă����番�����W���L���[�ɕۑ�����i�m�[�h�n�_�̍��W�̂݁j
      stuck_que(positions) if node?(positions)
    end
    return true
  end
  def close!(x,y)
    # �K��ς݂ɍX�V
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
    # ����4�}�X�̍��W��Ԃ��B�ǁE�O�ł������珜�O�B�K��ςݍ��W�͏��O
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
