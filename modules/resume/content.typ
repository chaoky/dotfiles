#let name = "Leonardo Dias Cardozo"
#let title = "Senior Software Engineer"

#let contacts = (
  (text: "levimanga@gmail.com", url: "mailto:levimanga@gmail.com"),
  (text: "linkedin.com/in/leonardo-da32973116", url: "https://www.linkedin.com/in/leonardo-da32973116"),
  (text: "github.com/chaoky", url: "https://github.com/chaoky"),
  (text: "Londrina, Brazil", url: none),
)

#let summary = "Senior product and platform engineer with 8+ years of experience taking ideas from zero to production and laying the groundwork so teams can succeed. Passionate about developer tooling, programming languages, Linux, and the world wide web."

#let experience = (
  (
    org: "Oppizi",
    role: "Senior Software Engineer",
    dates: "Jul 2025 - Present",
    location: "New York City, United States (remote)",
    intro: "Offline marketing platform. Product and platform engineer with broad ownership across performance, infrastructure, messaging, security, and AI.",
    bullets: (
      "Cut average load time from 30 minutes to 30 seconds for 100+ ops accounts in an internal operations board by removing N+1 queries, batching and caching at service boundaries, and cursor-based pagination with virtualized rendering.",
      "Audited platform security: closed a critical account takeover vulnerability, eliminated impersonation and unauthorized-deletion vectors for ~470 conversations/week by moving all chat-provider interaction server-side across four apps.",
      "RFC-designed and shipped a messaging engine powering all staff-authored lifecycle sequences, with 59 business event triggers, dynamic placeholder resolution, and goal-based unenrollment.",
      "Created the company's standard way to run dev services locally: ~20 Dockerized services in a shared repo, a side initiative during onboarding, adopted by all 20+ engineers, replacing shared cloud environments.",
      "Stood up company wide access to databases and internal services, using a WireGuard VPN managed declaratively with Nix and peered across VPCs.",
      "Redesigned the PostgreSQL-backed scheduled job system: cleared the backlog, added retries and monitoring, enabling transactional side effects across services. Now processing ~7,500 jobs/day across 29 job types.",
      "Built component test infrastructure for the core API against real PostgreSQL and MongoDB, isolated per test with templates, hundreds of tests PR-gated on CI under 4 min.",
      "Drove incremental TypeScript migration and modernized tooling: structured logging with context propagation, a type-safe query builder, feature flags, path aliases, and JSDoc coverage.",
      "Shipped AI chatbots on the internal LLM platform: a shared chat library consumed by four frontends and a Slack relay to monitor and take over chats.",
    ),
    stack: "TypeScript, Node.js, GraphQL, PostgreSQL, MongoDB, React, Nix flakes, AWS, Docker, CircleCI, PostHog, GitHub Actions",
  ),
  (
    org: "DexCare",
    role: "Software Engineer",
    dates: "Sep 2024 - Aug 2025",
    location: "Seattle, United States (remote)",
    intro: "Digital health platform, routing patients to care. Contributed to the search engine, release management, testing, platform engineering, ingestion pipelines and maintenance across engine versions.",
    bullets: (
      "Cut CI/CD from 40 to 15 minutes, including index rebuilds, through caching, parallelized stages, and replacing fixed sleeps with health checks.",
      "Designed a test framework for a codebase that had none, building example and property based component suites. Creating confidence for releasing every two weeks.",
      "Built autocorrect and autocomplete on dedicated indexes. Misspelled and partial queries started resolving to the intended care providers without measurable added latency.",
      "Replaced git-submodules and manual setup steps with standardized tooling and automation, making builds reproducible and on boarding not reliant on tribal knowledge.",
      "Wrote and reviewed dozens of design docs, catching incidental complexity and chances to share code before implementation.",
    ),
    stack: "TypeScript, Redis, Azure, SQLite, Microsoft SQL Server, GitHub Actions, Nix",
  ),
  (
    org: "Nano Capital",
    role: "Senior Software Engineer",
    dates: "Jun 2022 - Sep 2024",
    location: "São Paulo, Brazil (remote)",
    intro: "First engineer on a crowd investing platform. Folded a SaaS based solution fully in house, cutting operational costs and reliability issues while taking control of the user experience.",
    bullets: (
      "Architected and implemented a full stack solution for our web based platform, including authentication, public APIs, investment simulations, crowdfunding progress tracking, payment tracking, client and offer back-office, push notifications and email marketing.",
      "Served investment simulations directly from the finance team's spreadsheet models, delivering real time updates through a headless LibreOffice instance with cached computations.",
      "Optimized the web client for slow connections, minimizing waterfalls, network round trips, and bundle size, holding a 90+ lighthouse score on every page.",
      "Designed and implemented our cloud infrastructure as code, reducing documentation drift and eliminating most manual setup steps.",
      "Created aggressively cached CI/CD pipelines, taking builds from 1 hour to under 5 minutes by leveraging nix.",
      "Established monitoring and load testing, catching several bugs and scaling issues before they reached users.",
    ),
    stack: "TypeScript, Relay, React Native, Rust, PostgreSQL, Pulumi, AWS, Cloudflare, Nix flakes, Grafana, Traefik, Supabase, GitHub Actions",
  ),
  (
    org: "Genezys Global Tech",
    role: "Software Engineer",
    dates: "Feb 2022 - Jun 2022",
    location: "São Paulo, Brazil (remote)",
    intro: none,
    bullets: (
      "Engineered high-performance Solana smart contracts in Rust for blockchain infrastructure.",
      "Developed robust testing frameworks in TypeScript and Rust to ensure contract reliability.",
      "Designed and implemented an off-chain ledger system to reduce transaction costs.",
      "Designed and implemented a price monitoring backend for multiple currencies.",
    ),
    stack: "Rust, Typescript, Solana, PostgreSQL, DeployHQ",
  ),
  (
    org: "Club do Balanço",
    role: "Software Engineer",
    dates: "Sep 2019 - Nov 2021",
    location: "Morro de São Paulo, Brazil",
    intro: none,
    bullets: (
      "Developed a software suite for hotel guests to handle check-in, accounts, and facility access using Scala.",
      "Created a POS extension for automated tax reporting using Rust/TypeScript.",
      "Implemented other solutions to enhance guest experience and streamline operations.",
    ),
    stack: "Scala, Rust, Typescript, PostgreSQL, GCP, Linux, Docker, GitLab CI/CD",
  ),
  (
    org: "Club do Balanço",
    role: "Junior Software Engineer",
    dates: "Oct 2018 - Sep 2019",
    location: "Morro de São Paulo, Brazil",
    intro: none,
    bullets: (
      "Developed internal websites and public landing pages.",
      "General sysadmin tasks, like managing linux and windows machines, GSuite and configuring all kinds of software.",
      "Digitized paper-based processes by creating small tools in TypeScript and Scala, enhancing office efficiency.",
      "Enhanced office infrastructure by managing MikroTik (low level routing OS) and UniFi devices, ensuring seamless operations.",
    ),
    stack: "Mikrotik, Linux, Scala, Typescript, PostgreSQL, GCP, Docker",
  ),
)

#let education = (
  (
    school: "Universidade Salvador",
    degree: "Engenharia de Computação (Computer Engineering)",
    dates: "2017 - 2018",
  ),
)
