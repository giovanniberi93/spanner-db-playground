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

## Findings

When using `SCORE_NGRAMS` for sorting the search hits, the score seems to always be `0` when the search key is less than 3 characters, i.e. the results are unsorted:

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
