CREATE TABLE dim_event (
    ev_eventkey INT PRIMARY KEY,
    ev_eventname STRING,
    ev_eventnationame STRING,
    ev_startdate DATE,
    ev_enddate DATE
);

-- Inserts para ALGERIA
INSERT INTO dim_event (ev_eventkey, ev_eventname, ev_eventnationame, ev_startdate, ev_enddate)
VALUES
(1, 'Summer Sales', 'ALGERIA', '1992-07-01', '1992-08-01'),
(2, 'Winter Sales', 'ALGERIA', '1993-01-15', '1993-02-15'),
(3, 'Eid al-Fitr Sales', 'ALGERIA', '1994-06-15', '1994-07-15'),
(4, 'Back to School Sales', 'ALGERIA', '1995-09-01', '1995-09-30'),
(5, 'Ramadan Sales', 'ALGERIA', '1996-01-10', '1996-02-10'),
(6, 'Independence Day Sales', 'ALGERIA', '1997-07-05', '1997-07-07'),
(7, 'Summer Clearance', 'ALGERIA', '1998-08-15', '1998-09-15'),
(8, 'New Year Sales', 'ALGERIA', '1992-01-01', '1992-01-15'),
(9, 'Black Friday', 'ALGERIA', '1993-11-25', '1993-11-25'),
(10, 'Spring Sales', 'ALGERIA', '1994-04-01', '1994-04-30'),
(11, 'Christmas Sales', 'ALGERIA', '1995-12-20', '1995-12-31'),
(12, 'End of Season Sales', 'ALGERIA', '1996-10-15', '1996-11-15'),
(13, 'Valentine\'s Day Sales', 'ALGERIA', '1997-02-10', '1997-02-14'),
(14, 'National Day Sales', 'ALGERIA', '1998-11-01', '1998-11-07'),
(15, 'Labor Day Sales', 'ALGERIA', '1992-05-01', '1992-05-03'),
(16, 'Mid-Year Sales', 'ALGERIA', '1993-06-15', '1993-07-15'),
(17, 'Holiday Weekend Sales', 'ALGERIA', '1994-08-12', '1994-08-15'),
(18, 'Autumn Sales', 'ALGERIA', '1995-10-10', '1995-11-10'),
(19, 'Women\'s Day Sales', 'ALGERIA', '1996-03-08', '1996-03-10'),
(20, 'Spring Festival Sales', 'ALGERIA', '1997-03-01', '1997-03-05'),
(21, 'Year-End Clearance', 'ALGERIA', '1998-12-26', '1998-12-31'),
(22, 'Fashion Week Sales', 'ALGERIA', '1992-09-20', '1992-09-25'),
(23, 'Summer Solstice Sales', 'ALGERIA', '1993-06-21', '1993-06-23'),
(24, 'Youth Day Sales', 'ALGERIA', '1994-10-16', '1994-10-18'),
(25, 'Online Shopping Festival', 'ALGERIA', '1995-12-12', '1995-12-12');




