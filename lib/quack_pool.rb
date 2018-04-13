require 'reentrant_mutex'

require 'quack_pool/error'


class QuackPool

  def initialize(resource_class: , size: Float::INFINITY)
    raise ArgumentError, "'resource_class' must respond_to 'new'" unless resource_class.respond_to?(:new)
    @resource_class = resource_class
    raise ArgumentError, "'size' must be an Integer" unless size.is_a?(Integer) || size == Float::INFINITY
    @max_size = size
    @resources = []
    @available_resources = []
    @mutex = ReentrantMutex.new
    @condition_variable = ConditionVariable.new
  end
  
  def absorb_resource(resource)
    @mutex.synchronize do
      raise Error, "resource does not belong to this pool" unless has_resource?(resource)
      raise Error, "resource already in pool" if resource_available?(resource)
      @available_resources.push(resource)
      @condition_variable.signal
    end
    nil
  end
  
  def has_resource?(resource)
    @mutex.synchronize do
      raise Error, "resource is not an instance of 'resource_class'" unless resource.is_a?(@resource_class)
      @resources.include?(resource)
    end
  end
  
  def release_resource
    @mutex.synchronize do
      if @available_resources.any?
        release_available_resource
      elsif @resources.length < @max_size
        build_new_resource
      else
        release_next_available_resource
      end
    end
  end
  
  def resource_available?(resource)
    @mutex.synchronize do
      raise Error, "resource does not belong to this pool" unless has_resource?(resource)
      @available_resources.include?(resource)
    end
  end
  
  private
  
  def build_new_resource
    new_resource = @resource_class.new
    raise Error, "'new_resource' must be unique" if has_resource?(new_resource)
    @resources << new_resource
    new_resource
  end
  
  def release_available_resource
    @available_resources.pop
  end
  
  def release_next_available_resource
    @condition_variable.wait(@mutex)
    release_available_resource
  end
  
end
