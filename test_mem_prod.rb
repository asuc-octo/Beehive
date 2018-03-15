require "net/http"

@url = "https://whispering-sierra-88360.herokuapp.com"
# @url = "http://beehive.berkeley.edu"

def do_request
    uri = URI(@url)
    Net::HTTP.get(uri)
end

(1..10000).map do |n|
    puts "Request #{n}..."
    time = Time.now
    do_request
    puts Time.now - time
end
