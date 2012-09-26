require "bundler/setup"
require 'csv'
require "discrete_event"
require "vose"
require_relative "simulate_qos/packet"


class SimulateQOS < DiscreteEvent::Simulation

  attr_reader :arrival_rate, :service_rate, :system, :packets_sent, :queues

  #the arrival rate = rate that the packets are arriving
  #the processing rate = rate that the packets are being processed
  #
  def initialize(arrival_rate, service_rate)
    super()
    @protocol_dice = ProtocolProbability.new [0.5,0.5]
    @priority_dice = PriorityProbability.new [0.33,0.33,0.33]
    @queues = {:low=>[],:normal=>[],:high=>[]}
    @packets_sent = 0
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
      q << Packet.new(proto, prio)
      #TODO
      #it should serve all three queues
      serve_queue(q) if q.size == 1
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
          ProtocolProbability.new [0.1,0.8]
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

  def serve_queue(queue)
    #queue.first.service_begin = now
    after rand_exp(service_rate) do
      #queue.first.service_end now
      save_queue_to_csv(queue)
      @packets_sent += 1
      serve_queue(queue) unless queue.empty?
    end
  end
  def start
    new_packet
  end
end

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

