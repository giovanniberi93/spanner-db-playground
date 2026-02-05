SELECT DisplayName, SCORE_NGRAMS(NameTokens, 'sar') as MatchScore
FROM FuzzyTest 
WHERE SEARCH_NGRAMS(NameTokens, 'sar')
ORDER BY MatchScore DESC
LIMIT 5;