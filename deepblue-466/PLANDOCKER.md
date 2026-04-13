## Plan: Refactor & Simplify Docker Local Dev for dspace-containerization

This plan aims to streamline the Docker Desktop local development environment for the dspace-containerization project. The goal is to reduce complexity, improve developer experience, and remove unnecessary steps or containers. The plan will address build arguments, service dependencies, environment variables, and volume usage, based on the current setup in `README.md` and `docker-compose.yml`.

### Steps
1. Review and summarize current local dev workflow in [README.md](README.md) and [docker-compose.yml](docker-compose.yml).
2. Identify redundant or unnecessary containers, services, and steps in the local dev setup.
3. Propose a simplified service structure, consolidating containers where possible and clarifying service dependencies.
4. Recommend improvements for build arguments, environment variable management, and volume usage for easier onboarding and maintenance.
5. Outline changes to documentation ([README.md](README.md)) to reflect the streamlined workflow.

### Further Considerations
1. Should any services be merged (e.g., combine backend/frontend where feasible) or made optional for local dev?
2. Are there developer pain points (e.g., slow builds, manual steps) that should be prioritized for elimination?
3. Should the plan target Docker Compose v2 features or maintain compatibility with older versions?

