"
I keeps track of which bookmarks exist for a source database in the target database where they are stored.

Normally I am a singleton, with the target being the private database of the user.

I can also have a testing instance that uses in-memory databases.

Send #default or #uniqueInstance for the singletone, and #forTesting to get the testing isntance.

Data:
(i) the target bookmark storage database,
(ii) a dictionary mapping databases (by name) to dictionaries mapping page titles to bookmark titles.
NB: the latter may be needed in case of conflicts.
"
Class {
	#name : #BookmarkRegistry,
	#superclass : #Object,
	#category : #'GToolkit-Bookmarks-Model'
}
