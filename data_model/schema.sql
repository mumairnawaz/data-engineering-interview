CREATE DATABASE SupportAnalytics;
GO

USE SupportAnalytics;
GO

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(150),
    industry VARCHAR(100),
    region VARCHAR(50),
    country VARCHAR(50),
    contract_type VARCHAR(50),
    created_date DATE,
    is_active BIT
);

CREATE TABLE agents (
    agent_id INT PRIMARY KEY,
    agent_name VARCHAR(100),
    email VARCHAR(100),
    team VARCHAR(50),
    role VARCHAR(50),
    experience_years INT,
    location VARCHAR(50),
    is_active BIT
);


CREATE TABLE tickets (
    ticket_id INT PRIMARY KEY,
    customer_id INT,
    created_at DATETIME,
    closed_at DATETIME,
    status VARCHAR(50),
    priority VARCHAR(20),
    severity VARCHAR(20),
    channel VARCHAR(50), -- Email, Chat, Call
    category VARCHAR(100),
    sub_category VARCHAR(100),
    assigned_agent INT,
    resolution_time_minutes INT,
    first_response_time_minutes INT,
    reopened_flag BIT,
    escalation_flag BIT,
    sla_breach_flag BIT,
    satisfaction_score INT, -- 1 to 5
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (assigned_agent) REFERENCES agents(agent_id)
);



CREATE TABLE ticket_updates (
    update_id INT PRIMARY KEY,
    ticket_id INT,
    update_time DATETIME,
    updated_by INT,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    comment VARCHAR(255),
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
    FOREIGN KEY (updated_by) REFERENCES agents(agent_id)
);


CREATE TABLE sla_tracking (
    sla_id INT PRIMARY KEY,
    ticket_id INT,
    sla_type VARCHAR(50), -- Response / Resolution
    target_minutes INT,
    actual_minutes INT,
    breach_flag BIT,
    checked_at DATETIME,
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
);


CREATE TABLE ticket_tags (
    tag_id INT PRIMARY KEY,
    ticket_id INT,
    tag_name VARCHAR(100),
    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id)
);



INSERT INTO customers
SELECT TOP 50
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS customer_id,
    CONCAT('Customer_', ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 5 + 1, 'Finance','Healthcare','Retail','Tech','Telecom'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1, 'North America','Europe','Asia','Middle East'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 5 + 1, 'USA','UK','Canada','Germany','UAE'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1, 'Gold','Silver','Platinum'),
    DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 1000, GETDATE()),
    1
FROM sys.all_objects;



INSERT INTO agents
SELECT TOP 20
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS agent_id,
    CONCAT('Agent_', ROW_NUMBER() OVER (ORDER BY (SELECT NULL))),
    CONCAT('agent', ROW_NUMBER() OVER (ORDER BY (SELECT NULL)), '@company.com'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1, 'L1 Support','L2 Support','Escalation'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1, 'Analyst','Senior Analyst','Lead'),
    ABS(CHECKSUM(NEWID())) % 10 + 1,
    CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1, 'USA','UK','India','Pakistan'),
    1
FROM sys.all_objects;


WITH numbers AS (
    SELECT TOP 10000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO tickets
SELECT
    n AS ticket_id,
    ABS(CHECKSUM(NEWID())) % 50 + 1 AS customer_id,
    DATEADD(MINUTE, -ABS(CHECKSUM(NEWID())) % 100000, GETDATE()),
    NULL,
    CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1, 'Open','Closed','In Progress','Resolved'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1, 'Low','Medium','High'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1, 'Minor','Major','Critical'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 3 + 1, 'Email','Chat','Call'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1, 'Login Issue','Payment','Bug','Performance'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1, 'UI','Backend','API','Database'),
    ABS(CHECKSUM(NEWID())) % 20 + 1,
    ABS(CHECKSUM(NEWID())) % 500,
    ABS(CHECKSUM(NEWID())) % 120,
    ABS(CHECKSUM(NEWID())) % 2,
    ABS(CHECKSUM(NEWID())) % 2,
    ABS(CHECKSUM(NEWID())) % 2,
    ABS(CHECKSUM(NEWID())) % 5 + 1
FROM numbers;


UPDATE tickets
SET closed_at = DATEADD(MINUTE, resolution_time_minutes, created_at)
WHERE status IN ('Closed','Resolved');

WITH numbers AS (
    SELECT TOP 20000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO ticket_updates
SELECT
    n,
    ABS(CHECKSUM(NEWID())) % 10000 + 1,
    DATEADD(MINUTE, -ABS(CHECKSUM(NEWID())) % 50000, GETDATE()),
    ABS(CHECKSUM(NEWID())) % 20 + 1,
    CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1, 'Open','In Progress','Resolved','Closed'),
    CHOOSE(ABS(CHECKSUM(NEWID())) % 4 + 1, 'Open','In Progress','Resolved','Closed'),
    'Status updated'
FROM numbers;


INSERT INTO sla_tracking
SELECT
    ticket_id,
    ticket_id,
    CHOOSE(ABS(CHECKSUM(NEWID())) % 2 + 1, 'Response','Resolution'),
    ABS(CHECKSUM(NEWID())) % 300 + 30,
    ABS(CHECKSUM(NEWID())) % 500,
    ABS(CHECKSUM(NEWID())) % 2,
    GETDATE()
FROM tickets;



WITH numbers AS (
    SELECT TOP 15000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects a CROSS JOIN sys.objects b
)
INSERT INTO ticket_tags
SELECT
    n,
    ABS(CHECKSUM(NEWID())) % 10000 + 1,
    CHOOSE(ABS(CHECKSUM(NEWID())) % 5 + 1, 
        'urgent','bug','vip','payment','outage')
FROM numbers;




SELECT COUNT(*) FROM tickets;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM agents;
SELECT COUNT(*) FROM ticket_updates;



SELECT 
    a.agent_name,
    COUNT(*) AS total_breaches
FROM sla_tracking s
JOIN tickets t ON s.ticket_id = t.ticket_id
JOIN agents a ON t.assigned_agent = a.agent_id
WHERE s.breach_flag = 1
GROUP BY a.agent_name
ORDER BY total_breaches DESC;