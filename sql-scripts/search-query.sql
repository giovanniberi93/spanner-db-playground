SELECT DisplayName, SCORE_NGRAMS(NameTokens, __SEARCH_TERM__) as MatchScore
FROM FuzzyTest 
WHERE SEARCH_NGRAMS(NameTokens, __SEARCH_TERM__)
ORDER BY MatchScore DESC
