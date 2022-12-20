require 'net/http'   
require 'bio'
require './Gene.rb'

# Importing Arabidopsis genelist

genelist= Array.new
f = File.open(ARGV[0], "r") # input in the console: Interaction.rb Ara_GeneList.txt 
f.readlines.each do |line|
    line.strip().upcase()
    genelist.append(line)
end

#1:  Using BioRuby, examine the sequences of the ~167 Arabidopsis genes 
genelist.each do |gene|
    address = URI("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene}")  
    response = Net::HTTP.get_response(address)  
    record = response.body
    entry = Bio::EMBL.new(record)
    bioseq = entry.to_biosequence
    Gene.new(id: bioseq)
     
#2: Loop over every exon feature, and scan it for the CTTCTT sequence
#3: Take the coordinates of every CTTCTT sequence and create a new Sequence Feature               
  
Gene.get_genes.each do |gene|
        genus, sp, ch, chr_, source, par, seq, loc = gene.id.definition.split() #Ensembl accession is splitted to retrieve information of the chromosome and
        ch_start, ch_end = loc.split("..") # and the gene coordinates
        ch_start = ch_start.to_i
        ch_end = ch_end.to_i
        gene.id.features.each do |feature|
            featuretype=feature.feature
            next unless featuretype == 'exon'
                feature.locations.each do |location|
                exons= gene.id[location.from..location.to] 
                if location.strand == 1 and exons
                    matchfw = exons.match(/CTTCTT/i)
                    unless matchfw ==nil
                        genearray.append(gene)
                        first_fw_coordinate = exons.enum_for(:scan, /CTTCTT/i).map { Regexp.last_match.begin(0) }
                        first_fw_coordinate = first_fw_coordinate[0]         #start location relative to the exon (+strand) 
                        ch_first_fw_coord = ch_start + first_fw_coordinate   #start location in the chromosome (+strand)
                        last_fw_coordinate = exons.enum_for(:scan, /CTTCTT/i).map { Regexp.last_match.end(0)-1 }
                        last_fw_coordinate = last_fw_coordinate[0]           #final location relative to the exon (+strand)                     # puts "Match Last coordinate/s: #{last_fw_coordinate}"
                        ch_last_fw_coord = ch_start + last_fw_coordinate     #final location in the chromosome (+strand)                  # puts chr_last_fw_coord 
                        first_fw_coordinate = first_fw_coordinate.to_s
                        last_fw_coordinate = last_fw_coordinate.to_s 
                        myrepeat = matchfw                                                 
                        f1 = Bio::Feature.new("myrepeat","#{first_fw_coordinate}".."#{last_fw_coordinate }")
                        f1.append(Bio::Feature::Qualifier.new('seqid', "#{chr_}"))
                        f1.append(Bio::Feature::Qualifier.new('source', 'BioRuby'))
                        f1.append(Bio::Feature::Qualifier.new('type', 'dispersed repeat'))
                        f1.append(Bio::Feature::Qualifier.new('start', "#{first_fw_coordinate}"))
                        f1.append(Bio::Feature::Qualifier.new('end', "#{last_fw_coordinate}"))
                        f1.append(Bio::Feature::Qualifier.new('chrstart', "#{ch_first_fw_coord}"))
                        f1.append(Bio::Feature::Qualifier.new('chrend', "#{ch_last_fw_coord}"))                    
                        f1.append(Bio::Feature::Qualifier.new('score', '.'))
                        f1.append(Bio::Feature::Qualifier.new('strand', '+'))
                        f1.append(Bio::Feature::Qualifier.new('phase', '.'))
                        f1.append(Bio::Feature::Qualifier.new('attributes', '.'))
                        gene.id.features << f1 
                    end                     
                elsif location.strand == -1 and exons
                    matchrv = exons.match(/AAGAAG/i)
                    unless matchrv ==nil
                        first_rv_coordinate = exons.enum_for(:scan, /AAGAAG/i).map { Regexp.last_match.begin(0)+1 }
                        first_rv_coordinate = first_rv_coordinate[0]            #start location relative to the exon (-strand)                    # puts "Match Start coordinate/s:  #{first_rv_coordinate}"    
                        last_rv_coordinate = exons.enum_for(:scan, /AAGAAG/i).map { Regexp.last_match.end(0) }
                        last_rv_coordinate = last_rv_coordinate[0]              #final location relative to the exon (-strand)                      # puts "Match Last coordinate/s: #{last_rv_coordinate}"
                        ch_first_rv_coord = ch_start + last_rv_coordinate        #start location in the chromosome (-strand)   
                        ch_last_rv_coord = ch_start + first_rv_coordinate        #final location in the chromosome (-strand)    
                        first_rv_coordinate = first_rv_coordinate.to_s
                        last_rv_coordinate = last_rv_coordinate.to_s
                        myrepeat = matchrv
                        f2 = Bio::Feature.new("myrepeat","#{first_rv_coordinate}".."#{last_rv_coordinate }")  
                        f2.append(Bio::Feature::Qualifier.new('seqid', "#{chr_}"))
                        f2.append(Bio::Feature::Qualifier.new('source', 'BioRuby'))
                        f2.append(Bio::Feature::Qualifier.new('type', 'dispersed repeat'))
                        f2.append(Bio::Feature::Qualifier.new('start', "#{first_rv_coordinate}"))
                        f2.append(Bio::Feature::Qualifier.new('end', "#{last_rv_coordinate}"))
                        f2.append(Bio::Feature::Qualifier.new('chrstart', "#{ch_first_rv_coord }"))
                        f2.append(Bio::Feature::Qualifier.new('chrend', "#{ch_last_rv_coord}"))
                        f2.append(Bio::Feature::Qualifier.new('score', '.'))
                        f2.append(Bio::Feature::Qualifier.new('strand', '-'))
                        f2.append(Bio::Feature::Qualifier.new('phase', '.'))
                        f2.append(Bio::Feature::Qualifier.new('attributes', '.'))    
                        gene.id.features << f2                                        
                    end
                end  
            end
        end        
    end    
end

#4a:  Loop over each one of your CTTCTT features (using the #features method 
#   of the EnsEMBL Sequence object) and create a GFF3-formatted file of these features
# 
Gene.get_genes.each do |gene|
     gene.id.features.each do |feature|
        featuretype=feature.feature
        next unless featuretype =="myrepeat"
             qual = feature.assoc
             chromosome = qual['seqid']
             source = qual['source']
             type = qual['type']
             start = qual['start']
             final = qual['end']
             score = qual['score']
             strand = qual['strand']
             phase = qual['phase']
             attributes = qual['attributes']
             puts("chr#{chromosome}\t#{source}\t#{type}\t#{start}\t#{final}\t#{score}\t#{strand}\t#{phase}\t#{attributes}")
         end      
    end         

#4b:  Output a report showing which (if any) genes 
#on your list do NOT have exons with the CTTCTT repeat
    

    
#5:   Re-execute your GFF file creation so that 
# the CTTCTT regions are now in the full chromosome coordinates used by Ensembl
    
    File.open('./myfile.tsv', 'w') do |file| 
        file.puts("##gff-version 3")
        Gene.get_genes.each do |gene|
            gene.id.features.each do |feature|
                featuretype=feature.feature
                next unless featuretype =="myrepeat"
                    qual = feature.assoc
                    chromosome = qual['seqid']
                    source = qual['source']
                    type = qual['type']
                    start = qual['chrstart']
                    final = qual['chrend']
                    score = qual['score']
                    strand = qual['strand']
                    phase = qual['phase']
                    attributes = qual['attributes']
                    puts("chr#{chromosome}\t#{source}\t#{type}\t#{start}\t#{final}\t#{score}\t#{strand}\t#{phase}\t#{attributes}")
                    file.puts("chr#{chromosome}\t#{source}\t#{type}\t#{start}\t#{final}\t#{score}\t#{strand}\t#{phase}\t#{attributes}")
                end
            end
        end 
        
 #6:   Prove that your GFF file is correct by uploading it to ENSEMBL 
 # and adding it as a new “track” to the genome browser of Arabidopsis 
 
 ###### The file has been uploaded #########