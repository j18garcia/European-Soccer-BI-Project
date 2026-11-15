-- Question 1: How do total goals, average goals per match, and home-win percentage compare across the English Premier League, Spanish LIGA BBVA, and German 1. Bundesliga across the five seasons (2011/2012-2015/2016)?
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
GROUP BY 
    c.country_name,
    l.league_name,
    s.season_name
ORDER BY 
    l.league_name ASC,
    s.season_name ASC;

-- Question 2: Which clubs with at least 50 home matches played between 2011/2012 and 2015/2016 achieved an average of more than 2.0 goals scored per home match, and which league do they belong to?
SELECT 
    t.team_long_name,
    l.league_name,
    COUNT(*) AS home_matches,
    SUM(m.home_team_goal) AS total_home_goals,
    CAST(AVG(CAST(m.home_team_goal AS DECIMAL(5,2))) AS DECIMAL(5,2)) AS avg_home_goals
FROM dbo.[Match] m
INNER JOIN dbo.Team t 
    ON m.home_team_id = t.team_id
INNER JOIN dbo.League l 
    ON m.league_id = l.league_id
INNER JOIN dbo.Season s 
    ON m.season_id = s.season_id
WHERE 
    s.season_name BETWEEN '2011/2012' AND '2015/2016'
GROUP BY 
    t.team_long_name,
    l.league_name
HAVING 
    COUNT(*) >= 50 
    AND AVG(CAST(m.home_team_goal AS DECIMAL(5,2))) > 2.0
ORDER BY 
    avg_home_goals DESC;

-- Question 3: What is the final points ranking of the top 3 clubs in each league for the 2015/2016 season based on total points earned (3 for a win, 1 for a draw)?
WITH MatchPoints AS (
    SELECT 
        m.league_id,
        m.home_team_id AS team_id,
        CASE 
            WHEN m.home_team_goal > m.away_team_goal THEN 3
            WHEN m.home_team_goal = m.away_team_goal THEN 1
            ELSE 0 
        END AS points
    FROM dbo.[Match] m
    WHERE m.season_id = 2015

    UNION ALL

    SELECT 
        m.league_id,
        m.away_team_id AS team_id,
        CASE 
            WHEN m.away_team_goal > m.home_team_goal THEN 3
            WHEN m.away_team_goal = m.home_team_goal THEN 1
            ELSE 0 
        END AS points
    FROM dbo.[Match] m
    WHERE m.season_id = 2015
),
RankedTeams AS (
    SELECT 
        l.league_name,
        t.team_long_name,
        SUM(mp.points) AS total_points,
        RANK() OVER (
            PARTITION BY l.league_name 
            ORDER BY SUM(mp.points) DESC
        ) AS league_rank
    FROM MatchPoints mp
    INNER JOIN dbo.Team t 
        ON mp.team_id = t.team_id
    INNER JOIN dbo.League l 
        ON mp.league_id = l.league_id
    GROUP BY 
        l.league_name,
        t.team_long_name
)
SELECT 
    league_name,
    league_rank,
    team_long_name,
    total_points
FROM RankedTeams
WHERE league_rank <= 3
ORDER BY 
    league_name ASC,
    league_rank ASC;

-- Question 4: Which clubs scored more total goals (home and away combined) across the 5 seasons than the overall average total goals scored by clubs across all three leagues?
WITH ClubGoals AS (
    SELECT 
        m.home_team_id AS team_id,
        m.league_id,
        m.home_team_goal AS goals
    FROM dbo.[Match] m

    UNION ALL

    SELECT 
        m.away_team_id AS team_id,
        m.league_id,
        m.away_team_goal AS goals
    FROM dbo.[Match] m
),
TeamTotals AS (
    SELECT 
        team_id,
        league_id,
        SUM(goals) AS total_goals
    FROM ClubGoals
    GROUP BY 
        team_id,
        league_id
)
SELECT 
    t.team_long_name,
    l.league_name,
    tt.total_goals
FROM TeamTotals tt
INNER JOIN dbo.Team t 
    ON tt.team_id = t.team_id
INNER JOIN dbo.League l 
    ON tt.league_id = l.league_id
WHERE 
    tt.total_goals > (
        SELECT AVG(CAST(total_goals AS DECIMAL(10,2))) 
        FROM TeamTotals
    )
ORDER BY 
    tt.total_goals DESC;
