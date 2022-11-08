#!/usr/bin/env ruby

require 'csv'

class Gene
    attr_accessor :gene_id
    attr_accessor :gene_name
    attr_accessor :mutant_phenotype
    attr_accessor :linked_genes

    @@all_genes = {}

    def initialize(params = {})
        @gene_id = params.fetch(:gene_id)
        @gene_name = params.fetch(:gene_name)
        @mutant_phenotype = params.fetch(:mutant_phenotype)

        @linked_genes = {} 

        format_gene = /A[Tt]\d[Gg]\d\d\d\d\d/ 
        unless format_gene.match(@gene_id) 
            abort("[Watch]: Wrong ID format found for ID: #{@gene_id} in file: #{ARGV[0]}. Please, correct according to: #{format_gene}")
        end
    end

    def self.find_gene_by_id(id) 
        @@all_genes.each do |gene|
            return gene[1] if gene[1].gene_id == id
        end
    end

    def self.load_from_file(gene_table_file)
        gene_table = CSV.read(gene_table_file, headers: true, col_sep: "\t") 
        gene_table.each() do |row|
            @@all_genes[row["Gene_ID"]] =  Gene.new(:gene_id => row["Gene_ID"], :gene_name => row["Gene_name"], :mutant_phenotype => row["mutant_phenotype"])
        end
        return @@all_genes 
    end

    def add_linked_gene(gene, chi_squared) 
        @linked_genes[gene] = chi_squared
    end

end
