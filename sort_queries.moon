-- sort queries for the play message

{
    new: {
        query: "order by creation desc",
        name: "New"
    },
    recent: {
        query: "order by [update] desc",
        name: "Recent"
    }
}