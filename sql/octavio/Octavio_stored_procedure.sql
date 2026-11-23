-- Stored Procedure: dbo.usp_GetLeagueSeasonStats
-- Purpose: Returns seasonal offensive and home-win metrics for a specific league, or all leagues if no parameter is provided.

CREATE OR ALTER PROCEDURE dbo.usp_GetLeagueSeasonStats
    @LeagueName NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

IF @LeagueName IS NULL OR LTRIM(RTRIM(@LeagueName)) = ''
BEGIN SELECT 
    c.country_name,
    l.league_name,
    s.season_name,
    COUNT(*) AS total_matches,
    SUM(m.home_team_goal + m.away_team_goal) AS total_goals,
    CAST(AVG(CAST(m.home_team_goal + m.away_team_goal AS DECIMAL(5,2))) AS DECIMAL(5,2)) AS avg_goals_per_match,
    CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS home_win_pct
FROM dbo.[Match] m
INNER JOIN dbo.League l 
    ON m.league_id = l.league_id
INNER JOIN dbo.Country c 
    ON l.country_id = c.country_id
INNER JOIN dbo.Season s 
    ON m.season_id = s.season_id
GROUP BY 
    c.country_name,
    l.league_name,
    s.season_name
ORDER BY 
    l.league_name ASC,
    s.season_name ASC;
    END

    ELSE 
    BEGIN
    IF EXISTS (SELECT 1 FROM dbo.League WHERE league_name = @LeagueName)
    BEGIN
    SELECT 
    c.country_name,
    l.league_name,
    s.season_name,
    COUNT(*) AS total_matches,
    SUM(m.home_team_goal + m.away_team_goal) AS total_goals,
    CAST(AVG(CAST(m.home_team_goal + m.away_team_goal AS DECIMAL(5,2))) AS DECIMAL(5,2)) AS avg_goals_per_match,
    CAST(SUM(CASE WHEN m.home_team_goal > m.away_team_goal THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS home_win_pct
FROM dbo.[Match] m
INNER JOIN dbo.League l 
    ON m.league_id = l.league_id
INNER JOIN dbo.Country c 
    ON l.country_id = c.country_id
INNER JOIN dbo.Season s 
    ON m.season_id = s.season_id
WHERE l.league_name = @LeagueName
GROUP BY 
    c.country_name,
    l.league_name,
    s.season_name
ORDER BY 
    l.league_name ASC,
    s.season_name ASC;

    END
    ELSE
    BEGIN
    SELECT 'League not found. Valid options: England Premier League, Spain LIGA BBVA, Germany 1. Bundesliga.' AS StatusMessage;
    END
    END
    END;

    GO

-- Test 1: No parameter provided (returns all 3 leagues across 5 seasons - 15 rows)
EXEC dbo.usp_GetLeagueSeasonStats;

-- Test 2: Valid league parameter (returns only Spain LIGA BBVA - 5 rows)
EXEC dbo.usp_GetLeagueSeasonStats @LeagueName = N'Spain LIGA BBVA';

-- Test 3: Invalid league parameter (returns validation message - 1 row)
EXEC dbo.usp_GetLeagueSeasonStats @LeagueName = N'Italian Serie A';
