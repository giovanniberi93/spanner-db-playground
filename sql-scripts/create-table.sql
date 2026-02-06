CREATE TABLE FuzzyTest (
  Id STRING(36) DEFAULT (GENERATE_UUID()),
  DisplayName STRING(MAX),
  NameTokens TOKENLIST AS (
-- UNCOMMENT for SEARCH_NGRAMS/SEARCH_SUBSTRING queries
    TOKENIZE_SUBSTRING(DisplayName, ngram_size_min=>2, ngram_size_max=>3)
-- UNCOMMENT for SEARCH queries
    -- TOKENIZE_FULLTEXT(DisplayName)
-- END
  ) HIDDEN
) PRIMARY KEY(Id);
