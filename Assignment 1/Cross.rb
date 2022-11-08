#!/usr/bin/env ruby


class Cross
    attr_accessor :parent1
    attr_accessor :parent2
    attr_accessor :f2_wild
    attr_accessor :f2_p1
    attr_accessor :f2_p2
    attr_accessor :f2_p1p2

    @@all_crosses = {}

    def initialize(params = {})
        @parent1 = SeedStock.get_seed_stock(params.fetch(:parent1)).gene
        @parent2 = SeedStock.get_seed_stock(params.fetch(:parent2)).gene
        @f2_wild = params.fetch(:f2_wild).to_f
        @f2_p1 = params.fetch(:f2_p1).to_f
        @f2_p2 = params.fetch(:f2_p2).to_f
        @f2_p1p2 = params.fetch(:f2_p1p2).to_f

    end


    def self.load_from_file(crossdata_file)
        crossdata_table = CSV.read(crossdata_file, headers: true, col_sep: "\t")
        crossdata_table.each.with_index() do |row|
            @@all_crosses[row["Parent1"]+"_"+row["Parent2"]] =  Cross.new(:parent1 => row["Parent1"], :parent2 => row["Parent2"],
                                                                          :f2_wild => row["F2_Wild"], :f2_p1 => row["F2_P1"],
                                                                          :f2_p2 => row["F2_P2"], :f2_p1p2 => row["F2_P1P2"])
        end
        return @@all_crosses
    end

    
    def self.analyze_linkage(cross_object)
        sum_row = cross_object.f2_wild + cross_object.f2_p1 + cross_object.f2_p2 + cross_object.f2_p1p2 #Sum of all values
        expected_wild = sum_row * 9/16 
        expected_f2_p1 = sum_row * 3/16
        expected_f2_p2 = sum_row * 3/16
        expected_f2_p1p2 = sum_row * 1/16

        #chi_squared: Summ: ((O-E)^2/E)
        chi_squared = ( (cross_object.f2_wild - expected_wild)**2/expected_wild  +
                        (cross_object.f2_p1 - expected_f2_p1)**2/expected_f2_p1 +
                        (cross_object.f2_p2 - expected_f2_p2)**2/expected_f2_p2 +
                        (cross_object.f2_p1p2 - expected_f2_p1p2)**2/expected_f2_p1p2 )

                # for 95% probability of correlation(p-value:0.05), the expected chi-squared is 7.815
        if chi_squared > 7.815
            
            puts "#{cross_object.parent1.gene_name} is linked to #{cross_object.parent2.gene_name} with a chi-square score of #{chi_squared}"
            cross_object.parent1.add_linked_gene(cross_object.parent2.gene_name, chi_squared) 
            cross_object.parent2.add_linked_gene(cross_object.parent1.gene_name, chi_squared)
        end
    end


end
