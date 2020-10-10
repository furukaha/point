class Map
  attr_reader :start_xy, :goal_xy, :h, :w, :field

  WALL = "#"
  START,GOAL = "S","G"

  def initialize
    @field = read_map()
    @start_xy = find_xy(START)
    @goal_xy  = find_xy(GOAL)
    @h,@w = set_mapsize
    @initial_field = Marshal.load(Marshal.dump(@field))
  end

  # DATA定数から文字列地図を読み取る
  # 二次元配列化して保持する
  def read_map
    return DATA.read.split.map{|r|r.split("")}
  end

  # 二次元配列の地図から
  # 引数で指定された記号の座標を探して返す
  def find_xy(char)
    @field.each_with_index do|ar,y|
      if ar.include?(char) then
        x = ar.index(char)
        return [x, y]
      end
    end
  end

  # 地図の縦横サイズを取得して返す
  def set_mapsize
    h = @field.size
    w = @field[0].size
    return [h, w]
  end

  def description
    puts "スタート座標は #{@start_xy} です"
    puts "ゴール座標は #{@goal_xy} です"
    puts "地図のサイズは横縦 #{@w} x #{@h} です"
    puts "-"*30
    puts_map(-1)
  end


  # 地図を表示する
  def puts_map(n=@h)
    printf "\e[#{n}A"
    $stdout.flush

    @field.each do |ar|
      puts ar.join.gsub(/\*/, "\e[32m*\e[0m")
    end
  end
end

class Explorer
  #     UP    RIGHT  DOWN  LEFT
  V = [ [0,1],[1,0],[0,-1],[-1,0] ]

  def initialize(map)
    @map = map
    # 歩数, 直線距離, 移動済みか, 移動元座標
    @memo = { map.start_xy => [ 0, 0, true, [nil,nil] ] }
  end

  # 訪問予定リストから座標を1件取り出す(オープンかつスコアの高い座標)
  # 座標に移動し、座標をクローズする
  def move
    xy = @memo.select{|k,v|v[2]}.sort_by{|k,v|v[1]}.to_h.keys.shift
    @memo[xy][2] = false
    return xy
  end

  # 座標がゴールかどうかを判定する
  # 座標が nil であれば移動先なしと判断し true を返す
  def goal?(xy)
    return true if xy.nil?
    return true if @map.goal_xy == xy
    return false
  end

  # 周囲4方向の移動可能な座標リストを生成して返す
  def look_around(xy)
    next_xy_list = []
    V.each do |vx,vy|
      next_x = xy[0] - vx
      next_y = xy[1] - vy
      next_xy_list << [next_x, next_y]
    end

    # 地図外の座標は除外
    # すでに移動コスト計算済みの座標は除外
    # 地図上で壁であれば除外
    next_xy_list.select! do |x,y|
      x < @map.w and y < @map.h and
        x >= 0 and y >= 0 and
        !@memo[[x,y]] and
        @map.field[y][x] != "#"
    end
    return next_xy_list
  end

  # 座標リストから訪問予定リストを作成する
  def calc(xy_list,pxy)
    steps = @memo[pxy][0] + 1 # 実歩数(移動元座標の歩数+1)
    xy_list.each do |x,y|
      score = distance(x,y) + steps # 推定スコア:ゴールまでの直線距離+実歩数
      memo = [steps, score, true, pxy]
      @memo[ [x,y] ] = memo
    end
  end

  # 経路を取り出して地図を表示する
  def check_map(xy)
    arr = []
    x,y = xy
    until [x,y]==@map.start_xy do
      arr << [x,y]
      x,y = @memo[ [x,y] ][3]
    end
    arr.shift # ゴール座標除外
    arr.each do |x,y|
      @map.field[y][x] = "*"
    end

    @map.puts_map
  end

  private

  # ゴールまでの直線距離を返す（推定コスト）
  def distance(x,y)
    ans = Math.sqrt( (@map.goal_xy[0]-x).abs ** 2 + (@map.goal_xy[1]-y).abs ** 2 )
    return ans
  end

end



if __FILE__ == $0 then
  map = Map.new()
  map.description
  takashi = Explorer.new(map)
  xy = takashi.move
  until takashi.goal?(xy) do
    next_xy_list = takashi.look_around(xy)
    takashi.calc(next_xy_list, xy)
    xy = takashi.move
    # 実行時の引数に数値が指定されていたら
    # リアルタイムで経過を描写する
    if ARGV[0] then
      takashi.check_map(xy)
      sleep ARGV[0].to_f
    end
  end
  takashi.check_map(xy)
end

__END__
S#G......#.#...
.#######.#.#.##
.....#.........
.....######.###
.....#.........
.....#.##.#####
###..#..###....
.....#....#.##.
..#####.#...#..
......####.####
.##.###........
.#....#...#####
.#.######....#.
.#....#.####...
.#..#........#.
