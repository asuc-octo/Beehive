def server_pid
  `cat tmp/pids/server.pid`.to_i
end

def memory_size_mb
  (`ps -o rss= -p ***REMOVED***{server_pid}`.to_i * 1024).to_f / 2**20
end

puts memory_size_mb
