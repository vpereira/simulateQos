require 'vose'
class Probability
  def initialize(probs = [0.5,0.5])
    @vose = Vose::AliasMethod.new probs
  end
  def next
    @vose.next
  end
end

class ProtocolProbability < Probability
end

class PriorityProbability < Probability
end

