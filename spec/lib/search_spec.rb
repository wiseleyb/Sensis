require 'spec_helper'

describe Sensis do
  
  context "using sensis search" do

    it "should return results" do
      res = Sensis.search(:key => "v73669uhpjcmz443nb7zf444", :query => "poker", :location => "2034")
      res.results.size.should == 20
      res.code.should == 200
    end
    
    it "should raise error if :key is missing" do
      lambda { Sensis.search }.should raise_error(RuntimeError) 
    end
    
    it "should raise error if both query and location are missing" do
      lambda { Sensis.search(:key => "asdf") }.should raise_error(RuntimeError) 
    end
    
    it "should raise Net::HTTPServerException when an invalid key is given" do
      lambda {
        res = Sensis.search(:key => "43nb7zf444", :query => "poker", :location => "2034") 
      }.should raise_error(Net::HTTPServerException)
    end
    
  end
  
end
