# 数独を解く者
class SudokuSolver
  FIELD_SIZE = 9
  GRID_SIZE = 3
  ALL_NUMBER = (1..9).to_a

  # 盤面を読み取って配列として保持する
  def initialize
    @field = DATA.read.delete("\n").split("").map(&:to_i)
  end

  def display(str=@field.join)
    field = str.delete("\n").split("").map(&:to_i)
    puts "-" * 30
    field.each_slice(FIELD_SIZE) do |ar|
      puts ar.join
    end
  end

  # 81マスをスキャンして、候補がひとつしかないセルを
  # 探して確定させる。
  def scan_and_fix
    @field.size.times do |i|
      next if @field[i] != 0
      c = list_candidates(i)
      @field[i] = c[0] if c.size == 1
    end
  end

  # scan_and_fix を何度も実行する
  # 盤面が変化しなくなるまで繰り返す
  def basic_solve
    old_field = []
    until @field == old_field do
      old_field = @field
      scan_and_fix
    end
  end

  # 深さ優先探索の制御ロジック
  # スタックを活用する
  def deep_solve
    stack = []
    stack << @field.join

    field = loop do
      # スタックがなくなるか、盤面が完成したら終了
      break nil   if (field = stack.pop).nil?
      break field if (idx = field.index("0")).nil?

      # 派生した盤面リストを取得する
      list = simulate(field)
      next if list.empty?
      stack << list
      stack.flatten!
    end
    return field
  end

  # 盤面(文字列)を受け取り、特定の1セルについて
  # 派生する可能性を網羅する
  # 可能性の分だけ盤面を複製して一覧として返す
  def simulate(str)
    @field = str.delete("\n").split("").map(&:to_i)
    # 候補を洗い出す
    idx = @field.index(0)
    c = list_candidates(idx)

    # 候補の分だけ盤面を複製する
    list = []
    c.each do |v|
      @field[idx] = v
      list << @field.join.dup
    end
    return list
  end

  # 指定のインデックスが含まれる縦列・横行・9グリッドを
  # 精査して、数字の候補を一覧にして返す
  def list_candidates(idx)
    # インデックス一覧をすべて取得する
    indexes = []
    indexes << row_indexes(idx)
    indexes << col_indexes(idx)
    indexes << grid_indexes(idx)
    indexes.flatten!.uniq!

    # インデックスの値をすべて取得する
    values = @field.values_at(*indexes)
    values.select!{|v|v!=0}.uniq!
    list = ALL_NUMBER - values
    return list
  end

  # インデックス番号を受け取り、その行の
  # インデックス番号を一覧として返す
  def row_indexes(idx)
    y = idx / FIELD_SIZE # 何行目に相当するか
    min = y*FIELD_SIZE
    max = min + (FIELD_SIZE-1)
    return (min..max).to_a
  end
  # インデックス番号を受け取り、その列の
  # インデックス番号を一覧として返す
  def col_indexes(idx)
    x = idx % FIELD_SIZE # 何列目に相当するか
    list = []
    max = FIELD_SIZE * FIELD_SIZE - 1
    x.step(max, FIELD_SIZE) do |i|
      list << i
    end
    return list
  end

  # インデックス番号を受け取り、そのグリッドの
  # インデックス番号を一覧として返す
  def grid_indexes(idx)
    x = idx % FIELD_SIZE # 何列目に相当するか
    y = idx / FIELD_SIZE # 何行目に相当するか

    # グリッドの最小値(スタート位置)を算出する
    grid_x = x / GRID_SIZE
    grid_y = y / GRID_SIZE
    start_idx = (grid_y * GRID_SIZE * FIELD_SIZE) +
                (grid_x * GRID_SIZE)
    # グリッドのインデックスを一覧にする
    list = []
    start_idx.step(start_idx+2) do |n|
      list << [n, n+FIELD_SIZE, n+FIELD_SIZE*2]
    end
    return list.flatten.sort
  end


end


# 実行制御
if __FILE__ == $0 then
  masao = SudokuSolver.new
  masao.display

  # 単純な解法で解いてみる
  masao.basic_solve
  # 数字を仮置きして深さ優先探索
  field = masao.deep_solve
  # 正解を表示
  masao.display(field) if field
end


# ここから下は実行されない
# DATA 定数で読み出すことが出来る
__END__
100009004
800652070
000000600
760000000
090000050
010000026
004000700
050306000
300004001
