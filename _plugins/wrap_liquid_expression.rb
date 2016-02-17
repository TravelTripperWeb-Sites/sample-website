module Liquid
  class Variable
    alias_method :render_orig, :render

    def render(context)
      obj = render_orig(context)
      if @name.kind_of?(Liquid::VariableLookup)
        var = context.find_variable(context.evaluate(@name.name))
        if var.kind_of?(DataObject) && var.respond_to?(:__MODEL__)
          obj = "<span class=\"tt-region\" data-model=\"#{var.__MODEL__}\" data-instance=\"#{var.__INSTANCE__}\">#{obj}</span>"
        end
      end

      obj
    end
  end
end
