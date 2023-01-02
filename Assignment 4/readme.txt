Readme:

For Reciprocal orthologues Blast search, an e-value of 1.10-6 was chosen based on: 
https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0101850

First, both databases (S. Pombe and Arabidopsis thaliana) were indexed using:

makeblastdb -in protein_db.fa -parse_seqids -dbtype 'prot' -out protein_db     and 
makeblastdb -in seq_db.fa -parse_seqids -dbtype 'nucl' -out seq_db, respectively.

The code is written in blast_retrieval.rb

1.The first Blast (blastx) was done with Arabidopsis DNA seq (seq.fa) against the S. Pombe protein db (protein_db.fa).(**) 
Best protein hits IDs (e-value <= 1.10-6) were saved and their sequences were retrieved from S. Pombe db, to be used in the next blast (as myfile). 

2.The second Blast (tblastn) was done using protein best hits from the previous step against Arabidopsis DNA db, with the same e-value threshold. 

3.The results of both Blast searches were compared to retrieve the shared results, which should be good reciprocal orthologues candidates.


**: Note: when I run the whole Arabidopsis seq dataset against S.Pombe db, I got an error message that interrupted the code: 

“Error: NCBI C++ Exception:
    T0 "/build/ncbi-blast+-S1iyIZ/ncbi-blast+-2.9.0/c++/src/corelib/ncbistr.cpp", line 6542: Error: ncbi::CUtf8::SymbolToChar() - Failed to convert symbol to requested encoding (m_Pos = 0)
    T0 "/build/ncbi-blast+-S1iyIZ/ncbi-blast+-2.9.0/c++/src/serial/objostrxml.cpp", line 1507: Error: ncbi::CObjectOStreamXml::WriteClassMember() -  Frame type= eFrameClassMember, Member name= query-def (m_Pos = 0)
    ……..
Program failed, try executing the command manually.”

I mentioned that error in my email, and I checked the type of Blast I suggested. Blast (blastx) works fine for shorter sequences enquires 
against the protein db.Therefore, I run the code using a shorter version of Arabidopsis list of genes to probe that it works.
I call that file: seq.fa,and uploaded along with the code (blast_retrieval.rb)

