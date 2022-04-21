# REGULAR EXPRESSIONS INTRO

# useful links: 
# Good introductory regular expressions tutorial: https://regexone.com/ 
# regex cheat sheet: https://docs.google.com/document/d/1d5HdGNCEr7aPpVWC5N2a48NQrG34LLOwBgj8cHQ0ij8/edit?usp=sharing 
# virtual keyboard for writing regular expressions with Arabic: https://pverkind.github.io/arabicVirtualKeyboard/

library("readr")    # for loading text
library("stringr")  # contains many useful search and replace functions

url <- "https://raw.githubusercontent.com/OpenITI/0325AH/master/data/0310Tabari/0310Tabari.Tarikh/0310Tabari.Tarikh.Shamela0009783BK1-ara1.mARkdown"
tabari <- read_file(url)
tabari_lines <- read_lines(url)

# useful functions from `stringr` package: 

str_detect(tabari_lines, "أخبر")      # will check for every line whether or not string matches the query
str_extract(tabari, ".+أخبر.+")       # will extract the first line containing the combination khbr
str_extract_all(tabari, ".+أخبر.+")   # will extract the all lines containing the combination khbr
str_locate_all(tabari, "### \\| ")    # will return a list of all character index positions for the query
str_replace_all(tabari, "ms\\d+", "") # will remove all milestone numbers from the text

## NB: all of these have the same structure: str_function(string_to_be_searched, search_pattern)


# useful regex patterns:

## optionality: `?` : `kitā?b` : ā is optional (NB: Latin question mark only, not Arabic question mark!) 
## => matches either kitb or kitāb

regex = "كتا?ب"
str_extract(tabari, regex)

## wildcard character: `.` matches any character (except new line)
## `k.t.b.?` matches kitāb, kutub, kataba, k tibs, ...

regex = ".?كت.?ب"
str_extract(tabari, regex)

## problem using right-to-left and left-to-right characters together
## => break the pattern apart and join it using `paste0()`

regex = paste0(".?",  # one optional character
               "كت",  # followed by kāf and tā'
               ".?",  # optionally followed by another character
               "ب",   # followed by a bā'
               ".?")  # optionally followed by another character
str_extract_all(tabari, regex)

## How do we find a real full stop or question mark or other special character? 
## "Escape" it using a backslash `\`: `\.` matches only  a full stop, `\?` matches only a question mark
## NB: since backslash is a special character itself in R, we have to escape it as well
## => in R, `\\.` matches a full stop, `\\?` matches a question mark (and `\\\\` matches a backslash...)

regex = "كتب\\."                # ktb followed by a full stop
str_extract_all(tabari, regex)  # 1 result; compare with "كتب."!


## repeating:
## `*`: zero or more repeats
## `+` : one or more repeats
## `{1,5}` : between one and five repeats

regex = paste0(".*", 
               "كتب",
               ".*")  # all characters on any line that contains the characters ktb
str_extract_all(tabari, regex)

## Character classes:
## `\\w` : any "word character": letters, numbers, underscore
## `\\d` : any digit
## `\\n` : a new line character
## `\\r` : a carriage return character (part of a new line in Windows)
## `\\s` : any whitespace character (newline, tab, space, ...) NB: in Kate editor, `\s` does not include newline!
## `\\S` : any character that is NOT a white space character
## `\\W` : any character that is NOT a word character
## ...

str_extract_all(" جميلة كُتُب", "\\w+")
str_replace_all(tabari, "PageV\\d+P\\d+", "") # delete all page numbers!


## Either/Or: `|`
## e.g., `kitāb|qalam` : either "qalam" or "kitāb"
## e.g., `k(i|ut)tāb`  : either "kitāb" or "kuttāb"
regex <- paste0("ك",
                "(ت|ب)",
                "ب")
str_extract(tabari, regex)


## either/or: `[]` : any of the characters between the brackets
## e.g., `[ytn]?aktub` : aktub preceded by one or none of the characters y, t or n
regex <- paste0("[يتن]?",
                "كتب")
str_extract_all(tabari, regex)


# useful complex patterns:

## get context around a word:
context = "[\\s\\S]{0,50}"  # between 0 and 50 characters, including new line characters ("any whitespace and non-whitespace characters")
word = "كتاب"
context_around = paste0(context, word, context) # get the context of 50 characters (or less if there is less) around the word kitāb
context_before = paste0(context, word)
context_after = paste0(word, context)
str_extract_all(tabari, context_around)

## find two words only if they are closely together:
word1 = "كتاب"
word2 = "إلى"
context = "[\\s\\S]{0,30}"
words_in_context = paste0(word1,context,word2)
str_extract_all(tabari, words_in_context)

## find two words only if they are closely together,
## in any order:
words_in_context = paste0(word1,
                          context,
                          word2,
                          "|",   # OR!
                          word2,
                          context,
                          word1)
str_extract_all(tabari, words_in_context)

## find two words only if they are closely together,
## in any order, and add some context before and after:

words_in_context = paste0(context,
                          word1,
                          context,
                          word2,
                          context,
                          "|",   # OR!
                          context,
                          word2,
                          context,
                          word1,
                          context)
result <- str_extract_all(tabari, words_in_context)

# writing the results to a file is not simple on Windows
# because of issues with Arabic. This is a workaround:
result <- paste(unlist(result), collapse="\n\n") # collapse the list into a single string
writeBin(charToRaw(result), choose.files(), endian="little")
