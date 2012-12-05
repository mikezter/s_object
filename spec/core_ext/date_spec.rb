require 'spec_helper'

describe Date do
  before :each do
    @date = DateTime.new(2012, 5, 5, 12, 30, 0)
  end

  it '#to_gm_time' do
    pending 'test only public methods'
    date_with_new_offset = @date.new_offset
    @date.should_receive(:convert_to_time).with(date_with_new_offset, :gm)
    @date.to_gm_time
  end

  it '#to_local_time' do
    pending 'test only public methods'
    date_with_new_offset = @date.new_offset(DateTime.now.offset - @date.send(:offset))
    @date.should_receive(:convert_to_time).with(date_with_new_offset, :local).once
    @date.to_local_time
  end

end
