trying to simulate a naive implentation of a queue based QoS.

Imagine that there are two protocols (udp and tcp)

when the Queue is getting full, TCP starts to slowdown, but not UDP

After sometime the Queue should be mainly UDP and TCP will just get
dropped.. making the Queuing inefficient 

at bin/run_simulator you can ajust the amount of packets to be sent
