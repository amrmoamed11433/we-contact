# Manual testing checklist

## Group limits

- Open a group.
- Add customers until the group has 6 active customers.
- Try adding a 7th customer.
- Confirm the localized full-group alert appears.

## Contacts import

- Open Add Customer.
- Tap Choose from contacts.
- Grant Contacts permission when iOS asks.
- Select a contact with a phone number.
- Confirm the name field and phone field are filled automatically.
- Test a contact with multiple numbers and confirm each number appears as a selectable row.
- Deny Contacts permission and confirm the permission dialog appears with an Open Settings action.

## Payment updates

- Mark an unpaid customer as paid.
- Confirm dashboard collected money, pending money, paid count, and unpaid count update immediately.
- Mark the same customer as unpaid.
- Confirm all totals update immediately.

## Editing totals

- Edit a customer price.
- Confirm group and dashboard totals update.
- Edit a group company cost.
- Confirm group and dashboard net profit update.

## Cycle calculations

- Group with renewal day 1 should start on day 1 of the current month.
- Group with renewal day 16 should start on day 16 of the current month if today is day 16 or later.
- Group with renewal day 16 should start on day 16 of the previous month if today is before day 16.

## Monthly reset

- Change the device date to a new cycle window.
- Relaunch the app.
- Confirm previous cycle history is saved once.
- Confirm customer payment status resets to unpaid.
- Relaunch again in the same cycle.
- Confirm no duplicate history record is created.

## Localization

- Open Settings.
- Switch to English.
- Confirm layout is LTR and all labels are English.
- Switch to Arabic.
- Confirm layout is RTL and all labels are Arabic.

## Persistence

- Add/edit customers and group costs.
- Close the app completely.
- Reopen the app.
- Confirm data is persisted.
