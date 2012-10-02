require "bundler/setup"
require 'csv'
require "discrete_event"
require_relative "simulate_qos/probability"
require_relative "simulate_qos/packet"


class SimulateQOS < DiscreteEvent::Simulation

  attr_reader :arrival_rate, :service_rate, :system, :sent_packets, :queues, :enqueued_packets

  #the arrival rate = rate that the packets are arriving
  #the processing rate = rate that the packets are being processed
  #
  def initialize(arrival_rate, service_rate)
    super()
    #at begining we have the same change to get TCP/UDP packets
    @protocol_dice = ProtocolProbability.new [0.5,0.5]
    #We are assuming that in a network where QoS is configured
    #we have more normal traffic. some really special and low traffic 
    @priority_dice = PriorityProbability.new [0.10,0.70,0.20]
    @queues = {:low=>[],:normal=>[],:high=>[]}
    @sent_packets = []
    @arrival_rate = arrival_rate
    @service_rate = service_rate
    @csv = open_csv('results.csv')
  end

  def get_prio(prio = 1)
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

  def get_complement(e)
    1 - e.to_f
  end

  def new_packet
    after rand_exp(arrival_rate) do
      proto = @protocol_dice.next
      prio = @priority_dice.next
      q = @queues[get_prio(prio)]
      q << Packet.new(proto, prio,q.size)
      #TODO
      #it should serve all three queues
      rate = calculate_service_rate(prio)
      serve_queue(q,rate) if q.size == 1
      #we will simulate the TCP RED or any other "slow down algorithm"
      #TODO
      #be dynamic
      @protocol_dice = case q.size
        when 0..10
          ProtocolProbability.new [0.5,0.5]
        when 10..100
          ProtocolProbability.new [0.3,0.7]
        when 100..999
          ProtocolProbability.new [0.2,0.8]
        when 1000...100000
          ProtocolProbability.new [0.1,0.9]
        else
          @protocol_dice
      end
      new_packet
    end
  end

  def queue_length(prio)
    if @queues[get_prio(prio)].empty?
      0
    else
      @queues[get_prio(prio)].length - 1
    end
  end

  # Sample from Exponential distribution with given mean rate.
  def rand_exp(rate = 1.0)
        -Math::log(rand)/rate
  end

  def open_csv(filename)
    @csv = CSV.open(filename,"wb")
  end

  def save_queue_to_csv(line)
    line.each do |l|
      @csv << l.to_s.split(':')
    end
  end

  def calculate_service_rate(queue)
    #0,1,2
    #the time should get smaller if the queue is higher
    @service_rate / ((queue + 1) ** 2)
  end

  def serve_queue(queue, rate)
    queue.first.service_begin = now
    after rand_exp(rate) do
      queue.first.service_end = now
      save_queue_to_csv(queue)
      sent_packets << queue.shift
      serve_queue(queue,rate) unless queue.empty?
    end
  end
  def start
    new_packet
  end
end

