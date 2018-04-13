require 'quack_pool'

RSpec.describe QuackPool do
  resource_class = Class.new
  
  context "when resource class is passed that does not respond to 'new'" do
    it "should raise error" do
      klass = Class.new
      klass.private_class_method(:new)
      stub_const 'BadResource', klass
      expect { QuackPool.new(resource_class: BadResource) }.to raise_error ArgumentError
    end
  end
  
  context "when size is not specified" do
  
    pool = QuackPool.new(resource_class: resource_class)
  
    describe "#release_resource" do
    
      it "should return instance of given resource class" do
        resource = pool.release_resource
        expect(resource).to be_a(resource_class)
        resource = pool.release_resource
        expect(resource).to be_a(resource_class)
      end
      
      context "when resource it rereturned to pool" do
        it "should return instance of given resource class" do
          resource = pool.release_resource
          pool.absorb_resource(resource)
          resource = pool.release_resource
          expect(resource).to be_a(resource_class)
        end
      end
      
    end
    
    describe "#absorb_resource" do
      
      it "should accept resource" do
        resource = pool.release_resource
        expect { pool.absorb_resource(resource) }.not_to raise_error
      end
      
      context "when resource is absorbed twice" do
        it "should raise error" do
          resource = pool.release_resource
          pool.absorb_resource(resource)
          expect { pool.absorb_resource(resource) }.to raise_error QuackPool::Error
        end
      end
      
      context "when resource is returned to wrong pool" do
        it "should raise error" do
          resource = pool.release_resource
          pool2 = QuackPool.new(resource_class: resource_class)
          expect { pool2.absorb_resource(resource) }.to raise_error QuackPool::Error
        end
      end
    
    end
    
  end
  
  context "when size is specified" do
    pool = QuackPool.new(resource_class: resource_class, size: 2)
    
    describe "#release_resource" do
    
      context "when no resources are available" do
        it "will wait until resource has been returned to pool" do
          thread = Thread.new do
            resource1 = pool.release_resource
            resource2 = pool.release_resource
            sleep 2
            pool.absorb_resource(resource1)
          end
          sleep 1
          resource = pool.release_resource
          thread.join
          expect(resource).to be_a(resource_class)
        end
      end
      
    end
  
  end
  
end
