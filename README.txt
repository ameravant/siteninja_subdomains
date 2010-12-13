HOW THIS PLUGIN WORKS

Because of a retro-fit to work with all modules, given the possibility that some may or may not be in
any given application the approach is a bit different than what might usually be used for a multi-tenant app

When adding this plugin, it must be loaded last, after pages because it will be adding a migration to all tables

CREATING THE ACCOUNT

The first thing we needed to do is add an 'accounts' table. All data is scoped through the account which is 
found from the incoming request domain. For example, if we have an account record with the domain column of 
"jason" and we have a request come in of jason.siteninja.com/articles, we find the account(Account.find_by_domain("jason")
and then we find the articles $CURRENT_ACCOUNT.articles

In the creation process, we also needed each account to have its own cms.yml and make that information
persistent. You can see this process in the add_cms_to_shared private method in the Admin::AccountsController.

ADDING MIGRATIONS

We had to add an account_id to each table that needed scoped data. This had to be dynamic based on what modules
were present. For example, we couldn't add account_id to events if there's no events module. 

To compensate for this, I created a list of possible tablenames which the migration checks before trying to add
add the column.
** This list, found in subdomainify/konstants.rb will need to be updated as additional tables are added to the app.

VALIDATING DATA

All data will have to be validated based on scope so I modified ARs validation method to add a default scope of 
account_id. This way, while we validate uniqueness of "login", we can still have one "admin" user for each account.

We also had to modify permalink_fu for the same reason. So we wouldn't end up with users/admin-2

FINDING THE ACCOUNT

In the application_controller there's a before filter to get_account. We only do this if there's an 'accounts'
table which tells us this is a subdomainified application. Confirm that all this functionality is in core and 
then you can remove the application_controller.rb from this plugin.

This before filter uses the incoming domain to find the associated account. We set that account to a global variable
which is used throughout the app.

FINDING THE DATA

The key part of this module is the overwriting of the find method for all applicable models. This also adds
a default scope to all finds. So Person.all will return all people where account_id == $CURRENT_ACCOUNT.id


MASTER ACCOUNT

Settings:
The master account has the ability to restrict certain setting fields to values which they determine, 
these are not editable by account owners. For example if a master account wants all subdomains
to have the same logo, he can restrict that field and then set the value to what he wants and it will be 
applied to all accounts.

TODO

Master Account 
Settings: 
This feature is working but could use more work.

Master Account will need to be able to find all info for accounts. This is tricky because of the scoped
finder methods. Might take a little work but shouldn't be too difficult to put together. 



