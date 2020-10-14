class Map
  attr_reader :start_xy, :goal_xy, :field

  START,GOAL = "S","G"
  WALL = "#"

  def initialize
    # 地図フィールド情報
    @field = DATA.read.split.map{|r|r.split("")}
    # 地図の縦横サイズ
    @h = @field.size
    @w = @field[0].size
    # スタート地点・ゴール地点の座標
    @start_xy = find_xy(START)
    @goal_xy = find_xy(GOAL)
  end

  # 地図の詳細情報を出力する
  def description
    puts "地図の縦横サイズは #{@h} x #{@w} です"
    puts "スタート座標は #{@start_xy} です"
    puts "ゴール座標は #{@goal_xy} です"
  end

  # 地図のフィールド情報を出力する
  def puts_field(route=[])
    # 経路座標に "*" を表示する
    route.each do |x,y|
      @field[y][x] = "\e[32m*\e[0m"
    end

    puts "-" * 30
    @field.each do |ar|
      puts ar.join.gsub("."," ")
    end
  end

  # 指定の座標が移動可能かどうかを判定する
  def valid?(x,y)
    return false if x < 0
    return false if y < 0
    return false if x >= @w
    return false if y >= @h
    return false if @field[y][x] == WALL
    return true
  end

  # 指定の座標からゴール座標までの直線距離を算出する
  def distance2goal(x,y)
    hen1 = (@goal_xy[0] - x).abs ** 2
    hen2 = (@goal_xy[1] - y).abs ** 2
    ans = Math.sqrt( hen1 + hen2 )
    return ans
  end

  private

  # 指定の記号を検索して、その座標を返す
  def find_xy(char)
    @field.each_with_index do |ar,y|
      if ar.include?(char) then
        x = ar.index(char)
        return [x,y]
      end
    end
  end
end

class Explorer
  #     UP     RIGHT  DOWN    LEFT
  V = [ [0,1], [1,0], [0,-1], [-1,0] ]

  def initialize
    # 地図を手に入れる
    @map = Map.new
    @map.description
    @map.puts_field

    # スタート地点をメモして訪問先リストに登録する
    @memo = {
      @map.start_xy => [
        0, # スタート地点からの実歩数
        0, # ゴールに近いかどうかの評価(スコア)
        true, # 移動予定か(移動済みならfalse)
        [nil,nil] # 移動元座標
      ]
    }
  end

  # メモからゴールに近い座標をひとつ取り出して
  # その座標に移動する(移動済みとしてクローズする)
  def move
    arr = @memo.select{|_,v|v[2]}.sort_by{|_,v|v[1]}
    xy = arr.to_h.keys.shift
    @memo[xy][2] = false
    return xy
  end

  # 周囲を見渡して訪問予定リストを作成する
  # 移動不可能であれば除外する
  def look_around(xy)
    x,y = xy
    next_xy_list = []
    V.each do |vx,vy|
      next_x = x + vx
      next_y = y + vy
      next_xy_list << [next_x,next_y]
    end

    # 移動可能な座標だけを抽出する
    # すでにメモしてある座標は除外する
    next_xy_list.select! do |x,y|
      @map.valid?(x,y) and !@memo[[x,y]]
    end

    return next_xy_list
  end

  # 指定の座標一覧に対してメモを記入する
  def take_memo(xy_list, pxy)
    step = @memo[pxy][0] + 1
    xy_list.each do |x,y|
      score = @map.distance2goal(x,y) + step
      memo = [step, score, true, pxy]
      @memo[[x,y]] = memo
    end
    return @memo
  end

  # ゴールしたかどうか判定する
  def goal?(xy)
    return true if xy.nil?
    return true if xy == @map.goal_xy
    return false
  end

  # 指定の座標からスタート座標までの経路を返す
  def select_route(xy)
    route = []
    until xy == @map.start_xy do
      route << xy
      xy = @memo[xy][3]
    end
    route.shift if route[0] == @map.goal_xy
    route.shift if route[-1] == @map.start_xy
    p route
    return route
  end

  # 地図をチェックする
  def check_map(route)
    @map.puts_field(route)
  end

end

if __FILE__ == $0 then
  takashi = Explorer.new
  xy = takashi.move

  until takashi.goal?(xy) do
    next_xy_list = takashi.look_around(xy)
    takashi.take_memo(next_xy_list, xy)
    xy = takashi.move
  end
  route = takashi.select_route(xy)
  takashi.check_map(route)

end

__END__
S..#.#G
.###.#.
...#.#.
.#.....
