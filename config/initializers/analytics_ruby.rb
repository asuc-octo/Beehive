Analytics = Segment::Analytics.new({
    write_key: 'QYjCRRJrSmgq0M2irqd4r7IvMqvfVuyM',
    on_error: Proc.new { |status, msg| print msg }
})
