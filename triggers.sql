delimiter $$

-- Trigger to automatically update account balance after a transaction is inserted:
create trigger trg_after_transaction_insert
after insert on transactions
for each row
begin
	if new.transaction_type = 'expense' then
		update accounts
        set balance = balance - new.amount
        where id = new.account_id;
        
	elseif new.transaction_type = 'income' then
		update accounts
        set balance = balance + new.amount
        where id = new.account_id;
	
    end if;
end $$


-- Trigger to automatically update account balance after a transaction is deleted:
create trigger trg_after_transaction_delete
after delete on transactions
for each row
begin
	if old.transaction_type = 'expense' then
		update accounts
        set balance = balance + old.amount
        where id = old.account_id;
	
    elseif old.transaction_type = 'income' then
		update accounts
        set balance = balance - old.amount
        where id = old.account_id;
        
	end if;
end $$


-- Trigger to automatically update account balance after a transaction is updated:
create trigger trg_after_transaction_update
after update on transactions
for each row
begin
	
    -- Revert the old transaction amount
    if old.transaction_type = 'expense' then
		update accounts
        set balance = balance + old.amount
        where id = old.account_id;
	
    else
		update accounts
        set balance = balance - old.amount
        where id = old.account_id;
	
    end if;
    
    -- Apply the new transaction amount
    if new.transaction_type = 'expense' then
		update accounts
        set balance = balance - new.amount
        where id = new.account_id;
	
    else
		update accounts
        set balance = balance + new.amount
        where id = new.account_id;
	
    end if;
end $$


-- Trigger to enforce category parent integrity rules before insert / update:
create trigger trg_before_category_insert_update
before insert on categories
for each row
begin
	declare parent_type enum('income', 'expense');
    
    -- Prevent a category from being it's own parent:
    if new.parent_id is not null and new.id = new.parent_id then
		signal sqlstate '45000' set message_text = 'A Category Can Not be its Own Parent.';
	end if;
    
    -- Ensure Parent and Child have the Same Type (income / expense):
    if new.parent_id is not null then
		select type into parent_type from categories
        where id = new.parent_id;
        
        if parent_type <> new.type then
			signal sqlstate '45000' set message_text = 'A Sub-Category Must Have The Same Type (income / expense) as its Parent.';
		end if;
	end if;
end $$

delimiter ;