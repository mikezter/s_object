class Date
  def to_gm_time
    time = Time.parse(self.to_s)
    time.gmtime
  end

  def to_local_time
    time = Time.parse(self.to_s)
    time.localtime
  end
end
