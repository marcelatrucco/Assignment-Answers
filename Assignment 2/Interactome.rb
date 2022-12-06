require './gene.rb'
require 'rest-client' 
require './Network.rb'
require './fetch.rb'
require 'json'

puts "REPORT"
puts
genelist=[]
f = File.open(ARGV[0], "r") # input in the console: Interaction.rb Ara_GeneList.txt 
f.readlines.each do |line|
    line.strip!
    line= line.upcase()
    Gene.new(id: line)
    genelist.append(line)
end

Gene.get_genes.each do |gene|
    puts "AGI_locus: #{gene.id}"

    prot = fetch(url: "https://string-db.org/api/json/interaction_partners?identifiers=#{gene.id}"); 
    if prot
        puts "STRING_network"
        protfile = JSON.parse(prot.body)
        protfile.each do |line|
            interactor_AGI = line["stringId_B"].match(/AT\wG\d\d\d\d\d/)
            if genelist.include?("#{interactor_AGI}")
                puts "STRING gene below is included in the Arabidopsis list"
            end 
            n= Network.new(int: interactor_AGI)
            puts "#{n.int}"
        end
    end 
    kegg = fetch(url: "https://rest.kegg.jp/get/ath:#{gene.id}")
    if kegg
        path= kegg.body.match(/ath\d+\s+\w+\s+\w+/)
        if path== nil
            puts "Not Kegg found for AGI_locus"
            puts
        else
            puts "Kegg for AGI_locus: #{path}"
            puts
        end       
    end
    response = fetch(url: "http://togows.dbcls.jp/entry/uniprot/#{gene.id}")
    if response
        GO_ont = response.body.match(/GO:(\d+)/)
        if GO_ont == nil
            puts "Not Ontology found for the AGI locus"
        else
            puts "The Ontology is #{GO_ont}"
        end 
    end 
    puts "#########################################################"
end
