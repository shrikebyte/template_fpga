# External Libraries

External libraries in this project are managed with git subtree. Each directory within lib is an external git repository.

To update an existing dependency, run, for example:

`git subtree pull --prefix lib/sblib https://github.com/shrikebyte/sblib.git main --squash`

To add a new dependency, run, for example:

`git subtree add --prefix lib/new-repo https://github.com/shrikebyte/new-repo.git main --squash`
