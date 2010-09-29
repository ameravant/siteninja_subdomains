module UserExtension #:nodoc:
  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
    def extra_methods
      # add any class methods you want here, including validations
      def self.hello
        puts "This is a class method"
      end
      # since in line 2-4, you are only extending ClassMethods, you need to include the IntanceMethod 
      # Module inside the ClassMethod module so you'll get both on the send.
      include UserExtension::InstanceMethods
    end
  end
  module InstanceMethods
    def is_instance_of_user
      puts "I'm an instance of this class"
    end
  end
end
# This makes this module available within ActiveRecord::Base so its available to be sent to any class
ActiveRecord::Base.send(:include, UserExtension)
# This line will execute the method 'extra_methods' which makes the methods inside it available to the class
User.send(:extra_methods)
