#set dir "C:/Users/Public/Documents/caver_output/6/inputs"

mol load pdb ../data/EPH.pdb

after idle { 
  mol representation NewCartoon 
  mol delrep 0 top
  mol addrep top
  mol modcolor 0 top "ColorID" 8
} 

