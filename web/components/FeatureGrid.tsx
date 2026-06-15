import { features } from '@/lib/site';
import { SectionHeading } from './SectionHeading';

export function FeatureGrid() {
  return (
    <section id="privacy" className="px-4 py-20 md:px-8 md:py-28">
      <div className="mx-auto max-w-7xl">
        <SectionHeading eyebrow="Why it matters" title="Built for Christians trying to guard attention in real life." body="The goal is not shame. The goal is interruption, remembrance, and intentional access." />
        <div className="grid gap-5 md:grid-cols-2">
          {features.map((feature) => (
            <article key={feature.title} className="glass rounded-[2rem] p-7">
              <h3 className="text-2xl font-black tracking-[-0.03em] text-cream">{feature.title}</h3>
              <p className="mt-4 text-base font-bold leading-7 text-cream/58">{feature.body}</p>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
