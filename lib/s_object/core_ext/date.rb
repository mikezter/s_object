class Date
  def utc
    time = Time.parse(self.to_s)
    time.gmtime
  end

  def localtime
    time = Time.parse(self.to_s)
    time.localtime
  end
end
