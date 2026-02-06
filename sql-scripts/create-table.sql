CREATE TABLE FuzzyTest (
  Id STRING(36) DEFAULT (GENERATE_UUID()),
  DisplayName STRING(MAX),
  NameTokens TOKENLIST AS (
    -- TOKENIZE_SUBSTRING(DisplayName, ngram_size_min=>2, ngram_size_max=>3,
    -- relative_search_types=>["word_prefix", "word_suffix"]
    -- )
    TOKENIZE_SUBSTRING(DisplayName, ngram_size_min=>2, ngram_size_max=>3)
  ) HIDDEN
) PRIMARY KEY(Id);
