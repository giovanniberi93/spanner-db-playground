SELECT DisplayName, SCORE_NGRAMS(NameTokens, 'list') as MatchScore
FROM FuzzyTest 
WHERE SEARCH_NGRAMS(NameTokens, 'list')
ORDER BY MatchScore DESC
LIMIT 5;
