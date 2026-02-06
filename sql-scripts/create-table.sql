CREATE TABLE FuzzyTest (
  Id STRING(36) DEFAULT (GENERATE_UUID()),
  DisplayName STRING(MAX),
  NameTokens TOKENLIST AS (
-- for SEARCH_NGRAMS/SEARCH_SUBSTRING queries
    TOKENIZE_SUBSTRING(DisplayName, ngram_size_min=>2, ngram_size_max=>3
    -- ,relative_search_types=>["word_prefix", "word_suffix"]
    )
-- for SEARCH queries
    -- TOKENIZE_FULLTEXT(DisplayName)
  ) HIDDEN
) PRIMARY KEY(Id);
