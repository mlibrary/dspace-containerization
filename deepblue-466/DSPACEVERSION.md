Starting with the release of **DSpace 7.0**, the frontend and backend officially use the **same version numbering scheme** to ensure compatibility and simplify the installation process.

### How Versioning Works
In modern DSpace (versions 7, 8, and 9+), the architecture is split into two distinct applications that communicate via a REST API. To make it clear which versions are meant to work together:
* **Synchronized Releases:** When a new version is released (e.g., DSpace 9.2), the community releases a corresponding version of the **DSpace Angular frontend** and the **DSpace backend (REST API)** simultaneously.
* **Matching Tags:** On GitHub, both repositories are tagged with the same version number.
* **Compatibility:** While a minor version mismatch (like frontend 8.1 with backend 8.2) might work in some specific scenarios, it is officially recommended and supported only when both components share the exact same version number.



### Why are they separate if the version is the same?
Even though the version numbers match, they remain separate software packages because they use entirely different technology stacks:
1.  **The Backend (DSpace Server):** Built with **Java** and Spring Boot. It manages the database (PostgreSQL), the search index (Solr), and the file storage.
2.  **The Frontend (DSpace UI):** Built with **Angular** (TypeScript/Node.js). This is what the user sees in the browser and it "talks" to the backend to retrieve or submit data.

### Historical Context (DSpace 6 and older)
Prior to version 7, DSpace used a "monolithic" architecture. In those older versions, there was only one primary version number because the user interface (JSPUI or XMLUI) was built directly into the Java application. The move to synchronized versioning was a specific decision made to help administrators manage the newer, split architecture more easily.