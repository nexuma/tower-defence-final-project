# Tower Defence Project Wiki

This wiki contains the project's plan, time log, requirements, roadmap,
decisions, and supervisor meeting minutes.

## Documentation

- [Project Plan](Project-Plan)
- [Time Log](Time-Log)
- [Project Direction and Exploration Roadmap](Project-Direction)
- [Project Decision Log](Decision-Log)
- [Functional Requirements](Functional-Requirements)
- [Meeting 1](Meeting-01)
- [Meeting 2](Meeting-02)
- [Meeting 3](Meeting-03)
- [Meeting 4](Meeting-04)
- [Meeting 5](Meeting-05)

The pages are generated or copied from the source documents in the main
repository. After changing the source documents, publish the updated wiki with:

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
