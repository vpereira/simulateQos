require_relative '../lib/simulate_qos'

#a small delay in the packet processing
sim = SimulateQOS.new(0.5,1.0)
sim.start
sim.run do
  throw :stop if sim.sent_packets.size >= 1000
end  

puts "Packets sent: #{sim.sent_packets.size}"
puts "Packets enqueued #{sim.enqueued_packets}"
puts "Packets on the queues:"
sim.queues.each_with_index do |q,i|
  puts "#{i}: #{q.size}"
end

