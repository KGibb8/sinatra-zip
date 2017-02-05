# Sinatra Unzipper

The Unzip class unpacks the files and acts as a container for the results.
Is actually probably unnecessary in the long run.

The Entity class (needs renaming!) contains the logic that writes the file
to any specified path and validators to ensure that the file is one of the
permitted files on the whitelist. In this case, PDF.

At the moment we can still fake out a PDF file by inputting
one with "%PDF" at the beginning, %%EOF at the end
and ".pdf" as the file extension

# Get Started

Run the tests:
```
rspec
```

Run the server:
```
rake s
```

<ul>
  <li>Navigate to <a href="localhost:4567/">localhost:4567</a></li>
  <li>Follow the link and enter a ZIP file to upload</li>
  <li>Redirected to the uploaded_files page which displays the location of the files on your disk and the file_type</li>
</ul>
