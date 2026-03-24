Method for generating the AI response:
Workshop embeddings
Each workshop now has a vector embedding.
The embedding is generated from a concatenation of the workshop’s title, short description, and long description.
Query embedding + retrieval
The user’s search query is embedded using the same embedding model.
We run a vector similarity search to retrieve the top 6 most relevant workshops.
Notes:
The vector search currently only considers workshops marked “Public” (i.e., searchable). It excludes “Unlisted” and “Event” workshops.
Sprints are included in the retrieval set (for now).
Prompting OCI GenAI
We send OCI GenAI: (a) the user’s query and (b) the retrieved workshop details, along with the prompts referenced above.
Displaying the result
The resulting answer is displayed to the user in the LiveLabs “AI Companion” region on the search results page.