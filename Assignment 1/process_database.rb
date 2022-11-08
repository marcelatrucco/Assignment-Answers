#!/usr/bin/env ruby

require './Gene.rb'
require './SeedStock.rb'
require './Cross.rb'

# Planting from the stock

puts "1) Simulate planting 7 grams of seeds from each of the records in the seed stock"
puts

all_genes = Gene.load_from_file(ARGV[0])

all_seedstock = SeedStock.load_from_file(ARGV[1])

all_seedstock.each do |this_seed|
    this_seed[1].plant(7) 
end

SeedStock.write_database(ARGV[3])
puts


puts "2) Process the information in cross_data.tsv to determine which genes are
genetically-linked"
puts
puts "Linkage analysis"
puts 

all_crosses = Cross.load_from_file(ARGV[2])

all_crosses.each do |this_cross|
    Cross.analyze_linkage(this_cross[1])
end

puts "The linkage report is:"
puts

all_genes.each do |this_gene|
    this_gene[1].linked_genes.each do |linked| 
        linked_gene, chi_squared = linked 
        puts "#{this_gene[1].gene_name} is linked to #{linked_gene}"
    end
end


