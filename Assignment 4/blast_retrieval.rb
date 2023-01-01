require 'bio'
require 'stringio'


## An evalue: 1.10-6 was selected based on the article: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0101850
##
## First Blast (blastx)is done using Arabidopsis DNA sequences against S. Pombe proteins db
best_hits_blastx={}
factory = Bio::Blast.local('blastx', './protein_db')
Bio::FlatFile.auto('./seq_target.fa').each_entry do |entry|                
    report = factory.query(entry) 
    report.each do |hit|
        evalue = evalue.to_i
        next unless hit.evalue <= 1e-6
        query_id_nucl = hit.query_def.split("|")[0].strip
        target_id_prot = hit.target_id.split("|")[0].strip
        best_hits_blastx[query_id_nucl]= target_id_prot
    end
end 

## This step is done to retrieve the sequences of the target proteins found in the previous step (S.Pombe).
## These sequences are stored in a temp file 'myfile', in order to get the reciprocal gene orthologues in the next Blast search.

File.open('./myfile.fa', 'w') do |file| 
    Bio::FlatFile.auto('./protein_target.fa').each_entry do |entry|
        if best_hits_blastx.values.uniq.include?(entry.entry_id)
            file.puts(entry)
        end
    end
end


## Second Blast(tblastn)is done using 'myfile', with protein-hits from the first search, against DNA sequences of Arabidopsis.
best_hits_tblastn={}
factory = Bio::Blast.local('tblastn', './seq_db')
Bio::FlatFile.auto('./myfile.fa').each_entry do |entry|  
    report = factory.query(entry) 
    report.each do |hit|
        evalue = evalue.to_i
        next unless hit.evalue <= 1e-6
        query_id_prot = hit.query_def.split("|")[0].strip
        target_id_nucl = hit.target_id.split("|")[0].strip
        best_hits_tblastn[query_id_prot]= target_id_nucl
    end
end

#The keys and values are switched to compare, in the next step, the values using the same keys                
best_hits_tblastn_inverted=best_hits_tblastn.invert 


#The report of reciprocal orthologues is saved in 'report.tsv'
File.open('./report.tsv', 'w') do |file| 
    difference=best_hits_tblastn_inverted.to_a-best_hits_blastx.to_a # dictionaries are converted to arrays, to get the unique content of tblastn (second blast search)
    tblastn_not_ort=Hash[*difference.flatten]
    rec_ort_arr= best_hits_tblastn_inverted.to_a-tblastn_not_ort.to_a # subtracting the unique content from the whole array, is possible to get the reciprocal orthologues.
    rec_ort_hash=Hash[*rec_ort_arr.flatten]
    file.puts rec_ort_hash      
end