class QuackPool

  def initialize(resource_class: , size: Float::INFINITY)
    raise ArgumentError, "'resource_class' must respond_to 'new'" unless resource_class.respond_to?(:new)
    @resource_class = resource_class
    raise ArgumentError, "'size' must be an Integer" unless size.is_a?(Integer) || size == Float::INFINITY
    @max_size = size
    @resources = []
    @available_resources = []
    @mutex = Mutex.new
    @condition_variable = ConditionVariable.new
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
  
  def absorb_resource(resource)
    @mutex.synchronize do
      raise ArgumentError, "'resource' does not belong to this pool" unless @resources.include?(resource)
      raise ArgumentError, "'resource' already in pool" if @available_resources.include?(resource)
      @available_resources.push(resource)
      @condition_variable.signal
    end
    nil
  end
  
  private
  
  def release_available_resource
    @available_resources.pop
  end
  
  def build_new_resource
    new_resource = @resource_class.new
    raise "'new_resource' must be unique" if @resources.include?(new_resource)
    @resources << new_resource
    new_resource
  end
  
  def release_next_available_resource
    @condition_variable.wait(@mutex)
    release_available_resource
  end
  
end
