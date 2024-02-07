CREATE OR REPLACE PROCEDURE dm.fill_account_turnover_f(in_onDate DATE)
language plpgsql
as $$
begin

--Чистка таблицы
DELETE FROM dm.dm_account_turnover_f WHERE on_date = in_onDate;

INSERT INTO dm.dm_account_turnover_f  ( 
										 on_date
									   , acc_num
									   , turn_deb
									   , turn_deb_rub
									   , turn_cre
									   , turn_cre_rub
									  )

SELECT in_onDate                              as on_date
	 , t.account_rk                           as acc_num
	 , SUM(t.debet_amount)                    as turn_deb
	 , SUM(t.debet_amount_rub)                as turn_deb_rub
	 , SUM(t.credit_amount)                   as turn_cre
	 , SUM(t.credit_amount_rub)               as turn_cre_rub
  FROM 
  (
	  select p.credit_account_rk                             as account_rk
           , p.credit_amount                                 as credit_amount
           , p.credit_amount * nullif(er.reduced_cource, 1)  as credit_amount_rub
           , cast(null as numeric)               			 as debet_amount
           , cast(null as numeric)                 			 as debet_amount_rub
        from ds.ft_posting_f p
          inner join ds.md_account_d a           on a.account_rk = p.credit_account_rk
          left  join ds.md_exchange_rate_d er    on er.currency_rk = a.currency_rk
                                                 and in_onDate between er.data_actual_date and er.data_actual_end_date
       where p.oper_date = in_onDate
         and in_onDate between a.data_actual_date and a.data_actual_end_date
         and a.data_actual_date between  date_trunc('month', to_date(in_onDate::TEXT,'yyyy-mm-dd')) 
	                                and (date_trunc('month', to_date(in_onDate::TEXT,'yyyy-mm-dd')) + INTERVAL '1 MONTH - 1 day')
       
	 union all
		
      select p.debet_account_rk                   			as account_rk
           , cast(null as numeric)                 			as credit_amount
           , cast(null as numeric)                 			as credit_amount_rub
           , p.debet_amount                       			as debet_amount
           , p.debet_amount * nullif(er.reduced_cource, 1)  as debet_amount_rub
        from ds.ft_posting_f p
           inner join ds.md_account_d a           on a.account_rk = p.debet_account_rk
           left  join ds.md_exchange_rate_d er    on er.currency_rk = a.currency_rk
                                                   and '2018-01-01' between er.data_actual_date and er.data_actual_end_date
       where p.oper_date = in_onDate
         and in_onDate between a.data_actual_date and a.data_actual_end_date
         and a.data_actual_date between  date_trunc('month', to_date(in_onDate::TEXT,'yyyy-mm-dd')) 
	                                and (date_trunc('month', to_date(in_onDate::TEXT,'yyyy-mm-dd')) + INTERVAL '1 MONTH - 1 day')

	  ) t
    GROUP BY t.account_rk;
end; $$
