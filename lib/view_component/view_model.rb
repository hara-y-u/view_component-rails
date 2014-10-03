class ViewComponent
  class ViewModel < ActionView::Base
    attr_accessor :component

    def self.define_local_getters(locals)
      locals.each do |key, val|
        fail "Method for local variable #{key} is already defined" if
          method_defined?(key)

        define_method key.to_sym do
          val
        end
      end
    end
  end
end
