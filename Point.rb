class Point
  attr_accessor :x, :y, :direction
  attr_reader :field, :h, :w
  def initialize(*xy)
    x,y=xy.flatten; x||=0;y||=0
    @x,@y=x,y
    @field=["."]
    @w,@h=0,0
    @direction=0
    @moveDir ||= [ [0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1] ]
    return @x,@y
  end
  def add(*xy) x,y=xy.flatten; x+=@x;y+=@y; return [x,y] end
  def xy() return @x,@y end
  def xy=(*xy) @x,@y=xy.flatten end
  def move?(d) # directionNumber,stepNumber
    moveDir = Marshal.load(Marshal.dump(@moveDir))
    a = moveDir.shift(@direction); moveDir.push(a)
    x,y=moveDir[d]
    return under?(x,y)
  end
  def move(d) # directionNumber,stepNumber
    moveDir = Marshal.load(Marshal.dump(@moveDir))
    a = moveDir.shift(@direction); moveDir.concat(a)
    x,y=moveDir[d]
    @x,@y = self.add(x,y)
    return @x,@y
  end
  def under?(x,y)
    return false if x>@w or y>@h or x<0 or y<0
    return true
  end
  def turn(d) @direction = (@direction+d) % 8; return @direction end
  def distance(*xy)
    x,y=xy.flatten
    a=(x-@x).abs; b=(y-@y).abs; c2 = a**2 + b**2
    return Math.sqrt(c2)
  end
  def angle(*xy)
    x,y=xy.flatten; a=x-@x; b=y-@y
    t = Math.atan2(b,a) * 180 / Math::PI
    t += 360 if t < 0
    return t
  end
  def field= (arr2d)
    arr2d = Marshal.load(Marshal.dump(arr2d))
    arr2d.map!{|s|s.split("")} if arr2d[0].kind_of?(String)
    @field = arr2d
    @h = @field.size-1; @w = @field[0].size-1
    return @field
  end
  def putsField() @field.each do |r| puts r.join end end
  def value(*xy)
    x,y=@x,@y if xy.size==0
    x,y=xy.flatten if xy.size>0
    return nil if y>@h or x>@w or x<0 or y<0
    return @field[y][x] 
  end
  def value=(c) @field[@y][@x] = c end
  def around(x,y,mode=4)
    directions = mode==8 ? @moveDir : @moveDir.values_at(0,2,4,6)
    aroundPos=[]
    directions.each do |dx,dy=r|
      nx,ny = x+dx,y+dy
      val = self.value(nx,ny)
      nextPos = [nx,ny]
      nextPos = [nil,nil] unless under?(nx,ny)
      nextPos = [nil,nil] if block_given? and !yield(val)
      aroundPos << nextPos
    end
    return aroundPos
  end
end
