# Readme

## Getting started

Setup up the local Spanner emulator with:

```make
    make setup-db
    make setup-table
```

and then run search queries with:

```bash
    ./run-sql-script.sh ./sql-scripts/search-query.sql "search key"
```

See `./sql-scripts/populate-table.sql` for the data being inserted in the table.

## Analysis and comparison

### SEARCH_NGRAMS

Reference [docs](https://docs.cloud.google.com/spanner/docs/full-text-search/fuzzy-search).

#### Pros

Very good fuzzy search, from my experiments the fuzziness can handle substring match + case insensitivity + typos, e.g.
```
┌ ~/workspace/test-fuzzy-search-spanner git:(main) ✗
└─ ./run-sql-script.sh ./sql-scripts/search-query.sql "tat"
+---------------------------------------------------+------------+
| DisplayName                                       | MatchScore |
+---------------------------------------------------+------------+
| The Girl with the Dragon Tattoo                   | 0.037037   |
| Great Expectations by Charles Dickens             | 0.028571   |
| The Guernsey Literary and Potato Peel Pie Society | 0.021277   |
+---------------------------------------------------+------------+
```

typo:
```
┌ ~/workspace/test-fuzzy-search-spanner git:(main) ✗
└─ ./run-sql-script.sh ./sql-scripts/search-query.sql "dracla"
+------------------------+------------+
| DisplayName            | MatchScore |
+------------------------+------------+
| Dracula by Bram Stoker | 0.090909   |
+------------------------+------------+
```

The query size explosion when searching for very common search keys can be mitigated using inner/outer limits, see [docs](https://docs.cloud.google.com/spanner/docs/full-text-search/fuzzy-search#optimize-n-grams).

#### Cons

1. The tokenization parameters (`ngram_size_min`, `ngram_size_max`, `relative_search_types`) might have to be tweaked, and changing the parameters requires amending the SQL schema. Good to remark that the parameters provided as example in the docs seems to "just work", so parameter tuning might be a non-issue.
1. `SEARCH_NGRAMS` returns no result if the search key is shorter than `ngram_size_min`
1. When using `SCORE_NGRAMS` for sorting the search hits, the score seems to always be `0` when the search key is less than 3 characters, i.e. the results are unsorted:

```
┌ ~/workspace/test-fuzzy-search-spanner git:(main) ✗
└─ ./run-sql-script.sh ./sql-scripts/search-query.sql "tt"
+----------------------------------------------+------------+
| DisplayName                                  | MatchScore |
+----------------------------------------------+------------+
| The Girl with the Dragon Tattoo              | 0.000000   |
| The Secret Garden by Frances Hodgson Burnett | 0.000000   |
| A Little Princess by Frances Hodgson Burnett | 0.000000   |
| Stuart Little by E.B. White                  | 0.000000   |
| Charlotte’s Web by E.B. White                | 0.000000   |
| Harry Potter and the Prisoner of Azkaban     | 0.000000   |
| Little Women by Louisa May Alcott            | 0.000000   |
+----------------------------------------------+------------+
```

The score has instead meaningful values when the search key has at least 3 characters:

```
┌ ~/workspace/test-fuzzy-search-spanner git:(main) ✗
└─ ./run-sql-script.sh ./sql-scripts/search-query.sql "the"
+----------------------------+------------+
| DisplayName                | MatchScore |
+----------------------------+------------+
| The English Patient        | 0.058824   |
| The Wind in the Willows    | 0.058824   |
| The Three Musketeers       | 0.055556   |
| ...                        | ...        |

```

This seems to be due to the `SCORE_NGRAMS` implementation, which is based on _trigrams_, see the "Algorithm" section [in the docs](https://docs.cloud.google.com/spanner/docs/reference/standard-sql/search_functions#score_ngrams)

To prevent showing poor matches to the user, `min_ngrams_percent` parameter _might_ be used, but choosing a value for that parameter might be hard.

### SEARCH_SUBSTRING

Reference [docs](https://docs.cloud.google.com/spanner/docs/full-text-search/substring-search).

Seems very similar to `SEARCH_NGRAMS` for substring match and case insensitivity, e.g.:

```
┌ ~/workspace/test-fuzzy-search-spanner git:(main) ✗
└─ ./run-sql-script.sh ./sql-scripts/search-query.sql "tat"
+---------------------------------------------------+------------+
| DisplayName                                       | MatchScore |
+---------------------------------------------------+------------+
| The Girl with the Dragon Tattoo                   | 0.037037   |
| Great Expectations by Charles Dickens             | 0.028571   |
| The Guernsey Literary and Potato Peel Pie Society | 0.021277   |
+---------------------------------------------------+------------+
```

Key differences from `SEARCH_NGRAMS`:

It returns results with any search key lenght:
```
┌ ~/workspace/test-fuzzy-search-spanner git:(main) ✗
└─ ./run-sql-script.sh ./sql-scripts/search-query.sql "e"
+-------------------------------+------------+
| DisplayName                   | MatchScore |
+-------------------------------+------------+
| Charlotte’s Web by E.B. White | 0.000000   |
| Stuart Little by E.B. White   | 0.000000   |
| The Man from U.N.C.L.E.       | 0.000000   |
+-------------------------------+------------+
```

...but it can't handle typos:
```
┌ ~/workspace/test-fuzzy-search-spanner git:(main) ✗
└─ ./run-sql-script.sh ./sql-scripts/search-query.sql "dracla"
```

### SEARCH (enhance_query => true)

Reference [docs](https://docs.cloud.google.com/spanner/docs/reference/standard-sql/search_functions#search_fulltext).

#### Pros

1. It doesn't require parameter tuning.
1. It can handle case insensitivity.

#### Cons

1. The `enhance_query` parameter is supposed to introduce some fuzziness to the search, but the extent is not obvious. According to the docs _"For example, if `enhance_query` is enabled, a search query containing the term 'classic' can expand to include similar terms such as 'classical'"_. I don't expect this flag to bring any significant fuzziness to the search.
1. It can't handle typos
1. It will only match individual words, and not sequence of characters within a word. For example:
```
┌ ~/workspace/test-fuzzy-search-spanner git:(main) ✗
└─ ./run-sql-script.sh ./sql-scripts/search-query.sql "dracula"
+------------------------+------------+
| DisplayName            | MatchScore |
+------------------------+------------+
| Dracula by Bram Stoker | 1.000000   |
+------------------------+------------+

┌ ~/workspace/test-fuzzy-search-spanner git:(main) ✗
└─ ./run-sql-script.sh ./sql-scripts/search-query.sql "dracu"

┌ ~/workspace/test-fuzzy-search-spanner git:(main) ✗
└─ ./run-sql-script.sh ./sql-scripts/search-query.sql "acula"
```

## Outcome

The `SEARCH_NGRAMS` feature seems to provide the most powerful fuzzy search capabilities, and it shouldn't require fine tuning in order to function properly.

Note that none of the search functionalities are included in the standard Spanner edition.
