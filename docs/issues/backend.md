# Backend

This component covers the Go server, GraphQL middleware, authentication, downloads, and the API surface exposed to the Flutter client and browser UI.

## Issue: GraphQL and download routes have no throttling or concurrency guard

**Severity:** High  
**Category:** Performance  
**Location:** `stash/internal/api/server.go`  
**Status:** Open

### Description
The GraphQL server and download routes are mounted without any request rate limit or concurrency guard. That leaves expensive resolvers, subscriptions, and file downloads fully exposed to bursty clients.

### Evidence
`Initialize()` wires middleware for auth, logging, compression, and dataloaders, but there is no rate-limit layer around `gqlEndpoint` or the route handlers. The server does have some throttling elsewhere in the codebase, but not on the public API entry points.

### Impact
One misbehaving client or a small burst of requests can overload the API server and the underlying media/indexing services. For browser clients, this also increases the chance of accidental request storms.

### Suggested Fix
Add a modest rate limit or concurrency cap per IP/session for expensive GraphQL and download routes. Keep the limits conservative enough to avoid harming normal browsing.

### Validation
Replay a burst of GraphQL and download requests and confirm the server sheds load gracefully instead of queueing unbounded work.

