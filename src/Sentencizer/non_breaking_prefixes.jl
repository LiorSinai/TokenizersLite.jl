function get_default_non_breaking_prefixes()
    # regex rules will already capture acronyms with periods between each letter
    prefixes = Set([
        # letters in acronyms
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z",
        # English terms
        "co",
        "Co",
        "Capt",
        "corp",
        "Corp",
        "Dept",
        "Dr",
        "fig", #figure
        "Fig",
        "Gen", 
        "Gov",
        "Jr",
        "Ltd",
        "Mr",
        "Mrs",
        "Ms",
        "prof",
        "Prof",
        "Rep",
        "Rev",
        "Sen",
        "Snr",
        "St",
        "st",
        "vs",
        ## degrees
        "BA",
        "BBus",
        "BCom",
        "BComm",
        "BEng",
        "BSc",
        "MA",
        "MBA",
        "MSc",
        "PhD",
        "Phd",
        "Ph.d",
        "Ph.D",
        ## time
        "AM",
        "PM",
        "Mon",
        "Tues",
        "Wed",
        "Thurs",
        "Fri",
        "Sat",
        "Sun",
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
        # Latin
        "al", #et al.
        "eg",
        "Eg",
        #"etc", # more likely at end of sentences
        "ie",
        "Ie",
    ])
    prefixes
end

function get_default_non_breaking_numeric_prefixes()
    prefixes = Set([
        "no", # number
        "No",
        "nr",
        "Nr",
        "p", #page
        "pg",
    ])
    prefixes
end