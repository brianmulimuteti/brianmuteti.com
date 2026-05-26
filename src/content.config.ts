import { glob } from 'astro/loaders';
import { defineCollection, z } from 'astro:content';

const work = defineCollection({
  loader: glob({ base: './src/content/work', pattern: '**/*.{md,mdx}' }),
  schema: z.object({
    title: z.string(),
    subtitle: z.string(),
    summary: z.string(),
    role: z.string(),
    context: z.string(),
    stack: z.array(z.string()),
    order: z.number(),
    published: z.boolean().default(true),
    publishDate: z.coerce.date(),
  }),
});

export const collections = { work };