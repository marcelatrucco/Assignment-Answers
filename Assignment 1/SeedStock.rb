#!/usr/bin/env ruby

require 'date'

class SeedStock

    attr_accessor :seed_stock
    attr_accessor :gene_id
    attr_accessor :gene
    attr_accessor :last_planted
    attr_accessor :storage
    attr_accessor :grams_remaining

    @@all_seedstock = {}

    def initialize(params = {})
        @gene_id = params.fetch(:gene_id)
        @gene = Gene.find_gene_by_id(@gene_id)
        @storage = params.fetch(:storage)
        @seed_stock = params.fetch(:seed_stock)
        @last_planted = params.fetch(:last_planted)
        @grams_remaining = params.fetch(:grams_remaining).to_i 
    end


    def self.load_from_file(seedstock_file)
        stock_table = CSV.read(seedstock_file, headers: true, col_sep: "\t") 
        @stock_header = stock_table.headers 
        stock_table.each.with_index() do |row|
            @@all_seedstock[row["Seed_Stock"]] =  SeedStock.new(:gene_id => row["Mutant_Gene_ID"], :storage => row["Storage"], :seed_stock => row["Seed_Stock"],
                                                                :last_planted => row["Last_Planted"], :grams_remaining => row["Grams_Remaining"])
        end
        return @@all_seedstock 
    end

    def self.get_seed_stock(stock_ID) 
        @@all_seedstock.each do |stock|
            return stock[1] if stock[1].seed_stock == stock_ID
        end
    end

    def plant(number_of_grams) 
        if @grams_remaining < number_of_grams
            puts "[Watch]: #{@seed_stock} has only #{@grams_remaining} grams.It should be refilled."
            @grams_remaining = 0
        elsif @grams_remaining == number_of_grams
            puts "[Watch]: #{@seed_stock} is depleted. It should be refilled."
            @grams_remaining = 0 
        else
            @grams_remaining = @grams_remaining - 7
        end
        @last_planted = DateTime.now.strftime('%-d/%-m/%Y') 
    end

    def self.write_database(after_plant_file)
        after_plant = File.open(after_plant_file, 'w')
        after_plant.puts(@stock_header.join("\t")) 
        @@all_seedstock.each do |this_stock|
            
            after_plant.puts([this_stock[1].seed_stock, this_stock[1].gene_id, this_stock[1].last_planted, this_stock[1].storage, this_stock[1].grams_remaining].join("\t"))
        end
    end

end
