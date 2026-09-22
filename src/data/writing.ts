// Articles published on Medium, newest first. /writing lists them in this
// order, so add new ones at the top.

export interface Article {
  title: string;
  url: string;
  /** Publication date, YYYY-MM-DD. */
  date: string;
  summary: string;
}

export const ARTICLES: Article[] = [
  {
    title: 'Why Great Cloud Architects Embrace Legacy Systems',
    url: 'https://medium.com/@brianmulimuteti/why-great-cloud-architects-embrace-legacy-systems-3328d721daf4',
    date: '2026-03-11',
    summary:
      'Why the systems that move money still run decades-old code, and three patterns for modernising them safely: guarded lift-and-shift, adapters and sidecars, and the strangler fig.',
  },
  {
    title:
      'If AWS, Azure & GCP Treat Alerting Like Royalty… Why Are You Still Treating It Like an Afterthought?',
    url: 'https://medium.com/@brianmulimuteti/if-aws-azure-gcp-treat-alerting-like-royalty-why-are-you-still-treating-it-like-an-afterthought-d8d51f393066',
    date: '2026-02-09',
    summary:
      'What the hyperscalers get right about alerting, with a hands-on AWS example that flags sensitive reads from DynamoDB, wired together in CloudFormation.',
  },
  {
    title:
      'Unlock the Future of Customer Service: Supercharge Your Contact Center with Amazon Connect and Salesforce Integration',
    url: 'https://medium.com/@brianmulimuteti/unlock-the-future-of-customer-service-supercharge-your-contact-center-with-amazon-connect-and-a0ac92f58939',
    date: '2026-01-21',
    summary:
      'How Amazon Connect and Salesforce fit together through the CTI Adapter, so an agent sees the caller’s history before the first sentence ends.',
  },
  {
    title: 'Amazon Connect for Developers: Architecture, Core Concepts, and First Setup',
    url: 'https://medium.com/@brianmulimuteti/amazon-connect-for-developers-architecture-core-concepts-and-first-setup-9a61b2f1944a',
    date: '2025-12-22',
    summary:
      'A developer’s introduction to Amazon Connect: the architecture, the core concepts, and a first setup with static and Lambda-driven call routing.',
  },
];
