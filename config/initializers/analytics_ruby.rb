unless ENV['ANALYTICS_ID'].nil?
    Analytics = Segment::Analytics.new({
        write_key: ENV['ANALYTICS_ID'],
        on_error: Proc.new { |status, msg| print msg }
    })
end
