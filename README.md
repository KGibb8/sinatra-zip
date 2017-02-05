# Sinatra Unzip

The Unzip class unpacks the files and acts as a container for the results.
Is actually probably unnecessary in the long run.

The Entity class (needs renaming!) contains the logic that writes the file
to any specified path and validators to ensure that the file is one of the
permitted files on the whitelist. In this case, PDF.

At the moment we can still fake out a PDF file by inputting
one with "%PDF" at the beginning, %%EOF at the end
and ".pdf" as the file extension

