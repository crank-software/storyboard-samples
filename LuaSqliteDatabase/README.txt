This application opens usersettings.sqlite on init then populates, and updates,
the various controls on the main screen.
 
Changing the controls will keep their values locally until you change users at which
point an "UPDATE" query is sent to the database.