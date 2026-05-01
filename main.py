# ==================================================== Imports ====================================================#

import sys
from datetime import datetime
from decimal import Decimal
from typing import Optional

# Importing Services:
from services.user_service import UserService
from services.account_service import AccountService
from services.transaction_service import TransactionService
from services.budget_service import BudgetService
from services.category_service import CategoryService
from services.merchant_service import MerchantService
from services.analytics_service import AnalyticsService
from services.audit_log_service import AuditLogService

# Importing Core Modules:
from core.db_conn import DatabaseConnection
from core.auth import AuthManager
from core.exceptions import *

# Importing Utilities:
from utils.cli_helpers import *
from utils.validators import *

# Importing Analytics Functions:
from analytics import reports, charts

# =================================================================================================================#

class ExpenseTrackerCLI:

    def __init__(self):
        self.user_service = UserService()
        self.account_service = AccountService()
        self.transaction_service = TransactionService()
        self.budget_service = BudgetService()
        self.category_service = CategoryService()
        self.merchant_servie = MerchantService()
        self.analytics_service = AnalyticsService()
        self.audit_log_service = AuditLogService()

#===================================================================================================================#
    def run(self):

        while True:
            if not AuthManager.is_authenticated():
                self._startup_menu()
            else:
                self._main_menu()


    def _startup_menu(self):

        clear_screen(); print_title('Welcome to Expense Tracker!!')
        print('1. Register')
        print('2. Login')
        print('3. Exit')

        choice = get_input('> ', error_message= 'Please Enter a Number:')

        if choice == '1': self._handle_registration()
        elif choice == '2': self._handle_login()
        elif choice == '3':
            print('Goodbye! Have a Nice Day!!')
            sys.exit(0)


    def _main_menu(self):

        user = AuthManager.get_current_user()
        clear_screen(); print_title(f"Main Menu (Logged in as: {user.username})")
        print('1. Manage Accounts')
        print('2. Manage Categories')
        print('3. Add/View Transactions')
        print('4. Manage Budgets')
        print('5. Run Expense Analysis')
        print('6. Export/Import CSV')

        if AuthManager.is_admin():
            print('8. Admin Menu')

        print('9. Logout')

        choice = get_input('> ')

        if choice == '1': self._manage_accounts()
        elif choice == '2': self._manage_categories()
        elif choice == '3': self._manage_transactions()
        elif choice == '4': self._manage_budgets()
        elif choice == '5': self._run_expense_analysis()
        elif choice == '6': self._handle_csv_operations()
        elif choice == '8' and AuthManager.is_admin(): self._admin_menu()
        elif choice == '9': self._handle_logout()

# ===================================================================================================================#
    def _handle_registration(self):

        clear_screen(); print_title('Register New User')

        try:
            username = get_input('Username', validate_not_empty, 'UserName Can Not be Empty.')

            email = get_input('Email', validate_email, 'Invalid Email Format.')

            password = get_password_input()

            if not validate_password(password):
                raise ValidationError('Password Must be at least 8 Characters Long.')

            user = self.user_service.register(username, email, password)

            print(f"\nUser '{user.username}' Registered Successfully!!")

        except (ValueError, ValidationError) as e:
            print(f"\nRegistration Failed: {e}")

        input('\nPress Enter to Continue...')


    def _handle_login(self):

        clear_screen(); print_title('User Login')

        try:
            email = get_input('Email', validate_email, 'Invalid Email Format.')
            password = get_password_input()
            user = self.user_service.login(email, password)

            if user:
                AuthManager.login(user)
                print(f"\nWelcome Back, {user.username}")

            else:
                raise AuthenticationError('Invalid Email or password.')

        except AuthenticationError as e:
            print(f'\nLogin Failed: {e}')

        input('\nPress Enter to Continue...')


    def _handle_logout(self):
        AuthManager.logout()
        print('\nYou Have Been Logged Out.')
        input('Press Enter to Continue...')

# ===================================================================================================================#
    def _handle_add_account(self):
        user = AuthManager.get_current_user()
        clear_screen(); print_title('Add New Account')

        try:
            name = get_input('Enter Account Name', validator= validate_not_empty)

            print('Available Account Types: [1]Cash, [2]Bank, [3]Credit Card')
            type_choice = get_input('Choose Account Type', lambda c: c if c in ['1','2','3'] else None)

            type_map = {'1': 'CashAccount',
                        '2': 'BankAccount',
                        '3': 'CreditCardAccount'}

            account_type = type_map[type_choice]

            balance_str = get_input('Enter Initial Balance (e.g. 500.00)') or '0.0'
            balance = Decimal(balance_str)

            self.account_service.create_account(user.id, name, account_type, balance)
            print('\nAccount Created Successfully!')

        except Exception as e:
            print(f'\nError Creating Account: {e}')

        input('\nPress Enter to Continue...')

    def _handle_edit_account(self):
        user = AuthManager.get_current_user()
        clear_screen(); print_title('Edit Account Name')

        account_id_str = get_input('Enter Account ID to Edit', lambda i: i if i.isdigit() else None)
        if not account_id_str:
            return

        new_name = get_input('Enter New Name for The Account', validator= validate_not_empty)

        if self.account_service.update_account_name(int(account_id_str), user.id, new_name):
            print('\nAccount Updated Successfully!')
        else:
            print('\nFailed To Update Account. Please Check The ID.')

        input('\nPress Enter to Continue...')

    def _handle_delete_account(self):
        user = AuthManager.get_current_user()
        clear_screen(); print_title('Delete Account')

        account_id_str = get_input('Enter Account ID to Delete', lambda i: i if i.isdigit() else None)
        if not account_id_str:
            return

        confirm = get_input(f"Are You Sure You Want to Delete Account {account_id_str}?? [y/n]").lower()
        if confirm == 'y':
            if self.account_service.delete_account(int(account_id_str), user.id):
                print('\nAccount Deleted Successfully!')
            else:
                print('\nFailed to Delete Account. Please Check The ID.')
        else:
            print('\nDeletion Cancelled.')

        input('\nPress Enter to Continue...')

    def _manage_accounts(self):
        user = AuthManager.get_current_user()

        while True:
            clear_screen(); print_title('Manage Accounts')

            accounts = self.account_service.get_user_accounts(user.id)
            headers = ['ID','Name','Type','Balance']
            data = [{'id': acc.id,
                 'name': acc.name,
                 'type': acc.account_type,
                 'balance': f"{acc.balance:.2f}"}
                for acc in accounts]
            print_table(data= data, headers= headers)

            print('\nOptions: [A]dd, [E]dit, [D]elete, [B]ack to Main Menu')
            choice = get_input('> ').lower()

            if choice == 'a':
                self._handle_add_account()
            elif choice == 'e':
                self._handle_edit_account()
            elif choice == 'd':
                self._handle_delete_account()
            elif choice == 'b':
                break
            else:
                print('Invalid Option.')
                input('\nPress Enter to Continue...')

# ===================================================================================================================#
    def _manage_categories(self):

        user = AuthManager.get_current_user()
        clear_screen(); print_title('Manage Categories')

        categories = self.category_service.get_user_categories(user.id)
        headers = ['ID','Name','Type','Parent ID']
        data = [{
            'id': cat.id,
            'name': cat.name,
            'type': cat.type,
            'parent_id': cat.parent_id or 'N/A'
        } for cat in categories]
        print_table(data= data, headers= headers)

        print('\nOptions: [A]dd, [D]elete, [B]ack')
        choice = get_input('> ').lower()

        if choice == 'a':
            name = get_input('Category Name', validator= validate_not_empty).strip()
            cat_type = get_input('Type (income/expense)', lambda t : t if t in ['income', 'expense'] else None)
            parent_id_str = get_input('Parent ID (Optional, Press Enter to Skip)')
            parent_id = int(parent_id_str) if parent_id_str.isdigit() else None

            try:
                self.category_service.create_category(user.id, name, cat_type, parent_id)
                print('Category Added Successfully.')
            except Exception as e:
                print(f'Error: {e}')
            input('\nPress Enter To Continue...')

        elif choice == 'd':
            cat_id_str = get_input('Enter Category ID to Delete', lambda i : i if i.isdigit() else None)
            if cat_id_str:
                if self.category_service.delete_category(int(cat_id_str), user.id):
                    print('Category Deleted.')
                else:
                    print('Category Not Found OR Could Not be Deleted.')
            input('\nPress Enter to Continue...')

# ===================================================================================================================#
    def _handle_merchant_selection(self, user_id: int, is_edit: bool = False) -> Optional[int]:
        print('\n-- Merchants --')
        merchants = self.merchant_servie.get_user_merchants(user_id)
        if merchants:
            headers = ["ID", 'Name']
            data = [{'id': m.id, 'name': m.name} for m in merchants]
            print_table(data= data, headers= headers)

        choice = get_input("Enter Merchant ID, [N]ew, [R]emove, or [S]kip" if is_edit else "Enter Merchant ID, [N]ew, or [S]kip").lower()

        if choice.isdigit() and any(m.id == int(choice) for m in merchants):
            return int(choice)
        elif choice == 'n':
            name = get_input('Enter New Merchant Name', validate_not_empty)
            merchant = self.merchant_servie.get_or_create_merchant(user_id, name)
            print(f"Selected New Merchant '{merchant.name}' (ID: {merchant.id}).")
            return merchant.id
        elif choice == 'r' and is_edit:
            return False
        else:
            return None

    def _handle_add_transaction(self):
        user = AuthManager.get_current_user()
        clear_screen(); print_title('Add New Transaction')

        try:
            print('Your Accounts:')
            accounts = self.account_service.get_user_accounts(user.id)
            acc_data = [{'id': acc.id, 'name': acc.name, 'type': acc.account_type} for acc in accounts]
            print_table(data= acc_data, headers= ['ID','Name','Type'])

            account_id = int(get_input('\nEnter Account ID', lambda i: i if i.isdigit() else None))

            print('\nYour Categories:')
            categories = self.category_service.get_user_categories(user.id)
            cat_data = [{'id': cat.id, 'name': cat.name, 'type': cat.type} for cat in categories]
            print_table(data= cat_data, headers= ['ID','Name','Type'])
            category_id = int(get_input('\nEnter Category ID', lambda i: i if i.isdigit() else None))

            amount_str = get_input('\nEnter Amount')
            amount = validate_amount(amount_str)
            if amount is None:
                raise ValidationError('Amount Must be a Positive Number.')

            trans_type = get_input('Enter Type (income/expense)', lambda t: t if t in ['income','expense'] else None)
            date_str = get_input('Enter Date(YYYY-MM-DD, Press Enter for Today)')
            trans_date = validate_date(date_str) if date_str else datetime.now()
            description = get_input('Enter Description(optional)')
            merchant_id = self._handle_merchant_selection(user.id)

            self.transaction_service.add_transaction(
                user_id= user.id, account_id= account_id, category_id= category_id,
                amount= amount, transaction_type= trans_type, transaction_date= trans_date,
                description= description, merchant_id= merchant_id
            )
            print('\nTransaction Added Successfully!!')
        except Exception as e:
            print(f'\nError: {e}')
        input('\nPress Enter to Continue...')


    def _handle_delete_transaction(self):
        user = AuthManager.get_current_user()
        clear_screen(); print_title('Delete Transaction')
        trans_id_str = get_input('Enter Transaction ID', lambda i: i if i.isdigit() else None)

        if trans_id_str:
            if self.transaction_service.delete_transaction(int(trans_id_str), user.id):
                print(f"\nTransaction Deleted Successfully.")
            else:
                print("\nCould Not Delete Transaction.")
        input('\nPress Enter to Continue...')


    def _handle_edit_transaction(self):
        user = AuthManager.get_current_user()
        clear_screen(); print_title('Edit Transaction')
        trans_id_str = get_input('Enter Transaction ID', lambda i: i if i.isdigit() else None)
        if not trans_id_str: return

        trans = self.transaction_service.get_transaction_by_id(int(trans_id_str), user.id)
        if not trans:
            print('Transaction Not Found.')
            input('Press Enter...'); return

        print('\nEditing Transaction. Press Enter to Keep Current Value.')
        new_date_str = get_input(f"Date (Current: {trans.transaction_date.strftime('%Y-%m-%d')})")
        new_date = validate_date(new_date_str) if new_date_str else trans.transaction_date

        new_account_id_str = get_input(f"Account ID (Current: {trans.account_id})")
        new_account_id = int(new_account_id_str) if new_account_id_str else trans.account_id

        new_category_id_str = get_input(f"Category ID (Current: {trans.category_id})")
        new_category_id = int(new_category_id_str) if new_category_id_str else trans.category_id

        new_amount_str = get_input(f"Amount (Current: {trans.amount})")
        new_amount = validate_amount(new_amount_str) if new_amount_str else trans.amount

        new_desc = get_input(f"Description (Current: {trans.description})")
        final_desc = new_desc if new_desc is not None else trans.description

        print(f"\nCurrent Merchant ID: {trans.merchant_id or 'None'}")
        new_merchant_id = self._handle_merchant_selection(user.id, is_edit= True)

        if new_merchant_id is None: final_merchant_id = trans.merchant_id
        elif new_merchant_id is False: final_merchant_id = None
        else: final_merchant_id = new_merchant_id

        new_data = {
            'transaction_date': new_date, 'account_id': new_account_id,
            'category_id': new_category_id, 'amount': new_amount,
            'description': final_desc, 'merchant_id': final_merchant_id
        }

        if self.transaction_service.update_transaction(trans.id, user.id, new_data):
            print('\nTransaction Updated.')
        else:
            print('\nUpdate Failed.')
        input('\nPress Enter...')


    def _manage_transactions(self):
        user = AuthManager.get_current_user()
        while True:
            clear_screen(); print_title('Manage Transactions')
            transactions = self.transaction_service.get_user_transaction(user.id)
            data = [{
                'id': t.id,
                'date': t.transaction_date.strftime('%Y-%m-%d'),
                'type': t.transaction_type,
                'amount': f"{t.amount:.2f}",
                'category': getattr(t, 'category_name','N/A'),
                'account': getattr(t, 'account_name', 'N/A'),
                'description': t.description
            } for t in transactions]
            print_table(data= data, headers= ['ID','Date','Type','Amount','Category','Account','Description'])

            print('\nOptions: [A]dd, [E]dit, [D]elete, [B]ack')
            choice = get_input('> ').lower()
            if choice == 'a': self._handle_add_transaction()
            elif choice == 'e': self._handle_edit_transaction()
            elif choice == 'd': self._handle_delete_transaction()
            elif choice == 'b': break

# ===================================================================================================================#
    def _handle_set_budget(self):
        user = AuthManager.get_current_user()
        clear_screen(); print_title('Set Budget')
        try:
            year_str = get_input('Year (e.g 2025)', lambda y: y if y.isdigit() and len(y) == 4 else None)
            month_str = get_input('Month (1-12)', lambda m: m if m.isdigit() and 1<= int(m) <= 12 else None)
            
            categories = [c for c in self.category_service.get_user_categories(user.id) if c.type == 'expense']
            print_table(data= [{'id': cat.id, 'name': cat.name} for cat in categories], headers= ['ID','Name'])

            category_id_str = get_input('Category ID')
            amount_str = get_input('Amount')
            amount = validate_amount(amount_str)

            self.budget_service.set_budget(user.id, int(category_id_str), amount, int(year_str), int(month_str))
            print('\nBudget Set!')
        except Exception as e:
            print(f'Error: {e}')
        input('\nPress Enter...')

    def _manage_budgets(self):
        user = AuthManager.get_current_user()
        while True:
            clear_screen(); print_title('Manage Budgets')
            year_str = get_input('Year (e.g. 2025)', lambda y: y if y.isdigit() and len(y) == 4 else None)
            month_str = get_input('Month (1-12)', lambda m: m if m.isdigit() and 1 <= int(m) <= 12 else None)
            if not year_str or not month_str: return

            budgets = self.budget_service.get_budgets_for_period(user.id, int(year_str), int(month_str))
            data = [{
                'id': b['id'], 'category': b['category_name'],
                'type': b['category_type'], 'amount': f"{b['amount']:.2f}"
            } for b in budgets]
            print_table(data= data, headers= ['ID', 'Category', 'Type', 'Amount'])

            print('\nOptions: [S]et Budget, [B]ack')
            choice = get_input('> ').lower()
            if choice == 's': self._handle_set_budget()
            elif choice == 'b': break

# ===================================================================================================================#
    def _run_expense_analysis(self):
        user = AuthManager.get_current_user()
        clear_screen(); print_title('Expense Analysis')
        print('1. Trend | 2. Breakdown | 3. Budget vs Actual')
        choice = get_input('> ')
        df = self.analytics_service.get_transactions_as_dataframe(user.id)
        if df.empty:
            print('\nNo Data.'); input('Press Enter...'); return

        if choice == '1':
            path = charts.plot_monthly_trend(reports.monthly_expense_trend(df), user.id)
            print(f'\nSaved to: {path}')
        elif choice == '2':
            path = charts.plot_category_breakdown(reports.category_breakdown(df), user.id)
            print(f'\nSaved to: {path}')
        elif choice == '3':
            y = int(get_input('Year'))
            m = int(get_input('Month'))
            path = charts.plot_budget_vs_actual(reports.budget_vs_actual(user.id, y, m, df), user.id, y, m)
            print(f'\nSaved to: {path}')
        input('\nPress Enter...')

    def _handle_csv_operations(self):
        user = AuthManager.get_current_user()
        clear_screen(); print_title('CSV Operations')
        print('1. Export | 2. Import')
        choice = get_input('> ')
        if choice == '1':
            fn = get_input('Filename')
            print(f"\n{self.transaction_service.export_transaction_to_csv(user.id, fn)}")
        elif choice == '2':
            fn = get_input('Filename')
            print(f"\n{self.transaction_service.import_transactions_from_csv(user.id, fn)}")
        input('\nPress Enter...')

# ===================================================================================================================#
    def _admin_menu(self):
        while True:
            clear_screen(); print_title('Admin Menu')
            print('1. Manage Users | 2. Audit Logs | B. Back')
            choice = get_input('> ').lower()
            if choice == '1': self._admin_manage_users()
            elif choice == '2': self._admin_view_audit_logs()
            elif choice == 'b': break

    def _admin_view_audit_logs(self):
        clear_screen(); print_title('System Audit Logs')
        logs = self.audit_log_service.get_all_logs()
        data = [{
            'timestamp': log['timestamp'].strftime('%Y-%m-%d %H:%M:%S'),
            'username': log.get('username') or f"ID {log.get('user_id', 'N/A')}",
            'action': log['action'], 'details': log['details']
        } for log in logs]
        print_table(data= data, headers= ['Timestamp','UserName','Action','Details'])
        input('\nPress Enter...')

    def _admin_manage_users(self):
        admin_user = AuthManager.get_current_user()
        clear_screen(); print_title('Admin: Users')
        users = self.user_service.get_all_users()
        data = [{
            'id': u.id, 'username': u.username, 'email': u.email,
            'role': u.role, 'created_at': u.created_at.strftime('%Y-%m-%d')
        } for u in users]
        print_table(data= data, headers= ['Id','Username','Email','Role','Created At'])
        print('\nOptions: [D]elete, [B]ack')
        choice = get_input('> ').lower()
        if choice == 'd':
            uid = get_input('User ID')
            if uid:
                try:
                    if self.user_service.delete_user(int(uid), admin_user): print('Deleted.')
                    else: print('Not Found.')
                except Exception as e: print(f'Error: {e}')
        input('\nPress Enter...')


if __name__ == '__main__':
    try:
        print('Initializing Database Connection...')
        DatabaseConnection.initialize_pool()
        app = ExpenseTrackerCLI()
        app.run()
    except Exception as e:
        print(f'\nFatal Error: {e}')