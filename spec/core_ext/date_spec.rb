require 'spec_helper'

describe Date do
  it '#to_gm_time' do
    date = DateTime.now
    date.to_gm_time.should be_within(10).of Time.now.utc
  end

  it '#to_local_time' do
    date = DateTime.now.new_offset
    date.to_local_time.should be_within(10).of Time.now
  end

end
