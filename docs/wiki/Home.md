# Tower Defence Project Wiki

This wiki contains the project's requirements and supervisor meeting minutes.

## Documentation

- [Functional Requirements](Functional-Requirements)
- [Meeting 1](Meeting-01)
- [Meeting 2](Meeting-02)
- [Meeting 3](Meeting-03)
- [Meeting 4](Meeting-04)
- [Meeting 5](Meeting-05)

The pages are generated from the LaTeX source files in the main repository.
After changing the source documents, publish the updated wiki with:

```bash
make publish-wiki
```

The command pulls the wiki repository, regenerates the Markdown pages, asks
for a commit message, commits the changes, and pushes them to GitHub. The wiki
clone is kept next to the main repository at
`../tower-defence-final-project.wiki` by default. To use another location:

```bash
WIKI_REPO=/path/to/tower-defence-final-project.wiki make publish-wiki
```
