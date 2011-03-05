
module CEF
  class FileLogger
    def initialize(*args)
      Hash[*args].each { |argname, argval| self.send(("%s="%argname), argval) }
    end
  end
end
