set serveroutput on;
declare
cursor cont_cursor is
select *
from contracts;
v_cont_dur number(3) ;
v_cont_inst number(4) ;
v_cont_pur CONTRACTS.CONTRACT_TOTAL_FEES%type;
v_inst number (8,2) ; 
v_inst_date contracts.CONTRACT_STARTDATE%type;

begin
For v_cont_record in cont_cursor Loop 
    v_cont_dur := (months_between(v_cont_record.contract_enddate , v_cont_record.contract_startdate)) /12 ;

    if  v_cont_record.CONTRACT_PAYMENT_TYPE = 'ANNUAL'  then
    v_cont_inst := v_cont_dur * 1 ;
    elsif v_cont_record.CONTRACT_PAYMENT_TYPE = 'QUARTER'  then
    v_cont_inst := v_cont_dur * 4 ;
    elsif v_cont_record.CONTRACT_PAYMENT_TYPE = 'MONTHLY'  then
    v_cont_inst := v_cont_dur * 12 ;
    else
    v_cont_inst := v_cont_dur * 2 ;
    end if ;

    v_cont_pur :=  v_cont_record.CONTRACT_TOTAL_FEES - nvl(v_cont_record.CONTRACT_DEPOSIT_FEES , 0) ;
    v_inst := v_cont_pur / v_cont_inst ;
    v_inst_date :=  v_cont_record.CONTRACT_STARTDATE ;
   
    for i in 1 .. v_cont_inst loop
        if  v_cont_record.CONTRACT_PAYMENT_TYPE = 'ANNUAL'  then
        v_inst_date := add_months(v_inst_date , 12) ;
        elsif v_cont_record.CONTRACT_PAYMENT_TYPE = 'QUARTER'  then
        v_inst_date := add_months(v_inst_date , 3) ;
        elsif v_cont_record.CONTRACT_PAYMENT_TYPE = 'MONTHLY'  then
        v_inst_date := add_months(v_inst_date , 1) ;
        else
        v_inst_date := add_months(v_inst_date , 6) ;
        end if ;    
    
       insert into INSTALLMENTS_PAID
                (INSTALLMENT_ID ,CONTRACT_ID , INSTALLMENT_DATE , INSTALLMENT_AMOUNT , PAID )
        VALUES
                 (INSTALLMENTS_PAID_SEQ.nextval ,  v_cont_record.contract_id ,v_inst_date ,v_inst,0) ;
         
    end loop ;
end loop;
end;