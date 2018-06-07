Analytics = Segment::Analytics.new({
    write_key: '29YrYgRuROtuV4Ub6kNLEUWl5cT7HCHI',
    on_error: Proc.new { |status, msg| print msg }
})
