require_relative '../lib/simulate_qos'

#a small delay in the packet processing
sim = SimulateQOS.new(0.5,1.0)
sim.start
sim.run do
  throw :stop if sim.packets_sent >= 10000
end
