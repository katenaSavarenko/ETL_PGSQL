CREATE TABLE dm.DM_ACCOUNT_TURNOVER_F 
(
   on_date           DATE          not null, --Дата, на которую считаются обороты по счетам
   acc_num           NUMERIC(16)   not null, --Номер счета  
   turn_deb          NUMERIC(33),            --Оборот по дебету в рублях 
   turn_deb_rub      NUMERIC(33),            --Оборот по дебету в тыс.рублей 	
   turn_cre          NUMERIC(33),            --Оборот по кредиту в рублях 
   turn_cre_rub      NUMERIC(33)             --Оборот по кредиту в тыс.рублей 	
)


CREATE TABLE DM.DM_F101_ROUND_F
(
   from_date           DATE         not null, --отчетная дата, на которую составлена оборотная ведомость
   to_date             DATE         not null, --конечная дата                       
   chpt_plan           CHAR(1)      not null, --глава плана счетов бухгалтерского учета в кредитных организаций
   acct_num_sc         CHAR(5)      not null, --номер счета второго порядка
   acct_act_or_pass    CHAR(1)      not null, --признак счета (счет активный или пассивный)
   atrr_full_val       CHAR(1)      not null, --признак раскрытия информации (в полном обьеме?)

   bal_in_rub          NUMERIC(16),          --входящие остатки «в рублях»
   bal_in_val          NUMERIC(16),          --входящие остатки «ин. вал., драг.металлы»
   bal_in_total        NUMERIC(33),          --входящие остатки «итого»
   turn_deb_rub        NUMERIC(16),          --обороты за отчетный период по дебету (активу) «в рублях»
   turn_deb_val	       NUMERIC(16),          --обороты за отчетный период по дебету (активу) «ин. вал., драг.металлы»
   turn_deb_total      NUMERIC(33),          --обороты за отчетный период по дебету (активу) «итого»
   turn_cre_rub        NUMERIC(16),          --обороты за отчетный период по кредиту (пассиву) «в рублях»
   turn_cre_val        NUMERIC(16),          --обороты за отчетный период по кредиту (пассиву) «ин. вал., драг.металлы»
   turn_cre_total      NUMERIC(33),          --обороты за отчетный период по кредиту (пассиву) «итого»
   bal_out_rub         NUMERIC(16),          --исходящие остатки «в рублях»
   bal_out_val         NUMERIC(16),          --исходящие остатки «ин. вал., драг.металлы»
   bal_out_total       NUMERIC(33)           --исходящие остатки «итого»
)