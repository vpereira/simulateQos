require_relative './spec_helper'

describe Packet do
  describe "no parameters" do
    before do
      @pkt = Packet.new
    end
    it "should have a priority" do
      @pkt.priority.wont_be_nil
    end
    it "should have a protocol" do
      @pkt.protocol.wont_be_nil
    end
  end
  describe "integer as param" do
    before do
      @pkt = Packet.new 6
    end
    it "should have a priority" do
      @pkt.priority.wont_be_nil
    end
    it "should have a protocol" do
      @pkt.protocol.wont_be_nil
    end
   end
end
