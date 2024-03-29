DROP TRIGGER IF EXISTS check_hours_insert_trigger;
DROP TRIGGER IF EXISTS check_hours_update_trigger;
DROP TRIGGER IF EXISTS check_insert_hours_overlap;
DROP TRIGGER IF EXISTS check_update_hours_overlap;

DELIMITER $$
CREATE TRIGGER check_hours_insert_trigger BEFORE INSERT ON TeachingAssistantRoles
FOR EACH ROW
BEGIN
DECLARE totalhours INT;
SET totalhours = (SELECT SUM(hours) FROM TeachingAssistantRoles WHERE teachingAssistantID=NEW.teachingAssistantID);
IF ( totalhours ) > 260 THEN
	SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Insert will make the TA work for more 260 hours';
    END IF;
END;$$


DELIMITER $$
CREATE TRIGGER check_hours_update_trigger BEFORE UPDATE ON TeachingAssistantRoles
FOR EACH ROW
BEGIN
DECLARE totalhours INT;
SET totalhours = (SELECT SUM(hours) FROM TeachingAssistantRoles WHERE teachingAssistantID=NEW.teachingAssistantID);
IF ( totalhours ) > 260 THEN
	SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Update will make the TA work for more 260 hours';
    END IF;
END;$$


DELIMITER $$
CREATE TRIGGER check_insert_hours_overlap BEFORE INSERT ON InstructorSection
FOR EACH ROW
BEGIN
	IF EXISTS (	
 SELECT * FROM InstructorSection
             WHERE instructorID=NEW.instructorID 
             AND
             (sectionID = startat <= NEW.endat OR endat >= NEW.startat)
             )  
THEN
	SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'There is a time conflict with existing registered course-section';
    END IF;
END;$$


DELIMITER $$
CREATE TRIGGER check_update_hours_overlap BEFORE UPDATE ON InstructorSection
FOR EACH ROW
BEGIN
	IF EXISTS (	
 SELECT * FROM InstructorSection
             WHERE instructorID=NEW.instructorID 
             AND
             (sectionID = startat <= NEW.endat OR endat >= NEW.startat)
             )  
THEN
	SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'There is a time conflict with existing registered course-section';
    END IF;
END;$$


