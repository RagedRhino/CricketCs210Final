CREATE DATABASE CricketStats;
USE CricketStats;

CREATE TABLE players (
    player_id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100) NOT NULL
);

CREATE TABLE bowling_stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100),
    overs INT,
    maidens INT,
    runs INT,
    wickets INT,
    wides INT,
    no_balls INT,
    hattricks INT,
    dot_balls INT
);


CREATE TABLE batting_stats (
    stat_id INT AUTO_INCREMENT PRIMARY KEY,
    player_name VARCHAR(100),
    how_out VARCHAR(50),
    runs INT,
    balls INT,
    fours INT,
    sixers INT
);

CREATE TABLE aggregated_batting_stats (
    player_name VARCHAR(100) PRIMARY KEY,
    total_runs_batting INT,
    total_balls_faced INT,
    total_fours INT,
    total_sixers INT,
    strike_rate DECIMAL(5, 2),
    total_points INT,
    role VARCHAR(20)
);

INSERT INTO aggregated_batting_stats (player_name, total_runs_batting, total_balls_faced, total_fours, total_sixers, strike_rate, total_points, role)
SELECT 
    player_name,
    SUM(runs) AS total_runs_batting,
    SUM(balls) AS total_balls_faced,
    SUM(fours) AS total_fours,
    SUM(sixers) AS total_sixers,
    (SUM(runs) / SUM(balls)) * 100 AS strike_rate,
    CASE 
        WHEN (SUM(runs) / SUM(balls)) * 100 < 75 THEN ((SUM(sixers) * 10) + (SUM(fours) * 5) + (SUM(runs) - (SUM(sixers) * 6 + SUM(fours) * 4))) * 0.90
        WHEN (SUM(runs) / SUM(balls)) * 100 >= 75 AND (SUM(runs) / SUM(balls)) * 100 < 100 THEN ((SUM(sixers) * 10) + (SUM(fours) * 5) + (SUM(runs) - (SUM(sixers) * 6 + SUM(fours) * 4))) * 0.95
        WHEN (SUM(runs) / SUM(balls)) * 100 >= 100 AND (SUM(runs) / SUM(balls)) * 100 < 120 THEN ((SUM(sixers) * 10) + (SUM(fours) * 5) + (SUM(runs) - (SUM(sixers) * 6 + SUM(fours) * 4))) * 1.05
        WHEN (SUM(runs) / SUM(balls)) * 100 >= 120 THEN ((SUM(sixers) * 10) + (SUM(fours) * 5) + (SUM(runs) - (SUM(sixers) * 6 + SUM(fours) * 4))) * 1.07
        ELSE ((SUM(sixers) * 10) + (SUM(fours) * 5) + (SUM(runs) - (SUM(sixers) * 6 + SUM(fours) * 4)))
    END AS total_points,
    CASE 
        WHEN (SUM(runs) / SUM(balls)) * 100 > 105 AND SUM(runs) > 25 AND SUM(fours) >= 4 AND SUM(sixers) >= 2 THEN 'Opener'
        WHEN (SUM(runs) / SUM(balls)) * 100 < 70 THEN 'Tail Ender'
        ELSE 'Middle Order'
    END AS role
FROM batting_stats
GROUP BY player_name;

CREATE TABLE aggregated_bowling_stats (
    player_name VARCHAR(100) PRIMARY KEY,
    total_overs INT,
    total_maidens INT,
    total_runs_conceded INT,
    total_wickets INT,
    total_wides INT,
    total_no_balls INT,
    total_hattricks INT,
    total_dot_balls INT,
    economy_rate DECIMAL(5, 2),
    total_points DECIMAL(10, 2),
    role VARCHAR(20)
);

INSERT INTO aggregated_bowling_stats (player_name, total_overs, total_maidens, total_runs_conceded, total_wickets, total_wides, total_no_balls, total_hattricks, total_dot_balls, economy_rate, total_points, role)
SELECT 
    player_name,
    SUM(overs) AS total_overs,
    SUM(maidens) AS total_maidens,
    SUM(runs) AS total_runs_conceded,
    SUM(wickets) AS total_wickets,
    SUM(wides) AS total_wides,
    SUM(no_balls) AS total_no_balls,
    SUM(hattricks) AS total_hattricks,
    SUM(dot_balls) AS total_dot_balls,
    (SUM(runs) / SUM(overs)) AS economy_rate,
    (SUM(wickets) * 25) - (SUM(runs)) + (SUM(dot_balls) * 2) - (SUM(wides) * 2) + (SUM(maidens) * 25) + (SUM(hattricks) * 20) - (SUM(no_balls) * 4) AS total_points,
     CASE 
        WHEN SUM(overs) > 8 AND (SUM(runs) / SUM(overs)) < 10 AND (SUM(wides) / SUM(overs)) < 0.25 AND SUM(no_balls) < 2 THEN 'Powerplay'
        WHEN SUM(overs) > 8 AND SUM(dot_balls) > SUM(overs) * 2 AND (SUM(runs) / SUM(overs)) < 13 THEN 'Death Overs'
        ELSE 'Middle Overs'
    END AS role
FROM bowling_stats
GROUP BY player_name;

SELECT * FROM aggregated_batting_stats;

DROP DATABASE cricketstats
