module TimeExtensions
  def coerce(val)
    case val
      when Integer
        Time.at(val)
      when String
        Time.parse(val)
      else
        val
    end
  end
end
Time.extend(TimeExtensions)
