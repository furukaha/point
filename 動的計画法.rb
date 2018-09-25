# coding: Shift_JIS

class Array
  #     U:0           R:2         D:4          R:6
  V = [ [0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1] ]
  def self.new2d(y,x,v=nil) return Array.new(y).map{Array.new(x){v}} end
  def puts2d(c="") self.each{|r| puts r.join(c)} end
  def sum2d(arr2d) total=0; arr2d.each do |r| total+=r.sum end; return total end
  def ave2d(arr2d,n) total=0; arr2d.each do |r| total+=r.sum end; return total/n end
  def sum() return self.inject(:+) end
  def deep_dup() return Marshal.load(Marshal.dump(self)) end
  def to_i() return self.map(&:to_i) end
  def to_f() return self.map(&:to_f) end
end


# �A���S���Y�� �F ���I�v��@
class Code
  def initialize
    @m = $stdin.gets.chomp.to_i
    @n = $stdin.gets.chomp.to_i
    @q=[]; @n.times do |n| @q << $stdin.gets.chomp.split.to_i end
  end
  def run
    # ���I�v��@
    dp = {0 => 0} # k:�l�� v:�R�X�g
    @n.times do |n|
      # ���łɂ���v�Z���ʂɑ΂��āA�u�����čs���v���u�����čs���Ȃ����v
      # �����čs���Ȃ��ꍇ�͂��̂܂܂Ȃ̂ŁA�u�����čs�����v�ꍇ�̌v�Z���s��
      ans = take_or_not(n,dp)
      # �u�����čs�����ꍇ�v�Ɓu�����čs���Ȃ��ꍇ�v�̌v�Z���ʂ��}�[�W����B
      # �R�X�g�̒Ⴂ����D�悷��B
      # �V�����v�Z���ʂ��쐬����A���̃��[�v�ŐV�����v�Z���ʂƎ��̃A�C�e���Ō��؂���
      dp.merge!(ans){|k,ov,nv| ov > nv ? nv : ov}
      p dp
    end
    dp.select!{|k,v| k>=@m} # �K�v�l���ȏ�
    puts dp.min_by{|k,v| v}[1] # �����Œ�R�X�g

  end
  def take_or_not(n,dp)
    # �n���ꂽ�v�Z���ʂ�items[n]���|�����킹�����ʂ�Ԃ�
    ans={}
    dp.each do |k,v|
      # �l��            �R�X�g
      ans[k+@q[n][0]] = v + @q[n][1]
    end
    return ans
  end
end

inputs = <<_EOS
60 
3 
40 4300 
30 2300 
20 2400 
%
250 
5 
35 3640 
33 2706 
98 9810 
57 5472 
95 7790
_EOS

inputs.split("%\n").each do |input|
  $stdin = StringIO.new(input)
  Code.new.run
end
