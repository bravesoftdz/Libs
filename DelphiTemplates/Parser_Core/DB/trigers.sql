CREATE DEFINER=`root`@`localhost` TRIGGER `roman_parser`.`delete_body_group`
  AFTER DELETE ON `roman_parser`.`core_links`
  FOR EACH ROW
BEGIN
	delete from core_groups where id = old.body_group_id;
END;


CREATE DEFINER=`root`@`localhost` TRIGGER `roman_parser`.`write_root_chain`
  BEFORE INSERT ON `roman_parser`.`core_groups`
  FOR EACH ROW
BEGIN
  SET @A = (select root_chain from core_groups where id = NEW.parent_group_id);
	
	IF @A is NULL THEN
		SET NEW.root_chain = NEW.parent_group_id;
  ELSE
		SET NEW.root_chain = CONCAT_WS(';', @A, NEW.parent_group_id);
	END IF;
END;