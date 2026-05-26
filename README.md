# brianmuteti.com

Source code for my personal website — [brianmuteti.com](https://brianmuteti.com).

A type-led, low-decoration site built around four engineering case studies. No tracking, no analytics, no JavaScript runtime beyond what Astro ships.

## Stack

- **[Astro](https://astro.build)** — static site framework
- **Content collections** — case studies as Markdown
- **Fraunces + Inter + JetBrains Mono** — typography via Google Fonts
- **AWS** — S3 (origin) + CloudFront (CDN) + ACM (TLS) + Route 53 (DNS)
- **Terraform** — all infrastructure as code, see [`infra/`](./infra) *(coming soon)*
- **GitHub Actions** — CI/CD deploy on push to `main` *(coming soon)*

## Local development

```bash
npm install
npm run dev
```

The dev server runs at `http://localhost:4321`.

## Building

```bash
npm run build       # outputs to ./dist
npm run preview     # serve the build locally
```

## Structure
src/
├── assets/images/       photos used in pages
├── components/          BaseHead, Header, Footer
├── content/
│   └── work/            case studies (Markdown)
├── layouts/
│   └── BlogPost.astro   case study layout
├── pages/
│   ├── index.astro      homepage
│   ├── about.astro
│   ├── writing.astro
│   └── work/
│       ├── index.astro     /work
│       └── [...slug].astro /work/{slug}
└── styles/
└── global.css

## Deployment

The site is deployed automatically to S3 + CloudFront on push to `main`, via GitHub Actions and an OIDC-assumed IAM role (no long-lived AWS keys in CI). CloudFront cache is invalidated on each deploy.

The full infrastructure is in Terraform under [`infra/`](./infra).

## License

Code: MIT. Content (text, case studies, photos): all rights reserved.

---

Built and maintained by [Brian Muli Muteti](https://brianmuteti.com).
