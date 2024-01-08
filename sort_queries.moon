-- sort queries for the play message

{
    new: {
        query: "order by creation desc",
        name: "New"
    },
    recent: {
        query: "order by [update] desc",
        name: "Recent"
    },
    popular: {
        query: "order by score desc, creation desc",
        name: "Popular"
    }
}