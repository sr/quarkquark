class Class
  def dslify_accessor(*attributes)
    attributes.each do |attribute|
      class_eval <<-EOF
        alias_method :original_#{attribute}, :#{attribute}

        def #{attribute}(value=nil)
          send("#{attribute}=", value) if value
          original_#{attribute}
        end
      EOF
    end
  end
end
