require "net/http"

def start_server
  ***REMOVED*** Remove the X to enable the parameters for tuning.
  ***REMOVED*** These are the default values as of Ruby 2.2.0.
  @child = spawn(<<-EOC.split.join(" "))
    XRUBY_GC_HEAP_FREE_SLOTS=4096
    XRUBY_GC_HEAP_INIT_SLOTS=10000
    XRUBY_GC_HEAP_GROWTH_FACTOR=1.8
    XRUBY_GC_HEAP_GROWTH_MAX_SLOTS=0
    XRUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=2.0
    XRUBY_GC_MALLOC_LIMIT=16777216
    XRUBY_GC_MALLOC_LIMIT_MAX=33554432
    XRUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.4
    XRUBY_GC_OLDMALLOC_LIMIT=16777216
    XRUBY_GC_OLDMALLOC_LIMIT_MAX=134217728
    XRUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR=1.2
    rails server -p3000 > /dev/null
  EOC
  sleep 0.1 until alive?
end

def alive?
  system("curl http://localhost:3000/ &> /dev/null")
end

def stop_server
  Process.kill "HUP", server_pid
  Process.wait @child
end

def server_pid
  `cat tmp/pids/server.pid`.to_i
end

def memory_size_mb
  (`ps -o rss= -p ***REMOVED***{server_pid}`.to_i * 1024).to_f / 2**20
end

***REMOVED*** In /etc/hosts I have api.rails.local set to 127.0.0.1 for
***REMOVED*** API testing on any app. Curl freaks out and takes extra
***REMOVED*** seconds to do the request to these .local things, so we
***REMOVED*** will use Net::HTTP for moar speed.
def do_request
  uri = URI("http://localhost:3000/jobs")
  req = Net::HTTP::Get.new(uri)
  ***REMOVED*** Remove the next line if you don't need HTTP basic authentication.
  ***REMOVED*** req.basic_auth("user@example.com", "password")
  req["Content-Type"] = "application/json"

  Net::HTTP.start("localhost", uri.port) do |http|
    http.read_timeout = 60
    http.request(req)
  end
end

results = []

***REMOVED*** You can’t just measure once: memory usage has some variance.
***REMOVED*** We will take the mean of 7 runs.
***REMOVED*** 7.times do
  ***REMOVED*** start_server

  used_mb = nil
  (1..50).map do |n|
    print "Request ***REMOVED***{n}..."
    do_request
    used_mb = memory_size_mb
    puts "***REMOVED***{used_mb} MB"
  end

  final_mb = used_mb
  results << final_mb
  puts "Final Memory: ***REMOVED***{final_mb} MB"

  ***REMOVED*** stop_server
***REMOVED*** end

mean_final_mb = results.reduce(:+) / results.size
puts "Mean Final Memory: ***REMOVED***{mean_final_mb} MB"
