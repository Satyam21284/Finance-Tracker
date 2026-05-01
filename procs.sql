delimiter $$

-- Procedure to post a new transaction and update the corresponding account balance:
create procedure sp_post_transaction(
    in p_user_id int,
	in p_account_id int,
    in p_category_id int,
    in p_merchant_id int,
    in p_amount decimal(15,2),
    in p_transaction_type enum('expense', 'income'),
    in p_transaction_date datetime,
    in p_description varchar(255)
    )
begin
    declare exit handler for SQLEXCEPTION
    begin
        rollback;
        resignal;
    end;

    -- Insert the new transaction record
	insert into transactions (
	    user_id, account_id, category_id, merchant_id,
        amount, transaction_type, transaction_date,
        description
        )
	values (p_user_id, p_account_id, p_category_id, p_merchant_id,
		p_amount, p_transaction_type, p_transaction_date, p_description);
        
	-- The balance update is handled by the `trg_after_transaction_insert` trigger to avoid redundant logic.
    -- This procedure ensures the insertion is atomic. If the trigger fails, this transaction will roll back.

    COMMIT;
end $$

-- Procedure to insert or update a budget (UPSERT):
create procedure sp_upsert_budget(
	in p_user_id int,
    in p_category_id int,
    in p_amount decimal(15,2),
    in p_year int,
    in p_month int
	)
begin
	insert into budgets (user_id, category_id, amount, year, month)
	values (p_user_id, p_category_id, p_amount, p_year, p_month)
	on duplicate key update
	    amount = values(amount);
end $$

delimiter ;