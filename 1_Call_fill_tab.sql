--Заполнение таблицы dm.DM_ACCOUNT_TURNOVER_F 

do $$
declare
   in_date DATE := '2018-01-01';
   result_date DATE;
begin
   for cnt in 0..30 loop
    result_date := in_date + cnt;
    call dm.fill_account_turnover_f(result_date);
   end loop;
end; $$


--Заполнение таблицы DM.DM_F101_ROUND_F
call dm.fill_F101_ROUND_F('2018-01-31')