-- V2__create_functions.sql
-- Functions and triggers for the exam application

-- Function to generate random join codes
CREATE OR REPLACE FUNCTION generate_join_code() RETURNS VARCHAR(10) AS
$$
DECLARE
chars  VARCHAR(36) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result VARCHAR(10) := '';
    i      INTEGER;
BEGIN
FOR i IN 1..6
        LOOP
            result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
END LOOP;
RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate join codes
CREATE OR REPLACE FUNCTION set_join_code() RETURNS TRIGGER AS
$$
BEGIN
    IF NEW.join_code IS NULL OR NEW.join_code = '' THEN
        LOOP
            NEW.join_code := generate_join_code();
            -- Ensure uniqueness
            IF NOT EXISTS (SELECT 1 FROM exams WHERE join_code = NEW.join_code) THEN
                EXIT;
END IF;
END LOOP;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_join_code
    BEFORE INSERT
    ON exams
    FOR EACH ROW
    EXECUTE FUNCTION set_join_code();