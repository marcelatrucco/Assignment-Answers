require './gene.rb'

class Network < Gene
    @@known_genes = []
    attr_accessor  :int
          
    def initialize (int:) 
        @int = int
    end
end