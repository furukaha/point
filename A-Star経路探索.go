package main

/* アルゴリズム実装
   構造体とメソッドを使用した 最良経路探索（A*Star)
*/
import (
	"bufio"
	"fmt"
	"math"
	"os"
	"strconv"
	"strings"
)

// =================================================================================
// データ定義
// =================================================================================
// 座標を表す構造体
type point struct{ x, y int }

// コストを表す構造体
type cost struct {
	step     int     "実コスト（移動ステップス数）"
	distance float64 "推定スコア：ゴールまでの距離（ユークリッド距離）"
	score    float64 "スコア（実スコア＋推定スコア）"
	point    "移動元座標"
}

// 方向の文字列で座標の増減値を返す連想配列
var V = map[string]point{"U": {x: 0, y: -1}, "D": {x: 0, y: 1}, "L": {x: -1, y: 0}, "R": {x: 1, y: 0}}

// フィールド記号
const space, wall, start, goal, visit, route = ".", "#", "S", "G", "+", "*"

// =================================================================================
// メソッド：探検家クラス
// =================================================================================
// インスタンス変数
type Explorer struct {
	x, y    int            "現座標"
	sx, sy  int            "スタート座標"
	gx, gy  int            "ゴール座標"
	h, w    int            "フィールドサイズ(index+1)"
	field   [][]string     "フィールドマップ（地図）"
	visited map[point]cost "訪問済み座標スタック"
	plan    map[point]cost "訪問予定座標キュー"
}

// 初期設定
func (p *Explorer) initialize() {
	s := geta()
	sl := strings.Split(s, "\n")
	p.w, p.h = tointXY(sl[0])
	p.sx, p.sy = tointXY(sl[1])
	p.gx, p.gy = tointXY(sl[2])
	field := sl[3 : p.h+3]
	p.getMap(p.h, p.w, field)
	p.visited = map[point]cost{}
	p.plan = map[point]cost{}
	dist := p.calcDistance(p.sx, p.sy)
	sc := 0 + dist
	p.plan[point{p.sx, p.sy}] = cost{step: 0, distance: dist, score: sc, point: point{p.sx, p.sy}}
}

// main
func (p Explorer) solve() {
	for {
		if p.jadgeFinish() == true {
			break
		} // 予定が空になるか、ゴールに到達したら終了
		p.x, p.y = p.getPlan()   // 訪問予定からもっともスコアが小さい座標を取り出して移動する
		points := p.lookAround() // 周囲4マスを見回して、移動可能な座標のリストを得る
		p.planto(points)         // 移動可能な座標についてスコアを計算し訪問予定を立てる
		p.closed()               // 現座標を訪問済みとして記録する
	}

	p.follow()
	p.puts("end")
}

// 処理の終了条件を判定して返す
func (p Explorer) jadgeFinish() bool {
	if len(p.plan) <= 0 {
		return true
	} // 訪問先がない
	if p.x == p.gx && p.y == p.gy {
		return true
	} // ゴール
	return false
}

// 指定されたサイズでフィールド用の配列を初期作成する
func (p *Explorer) getMap(h int, w int, sl []string) {
	p.field = initArr2d(h, w)
	for k, v := range sl {
		p.field[k] = strings.Split(v, "")
	}
}

// 訪問予定からもっともスコアが小さい座標を取り出して返す
func (p *Explorer) getPlan() (int, int) {
	min := math.Inf(0.0)
	x, y := 0, 0
	for k, v := range p.plan {
		if v.score < min {
			min = v.score
			x, y = k.x, k.y
		}
	}
	return x, y
}

// 現在地から移動可能な周囲４マスの座標配列を返す
func (p Explorer) lookAround() []point {
	v := []string{"R", "D", "L", "U"}
	around := []point{}
	for _, v := range v {
		nx, ny, b := p.jadgeNext(v)
		if b == true {
			around = append(around, point{nx, ny})
		}
	}
	return around
}

// 現在地の向きから次の座標を計算し、移動先座標と移動可能かどうかを返す
func (p Explorer) jadgeNext(s string) (int, int, bool) {
	nx := p.x + V[s].x
	ny := p.y + V[s].y
	if nx > p.w-1 || ny > p.h-1 || nx < 0 || ny < 0 {
		return 0, 0, false
	} // フィールド外
	if p.jadgeVisited(nx, ny) == true {
		return 0, 0, false
	} // 訪問済み
	if p.field[ny][nx] == wall {
		return 0, 0, false
	} // 壁
	return nx, ny, true
}

// 移動可能な座標配列についてスコアを計算し訪問予定を立てる
func (p *Explorer) planto(points []point) {
	for _, v := range points {
		step := p.plan[point{p.x, p.y}].step + 1 // 移動元（現在地）座標の歩数＋１
		dist := p.calcDistance(v.x, v.y)         //ゴールまでのユークリッド距離
		sc := float64(step) + dist               // 実コスト＋推定コスト
		p.plan[point{v.x, v.y}] = cost{step, dist, sc, point{p.x, p.y}}
	}
}

// 現座標を訪問済みにし、訪問予定から現座標を消去する
func (p *Explorer) closed() {
	cost := p.plan[point{p.x, p.y}]
	p.visited[point{p.x, p.y}] = cost
	delete(p.plan, point{p.x, p.y})
	if p.field[p.y][p.x] != start && p.field[p.y][p.x] != goal && p.field[p.y][p.x] != wall {
		p.field[p.y][p.x] = visit
	}
}

// 指定の座標が訪問済みかどうかを判定して返す
func (p Explorer) jadgeVisited(x, y int) bool {
	_, visited := p.visited[point{x, y}]
	return visited
}

// 指定座標からゴール座標までのユークリッド距離を計算して返す
func (p Explorer) calcDistance(x, y int) float64 {
	absx := math.Abs(float64(p.gx) - float64(x))
	absy := math.Abs(float64(p.gy) - float64(y))
	return math.Sqrt(math.Pow(absx, 2) + math.Pow(absy, 2))
}

// visited より再帰的に経路を返す
func (p *Explorer) follow() {
	points := []point{point{p.gx, p.gy}}
	pos := p.visited[point{p.gx, p.gy}].point
	for {
		if pos.x == p.sx && pos.y == p.sy {
			break
		} // スタートまでたどったら終了
		p.field[pos.y][pos.x] = route
		points = append(points, pos)
		pos = p.visited[pos].point // 移動元座標を取り出す
	}
	points = append(points, pos)
	// reverse して出力する
	for i := len(points) - 1; i >= 0; i-- {
		fmt.Print(points[i])
	}
	fmt.Print("\n")
}

// フィールド情報を出力する
func (p Explorer) puts(s ...interface{}) {
	fmt.Println(s, " ===> ")
	for _, v := range p.field {
		fmt.Println(strings.Join(v, ""))
	}
	fmt.Println("")
}

// 2次元配列を初期設定する
func initArr2d(h, w int) [][]string {
	arr := make([][]string, h)
	for i, _ := range arr {
		arr[i] = make([]string, w)
	}
	return arr
}

// 空白区切りの２つの数字文字列を２つの数値として返す
func tointXY(s string) (int, int) {
	line := strings.Fields(s)
	i, _ := strconv.Atoi(line[0])
	j, _ := strconv.Atoi(line[1])
	return i, j
}

// =================================================================================
// main
// =================================================================================
func main() {
	explorer := Explorer{}
	explorer.initialize()
	explorer.solve()
}

// すべての行を読み込み、改行区切りの文字列として返す
func geta() string {
	// 引数の指定がある場合は該当の定数をテストケースとする
	//       指定がない場合は標準入力を待つ
	if len(os.Args) > 1 && os.Args[1] == "test1" {
		return test1
	}
	if len(os.Args) > 1 && os.Args[1] == "test2" {
		return test2
	}
	var s string
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		s = s + scanner.Text() + "\n"
	}
	return s
}

// テストケース
// 一行目：フィールドサイズ(W,H)
// 二行目：スタート座標(X,Y)
// 三行目：ゴール座標(X,Y)
// 残りH行：フィールド
const test1 = `4 5
0 0
3 3
S..#
..#.
.##.
..#G
....
`
const test2 = `15 12
0 0
4 2
S#..#.#.##.#...
...##......##.#
.###G.###.###.#
....###.#..#...
#.#......#...#.
..#.##.#..#.##.
..##...#.#..##.
..###.#...#...#
.####...#####.#
####..##..#....
###.#.##.#..##.
###.........#..
`
