CREATE OR REPLACE PROCEDURE dm.fill_F101_ROUND_F(in_onDate DATE)
language plpgsql
as $$
begin

--Чистка таблицы
DELETE FROM DM.DM_F101_ROUND_F WHERE from_date = in_onDate;

INSERT INTO DM.DM_F101_ROUND_F 
                             (   from_date
							   , to_date
							   , chpt_plan
							   , acct_num_sc
							   , acct_act_or_pass
							   , atrr_full_val
							   , bal_in_rub
							   , bal_in_val
							   , bal_in_total
							   , turn_deb_rub
							   , turn_deb_val
							   , turn_deb_total
							   , turn_cre_rub
							   , turn_cre_val
							   , turn_cre_total
							   , bal_out_rub
							   , bal_out_val
							   , bal_out_total
							 )


SELECT tab.from_date
	 , tab.to_date
	 , tab.chpt_plan
	 , tab.acct_num_sc
	 , tab.acct_act_or_pass
	 , tab.atrr_full_val 
	 , CAST(tab.bal_in_rub as NUMERIC(16))
	 , CAST(tab.bal_in_val as NUMERIC(16))
	 , CAST(tab.bal_in_total as NUMERIC(33))
	 , CAST(tab.turn_deb_rub as NUMERIC(16))
	 , CAST(tab.turn_deb_val as NUMERIC(16))
	 , CAST(tab.turn_deb_total as NUMERIC(33))
	 , CAST(tab.turn_cre_rub as NUMERIC(16))
	 , CAST(tab.turn_cre_val as NUMERIC(16))
	 , CAST(tab.turn_cre_total as NUMERIC(33))
	 , CAST(tab.bal_out_rub as NUMERIC(16))
	 , CAST(tab.bal_out_val as NUMERIC(16))
	 , CAST((tab.bal_out_rub + tab.bal_out_val) as NUMERIC(33))
FROM
(
SELECT date_trunc('month', to_date(in_onDate::TEXT,'yyyy-mm-dd'))                                   as from_date 
     , date_trunc('month', to_date(in_onDate::TEXT,'yyyy-mm-dd')) + INTERVAL '1 MONTH - 1 day'      as to_date
	 , acct_s.chapter                         as chpt_plan
	 , SUBSTRING(acct_d.account_number, 1, 5) as acct_num_sc
	 , acct_d.char_type                       as acct_act_or_pass
	 , 1                                      as atrr_full_val
	 --входящие остатки «в рублях»
	 , SUM( 
			CASE
			  WHEN cur_d.currency_code in ('643', '810')
				 THEN bal_f.balance_out
			  ELSE 0
			END
		  ) as bal_in_rub
	 --входящие остатки «ин. вал., драг.металлы»  
	 , SUM( 
			CASE
			  WHEN cur_d.currency_code not in ('643', '810')
				 THEN bal_f.balance_out * exch_r.reduced_cource
			  ELSE 0
			END
	      ) as bal_in_val
	 --входящие остатки «итого»	  
	 , SUM( 
			CASE
			  WHEN cur_d.currency_code not in ('643', '810')
				 THEN bal_f.balance_out * exch_r.reduced_cource
			  ELSE bal_f.balance_out
			END
		  ) as bal_in_total
	---------------------------------------------------------------------  
	--обороты за отчетный период по дебету (активу) «в рублях»
	, SUM( 
		  CASE
		    WHEN cur_d.currency_code in ('643', '810')
		      THEN turn.turn_deb_rub
		    ELSE 0
		  END
	     ) as turn_deb_rub
	--обороты за отчетный период по дебету (активу) «ин. вал., драг.металлы»  
	, SUM( 
		  CASE
		    WHEN cur_d.currency_code not in ('643', '810')
		      THEN turn.turn_deb_rub
		    ELSE 0
		  END
	   ) as turn_deb_val
	--обороты за отчетный период по дебету (активу) «итого»
	, SUM(turn.turn_deb_rub) as turn_deb_total
	-------------------------------------------------------------------------
	--обороты за отчетный период по кредиту (пассиву) «в рублях»
  	, SUM( 
		  CASE
		    WHEN cur_d.currency_code in ('643', '810')
		      THEN turn.turn_cre_rub
		    ELSE 0
		  END
	     ) as turn_cre_rub
	--обороты за отчетный период по кредиту (пассиву) «ин. вал., драг.металлы»   
	, SUM( 
		  CASE
		    WHEN cur_d.currency_code not in ('643', '810')
		      THEN turn.turn_cre_rub
		    ELSE 0
		  END
	   ) as turn_cre_val
	--обороты за отчетный период по кредиту (пассиву) «итого»   
	, SUM(turn.turn_cre_rub) as turn_cre_total
 ----------------------------------------------------------------------------- 
    --исходящие остатки «в рублях»
	, SUM(
		  CASE 
			   WHEN cur_d.currency_code in ('643', '810') AND acct_d.char_type = 'A'
				 THEN bal_f.balance_out - turn.turn_cre_rub + turn.turn_deb_rub
			   WHEN cur_d.currency_code in ('643', '810') AND acct_d.char_type = 'P'
				 THEN bal_f.balance_out + turn.turn_cre_rub - turn.turn_deb_rub
			   ELSE 0
		   END
		  ) as bal_out_rub
     --исходящие остатки «ин. вал., драг.металлы»
	 , SUM(
		  CASE 
			   WHEN cur_d.currency_code not in ('643', '810') AND acct_d.char_type = 'A'
				 THEN bal_f.balance_out - turn.turn_cre_rub + turn.turn_deb_rub
			   WHEN cur_d.currency_code not in ('643', '810') AND acct_d.char_type = 'P'
				 THEN bal_f.balance_out + turn.turn_cre_rub - turn.turn_deb_rub
			   ELSE 0
		   END
		  ) as bal_out_val
  FROM ds.md_ledger_account_s acct_s
    INNER JOIN ds.md_account_d acct_d        ON SUBSTRING(acct_d.account_number, 1, 5)::NUMERIC = acct_s.ledger_account
    INNER JOIN ds.md_currency_d cur_d        ON cur_d.currency_rk = acct_d.currency_rk
    LEFT  JOIN ds.ft_balance_f bal_f         ON bal_f.account_rk = acct_d.account_rk
                                                AND bal_f.on_date = date_trunc('month', to_date(in_onDate::TEXT,'yyyy-mm-dd')) - INTERVAL '1 DAY'
    LEFT  JOIN ds.md_exchange_rate_d exch_r  ON exch_r.currency_rk = acct_d.currency_rk
                                                AND in_onDate between exch_r.data_actual_date and exch_r.data_actual_end_date
    LEFT  JOIN dm.dm_account_turnover_f turn ON turn.acc_num = acct_d.account_rk
                                                AND turn.on_date between date_trunc('month', to_date(in_onDate::TEXT,'yyyy-mm-dd')) 
												AND date_trunc('month', to_date(in_onDate::TEXT,'yyyy-mm-dd')) + INTERVAL '1 MONTH - 1 day'
 WHERE in_onDate between acct_s.start_date and acct_s.end_date 
   AND in_onDate between acct_d.data_actual_date and acct_d.data_actual_end_date
   AND in_onDate between cur_d.data_actual_date and cur_d.data_actual_end_date
GROUP BY  acct_s.chapter
	    , acct_d.account_number
	    , acct_d.char_type
) tab;
end; $$
