
class Packet 
  attr_accessor :protocol, :priority, :queue_on_arrival, :service_begin, :service_end

  #priority = 0,1,2 # LOW, NORMAL, HIGH
  PRIORITIES = [0, 1, 2]
  #protocol = 0 or 1
  #0 TCP and UDP 1 (not IANA just for sake of Simulation
  PROTOCOLS  = [0, 1]

  def initialize(protocol=nil, priority=nil, queue_on_arrival = 0)

    if protocol.is_a? Integer
      @protocol = protocol
    end

    if priority.is_a? Integer
      @priority = priority
    end

    @protocol = protocol || PROTOCOLS.sample
    @priority = priority || PRIORITIES.sample
    @queue_on_arrival = queue_on_arrival

  end

  def get_prio(prio)
    case prio
      when 0
        :low
      when 1
        :normal
      when 2
        :high
      else
        :normal
    end
  end
  def get_protocol(proto)
    case proto
      when 0
        :tcp
      when 1
        :udp
      else
        :tcp
    end
  end
  def to_s
    "#{get_protocol(protocol)}:#{get_prio(priority)}:#{service_begin}:#{service_end}"
  end

end
