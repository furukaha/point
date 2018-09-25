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
    # �H���i�G�b�W�j�̐��A�w�i�m�[�h�j�̐��A�ړI�n�ԍ�
    @n,@v,@t = $stdin.gets.chomp.split.map(&:to_i)
    # �w1�C�w2�C�w�Ԃ̉^���i�R�X�g�j
    @edges=[]; @n.times {@edges << $stdin.gets.chomp.split.map(&:to_i)}
    @costs={}; @edges.each do |s,e,cost| @costs[ [s,e].sort ] = cost end
    @nodes=Array.new(@v){Float::INFINITY}
  end
  def run
    # �_�C�N�X�g���o�H�T��
    @nodes[0]=0
    changed_nodes = *(0..@v-1)
    # �m�[�h�ɕω����Ȃ��Ȃ�܂ŌJ��Ԃ�
    until changed_nodes==[] do
      # �ω��̂������m�[�h���ӂ̂ݍČv�Z����
      changed_nodes = loop_run(changed_nodes)
      changed_nodes.flatten!.uniq!
      #puts "�Čv�Z���܂��F#{changed_nodes}"
    end
    puts @nodes[@t]
  end
  def loop_run(changed_nodes)
    # �O��ω��̂������m�[�h���ӂ̂݃R�X�g�v�Z����
    changed=[]
    changed_nodes.each do |n|
      # �ڑ����ꂽ���͂̃m�[�h�ꗗ���擾����
      nodes = around_nodes(n)
      #puts "#{n} ���N�_�Ƃ��� #{nodes} ���v�Z���܂�"
      # ���͂̃m�[�h�ւ̈ړ��R�X�g���v�Z����
      changed << calc_cost(nodes,n)
      #puts "�v�Z���ʁF#{@nodes}"
    end
    return changed
  end
  def calc_cost(nodes,from)
    # �e�m�[�h�̃R�X�g���v�Z����B���ǂ��R�X�g�ł���΍X�V����
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
    # ���͂̐ڑ����ꂽ�m�[�h�ԍ��ꗗ��Ԃ�
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
