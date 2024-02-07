-- PROCEDURE: dm.fill_account_turnover_f(date)

-- DROP PROCEDURE IF EXISTS dm.fill_account_turnover_f(date);

CREATE OR REPLACE PROCEDURE dm.input_csv(
	IN in_action numeric)
LANGUAGE 'plpgsql'
AS $BODY$
begin
--1 - выгрузка в csv из бд
--2 - загрузка из csv в бд
if in_action = 1 then

    --выгрузка в csv dm_account_turnover_f
	COPY dm.dm_account_turnover_f(on_date, acc_num, turn_deb, turn_deb_rub, turn_cre, turn_cre_rub)
	TO 'C:\Program Files\PostgreSQL\16\pgAdmin 4\dm_account_turnover_f.csv' DELIMITER ',' CSV HEADER;
    
	--запись в лог
	insert into logs.load_logs (source, action_datatime, action)
	select 'dm_account_turnover_f', current_timestamp, 'input_csv';
	
	--выгрузка в csv dm_account_turnover_f
    COPY dm.dm_f101_round_f(from_date, to_date, chpt_plan, acct_num_sc, acct_act_or_pass, atrr_full_val, bal_in_rub, bal_in_val, bal_in_total, turn_deb_rub, turn_deb_val, turn_deb_total, turn_cre_rub, turn_cre_val, turn_cre_total, bal_out_rub, bal_out_val, bal_out_total)
	TO 'C:\Program Files\PostgreSQL\16\pgAdmin 4\dm_f101_round_f.csv' DELIMITER ',' CSV HEADER;
    
    --запись в лог
	insert into logs.load_logs (source, action_datatime, action)
	select 'dm_f101_round_f', current_timestamp, 'input_csv';
else
    truncate table dm.dm_account_turnover_f;
    --загрузка из csv в dm_account_turnover_f
	COPY dm.dm_account_turnover_f(on_date, acc_num, turn_deb, turn_deb_rub, turn_cre, turn_cre_rub)
	FROM 'C:\Program Files\PostgreSQL\16\pgAdmin 4\dm_account_turnover_f.csv' DELIMITER ',' CSV HEADER;
    
	--запись в лог
	insert into logs.load_logs (source, action_datatime, action)
	select 'dm_account_turnover_f', current_timestamp, 'output_csv';
	
	truncate table dm.dm_f101_round_f;
	--загрузка из csv в dm_account_turnover_f
    COPY dm.dm_f101_round_f(from_date, to_date, chpt_plan, acct_num_sc, acct_act_or_pass, atrr_full_val, bal_in_rub, bal_in_val, bal_in_total, turn_deb_rub, turn_deb_val, turn_deb_total, turn_cre_rub, turn_cre_val, turn_cre_total, bal_out_rub, bal_out_val, bal_out_total)
	FROM 'C:\Program Files\PostgreSQL\16\pgAdmin 4\dm_f101_round_f.csv' DELIMITER ',' CSV HEADER;
    
    --запись в лог
	insert into logs.load_logs (source, action_datatime, action)
	select 'dm_f101_round_f', current_timestamp, 'output_csv';
end if;

end; 
$BODY$;
ALTER PROCEDURE dm.fill_account_turnover_f(date)
    OWNER TO postgres;
