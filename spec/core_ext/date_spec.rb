require 'spec_helper'

describe Date do
  it '#utc' do
    date = DateTime.now
    date.utc.should be_within(10).of Time.now.utc
  end

  it '#localtime' do
    date = DateTime.now.new_offset
    date.localtime.should be_within(10).of Time.now
  end

end
