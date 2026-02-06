-- SELECT DisplayName, SCORE_NGRAMS(NameTokens, __SEARCH_TERM__) as MatchScore
-- FROM FuzzyTest 
-- WHERE SEARCH_NGRAMS(NameTokens, __SEARCH_TERM__)
-- ORDER BY MatchScore DESC

-- SELECT DisplayName, SCORE(NameTokens, __SEARCH_TERM__, enhance_query=>true) AS MatchScore
-- FROM FuzzyTest
-- WHERE SEARCH(NameTokens, __SEARCH_TERM__, enhance_query=>true)
-- ORDER BY MatchScore DESC

SELECT DisplayName, SCORE_NGRAMS(NameTokens, __SEARCH_TERM__) AS MatchScore
FROM FuzzyTest
WHERE SEARCH_SUBSTRING(NameTokens, __SEARCH_TERM__)
ORDER BY MatchScore DESC
